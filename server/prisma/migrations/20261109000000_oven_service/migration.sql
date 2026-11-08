-- M8 oven service (Christmas): customers bring a dish, the bakery bakes it
-- for a fee by dish type and weight.

-- CreateEnum
CREATE TYPE "OvenStatus" AS ENUM ('RECEIVED', 'IN_OVEN', 'READY', 'PICKED_UP');

-- AlterTable
ALTER TABLE "branch" ADD COLUMN "oven_enabled" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "oven_fee_rule" (
    "id" UUID NOT NULL,
    "name" VARCHAR(60) NOT NULL,
    "base_cents" INTEGER NOT NULL,
    "per_kg_cents" INTEGER NOT NULL,
    "variant_id" UUID NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "oven_fee_rule_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "oven_fee_rule_amounts_check" CHECK ("base_cents" >= 0 AND "per_kg_cents" >= 0)
);

-- CreateTable
CREATE TABLE "oven_ticket" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "tag" VARCHAR(10) NOT NULL,
    "customer_name" VARCHAR(120) NOT NULL,
    "phone" VARCHAR(20),
    "description" VARCHAR(200) NOT NULL,
    "rule_id" UUID NOT NULL,
    "weight_grams" INTEGER NOT NULL,
    "fee_cents" INTEGER NOT NULL,
    "requested_at" TIMESTAMPTZ(6) NOT NULL,
    "status" "OvenStatus" NOT NULL DEFAULT 'RECEIVED',
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "received_by_staff_id" UUID NOT NULL,
    "in_oven_at" TIMESTAMPTZ(6),
    "ready_at" TIMESTAMPTZ(6),
    "picked_up_at" TIMESTAMPTZ(6),
    "fee_sale_id" UUID,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "oven_ticket_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "oven_ticket_weight_check" CHECK ("weight_grams" > 0)
);

-- CreateIndex
CREATE UNIQUE INDEX "oven_fee_rule_variant_id_key" ON "oven_fee_rule"("variant_id");
CREATE INDEX "oven_ticket_branch_id_status_idx" ON "oven_ticket"("branch_id", "status");
CREATE INDEX "oven_ticket_branch_id_requested_at_idx" ON "oven_ticket"("branch_id", "requested_at");
CREATE UNIQUE INDEX "oven_ticket_fee_sale_id_key" ON "oven_ticket"("fee_sale_id");

-- AddForeignKey
ALTER TABLE "oven_fee_rule" ADD CONSTRAINT "oven_fee_rule_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "oven_ticket" ADD CONSTRAINT "oven_ticket_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "oven_ticket" ADD CONSTRAINT "oven_ticket_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "oven_fee_rule"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "oven_ticket" ADD CONSTRAINT "oven_ticket_fee_sale_id_fkey" FOREIGN KEY ("fee_sale_id") REFERENCES "sale"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- pos_app: rules and tickets change; nothing here is deleted.
GRANT SELECT, INSERT, UPDATE ON TABLE "oven_fee_rule", "oven_ticket" TO pos_app;
