import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { BatchSyncPushDto, LedgerEventDto } from './sync.dto';

export interface ProcessedSyncResult {
  accepted_count: number;
  duplicate_count: number;
  processed_event_ids: string[];
  server_timestamp: string;
}

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(private readonly db: DatabaseService) {}

  /**
   * Process a batch of offline ledger events inside an atomic transaction.
   * Uses ON CONFLICT DO NOTHING for idempotent event writes.
   * Atomically updates inventory_balances with UPSERT arithmetic.
   */
  async processBatchEvents(dto: BatchSyncPushDto): Promise<ProcessedSyncResult> {
    const { branch_id, events } = dto;

    if (!events || events.length === 0) {
      return {
        accepted_count: 0,
        duplicate_count: 0,
        processed_event_ids: [],
        server_timestamp: new Date().toISOString(),
      };
    }

    return await this.db.transaction(async (client) => {
      let acceptedCount = 0;
      let duplicateCount = 0;
      const processedEventIds: string[] = [];

      for (const event of events) {
        // 1. Try to insert event into inventory_ledger with ON CONFLICT DO NOTHING
        const insertQuery = `
          INSERT INTO inventory_ledger (
            client_event_id,
            branch_id,
            terminal_id,
            event_type,
            user_id,
            product_id,
            quantity_change,
            batch_number,
            reference_id,
            metadata,
            client_timestamp
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
          ON CONFLICT (branch_id, client_event_id) DO NOTHING
          RETURNING id;
        `;

        const metaJson = event.metadata ? JSON.stringify(event.metadata) : '{}';
        const clientTimestamp = new Date(event.client_timestamp);

        const insertRes = await client.query(insertQuery, [
          event.client_event_id,
          branch_id,
          event.terminal_id,
          event.event_type,
          event.user_id,
          event.product_id,
          event.quantity_change,
          event.batch_number || null,
          event.reference_id || null,
          metaJson,
          clientTimestamp,
        ]);

        if (insertRes.rowCount > 0) {
          // Event was fresh! Apply to inventory_balances atomically
          const eventDbId = insertRes.rows[0].id;

          const upsertBalanceQuery = `
            INSERT INTO inventory_balances (
              branch_id,
              product_id,
              current_stock,
              last_event_id,
              last_updated_at
            ) VALUES ($1, $2, $3, $4, NOW())
            ON CONFLICT (branch_id, product_id) DO UPDATE SET
              current_stock = inventory_balances.current_stock + EXCLUDED.current_stock,
              last_event_id = EXCLUDED.last_event_id,
              last_updated_at = NOW();
          `;

          await client.query(upsertBalanceQuery, [
            branch_id,
            event.product_id,
            event.quantity_change,
            eventDbId,
          ]);

          acceptedCount++;
          processedEventIds.push(event.client_event_id);
        } else {
          // Idempotent duplicate event from earlier sync attempt
          duplicateCount++;
          processedEventIds.push(event.client_event_id);
        }
      }

      this.logger.log(
        `Batch sync completed for branch ${branch_id}: ${acceptedCount} accepted, ${duplicateCount} duplicates`,
      );

      return {
        accepted_count: acceptedCount,
        duplicate_count: duplicateCount,
        processed_event_ids: processedEventIds,
        server_timestamp: new Date().toISOString(),
      };
    });
  }

  /**
   * Pull latest catalog, staff, and current branch stock balances for edge terminal initialization/refresh.
   */
  async pullBranchSnapshot(branchId: string) {
    const productsRes = await this.db.query(
      `SELECT id, sku, barcode, name, category, unit, price_cents, is_active FROM products WHERE is_active = true`,
    );

    const balancesRes = await this.db.query(
      `SELECT product_id, current_stock, last_updated_at FROM inventory_balances WHERE branch_id = $1`,
      [branchId],
    );

    const usersRes = await this.db.query(
      `SELECT id, branch_id, username, pin_hash, full_name, role, is_active FROM users WHERE (branch_id = $1 OR role = 'GLOBAL_ADMIN') AND is_active = true`,
      [branchId],
    );

    return {
      branch_id: branchId,
      server_timestamp: new Date().toISOString(),
      products: productsRes.rows,
      balances: balancesRes.rows,
      users: usersRes.rows,
    };
  }
}
