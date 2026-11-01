-- M3 sales: till numbers and folio prefixes on devices, and the sale tables
-- filled by the sale.completed and sale.refunded sync handlers.

-- CreateEnum
CREATE TYPE "SaleStatus" AS ENUM ('COMPLETED', 'PARTIALLY_REFUNDED', 'REFUNDED', 'VOIDED');

-- CreateEnum
CREATE TYPE "DiscountKind" AS ENUM ('PERCENT', 'AMOUNT');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CASH');

-- CreateEnum
CREATE TYPE "RefundKind" AS ENUM ('REFUND', 'VOID');

-- AlterTable
ALTER TABLE "device" ADD COLUMN     "folio_prefix" VARCHAR(16),
ADD COLUMN     "till_number" INTEGER;

-- CreateTable
CREATE TABLE "sale" (
    "id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "folio" VARCHAR(30) NOT NULL,
    "folio_number" INTEGER NOT NULL,
    "cashier_staff_id" UUID NOT NULL,
    "shift_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "gross_cents" INTEGER NOT NULL,
    "discount_cents" INTEGER NOT NULL,
    "total_cents" INTEGER NOT NULL,
    "refunded_cents" INTEGER NOT NULL DEFAULT 0,
    "status" "SaleStatus" NOT NULL DEFAULT 'COMPLETED',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sale_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sale_line" (
    "sale_id" UUID NOT NULL,
    "line_no" INTEGER NOT NULL,
    "variant_id" UUID NOT NULL,
    "product_name" VARCHAR(120) NOT NULL,
    "variant_name" VARCHAR(120) NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price_cents" INTEGER NOT NULL,
    "gross_cents" INTEGER NOT NULL,
    "line_discount_cents" INTEGER NOT NULL,
    "order_discount_cents" INTEGER NOT NULL,
    "net_cents" INTEGER NOT NULL,
    "iva_rate_id" UUID NOT NULL,
    "iva_bp" INTEGER NOT NULL,
    "ieps_rate_id" UUID,
    "ieps_bp" INTEGER NOT NULL,
    "base_cents" INTEGER NOT NULL,
    "ieps_cents" INTEGER NOT NULL,
    "iva_cents" INTEGER NOT NULL,
    "refunded_quantity" INTEGER NOT NULL DEFAULT 0,
    "refunded_cents" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "sale_line_pkey" PRIMARY KEY ("sale_id","line_no")
);

