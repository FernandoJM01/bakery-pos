import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
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
  CustomerDto,
  CustomersQueryDto,
  CustomerUpdateDto,
  OrderCreateDto,
  OrderPauseDto,
  OrderSkipDto,
  OrdersQueryDto,
  OrderUpdateDto,
  PickListQueryDto,
} from './dto/orders.dto';
import { OrdersService } from './orders.service';

@Controller()
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Get('customers')
  @RequirePermission('orders.pickup')
  listCustomers(@Query() q: CustomersQueryDto) {
    return this.orders.listCustomers(q.q);
  }

  @Post('customers')
  @RequirePermission('orders.manage')
  createCustomer(
    @Body() dto: CustomerDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.createCustomer(user, dto);
  }

  @Get('customers/:customerId')
  @RequirePermission('orders.pickup')
  getCustomer(@Param('customerId', ParseUUIDPipe) id: string) {
    return this.orders.getCustomer(id);
  }

  @Patch('customers/:customerId')
  @RequirePermission('orders.manage')
  updateCustomer(
    @Param('customerId', ParseUUIDPipe) id: string,
    @Body() dto: CustomerUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.updateCustomer(user, id, dto);
  }

  @Get('orders')
  @RequirePermission('orders.pickup')
  listOrders(
    @Query() q: OrdersQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.listOrders(user, q);
  }

  @Post('orders')
  @RequirePermission('orders.manage')
  createOrder(
    @Body() dto: OrderCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.createOrder(user, dto);
  }

  @Get('orders/tickets')
  @Public()
  @RequireDevice()
  tickets(@CurrentDevice() device: Device) {
    return this.orders.branchTickets(device);
  }

  @Get('orders/pick-list')
  @RequirePermission('orders.pickup')
  pickList(
    @Query() q: PickListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.pickList(user, q.branchId, q.date);
  }

  @Get('orders/:orderId')
  @RequirePermission('orders.pickup')
  getOrder(
    @Param('orderId', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.getOrder(user, id);
  }

  @Put('orders/:orderId')
  @RequirePermission('orders.manage')
  updateOrder(
    @Param('orderId', ParseUUIDPipe) id: string,
    @Body() dto: OrderUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.updateOrder(user, id, dto);
  }

  @Post('orders/:orderId/skips')
  @HttpCode(200)
  @RequirePermission('orders.manage')
  skip(
    @Param('orderId', ParseUUIDPipe) id: string,
    @Body() dto: OrderSkipDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.skip(user, id, dto.date);
  }

  @Delete('orders/:orderId/skips/:date')
  @RequirePermission('orders.manage')
  unskip(
    @Param('orderId', ParseUUIDPipe) id: string,
    @Param('date') date: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.unskip(user, id, date);
  }

  @Post('orders/:orderId/pause')
  @HttpCode(200)
  @RequirePermission('orders.manage')
  pause(
    @Param('orderId', ParseUUIDPipe) id: string,
    @Body() dto: OrderPauseDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.pause(user, id, dto);
  }

  @Post('orders/:orderId/resume')
  @HttpCode(200)
  @RequirePermission('orders.manage')
  resume(
    @Param('orderId', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.resume(user, id);
  }

  @Post('orders/:orderId/end')
  @HttpCode(200)
  @RequirePermission('orders.manage')
  end(
    @Param('orderId', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.orders.end(user, id);
  }
}
