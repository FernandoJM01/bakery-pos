import { Controller, Get, Param } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Controller('products')
export class ProductsController {
  constructor(private readonly db: DatabaseService) {}

  @Get()
  async getAll() {
    const res = await this.db.query(
      `SELECT id, sku, barcode, name, category, unit, price_cents, is_active FROM products WHERE is_active = true ORDER BY category, name`,
    );
    return res.rows;
  }
}
