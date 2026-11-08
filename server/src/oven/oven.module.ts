import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { OvenController } from './oven.controller';
import { OvenService } from './oven.service';

@Module({
  imports: [PrismaModule],
  controllers: [OvenController],
  providers: [OvenService],
})
export class OvenModule {}
