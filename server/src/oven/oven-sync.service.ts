import { Injectable } from '@nestjs/common';
import { Device, OvenStatus, Prisma } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../common/clock.service';
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
} from '../sync/sync-plan';
import {
  OvenPickedUpPayloadDto,
  OvenReceivedPayloadDto,
  OvenStatusPayloadDto,
} from './dto/oven.dto';
import { ovenFee } from './fee';

type Tx = Prisma.TransactionClient;
const DAY_MS = 86_400_000;

/** The order a dish moves through; a record never moves it back. */
const STEP: Record<OvenStatus, number> = {
  RECEIVED: 0,
  IN_OVEN: 1,
  READY: 2,
  PICKED_UP: 3,
};

/**
 * Oven records from tills and the oven board (M8). They work offline, so
 * each is checked again here, and a late record never undoes a newer one.
 */
@Injectable()
export class OvenSyncService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: ClockService,
  ) {}

  private async staff(
    device: Device,
    record: SyncRecordDto,
    staffId: string,
    key: 'oven.intake_pickup' | 'oven.board',
  ): Promise<Rejection | null> {
    const at = new Date(record.occurredAt);
    if (at.getTime() > this.clock.now().getTime() + DAY_MS) {
      return rejected('occurredAt is more than a day in the future');
    }
    const s = await findStaff(this.prisma, staffId);
    if (!s) return rejected('Unknown staffId');
    if (!inBranch(s, device.branchId)) {
      return rejected('Staff member is not assigned to this branch');
    }
    if (!(await holds(this.prisma, s, key))) {
      return rejected(`Staff member lacks ${key}`);
    }
    return null;
  }

  /** The fee sale: this branch's, for this dish type, for the whole fee. */
  private async checkFeeSale(
    tx: Tx,
    device: Device,
    saleId: string,
    variantId: string,
    feeCents: number,
  ): Promise<Rejection | null> {
    const sale = await tx.sale.findUnique({
      where: { id: saleId },
      include: { lines: true, ovenTicket: true },
    });
    if (!sale || sale.branchId !== device.branchId) {
      return rejected('Fee sale not found in this branch');
    }
    if (sale.ovenTicket) return rejected('Fee sale already pays a dish');
    const line = sale.lines.find((l) => l.variantId === variantId);
    if (!line || line.netCents !== feeCents) {
      return rejected('Fee sale does not charge this dish');
    }
    return null;
  }

  async planReceived(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(OvenReceivedPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const denied = await this.staff(
      device,
      record,
      p.staffId,
      'oven.intake_pickup',
    );
    if (denied) return denied;
    const branch = await this.prisma.branch.findUniqueOrThrow({
      where: { id: device.branchId },
    });
    if (!branch.ovenEnabled) {
      return rejected('Oven service is off in this branch');
    }
    const rule = await this.prisma.ovenFeeRule.findUnique({
      where: { id: p.ruleId },
    });
    if (!rule) return rejected('Unknown ruleId');
    const fee = ovenFee(rule.baseCents, rule.perKgCents, p.weightGrams);
    if (fee !== p.feeCents) {
      return rejected(`feeCents is ${p.feeCents}, expected ${fee}`);
    }
    const occurredAt = new Date(record.occurredAt);

    return {
      ok: true,
      apply: async (tx) => {
        if (p.feeSaleId) {
          const bad = await this.checkFeeSale(
            tx,
            device,
            p.feeSaleId,
            rule.variantId,
            fee,
          );
          if (bad) return bad;
        }
        await tx.ovenTicket.create({
          data: {
            id: record.id,
            branchId: device.branchId,
            deviceId: device.id,
            tag: p.tag.trim(),
            customerName: p.customerName.trim(),
            phone: p.phone?.replace(/\s/g, '') ?? null,
            description: p.description.trim(),
            ruleId: rule.id,
            weightGrams: p.weightGrams,
            feeCents: fee,
            requestedAt: new Date(p.requestedAt),
            receivedAt: occurredAt,
            receivedByStaffId: p.staffId,
            feeSaleId: p.feeSaleId ?? null,
          },
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt,
            action: 'oven.received',
            branchId: device.branchId,
            deviceId: device.id,
            actorStaffId: p.staffId,
            entityType: 'oven_ticket',
            entityId: record.id,
            data: { tag: p.tag, feeCents: fee, paid: p.feeSaleId != null },
          },
        });
      },
    };
  }

  private async lockTicket(tx: Tx, device: Device, id: string) {
    await tx.$queryRaw`SELECT 1 FROM "oven_ticket" WHERE "id" = ${id}::uuid FOR UPDATE`;
    const t = await tx.ovenTicket.findUnique({
      where: { id },
      include: { rule: true },
    });
    return t && t.branchId === device.branchId ? t : null;
  }

  async planStatus(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(OvenStatusPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const denied = await this.staff(device, record, p.staffId, 'oven.board');
    if (denied) return denied;
    const at = new Date(record.occurredAt);

    return {
      ok: true,
      apply: async (tx) => {
        const t = await this.lockTicket(tx, device, p.ticketId);
        if (!t) return rejected('Oven ticket not found in this branch');
        // Two devices may mark the same dish; the furthest step stands.
        if (STEP[p.status] <= STEP[t.status]) return;
        await tx.ovenTicket.update({
          where: { id: t.id },
          data:
            p.status === OvenStatus.IN_OVEN
              ? { status: OvenStatus.IN_OVEN, inOvenAt: at }
              : {
                  status: OvenStatus.READY,
                  readyAt: at,
                  inOvenAt: t.inOvenAt ?? at,
                },
        });
      },
    };
  }

  async planPickedUp(device: Device, record: SyncRecordDto): Promise<Plan> {
    const parsed = parsePayload(OvenPickedUpPayloadDto, record.payload);
    if (isRejection(parsed)) return parsed;
    const p = parsed.value;
    const denied = await this.staff(
      device,
      record,
      p.staffId,
      'oven.intake_pickup',
    );
    if (denied) return denied;
    const at = new Date(record.occurredAt);

    return {
      ok: true,
      apply: async (tx) => {
        const t = await this.lockTicket(tx, device, p.ticketId);
        if (!t) return rejected('Oven ticket not found in this branch');
        if (t.status === OvenStatus.PICKED_UP) {
          return rejected('This dish was already picked up');
        }
        if (t.feeSaleId && p.feeSaleId) {
          return rejected('This dish was paid at drop-off');
        }
        if (!t.feeSaleId && !p.feeSaleId) {
          return rejected('The fee was not paid');
        }
        if (p.feeSaleId) {
          const bad = await this.checkFeeSale(
            tx,
            device,
            p.feeSaleId,
            t.rule.variantId,
            t.feeCents,
          );
          if (bad) return bad;
        }
        await tx.ovenTicket.update({
          where: { id: t.id },
          data: {
            status: OvenStatus.PICKED_UP,
            pickedUpAt: at,
            readyAt: t.readyAt ?? at,
            inOvenAt: t.inOvenAt ?? at,
            feeSaleId: t.feeSaleId ?? p.feeSaleId,
          },
        });
        await tx.auditLog.create({
          data: {
            id: uuidv7(),
            occurredAt: at,
            action: 'oven.picked_up',
            branchId: device.branchId,
            deviceId: device.id,
            actorStaffId: p.staffId,
            entityType: 'oven_ticket',
            entityId: t.id,
            data: { tag: t.tag, feeCents: t.feeCents },
          },
        });
      },
    };
  }
}
