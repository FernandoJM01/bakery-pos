import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { OrderSyncService } from '../orders/order-sync.service';
import { SaleSyncService } from '../sales/sale-sync.service';
import { ShiftSyncService } from '../shifts/shift-sync.service';
import { StockLedgerService } from '../stock/stock-ledger.service';
import { StockSyncService } from '../stock/stock-sync.service';
import { CatalogFeedService } from './catalog-feed.service';
import { QuarantineService } from './quarantine.service';
import { SyncController } from './sync.controller';
import { SyncPushService } from './sync-push.service';

@Module({
  imports: [PrismaModule],
  controllers: [SyncController],
  providers: [
    CatalogFeedService,
    SyncPushService,
    SaleSyncService,
    ShiftSyncService,
    StockLedgerService,
    StockSyncService,
    OrderSyncService,
    QuarantineService,
  ],
})
export class SyncModule {}
