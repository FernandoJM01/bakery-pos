import { Test, TestingModule } from '@nestjs/testing';
import { SyncService } from './sync.service';
import { DatabaseService } from '../../database/database.service';
import { LedgerEventType } from '../../common/types';

describe('SyncService Atomic Transaction & Idempotency', () => {
  let syncService: SyncService;
  let mockDbService: any;
  let mockClient: any;

  beforeEach(async () => {
    mockClient = {
      query: jest.fn(),
    };

    mockDbService = {
      query: jest.fn(),
      transaction: jest.fn(async (cb) => cb(mockClient)),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SyncService,
        { provide: DatabaseService, useValue: mockDbService },
      ],
    }).compile();

    syncService = module.get<SyncService>(SyncService);
  });

  it('should be defined', () => {
    expect(syncService).toBeDefined();
  });

  it('should process fresh offline events and update balances atomically', async () => {
    // Mock insert returning an ID (fresh event)
    mockClient.query
      .mockResolvedValueOnce({ rowCount: 1, rows: [{ id: 'cloud-evt-1' }] }) // insert ledger
      .mockResolvedValueOnce({ rowCount: 1, rows: [] }); // upsert balance

    const result = await syncService.processBatchEvents({
      branch_id: 'a0000000-0000-0000-0000-000000000001',
      terminal_id: 'REG-01',
      events: [
        {
          client_event_id: 'local-evt-123',
          branch_id: 'a0000000-0000-0000-0000-000000000001',
          terminal_id: 'REG-01',
          event_type: LedgerEventType.BAKE_BATCH_PRODUCED,
          user_id: 'b0000000-0000-0000-0000-000000000002',
          product_id: 'c0000000-0000-0000-0000-000000000001',
          quantity_change: 24,
          batch_number: 'BATCH-20261011-01',
          client_timestamp: new Date().toISOString(),
        },
      ],
    });

    expect(result.accepted_count).toBe(1);
    expect(result.duplicate_count).toBe(0);
    expect(result.processed_event_ids).toContain('local-evt-123');
    expect(mockClient.query).toHaveBeenCalledTimes(2);
  });

  it('should ignore duplicate events idempotently without double-counting balances', async () => {
    // Mock insert returning 0 rows (duplicate conflict resolved by DO NOTHING)
    mockClient.query.mockResolvedValueOnce({ rowCount: 0, rows: [] });

    const result = await syncService.processBatchEvents({
      branch_id: 'a0000000-0000-0000-0000-000000000001',
      terminal_id: 'REG-01',
      events: [
        {
          client_event_id: 'local-evt-123',
          branch_id: 'a0000000-0000-0000-0000-000000000001',
          terminal_id: 'REG-01',
          event_type: LedgerEventType.SALE_COMPLETED,
          user_id: 'b0000000-0000-0000-0000-000000000001',
          product_id: 'c0000000-0000-0000-0000-000000000001',
          quantity_change: -2,
          client_timestamp: new Date().toISOString(),
        },
      ],
    });

    expect(result.accepted_count).toBe(0);
    expect(result.duplicate_count).toBe(1);
    expect(result.processed_event_ids).toContain('local-evt-123');
    // Balance query should NOT be called on duplicates!
    expect(mockClient.query).toHaveBeenCalledTimes(1);
  });
});
