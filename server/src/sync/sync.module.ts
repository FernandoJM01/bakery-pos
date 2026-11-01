import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { SaleSyncService } from '../sales/sale-sync.service';
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
    QuarantineService,
  ],
})
export class SyncModule {}
