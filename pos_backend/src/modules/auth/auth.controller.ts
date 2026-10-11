import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PinLoginDto } from './pin-login.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login-pin')
  async loginPin(@Body() dto: PinLoginDto) {
    return this.authService.validatePin(dto);
  }

  @Get('staff-sync/:branchId')
  async getStaffForBranch(@Param('branchId') branchId: string) {
    return this.authService.getStaffForBranch(branchId);
  }
}
