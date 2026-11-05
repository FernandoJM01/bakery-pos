import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Put,
} from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CatalogRulesService } from './catalog-rules.service';
import { DayOldRuleSetDto, SetCostDto } from './dto/rules.dto';

@Controller()
export class CatalogRulesController {
  constructor(private readonly rules: CatalogRulesService) {}

  @Get('day-old-rules')
  @RequirePermission('catalog.manage')
  listRules() {
    return this.rules.listRules();
  }

  @Put('day-old-rules')
  @RequirePermission('catalog.manage')
  setRules(
    @Body() dto: DayOldRuleSetDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.rules.setRules(user, dto);
  }

  @Get('costs')
  @RequirePermission('catalog.cost')
  listCosts() {
    return this.rules.listCosts();
  }

  @Put('costs/:variantId')
  @RequirePermission('catalog.cost')
  setCost(
    @Param('variantId', ParseUUIDPipe) variantId: string,
    @Body() dto: SetCostDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.rules.setCost(user, variantId, dto.costCents);
  }
}
