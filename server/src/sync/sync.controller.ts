import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Device } from '@prisma/client';
import { createHash } from 'crypto';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CurrentDevice } from '../devices/decorators/current-device.decorator';
import { RequireDevice } from '../devices/decorators/require-device.decorator';
import { CatalogFeedService } from './catalog-feed.service';
import {
  CatalogPullQueryDto,
  QuarantineQueryDto,
  QuarantineResolveDto,
  SyncPushDto,
} from './dto/sync.dto';
import { QuarantineService } from './quarantine.service';
import { SyncPushService } from './sync-push.service';

/**
 * The throttler runs before the device guard, so it keys on a hash of the
 * raw device token: each till gets its own 60 a minute, while tills of one
 * branch share a public IP.
 */
export function deviceTracker(req: Record<string, unknown>): Promise<string> {
  const headers = (req.headers ?? {}) as Record<string, unknown>;
  const token = headers['x-device-token'];
  if (typeof token === 'string' && token.length > 0) {
    return Promise.resolve(
      'device:' + createHash('sha256').update(token).digest('hex'),
    );
  }
  return Promise.resolve(`ip:${typeof req.ip === 'string' ? req.ip : ''}`);
}

@Controller('sync')
export class SyncController {
  constructor(
    private readonly feed: CatalogFeedService,
    private readonly pushService: SyncPushService,
    private readonly quarantine: QuarantineService,
  ) {}

  @Get('catalog')
  @Public()
  @RequireDevice()
  @Throttle({ default: { limit: 120, ttl: 60000, getTracker: deviceTracker } })
  pullCatalog(
    @Query() query: CatalogPullQueryDto,
    @CurrentDevice() device: Device,
  ) {
    return this.feed.pull(device, BigInt(query.since), query.limit ?? 500);
  }

  @Post('push')
  @Public()
  @RequireDevice()
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 60, ttl: 60000, getTracker: deviceTracker } })
  push(@Body() dto: SyncPushDto, @CurrentDevice() device: Device) {
    return this.pushService.push(device, dto.records);
  }

  @Get('quarantine')
  @RequirePermission('settings.manage')
  listQuarantine(@Query() query: QuarantineQueryDto) {
    return this.quarantine.list(query);
  }

  @Post('quarantine/:recordId/resolve')
  @RequirePermission('settings.manage')
  @HttpCode(HttpStatus.OK)
  resolve(
    @Param('recordId', ParseUUIDPipe) recordId: string,
    @Body() dto: QuarantineResolveDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.quarantine.resolve(recordId, dto.note, user.staffId);
  }
}
