-- CreateExtension
CREATE EXTENSION IF NOT EXISTS unaccent;

-- CreateEnum
CREATE TYPE "tax_kind" AS ENUM ('IVA', 'IEPS');

-- CreateEnum
CREATE TYPE "product_unit" AS ENUM ('PIECE', 'KG', 'PACKAGE');

-- CreateSequence
CREATE SEQUENCE IF NOT EXISTS "catalog_change_seq" START WITH 1 INCREMENT BY 1;

-- CreateTriggerFunction
CREATE OR REPLACE FUNCTION set_catalog_change_seq()
RETURNS TRIGGER AS $$
BEGIN
    -- Catalog writes take one transaction-scoped lock before drawing a number,
    -- so change_seq values are handed out in commit order. Without it a slow
    -- transaction could commit a lower number after a till has already read
    -- past it, and that till would never receive the row.
    PERFORM pg_advisory_xact_lock(hashtext('catalog_change_seq'));
    NEW.change_seq := nextval('catalog_change_seq');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CreateTable tax_rate
CREATE TABLE "tax_rate" (
    "id" UUID NOT NULL,
    "kind" "tax_kind" NOT NULL,
    "name" VARCHAR(60) NOT NULL,
    "rate_bp" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "change_seq" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tax_rate_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "tax_rate_rate_bp_check" CHECK ("rate_bp" >= 0 AND "rate_bp" <= 10000)
);

CREATE INDEX "tax_rate_change_seq_idx" ON "tax_rate"("change_seq");

CREATE TRIGGER set_tax_rate_change_seq
BEFORE INSERT OR UPDATE ON "tax_rate"
FOR EACH ROW
EXECUTE FUNCTION set_catalog_change_seq();

-- CreateTable category
CREATE TABLE "category" (
    "id" UUID NOT NULL,
    "name" VARCHAR(60) NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "color" VARCHAR(7),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "change_seq" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "category_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "category_sort_order_check" CHECK ("sort_order" >= 0 AND "sort_order" <= 10000)
);

CREATE INDEX "category_change_seq_idx" ON "category"("change_seq");
CREATE UNIQUE INDEX "category_name_active_idx" ON "category"("name") WHERE "is_active" = true;

CREATE TRIGGER set_category_change_seq
BEFORE INSERT OR UPDATE ON "category"
FOR EACH ROW
EXECUTE FUNCTION set_catalog_change_seq();

