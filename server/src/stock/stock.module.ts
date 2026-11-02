import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { StockLedgerService } from './stock-ledger.service';
import { StockController } from './stock.controller';
import { StockService } from './stock.service';

@Module({
  imports: [PrismaModule],
  controllers: [StockController],
  providers: [StockLedgerService, StockService],
  exports: [StockService],
})
export class StockModule {}
