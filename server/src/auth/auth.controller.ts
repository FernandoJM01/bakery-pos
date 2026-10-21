import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  Req,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { AUTHENTICATED } from '../common/permissions';
import { AuthService } from './auth.service';
import { PasswordLoginDto } from './dto/password-login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { AuthenticatedUser } from './interfaces/auth.interface';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('password-login')
  @Public()
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  async passwordLogin(@Body() dto: PasswordLoginDto) {
    return this.authService.passwordLogin(dto);
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
  async logout(@Req() req: { user: AuthenticatedUser }): Promise<void> {
    await this.authService.logout(req.user);
  }
}
