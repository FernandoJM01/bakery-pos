import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsUUID,
  Max,
  Min,
  ValidateIf,
} from 'class-validator';

/** Required, but null is a value: null clears the rule. */
const OrNull = () => ValidateIf((_o, v) => v !== null);

/** `DayOldRuleSet` */
export class DayOldRuleSetDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(500)
  @IsUUID('all', { each: true })
  productIds!: string[];

  @OrNull()
  @IsInt()
  @Min(1)
  @Max(60)
  dayOldDiscountAfterDays!: number | null;

  @OrNull()
  @IsInt()
  @Min(1)
  @Max(10000)
  dayOldDiscountBp!: number | null;

  @OrNull()
  @IsInt()
  @Min(1)
  @Max(60)
  dayOldWasteAfterDays!: number | null;
}

/** Body of `PUT /v1/costs/{variantId}` */
export class SetCostDto {
  @OrNull()
  @IsInt()
  @Min(1)
  @Max(100_000_000)
  costCents!: number | null;
}
