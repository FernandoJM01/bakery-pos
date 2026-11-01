import { Controller, Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import type { Device } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CurrentDevice } from '../devices/decorators/current-device.decorator';
import { RequireDevice } from '../devices/decorators/require-device.decorator';
import { SaleLookupQueryDto, SalesQueryDto } from './dto/sales-query.dto';
import { SalesService } from './sales.service';

@Controller('sales')
export class SalesController {
  constructor(private readonly sales: SalesService) {}

  @Get()
  @RequirePermission('reports.branch')
  list(@Query() query: SalesQueryDto, @CurrentUser() user: AuthenticatedUser) {
    return this.sales.list(user, query);
  }

  @Get('lookup')
  @RequirePermission('sale.create')
  @RequireDevice()
  lookup(@Query() query: SaleLookupQueryDto, @CurrentDevice() device: Device) {
    return this.sales.lookup(device, query.folio);
  }

  @Get(':saleId')
  @RequirePermission('reports.branch')
  get(
    @Param('saleId', ParseUUIDPipe) saleId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.sales.get(user, saleId);
  }
}