-- CreateTable
CREATE TABLE "sale_discount" (
    "id" UUID NOT NULL,
    "sale_id" UUID NOT NULL,
    "line_no" INTEGER,
    "kind" "DiscountKind" NOT NULL,
    "value" INTEGER NOT NULL,
    "cents" INTEGER NOT NULL,
    "reason" VARCHAR(30) NOT NULL,
    "note" VARCHAR(120),
    "approver_staff_id" UUID,

    CONSTRAINT "sale_discount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sale_voided_line" (
    "sale_id" UUID NOT NULL,
    "seq" INTEGER NOT NULL,
    "variant_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price_cents" INTEGER NOT NULL,
    "voided_at" TIMESTAMPTZ(6) NOT NULL,
    "staff_id" UUID NOT NULL,

    CONSTRAINT "sale_voided_line_pkey" PRIMARY KEY ("sale_id","seq")
);

-- CreateTable
CREATE TABLE "payment" (
    "id" UUID NOT NULL,
    "sale_id" UUID NOT NULL,
    "method" "PaymentMethod" NOT NULL,
    "amount_cents" INTEGER NOT NULL,
    "tendered_cents" INTEGER NOT NULL,
    "change_cents" INTEGER NOT NULL,

    CONSTRAINT "payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refund" (
    "id" UUID NOT NULL,
    "sale_id" UUID NOT NULL,
    "kind" "RefundKind" NOT NULL,
    "reason" VARCHAR(30) NOT NULL,
    "note" VARCHAR(120),
    "device_id" UUID NOT NULL,
    "staff_id" UUID NOT NULL,
    "approver_staff_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "total_cents" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refund_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refund_line" (
    "refund_id" UUID NOT NULL,
    "line_no" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "amount_cents" INTEGER NOT NULL,
    "base_cents" INTEGER NOT NULL,
    "ieps_cents" INTEGER NOT NULL,
    "iva_cents" INTEGER NOT NULL,
    "restock" BOOLEAN NOT NULL,

    CONSTRAINT "refund_line_pkey" PRIMARY KEY ("refund_id","line_no")
);

-- CreateIndex
CREATE UNIQUE INDEX "sale_folio_key" ON "sale"("folio");

-- CreateIndex
CREATE INDEX "sale_branch_id_occurred_at_idx" ON "sale"("branch_id", "occurred_at");

-- CreateIndex
CREATE INDEX "sale_occurred_at_idx" ON "sale"("occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "sale_device_id_folio_number_key" ON "sale"("device_id", "folio_number");

-- CreateIndex
CREATE INDEX "sale_line_variant_id_idx" ON "sale_line"("variant_id");

-- CreateIndex
CREATE INDEX "sale_discount_sale_id_idx" ON "sale_discount"("sale_id");

-- CreateIndex
CREATE INDEX "payment_sale_id_idx" ON "payment"("sale_id");

-- CreateIndex
CREATE INDEX "refund_sale_id_idx" ON "refund"("sale_id");

-- CreateIndex
CREATE UNIQUE INDEX "device_branch_id_till_number_key" ON "device"("branch_id", "till_number");

-- AddForeignKey
ALTER TABLE "sale" ADD CONSTRAINT "sale_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale" ADD CONSTRAINT "sale_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale" ADD CONSTRAINT "sale_cashier_staff_id_fkey" FOREIGN KEY ("cashier_staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_line" ADD CONSTRAINT "sale_line_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_line" ADD CONSTRAINT "sale_line_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_discount" ADD CONSTRAINT "sale_discount_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_voided_line" ADD CONSTRAINT "sale_voided_line_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refund" ADD CONSTRAINT "refund_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refund" ADD CONSTRAINT "refund_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refund" ADD CONSTRAINT "refund_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refund_line" ADD CONSTRAINT "refund_line_refund_id_fkey" FOREIGN KEY ("refund_id") REFERENCES "refund"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Number the sales tills that already exist, per branch in creation order,
-- and fix their folio prefix (<branch code>-<till number, 2 digits>).
UPDATE "device" d
SET "till_number" = n.num,
    "folio_prefix" = b."code" || '-' || lpad(n.num::text, 2, '0')
FROM (
  SELECT "id", row_number() OVER (PARTITION BY "branch_id" ORDER BY "created_at", "id") AS num
  FROM "device" WHERE "type" = 'TILL'
) n, "branch" b
WHERE d."id" = n."id" AND b."id" = d."branch_id";

-- New sales tills take the next number of their branch (1 + the highest
-- ever used, so numbers are never reused) and its folio prefix, whatever
-- inserts them. Two tills inserted at once collide on the unique
-- (branch, till number); the service retries.
CREATE FUNCTION "device_assign_till_number"() RETURNS trigger AS $$
DECLARE
  next_num INTEGER;
BEGIN
  IF NEW."type" = 'TILL' AND NEW."till_number" IS NULL THEN
    SELECT COALESCE(MAX("till_number"), 0) + 1 INTO next_num
      FROM "device" WHERE "branch_id" = NEW."branch_id";
    IF next_num > 99 THEN
      RAISE EXCEPTION 'TILL_LIMIT: a branch can have at most 99 sales tills';
    END IF;
    NEW."till_number" := next_num;
    SELECT "code" || '-' || lpad(next_num::text, 2, '0') INTO NEW."folio_prefix"
      FROM "branch" WHERE "id" = NEW."branch_id";
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "device_assign_till_number"
  BEFORE INSERT ON "device"
  FOR EACH ROW EXECUTE FUNCTION "device_assign_till_number"();

ALTER TABLE "device" ADD CONSTRAINT "device_till_number_check"
  CHECK (("type" = 'TILL') = ("till_number" IS NOT NULL) AND ("till_number" IS NULL OR "till_number" BETWEEN 1 AND 99));

-- pos_app: sales arrive once and are never edited, except their refund
-- totals and status; refunds are append-only. No deletes.
GRANT SELECT, INSERT, UPDATE ON TABLE "sale" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "sale_line" TO pos_app;
GRANT SELECT, INSERT ON TABLE "sale_discount", "sale_voided_line", "payment", "refund", "refund_line" TO pos_app;
