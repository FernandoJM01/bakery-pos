import { TaxKind, ProductUnit } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateIf,
  ValidateNested,
} from 'class-validator';

const HEX_COLOR = /^#[0-9A-Fa-f]{6}$/;
const BARCODE = /^[0-9A-Za-z-]{4,32}$/;
const MAX_CENTS = 10_000_000;

/**
 * May be left out, but `null` is refused. class-validator's IsOptional also
 * lets `null` through, which would reach the database for NOT NULL columns.
 */
const Optional = () => ValidateIf((_obj, val) => val !== undefined);

/** May be left out or `null` (which clears the field). */
const Nullable = () => IsOptional();

/** Query flags arrive as strings; anything but "true" means false. */
const BooleanQuery = () =>
  Transform(({ value }) => value === true || value === 'true');

export class IncludeInactiveQueryDto {
  @Optional()
  @BooleanQuery()
  @IsBoolean()
  includeInactive?: boolean;
}

export class CreateTaxRateDto {
  @IsEnum(TaxKind)
  kind!: TaxKind;

  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name!: string;

  @IsInt()
  @Min(0)
  @Max(10000)
  rateBp!: number;
}

export class UpdateTaxRateDto {
  @Optional()
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name?: string;

  @Optional()
  @IsBoolean()
  isActive?: boolean;
}

export class CreateCategoryDto {
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name!: string;

  @Nullable()
  @Matches(HEX_COLOR)
  color?: string | null;

  @Optional()
  @IsInt()
  @Min(0)
  @Max(10000)
  sortOrder?: number;
}

export class UpdateCategoryDto extends CreateCategoryDto {
  @Optional()
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  declare name: string;

  @Optional()
  @IsBoolean()
  isActive?: boolean;
}

export class CreateVariantDto {
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name!: string;

  @Nullable()
  @IsString()
  @MinLength(1)
  @MaxLength(40)
  sku?: string | null;

  @Nullable()
  @Matches(BARCODE)
  barcode?: string | null;

  @IsInt()
  @Min(1)
  @Max(MAX_CENTS)
  priceCents!: number;

  @Optional()
  @IsInt()
  @Min(0)
  @Max(10000)
  sortOrder?: number;
}

export class UpdateVariantDto extends CreateVariantDto {
  @Optional()
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  declare name: string;

  @Optional()
  @IsInt()
  @Min(1)
  @Max(MAX_CENTS)
  declare priceCents: number;

  @Optional()
  @IsBoolean()
  isActive?: boolean;
}

export class BranchPriceSetDto {
  @IsInt()
  @Min(1)
  @Max(MAX_CENTS)
  priceCents!: number;
}

class ProductFieldsDto {
  @Nullable()
  @IsString()
  @MaxLength(500)
  description?: string | null;

  @Nullable()
  @IsUUID()
  photoId?: string | null;

  @Nullable()
  @IsUUID()
  iepsRateId?: string | null;

  @Nullable()
  @IsInt()
  @Min(1)
  @Max(60)
  dayOldDiscountAfterDays?: number | null;

  @Nullable()
  @IsInt()
  @Min(1)
  @Max(10000)
  dayOldDiscountBp?: number | null;

  @Nullable()
  @IsInt()
  @Min(1)
  @Max(60)
  dayOldWasteAfterDays?: number | null;

  @Optional()
  @IsInt()
  @Min(0)
  @Max(10000)
  sortOrder?: number;
}

export class CreateProductDto extends ProductFieldsDto {
  @IsUUID()
  categoryId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  name!: string;

  @IsEnum(ProductUnit)
  unit!: ProductUnit;

  @IsUUID()
  ivaRateId!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(30)
  @ValidateNested({ each: true })
  @Type(() => CreateVariantDto)
  variants!: CreateVariantDto[];
}

export class UpdateProductDto extends ProductFieldsDto {
  @Optional()
  @IsUUID()
  categoryId?: string;

  @Optional()
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  name?: string;

  @Optional()
  @IsEnum(ProductUnit)
  unit?: ProductUnit;

  @Optional()
  @IsUUID()
  ivaRateId?: string;

  @Optional()
  @IsBoolean()
  isActive?: boolean;
}

export class ListProductsQueryDto extends IncludeInactiveQueryDto {
  @Optional()
  @IsString()
  @MaxLength(100)
  q?: string;

  @Optional()
  @IsUUID()
  categoryId?: string;

  @Optional()
  @IsString()
  cursor?: string;

  @Optional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200)
  limit?: number;
}
