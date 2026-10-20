import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';

export interface HealthResponse {
  status: 'ok' | 'degraded';
  database: 'ok' | 'unreachable';
  version: string;
}

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  async check(): Promise<HealthResponse> {
    const isDbHealthy = await this.prisma.isHealthy();
    const version = this.configService.get<string>('APP_VERSION') ?? '0.1.0-m1';

    return {
      status: isDbHealthy ? 'ok' : 'degraded',
      database: isDbHealthy ? 'ok' : 'unreachable',
      version,
    };
  }
}
