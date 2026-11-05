import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { CatalogRulesController } from './catalog-rules.controller';
import { CatalogRulesService } from './catalog-rules.service';
import { CatalogController } from './catalog.controller';
import { CatalogService } from './catalog.service';

@Module({
  imports: [PrismaModule],
  controllers: [CatalogController, CatalogRulesController],
  providers: [CatalogService, CatalogRulesService],
})
export class CatalogModule {}
