import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Device } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { AUTHENTICATED } from '../common/permissions';
import { CurrentDevice } from '../devices/decorators/current-device.decorator';
import { RequireDevice } from '../devices/decorators/require-device.decorator';
import { ApprovalService } from './approval.service';
import { AuthService } from './auth.service';
import { ApprovalDto } from './dto/approval.dto';
import { PasswordLoginDto } from './dto/password-login.dto';
import { PinLoginDto } from './dto/pin-login.dto';
import { RefreshDto } from './dto/refresh.dto';
import type { AuthenticatedUser } from './interfaces/auth.interface';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly approvalService: ApprovalService,
  ) {}

  @Post('password-login')
  @Public()
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 30, ttl: 60000 } })
  async passwordLogin(@Body() dto: PasswordLoginDto) {
    return this.authService.passwordLogin(dto);
  }

  @Post('pin-login')
  @Public()
  @RequireDevice()
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 30, ttl: 60000 } })
  async pinLogin(@Body() dto: PinLoginDto, @CurrentDevice() device: Device) {
    return this.authService.pinLogin(dto, device);
  }

  @Post('refresh')
  @Public()
  @Throttle({ default: { limit: 60, ttl: 60000 } })
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Post('logout')
  @RequirePermission(AUTHENTICATED)
  @HttpCode(HttpStatus.NO_CONTENT)
  async logout(@CurrentUser() user: AuthenticatedUser): Promise<void> {
    await this.authService.logout(user);
  }

  @Post('approvals')
  @RequirePermission(AUTHENTICATED)
  @RequireDevice()
  @Throttle({ default: { limit: 30, ttl: 60000 } })
  @HttpCode(HttpStatus.CREATED)
  async createApproval(
    @Body() dto: ApprovalDto,
    @CurrentUser() user: AuthenticatedUser,
    @CurrentDevice() device: Device,
  ) {
    return this.approvalService.createApproval(dto, user, device);
  }
}
