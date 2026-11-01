import { Injectable } from '@nestjs/common';
import { Device, Prisma, Role, SyncInboxStatus } from '@prisma/client';
import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PERMISSION_KEYS, PermissionKey } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { OfflineAuditPayloadDto, SyncRecordDto } from './dto/sync.dto';

export type SyncErrorCode =
  'SYNC_UNKNOWN_TYPE' | 'SYNC_INVALID_PAYLOAD' | 'SYNC_REJECTED';

export interface SyncPushResult {
  id: string;
  status: 'APPLIED' | 'DUPLICATE' | 'QUARANTINED';
  errorCode: SyncErrorCode | null;
  message: string | null;
}

type Plan =
  | { ok: true; audit: Prisma.AuditLogUncheckedCreateInput }
  | { ok: false; code: SyncErrorCode; message: string };

/** Only these roles can approve (same rule as online approvals, A12). */
const APPROVER_ROLES: readonly Role[] = [Role.OWNER, Role.BRANCH_MANAGER];

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

      if (plan.ok) {
        await tx.auditLog.create({ data: plan.audit });
        return {
          id: record.id,
          status: 'APPLIED',
          errorCode: null,
          message: null,
        };
      }

      await tx.syncQuarantine.create({
        data: {
          recordId: record.id,
          deviceId: device.id,
          branchId: device.branchId,
          type: record.type,
          payload: scrub(record.payload) as Prisma.InputJsonValue,
          errorCode: plan.code,
          errorMessage: plan.message.slice(0, 500),
          occurredAt,
          receivedAt,
        },
      });
      return {
        id: record.id,
        status: 'QUARANTINED',
        errorCode: plan.code,
        message: plan.message,
      };
    });
  }

  private async plan(device: Device, record: SyncRecordDto): Promise<Plan> {
    switch (record.type) {
      case 'audit.offline_event':
        return this.planOfflineAudit(device, record);
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
    const payload = plainToInstance(OfflineAuditPayloadDto, record.payload);
    const errors = validateSync(payload, {
      whitelist: true,
      forbidNonWhitelisted: true,
    });
    if (errors.length > 0) {
      return {
        ok: false,
        code: 'SYNC_INVALID_PAYLOAD',
        message: errors
          .flatMap((e) => Object.values(e.constraints ?? {}))
          .join('; '),
      };
    }
    const rejected = (message: string): Plan => ({
      ok: false,
      code: 'SYNC_REJECTED',
      message,
    });

    const occurredAt = new Date(record.occurredAt);
    // A till clock a little ahead is normal; a day ahead is not.
    if (occurredAt.getTime() > this.clock.now().getTime() + 86_400_000) {
      return rejected('occurredAt is more than a day in the future');
    }

    const staff = await this.prisma.staff.findUnique({
      where: { id: payload.staffId },
      include: { staffBranches: true },
    });
    const inBranch = (s: NonNullable<typeof staff>) =>
      s.role === Role.OWNER ||
      s.staffBranches.some((sb) => sb.branchId === device.branchId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff)) {
      return rejected('Staff member is not assigned to this branch');
    }

    let approverStaffId: string | null = null;
    if (payload.action === 'auth.approval_granted') {
      const action = payload.approvalAction!;
      if (!(PERMISSION_KEYS as readonly string[]).includes(action)) {
        return rejected(`Unknown approvalAction ${action}`);
      }
      if (payload.approverStaffId === payload.staffId) {
        return rejected('Requester cannot self-approve');
      }
      const approver = await this.prisma.staff.findUnique({
        where: { id: payload.approverStaffId! },
        include: { staffBranches: true },
      });
      if (!approver) return rejected('Unknown approverStaffId');
      if (!inBranch(approver)) {
        return rejected('Approver is not assigned to this branch');
      }
      if (!APPROVER_ROLES.includes(approver.role)) {
        return rejected('Only owners and branch managers can approve');
      }
      if (approver.role !== Role.OWNER) {
        const granted = await this.prisma.rolePermission.findUnique({
          where: {
            role_permissionKey: {
              role: approver.role,
              permissionKey: action as PermissionKey,
            },
          },
        });
        if (!granted)
          return rejected('Approver lacks permission for this action');
      }
      approverStaffId = approver.id;
    }

    return {
      ok: true,
      audit: {
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
        },
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
