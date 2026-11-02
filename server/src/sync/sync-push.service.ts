import { Injectable } from '@nestjs/common';
import { Device, Prisma, SyncInboxStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { SaleSyncService } from '../sales/sale-sync.service';
import { ShiftSyncService } from '../shifts/shift-sync.service';
import { OfflineAuditPayloadDto, SyncRecordDto } from './dto/sync.dto';
import {
  checkApprover,
  findStaff,
  inBranch,
  isRejection,
  parsePayload,
  Plan,
  rejected,
  Rejection,
  SyncErrorCode,
} from './sync-plan';

export type { SyncErrorCode } from './sync-plan';

export interface SyncPushResult {
  id: string;
  status: 'APPLIED' | 'DUPLICATE' | 'QUARANTINED';
  errorCode: SyncErrorCode | null;
  message: string | null;
}

/** Payload keys never kept in quarantine, whatever a till sends. */
const SECRET_KEY = /pin|password|token|verifier|secret/i;

/**
 * Applies records from a till's outbox (M2 brief 4.3). Each record runs in
 * its own transaction and is keyed by its id in `sync_inbox`, so sending a
 * record twice (a retry, two workers, a lost response) applies it once.
 */
@Injectable()
export class SyncPushService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly sales: SaleSyncService,
    private readonly shifts: ShiftSyncService,
  ) {}

  async push(device: Device, records: SyncRecordDto[]) {
    const results: SyncPushResult[] = [];
    for (const record of records) {
      results.push(await this.pushOne(device, record));
    }
    return { results, serverTime: this.clock.now().toISOString() };
  }

  private async pushOne(
    device: Device,
    record: SyncRecordDto,
  ): Promise<SyncPushResult> {
    // A record already received needs no checks, so look before planning.
    const seen = await this.prisma.syncInbox.findUnique({
      where: { recordId: record.id },
      include: { quarantine: true },
    });
    if (seen) return repeat(seen, device, record);

    const plan = await this.plan(device, record);
    const receivedAt = this.clock.now();
    const occurredAt = new Date(record.occurredAt);

    return this.prisma.$transaction(async (tx) => {
      // ON CONFLICT DO NOTHING waits for a parallel insert of the same id to
      // commit, so exactly one of two simultaneous pushes gets count 1.
      const { count } = await tx.syncInbox.createMany({
        data: [
          {
            recordId: record.id,
            deviceId: device.id,
            type: record.type,
            occurredAt,
            receivedAt,
            status: plan.ok
              ? SyncInboxStatus.APPLIED
              : SyncInboxStatus.QUARANTINED,
          },
        ],
        skipDuplicates: true,
      });
      if (count === 0) {
        const other = await tx.syncInbox.findUniqueOrThrow({
          where: { recordId: record.id },
          include: { quarantine: true },
        });
        return repeat(other, device, record);
      }

      let failure: Rejection | null = plan.ok ? null : plan;
      if (plan.ok) {
        const late = await plan.apply(tx);
        if (!late) {
          return {
            id: record.id,
            status: 'APPLIED',
            errorCode: null,
            message: null,
          };
        }
        failure = late;
        await tx.syncInbox.update({
          where: { recordId: record.id },
          data: { status: SyncInboxStatus.QUARANTINED },
        });
      }
      const { code, message } = failure!;

      await tx.syncQuarantine.create({
        data: {
          recordId: record.id,
          deviceId: device.id,
          branchId: device.branchId,
          type: record.type,
          payload: scrub(record.payload) as Prisma.InputJsonValue,
          errorCode: code,
          errorMessage: message.slice(0, 500),
          occurredAt,
          receivedAt,
        },
      });
      return {
        id: record.id,
        status: 'QUARANTINED',
        errorCode: code,
        message,
      };
    });
  }

  private async plan(device: Device, record: SyncRecordDto): Promise<Plan> {
    switch (record.type) {
      case 'audit.offline_event':
        return this.planOfflineAudit(device, record);
      case 'sale.completed':
        return this.sales.planCompleted(device, record);
      case 'sale.refunded':
        return this.sales.planRefunded(device, record);
      case 'shift.opened':
        return this.shifts.planOpened(device, record);
      case 'cash.movement':
        return this.shifts.planMovement(device, record);
      case 'shift.closed':
        return this.shifts.planClosed(device, record);
      default:
        return {
          ok: false,
          code: 'SYNC_UNKNOWN_TYPE',
          message: `Unknown record type ${record.type}`,
        };
    }
  }

  private async planOfflineAudit(
    device: Device,
    record: SyncRecordDto,
  ): Promise<Plan> {
    const parsed = parsePayload(OfflineAuditPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const payload = parsed.value;

    const occurredAt = new Date(record.occurredAt);
    // A till clock a little ahead is normal; a day ahead is not.
    if (occurredAt.getTime() > this.clock.now().getTime() + 86_400_000) {
      return rejected('occurredAt is more than a day in the future');
    }

    const staff = await findStaff(this.prisma, payload.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }

    let approverStaffId: string | null = null;
    if (payload.action === 'auth.approval_granted') {
      const approver = await checkApprover(
        this.prisma,
        payload.approverStaffId!,
        payload.staffId,
        device.branchId,
        payload.approvalAction!,
      );
      if (isRejection(approver)) return approver;
      approverStaffId = approver.id;
    }

    const audit: Prisma.AuditLogUncheckedCreateInput = {
      id: uuidv7(),
      occurredAt,
      action: payload.action,
      branchId: device.branchId,
      deviceId: device.id,
      actorStaffId: staff.id,
      approverStaffId,
      entityType: 'sync_record',
      entityId: record.id,
      data: {
        offline: true,
        reference: payload.reference ?? null,
        ...(payload.approvalAction ? { action: payload.approvalAction } : {}),
        ...(payload.ticket
          ? {
              ticket: {
                lineCount: payload.ticket.lineCount,
                amountCents: payload.ticket.amountCents,
              },
            }
          : {}),
      },
    };
    return {
      ok: true,
      apply: async (tx) => {
        await tx.auditLog.create({ data: audit });
      },
    };
  }
}

/** A record id the server has seen before. */
function repeat(
  seen: {
    deviceId: string;
    status: SyncInboxStatus;
    quarantine: { errorCode: string } | null;
  },
  device: Device,
  record: SyncRecordDto,
): SyncPushResult {
  if (seen.deviceId !== device.id) {
    // UUID v7 ids do not collide by accident; another till reusing one is
    // refused without touching the stored record.
    return {
      id: record.id,
      status: 'QUARANTINED',
      errorCode: 'SYNC_REJECTED',
      message: 'Record id belongs to another device',
    };
  }
  if (seen.status === SyncInboxStatus.APPLIED) {
    return {
      id: record.id,
      status: 'DUPLICATE',
      errorCode: null,
      message: null,
    };
  }
  return {
    id: record.id,
    status: 'QUARANTINED',
    errorCode: (seen.quarantine?.errorCode ?? 'SYNC_REJECTED') as SyncErrorCode,
    message: 'Already quarantined',
  };
}

/** Copy of a payload without secret-looking keys, at any depth. */
export function scrub(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(scrub);
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .filter(([k]) => !SECRET_KEY.test(k))
        .map(([k, v]) => [k, scrub(v)]),
    );
  }
  return value;
}
