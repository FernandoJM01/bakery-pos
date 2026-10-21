import { Controller, Get, Req } from '@nestjs/common';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { AUTHENTICATED } from '../common/permissions';
import { AuthService } from './auth.service';
import { AuthenticatedUser } from './interfaces/auth.interface';

@Controller('me')
export class MeController {
  constructor(private readonly authService: AuthService) {}

  @Get()
  @RequirePermission(AUTHENTICATED)
  async getMe(@Req() req: { user: AuthenticatedUser }) {
    return this.authService.getMe(req.user);
  }
}
