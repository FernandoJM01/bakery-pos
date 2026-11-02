import { Injectable } from '@nestjs/common';
import { Device, Prisma, StockEventKind } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
import { localDay } from '../common/local-day';
import { PermissionKey } from '../common/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { SyncRecordDto } from '../sync/dto/sync.dto';
import {
  findStaff,
  holds,
  inBranch,
  isRejection,
  parsePayload,
  Plan,
  rejected,
  Rejection,
  StaffWithBranches,
} from '../sync/sync-plan';
import {
  StockCountedPayloadDto,
  StockProducedPayloadDto,
  StockWastedPayloadDto,
} from './dto/stock-sync.dto';
import { StockLedgerService } from './stock-ledger.service';

const DAY_MS = 86_400_000;

/**
 * Sync handlers for what bakers and managers record on a device (M5 brief
 * 4). They work offline, so they arrive late and are checked again here.
 */
@Injectable()
export class StockSyncService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
    private readonly ledger: StockLedgerService,
  ) {}

  /** The record's staff member, if they may do this in this branch. */
  private async staffFor(
    device: Device,
    record: SyncRecordDto,
    staffId: string,
    key: PermissionKey,
  ): Promise<StaffWithBranches | Rejection> {
    const occurredAt = new Date(record.occurredAt);
    if (occurredAt.getTime() > this.clock.now().getTime() + DAY_MS) {
      return rejected('occurredAt is more than a day in the future');
    }
    const staff = await findStaff(this.prisma, staffId);
    if (!staff) return rejected('Unknown staffId');
    if (!inBranch(staff, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (!(await holds(this.prisma, staff, key))) {
      return rejected(`Staff member lacks ${key}`);
    }
    return staff;
  }

  private audit(
    device: Device,
    record: SyncRecordDto,
    staffId: string,
    action: string,
    data: Prisma.InputJsonValue,
  ) {
    return {
      id: uuidv7(),
      occurredAt: new Date(record.occurredAt),
      action,
      branchId: device.branchId,
      deviceId: device.id,
      actorStaffId: staffId,
      entityType: 'stock',
      entityId: record.id,
      data,
    };
  }

  async planProduced(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(StockProducedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const staff = await this.staffFor(
      device,
      record,
      p.staffId,
      'stock.production_entry',
    );
    if (isRejection(staff)) return staff;
    const variant = await this.prisma.productVariant.findUnique({
      where: { id: p.variantId },
    });
    if (!variant) return rejected('Unknown variantId');

    return {
      ok: true,
      apply: async (tx) => {
        await this.ledger.lock(tx, device.branchId, p.variantId);
        await this.ledger.addLot(
          tx,
          {
            branchId: device.branchId,
            variantId: p.variantId,
            quantity: p.quantity,
            kind: StockEventKind.PRODUCTION,
            referenceType: 'lot',
            referenceId: record.id,
            staffId: p.staffId,
            occurredAt: new Date(record.occurredAt),
          },
          p.producedOn,
          record.id,
        );
        await tx.auditLog.create({
          data: this.audit(
            device,
            record,
            p.staffId,
            'stock.production_entered',
            {
              variantId: p.variantId,
              quantity: p.quantity,
              producedOn: p.producedOn,
            },
          ),
        });
      },
    };
  }

  async planWasted(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(StockWastedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const staff = await this.staffFor(device, record, p.staffId, 'stock.waste');
    if (isRejection(staff)) return staff;
    const variant = await this.prisma.productVariant.findUnique({
      where: { id: p.variantId },
    });
    if (!variant) return rejected('Unknown variantId');
    const occurredAt = new Date(record.occurredAt);

    return {
      ok: true,
      apply: async (tx) => {
        await this.ledger.lock(tx, device.branchId, p.variantId);
        await tx.stockWaste.create({
          data: {
            id: record.id,
            branchId: device.branchId,
            variantId: p.variantId,
            quantity: p.quantity,
            reason: p.reason,
            staffId: p.staffId,
            occurredAt,
            costCents: variant.costCents,
          },
        });
        await this.ledger.take(
          tx,
          {
            branchId: device.branchId,
            variantId: p.variantId,
            quantity: p.quantity,
            kind: StockEventKind.WASTE,
            referenceType: 'waste',
            referenceId: record.id,
            staffId: p.staffId,
            occurredAt,
          },
          { lotId: p.lotId },
        );
        await tx.auditLog.create({
          data: this.audit(device, record, p.staffId, 'stock.waste_recorded', {
            variantId: p.variantId,
            quantity: p.quantity,
            reason: p.reason,
          }),
        });
      },
    };
  }

  async planCounted(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(StockCountedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const staff = await this.staffFor(
      device,
      record,
      p.staffId,
      'stock.count_adjust',
    );
    if (isRejection(staff)) return staff;
    const ids = p.lines.map((l) => l.variantId);
    if (new Set(ids).size !== ids.length) {
      return rejected('A variant repeats');
    }
    const known = await this.prisma.productVariant.count({
      where: { id: { in: ids } },
    });
    if (known !== ids.length) return rejected('Unknown variantId');
    const branch = await this.prisma.branch.findUniqueOrThrow({
      where: { id: device.branchId },
    });
    const occurredAt = new Date(record.occurredAt);
    const today = localDay(occurredAt, branch.timezone);

    return {
      ok: true,
      apply: async (tx) => {
        await tx.stockCount.create({
          data: {
            id: record.id,
            branchId: device.branchId,
            staffId: p.staffId,
            occurredAt,
          },
        });
        for (const l of [...p.lines].sort((a, b) =>
          a.variantId.localeCompare(b.variantId),
        )) {
          await this.ledger.lock(tx, device.branchId, l.variantId);
          const expected = await this.ledger.onHand(
            tx,
            device.branchId,
            l.variantId,
          );
          await tx.stockCountLine.create({
            data: {
              countId: record.id,
              variantId: l.variantId,
              expected,
              counted: l.counted,
            },
          });
          const difference = l.counted - expected;
          if (difference === 0) continue;
          const move = {
            branchId: device.branchId,
            variantId: l.variantId,
            quantity: Math.abs(difference),
            kind: StockEventKind.COUNT_ADJUST,
            referenceType: 'count',
            referenceId: record.id,
            staffId: p.staffId,
            occurredAt,
          };
          if (difference < 0) await this.ledger.take(tx, move);
          else await this.ledger.raise(tx, move, today);
          await tx.auditLog.create({
            data: this.audit(
              device,
              record,
              p.staffId,
              'stock.count_adjusted',
              {
                variantId: l.variantId,
                expected,
                counted: l.counted,
                difference,
              },
            ),
          });
        }
      },
    };
  }
}
