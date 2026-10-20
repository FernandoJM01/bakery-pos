import { Controller, Post, Body, Get, Param, UseGuards } from '@nestjs/common';
import { SyncService } from './sync.service';
import { BatchSyncPushDto } from './sync.dto';
import { AuthGuard } from '@nestjs/passport';

@Controller('sync')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('push')
  async pushBatchEvents(@Body() dto: BatchSyncPushDto) {
    return this.syncService.processBatchEvents(dto);
  }

  @Get('pull/:branchId')
  async pullSnapshot(@Param('branchId') branchId: string) {
    return this.syncService.pullBranchSnapshot(branchId);
  }
}