-- CreateTable photo
CREATE TABLE "photo" (
    "id" UUID NOT NULL,
    "content_type" VARCHAR(50) NOT NULL,
    "bytes" INTEGER NOT NULL,
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,
    "sha256" VARCHAR(64) NOT NULL,
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "photo_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "photo_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "staff"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable product
CREATE TABLE "product" (
    "id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "description" VARCHAR(500),
    "unit" "product_unit" NOT NULL,
    "photo_id" UUID,
    "iva_rate_id" UUID NOT NULL,
    "ieps_rate_id" UUID,
    "day_old_discount_after_days" INTEGER,
    "day_old_discount_bp" INTEGER,
    "day_old_waste_after_days" INTEGER,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "change_seq" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "product_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "product_sort_order_check" CHECK ("sort_order" >= 0 AND "sort_order" <= 10000),
    CONSTRAINT "product_day_old_discount_check" CHECK (
        ("day_old_discount_after_days" IS NULL AND "day_old_discount_bp" IS NULL) OR
        ("day_old_discount_after_days" IS NOT NULL AND "day_old_discount_bp" IS NOT NULL)
    ),
    CONSTRAINT "product_day_old_waste_check" CHECK (
        "day_old_waste_after_days" IS NULL OR
        "day_old_discount_after_days" IS NULL OR
        "day_old_waste_after_days" > "day_old_discount_after_days"
    ),
    CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "product_photo_id_fkey" FOREIGN KEY ("photo_id") REFERENCES "photo"("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "product_iva_rate_id_fkey" FOREIGN KEY ("iva_rate_id") REFERENCES "tax_rate"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "product_ieps_rate_id_fkey" FOREIGN KEY ("ieps_rate_id") REFERENCES "tax_rate"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX "product_category_id_idx" ON "product"("category_id");
CREATE INDEX "product_change_seq_idx" ON "product"("change_seq");

CREATE TRIGGER set_product_change_seq
BEFORE INSERT OR UPDATE ON "product"
FOR EACH ROW
EXECUTE FUNCTION set_catalog_change_seq();

-- CreateTable product_variant
CREATE TABLE "product_variant" (
    "id" UUID NOT NULL,
    "product_id" UUID NOT NULL,
    "name" VARCHAR(60) NOT NULL,
    "sku" VARCHAR(40),
    "barcode" VARCHAR(32),
    "price_cents" INTEGER NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "change_seq" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "product_variant_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "product_variant_price_cents_check" CHECK ("price_cents" > 0),
    CONSTRAINT "product_variant_sort_order_check" CHECK ("sort_order" >= 0 AND "sort_order" <= 10000),
    CONSTRAINT "product_variant_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "product_variant_sku_key" ON "product_variant"("sku");
CREATE UNIQUE INDEX "product_variant_barcode_key" ON "product_variant"("barcode");
CREATE INDEX "product_variant_product_id_idx" ON "product_variant"("product_id");
CREATE INDEX "product_variant_change_seq_idx" ON "product_variant"("change_seq");

CREATE TRIGGER set_product_variant_change_seq
BEFORE INSERT OR UPDATE ON "product_variant"
FOR EACH ROW
EXECUTE FUNCTION set_catalog_change_seq();

-- CreateTable branch_price
CREATE TABLE "branch_price" (
    "variant_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "price_cents" INTEGER NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),
    "change_seq" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branch_price_pkey" PRIMARY KEY ("variant_id", "branch_id"),
    CONSTRAINT "branch_price_price_cents_check" CHECK ("price_cents" > 0),
    CONSTRAINT "branch_price_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "branch_price_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "branch_price_branch_id_idx" ON "branch_price"("branch_id");
CREATE INDEX "branch_price_change_seq_idx" ON "branch_price"("change_seq");

CREATE TRIGGER set_branch_price_change_seq
BEFORE INSERT OR UPDATE ON "branch_price"
FOR EACH ROW
EXECUTE FUNCTION set_catalog_change_seq();

-- Seed placeholder tax rates (needed in production)
INSERT INTO "tax_rate" ("id", "kind", "name", "rate_bp", "is_active", "created_at", "updated_at")
VALUES
    ('019a1e00-0000-7000-8000-000000000001', 'IVA', 'IVA 0%', 0, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('019a1e00-0000-7000-8000-000000000002', 'IVA', 'IVA 16%', 1600, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('019a1e00-0000-7000-8000-000000000003', 'IEPS', 'IEPS 8%', 800, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT ("id") DO NOTHING;

-- Grant permissions to pos_app (least privilege: only SELECT, INSERT, UPDATE)
GRANT SELECT, INSERT, UPDATE ON TABLE "tax_rate" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "category" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "photo" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "product" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "product_variant" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "branch_price" TO pos_app;
GRANT USAGE, SELECT ON SEQUENCE "catalog_change_seq" TO pos_app;

REVOKE DELETE, TRUNCATE ON TABLE "tax_rate" FROM pos_app;
REVOKE DELETE, TRUNCATE ON TABLE "category" FROM pos_app;
REVOKE DELETE, TRUNCATE ON TABLE "photo" FROM pos_app;
REVOKE DELETE, TRUNCATE ON TABLE "product" FROM pos_app;
REVOKE DELETE, TRUNCATE ON TABLE "product_variant" FROM pos_app;
REVOKE DELETE, TRUNCATE ON TABLE "branch_price" FROM pos_app;
