import { Controller, Get, HttpStatus, Res } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';
import { Public } from '../common/decorators/public.decorator';
import { HealthService } from './health.service';

@SkipThrottle()
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Public()
  @Get()
  async getHealth(@Res({ passthrough: true }) res: Response) {
    const health = await this.healthService.check();
    if (health.status !== 'ok') {
      res.status(HttpStatus.SERVICE_UNAVAILABLE);
    }
    return health;
  }
}
