import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_GUARD } from '@nestjs/core';
import { LoggerModule } from 'nestjs-pino';
import { GlobalExceptionFilter } from './common/filters/http-exception.filter';
import { PermissionsGuard } from './common/guards/permissions.guard';
import { validateEnv } from './config/env.validation';
import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnv,
    }),
    LoggerModule.forRoot({
      pinoHttp: {
        redact: {
          paths: [
            'req.headers.authorization',
            'req.headers.cookie',
            'res.headers["set-cookie"]',
            'req.headers["x-device-token"]',
            'req.headers["x-approval-token"]',
            'req.body.pin',
            'req.body.password',
            'req.body.token',
            'req.body.deviceToken',
            'req.body.refreshToken',
            'req.body.approvalToken',
            'req.body.offlinePinVerifier',
          ],
          censor: '[REDACTED]',
        },
        level:
          process.env.NODE_ENV === 'test'
            ? 'silent'
            : (process.env.LOG_LEVEL ?? 'info'),
        // JSON logs everywhere except explicit local development; pino-pretty
        // is a devDependency and is not installed in staging or production.
        transport:
          process.env.NODE_ENV === 'development'
            ? { target: 'pino-pretty', options: { colorize: true } }
            : undefined,
      },
    }),
    PrismaModule,
    HealthModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: PermissionsGuard,
    },
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
  ],
})
export class AppModule {}
