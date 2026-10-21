import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { AuditModule } from '../audit/audit.module';
import { ClockService } from '../common/clock.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthGuard } from './guards/auth.guard';
import { MeController } from './me.controller';

@Module({
  imports: [
    PrismaModule,
    AuditModule,
    ConfigModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: '15m' },
      }),
    }),
  ],
  controllers: [AuthController, MeController],
  providers: [AuthService, AuthGuard, ClockService],
  exports: [AuthService, AuthGuard, JwtModule, ClockService],
})
export class AuthModule {}
