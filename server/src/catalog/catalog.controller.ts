import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CatalogService } from './catalog.service';
import {
  BranchPriceSetDto,
  CreateCategoryDto,
  CreateProductDto,
  CreateTaxRateDto,
  CreateVariantDto,
  IncludeInactiveQueryDto,
  ListProductsQueryDto,
  UpdateCategoryDto,
  UpdateProductDto,
  UpdateTaxRateDto,
  UpdateVariantDto,
} from './dto/catalog.dto';

@Controller()
@RequirePermission('catalog.manage')
export class CatalogController {
  constructor(private readonly catalog: CatalogService) {}

  @Get('tax-rates')
  listTaxRates(@Query() query: IncludeInactiveQueryDto) {
    return this.catalog.listTaxRates(query.includeInactive);
  }

  @Post('tax-rates')
  @HttpCode(HttpStatus.CREATED)
  createTaxRate(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateTaxRateDto,
  ) {
    return this.catalog.createTaxRate(user, dto);
  }

  @Patch('tax-rates/:taxRateId')
  updateTaxRate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('taxRateId', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTaxRateDto,
  ) {
    return this.catalog.updateTaxRate(user, id, dto);
  }

  @Get('categories')
  listCategories(@Query() query: IncludeInactiveQueryDto) {
    return this.catalog.listCategories(query.includeInactive);
  }

  @Post('categories')
  @HttpCode(HttpStatus.CREATED)
  createCategory(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateCategoryDto,
  ) {
    return this.catalog.createCategory(user, dto);
  }

  @Patch('categories/:categoryId')
  updateCategory(
    @CurrentUser() user: AuthenticatedUser,
    @Param('categoryId', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCategoryDto,
  ) {
    return this.catalog.updateCategory(user, id, dto);
  }

  @Get('products')
  listProducts(@Query() query: ListProductsQueryDto) {
    return this.catalog.listProducts(query);
  }

  @Post('products')
  @HttpCode(HttpStatus.CREATED)
  createProduct(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateProductDto,
  ) {
    return this.catalog.createProduct(user, dto);
  }

  @Get('products/:productId')
  getProduct(@Param('productId', ParseUUIDPipe) id: string) {
    return this.catalog.getProduct(id);
  }

  @Patch('products/:productId')
  updateProduct(
    @CurrentUser() user: AuthenticatedUser,
    @Param('productId', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProductDto,
  ) {
    return this.catalog.updateProduct(user, id, dto);
  }

  @Post('products/:productId/variants')
  @HttpCode(HttpStatus.CREATED)
  createVariant(
    @CurrentUser() user: AuthenticatedUser,
    @Param('productId', ParseUUIDPipe) productId: string,
    @Body() dto: CreateVariantDto,
  ) {
    return this.catalog.createVariant(user, productId, dto);
  }

  @Patch('variants/:variantId')
  updateVariant(
    @CurrentUser() user: AuthenticatedUser,
    @Param('variantId', ParseUUIDPipe) id: string,
    @Body() dto: UpdateVariantDto,
  ) {
    return this.catalog.updateVariant(user, id, dto);
  }

  @Put('variants/:variantId/branch-prices/:branchId')
  setBranchPrice(
    @CurrentUser() user: AuthenticatedUser,
    @Param('variantId', ParseUUIDPipe) variantId: string,
    @Param('branchId', ParseUUIDPipe) branchId: string,
    @Body() dto: BranchPriceSetDto,
  ) {
    return this.catalog.setBranchPrice(
      user,
      variantId,
      branchId,
      dto.priceCents,
    );
  }

  @Delete('variants/:variantId/branch-prices/:branchId')
  @HttpCode(HttpStatus.NO_CONTENT)
  removeBranchPrice(
    @CurrentUser() user: AuthenticatedUser,
    @Param('variantId', ParseUUIDPipe) variantId: string,
    @Param('branchId', ParseUUIDPipe) branchId: string,
  ) {
    return this.catalog.removeBranchPrice(user, variantId, branchId);
  }
}
