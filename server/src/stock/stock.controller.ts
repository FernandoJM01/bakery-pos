import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import type { Device } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CurrentDevice } from '../devices/decorators/current-device.decorator';
import { RequireDevice } from '../devices/decorators/require-device.decorator';
import {
  CreateTransferDto,
  ReceiveTransferDto,
  StockEventsQueryDto,
  StockLevelsQueryDto,
  TransfersQueryDto,
  WasteQueryDto,
} from './dto/stock-query.dto';
import { StockService } from './stock.service';

@Controller('stock')
export class StockController {
  constructor(private readonly stock: StockService) {}

  @Get('lots')
  @Public()
  @RequireDevice()
  lots(@CurrentDevice() device: Device) {
    return this.stock.branchStock(device);
  }

  @Get('levels')
  @RequirePermission('reports.branch')
  levels(
    @Query() q: StockLevelsQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.stock.levels(user, q.branchId);
  }

  @Get('events')
  @RequirePermission('reports.branch')
  events(
    @Query() q: StockEventsQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.stock.events(user, q);
  }

  @Get('waste')
  @RequirePermission('reports.branch')
  waste(@Query() q: WasteQueryDto, @CurrentUser() user: AuthenticatedUser) {
    return this.stock.waste(user, q);
  }

  @Get('transfers')
  @RequirePermission('reports.branch')
  transfers(
    @Query() q: TransfersQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.stock.transfers(user, q);
  }

  @Post('transfers')
  @RequirePermission('stock.transfer')
  send(@Body() dto: CreateTransferDto, @CurrentUser() user: AuthenticatedUser) {
    return this.stock.send(user, dto);
  }

  @Post('transfers/:transferId/receive')
  @HttpCode(200)
  @RequirePermission('stock.transfer')
  receive(
    @Param('transferId', ParseUUIDPipe) id: string,
    @Body() dto: ReceiveTransferDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.stock.receive(user, id, dto);
  }

  @Get('checks/latest')
  @RequirePermission('reports.branch')
  latestCheck() {
    return this.stock.latestCheck();
  }
}
