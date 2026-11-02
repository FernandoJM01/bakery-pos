import { Injectable } from '@nestjs/common';
import {
  CashCountStage,
  CashMovementKind,
  Device,
  DeviceType,
  Prisma,
  ShiftStatus,
} from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { PrismaService } from '../prisma/prisma.service';
import { SALE_SETTINGS } from '../sales/sale-settings';
import { SyncRecordDto } from '../sync/dto/sync.dto';
import {
  checkApprover,
  checkShift,
  findStaff,
  holds,
  inBranch,
  isRejection,
  parsePayload,
  Plan,
  rejected,
  Rejection,
} from '../sync/sync-plan';
import { closeResult, countTotal } from './cash-totals';
import {
  CashCountRowDto,
  CashMovementPayloadDto,
  ShiftClosedPayloadDto,
  ShiftOpenedPayloadDto,
} from './dto/shift-sync.dto';

const DAY_MS = 86_400_000;

function repeatedRow(count: CashCountRowDto[]): boolean {
  return new Set(count.map((r) => r.denominationCents)).size !== count.length;
}

/**
 * Sync handlers for cash shifts made on a till (M4 brief 4.6). The till runs
 * the shift; the server checks every rule again and recomputes the close.
 */
@Injectable()
export class ShiftSyncService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  private future(occurredAt: Date): boolean {
    return occurredAt.getTime() > this.clock.now().getTime() + DAY_MS;
  }

  async planOpened(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(ShiftOpenedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const occurredAt = new Date(record.occurredAt);

    if (this.future(occurredAt)) {
      return rejected('occurredAt is more than a day in the future');
    }
    if (device.type !== DeviceType.TILL) {
      return rejected('Only a sales till can open a shift');
    }
    const staff = await findStaff(this.prisma, p.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (!(await holds(this.prisma, staff, 'cash.open_shift'))) {
      return rejected('Staff member lacks cash.open_shift');
    }
    if (repeatedRow(p.count)) return rejected('A denomination repeats');
    if (countTotal(p.count) !== p.floatCents) {
      return rejected('The count does not add up to floatCents');
    }

    return {
      ok: true,
      apply: async (tx) => {
        // Serialises this till's opens, so the check below is the last word.
        await tx.$queryRaw`SELECT 1 FROM "device" WHERE "id" = ${device.id}::uuid FOR UPDATE`;
        const open = await tx.cashShift.count({
          where: { deviceId: device.id, status: ShiftStatus.OPEN },
        });
        if (open > 0) return rejected('This till already has an open shift');
        await tx.cashShift.create({
          data: {
            id: record.id,
            deviceId: device.id,
            branchId: device.branchId,
            openedAt: occurredAt,
            openedByStaffId: staff.id,
            floatCents: p.floatCents,
          },
        });
        await tx.cashCount.createMany({
          data: p.count.map((r) => ({
            shiftId: record.id,
            stage: CashCountStage.OPEN,
            denominationCents: r.denominationCents,
            quantity: r.quantity,
          })),
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt,
            action: 'cash.shift_opened',
            branchId: device.branchId,
            deviceId: device.id,
            actorStaffId: staff.id,
            entityType: 'cash_shift',
            entityId: record.id,
            data: { floatCents: p.floatCents },
          },
        });
      },
    };
  }

  async planMovement(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(CashMovementPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const occurredAt = new Date(record.occurredAt);

    if (this.future(occurredAt)) {
      return rejected('occurredAt is more than a day in the future');
    }
    if (p.reason === 'OTHER' && !p.note?.trim()) {
      return rejected('A note is required with reason OTHER');
    }
    const shift = await checkShift(
      this.prisma,
      device.id,
      p.shiftId,
      occurredAt,
    );
    if (isRejection(shift)) return shift;

    const staff = await findStaff(this.prisma, p.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (p.approverStaffId) {
      const approver = await checkApprover(
        this.prisma,
        p.approverStaffId,
        staff.id,
        device.branchId,
        'cash.movement',
      );
      if (isRejection(approver)) return approver;
    } else if (!(await holds(this.prisma, staff, 'cash.movement'))) {
      return rejected('Staff member lacks cash.movement and has no approval');
    }

    return {
      ok: true,
      apply: async (tx) => {
        await tx.cashMovement.create({
          data: {
            id: record.id,
            shiftId: p.shiftId,
            kind: p.kind,
            amountCents: p.amountCents,
            reason: p.reason,
            note: p.note ?? null,
            staffId: staff.id,
            approverStaffId: p.approverStaffId ?? null,
            occurredAt,
          },
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt,
            action: 'cash.movement',
            branchId: device.branchId,
            deviceId: device.id,
            actorStaffId: staff.id,
            approverStaffId: p.approverStaffId ?? null,
            entityType: 'cash_shift',
            entityId: p.shiftId,
            data: {
              movementId: record.id,
              kind: p.kind,
              amountCents: p.amountCents,
              reason: p.reason,
            },
          },
        });
      },
    };
  }

  async planClosed(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(ShiftClosedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const occurredAt = new Date(record.occurredAt);

    if (this.future(occurredAt)) {
      return rejected('occurredAt is more than a day in the future');
    }
    const staff = await findStaff(this.prisma, p.staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (!(await holds(this.prisma, staff, 'cash.close_shift'))) {
      return rejected('Staff member lacks cash.close_shift');
    }
    if (repeatedRow(p.count)) return rejected('A denomination repeats');
    if (countTotal(p.count) !== p.countedCents) {
      return rejected('The count does not add up to countedCents');
    }
    return {
      ok: true,
      apply: (tx) => this.applyClose(tx, device, record.id, occurredAt, p),
    };
  }

  /** Recomputes the close under a lock on the shift, then writes it. */
  private async applyClose(
    tx: Prisma.TransactionClient,
    device: Device,
    recordId: string,
    occurredAt: Date,
    p: ShiftClosedPayloadDto,
  ): Promise<Rejection | void> {
    await tx.$queryRaw`SELECT 1 FROM "cash_shift" WHERE "id" = ${p.shiftId}::uuid FOR UPDATE`;
    const shift = await tx.cashShift.findUnique({ where: { id: p.shiftId } });
    if (!shift || shift.deviceId !== device.id) {
      return rejected('Shift not found on this device');
    }
    if (shift.status !== ShiftStatus.OPEN) {
      return rejected('The shift was already closed');
    }
    const usedZ = await tx.cashShift.count({
      where: { deviceId: device.id, zNumber: p.zNumber },
    });
    if (usedZ > 0) return rejected(`Z number ${p.zNumber} was already used`);

    const [payments, refunds, movements] = await Promise.all([
      tx.payment.findMany({
        where: { sale: { shiftId: shift.id } },
        select: { amountCents: true },
      }),
      tx.refund.findMany({
        where: { shiftId: shift.id },
        select: { totalCents: true },
      }),
      tx.cashMovement.findMany({
        where: { shiftId: shift.id },
        select: { kind: true, amountCents: true },
      }),
    ]);
    const amountsOf = (kind: CashMovementKind) =>
      movements.filter((m) => m.kind === kind).map((m) => m.amountCents);
    const result = closeResult(
      {
        floatCents: shift.floatCents,
        saleAmountsCents: payments.map((x) => x.amountCents),
        cashInCents: amountsOf(CashMovementKind.IN),
        cashOutCents: amountsOf(CashMovementKind.OUT),
        refundsCents: refunds.map((r) => r.totalCents),
      },
      p.countedCents,
      SALE_SETTINGS.cashVarianceFlagCents,
    );
    if (
      p.expectedCents !== result.expectedCents ||
      p.varianceCents !== result.varianceCents ||
      p.flagged !== result.flagged
    ) {
      return rejected(
        `Close is expected ${p.expectedCents}, difference ${p.varianceCents}; server has ${result.expectedCents}, ${result.varianceCents}`,
      );
    }
    if (result.flagged && !p.note?.trim()) {
      return rejected('A flagged difference needs a note');
    }

    await tx.cashShift.update({
      where: { id: shift.id },
      data: {
        status: ShiftStatus.CLOSED,
        zNumber: p.zNumber,
        closedAt: occurredAt,
        closedByStaffId: p.staffId,
        expectedCents: result.expectedCents,
        countedCents: p.countedCents,
        varianceCents: result.varianceCents,
        flagged: result.flagged,
        note: p.note ?? null,
      },
    });
    await tx.cashCount.createMany({
      data: p.count.map((r) => ({
        shiftId: shift.id,
        stage: CashCountStage.CLOSE,
        denominationCents: r.denominationCents,
        quantity: r.quantity,
      })),
    });
    const audit = {
      occurredAt,
      branchId: device.branchId,
      deviceId: device.id,
      actorStaffId: p.staffId,
      entityType: 'cash_shift',
      entityId: shift.id,
      data: {
        recordId,
        zNumber: p.zNumber,
        expectedCents: result.expectedCents,
        countedCents: p.countedCents,
        varianceCents: result.varianceCents,
      },
    };
    await tx.auditLog.create({
      data: { ...audit, id: uuidv7(), action: 'cash.shift_closed' },
    });
    if (result.flagged) {
      await tx.auditLog.create({
        data: { ...audit, id: uuidv7(), action: 'cash.variance_flagged' },
      });
    }
  }
}
