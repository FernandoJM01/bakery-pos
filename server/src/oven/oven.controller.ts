import {
  Body,
  Controller,
  Get,
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
  OvenBranchDto,
  OvenFeeRuleCreateDto,
  OvenFeeRuleUpdateDto,
  OvenTicketsQueryDto,
} from './dto/oven.dto';
import { OvenService } from './oven.service';

@Controller('oven')
export class OvenController {
  constructor(private readonly oven: OvenService) {}

  @Get('board')
  @Public()
  @RequireDevice()
  board(@CurrentDevice() device: Device) {
    return this.oven.board(device);
  }

  @Get('fees')
  @RequirePermission('catalog.manage')
  listRules() {
    return this.oven.listRules();
  }

  @Post('fees')
  @RequirePermission('catalog.manage')
  createRule(
    @Body() dto: OvenFeeRuleCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.oven.createRule(user, dto);
  }

  @Patch('fees/:ruleId')
  @RequirePermission('catalog.manage')
  updateRule(
    @Param('ruleId', ParseUUIDPipe) id: string,
    @Body() dto: OvenFeeRuleUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.oven.updateRule(user, id, dto);
  }

  @Put('branches/:branchId')
  @RequirePermission('branches.manage')
  setBranch(
    @Param('branchId', ParseUUIDPipe) branchId: string,
    @Body() dto: OvenBranchDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.oven.setBranch(user, branchId, dto.enabled);
  }

  @Get('tickets')
  @RequirePermission('reports.branch')
  list(
    @Query() q: OvenTicketsQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.oven.list(user, q);
  }
}
