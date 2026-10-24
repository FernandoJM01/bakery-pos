import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { AUTHENTICATED } from '../common/permissions';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { BranchesService } from './branches.service';
import { CreateBranchDto, UpdateBranchDto } from './dto/branch.dto';

@Controller('branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get()
  @RequirePermission(AUTHENTICATED)
  async list(@CurrentUser() user: AuthenticatedUser) {
    return this.branchesService.list(user);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission('branches.manage')
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateBranchDto,
  ) {
    return this.branchesService.create(user, dto);
  }

  @Patch(':branchId')
  @RequirePermission('branches.manage')
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('branchId', ParseUUIDPipe) branchId: string,
    @Body() dto: UpdateBranchDto,
  ) {
    return this.branchesService.update(user, branchId, dto);
  }
}
