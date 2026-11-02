-- M5 stock: dated lots and an insert-only ledger of every stock change.

-- CreateEnum
CREATE TYPE "StockEventKind" AS ENUM ('PRODUCTION', 'SALE', 'REFUND_RETURN', 'WASTE', 'TRANSFER_OUT', 'TRANSFER_IN', 'COUNT_ADJUST');

-- CreateEnum
CREATE TYPE "TransferStatus" AS ENUM ('SENT', 'RECEIVED');

-- AlterTable
ALTER TABLE "product_variant" ADD COLUMN "cost_cents" INTEGER,
ADD COLUMN "units_per_tray" INTEGER;

-- AlterTable
ALTER TABLE "sale_line" ADD COLUMN "day_old" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "full_price_cents" INTEGER;
UPDATE "sale_line" SET "full_price_cents" = "unit_price_cents";
ALTER TABLE "sale_line" ALTER COLUMN "full_price_cents" SET NOT NULL;

-- CreateTable
CREATE TABLE "stock_lot" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "produced_on" DATE NOT NULL,
    "quantity_left" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_lot_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "stock_lot_quantity_check" CHECK ("quantity_left" >= 0)
);

-- CreateTable
CREATE TABLE "stock_event" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "lot_id" UUID,
    "kind" "StockEventKind" NOT NULL,
    "quantity" INTEGER NOT NULL,
    "reference_type" VARCHAR(30),
    "reference_id" UUID,
    "staff_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_waste" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "reason" VARCHAR(20) NOT NULL,
    "staff_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "cost_cents" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_waste_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_transfer" (
    "id" UUID NOT NULL,
    "from_branch_id" UUID NOT NULL,
    "to_branch_id" UUID NOT NULL,
    "status" "TransferStatus" NOT NULL DEFAULT 'SENT',
    "sent_by_staff_id" UUID NOT NULL,
    "sent_at" TIMESTAMPTZ(6) NOT NULL,
    "received_by_staff_id" UUID,
    "received_at" TIMESTAMPTZ(6),
    "flagged" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "stock_transfer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_transfer_line" (
    "transfer_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "produced_on" DATE NOT NULL,
    "quantity_sent" INTEGER NOT NULL,
    "quantity_received" INTEGER,

    CONSTRAINT "stock_transfer_line_pkey" PRIMARY KEY ("transfer_id", "variant_id", "produced_on")
);

-- CreateTable
CREATE TABLE "stock_count" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "staff_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "stock_count_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_count_line" (
    "count_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "expected" INTEGER NOT NULL,
    "counted" INTEGER NOT NULL,

    CONSTRAINT "stock_count_line_pkey" PRIMARY KEY ("count_id", "variant_id")
);

-- CreateTable
CREATE TABLE "stock_check" (
    "id" UUID NOT NULL,
    "checked_at" TIMESTAMPTZ(6) NOT NULL,
    "rows_checked" INTEGER NOT NULL,
    "mismatches" INTEGER NOT NULL,

    CONSTRAINT "stock_check_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "stock_lot_branch_id_variant_id_produced_on_idx" ON "stock_lot"("branch_id", "variant_id", "produced_on");
CREATE INDEX "stock_event_branch_id_variant_id_occurred_at_idx" ON "stock_event"("branch_id", "variant_id", "occurred_at");
CREATE INDEX "stock_event_lot_id_idx" ON "stock_event"("lot_id");
CREATE INDEX "stock_event_reference_id_idx" ON "stock_event"("reference_id");
CREATE INDEX "stock_waste_branch_id_occurred_at_idx" ON "stock_waste"("branch_id", "occurred_at");
CREATE INDEX "stock_waste_occurred_at_idx" ON "stock_waste"("occurred_at");
CREATE INDEX "stock_transfer_sent_at_idx" ON "stock_transfer"("sent_at");

-- AddForeignKey
ALTER TABLE "stock_lot" ADD CONSTRAINT "stock_lot_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_lot" ADD CONSTRAINT "stock_lot_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_event" ADD CONSTRAINT "stock_event_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_event" ADD CONSTRAINT "stock_event_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_event" ADD CONSTRAINT "stock_event_lot_id_fkey" FOREIGN KEY ("lot_id") REFERENCES "stock_lot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_waste" ADD CONSTRAINT "stock_waste_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_waste" ADD CONSTRAINT "stock_waste_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_transfer" ADD CONSTRAINT "stock_transfer_from_branch_id_fkey" FOREIGN KEY ("from_branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_transfer" ADD CONSTRAINT "stock_transfer_to_branch_id_fkey" FOREIGN KEY ("to_branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_transfer_line" ADD CONSTRAINT "stock_transfer_line_transfer_id_fkey" FOREIGN KEY ("transfer_id") REFERENCES "stock_transfer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_transfer_line" ADD CONSTRAINT "stock_transfer_line_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_count" ADD CONSTRAINT "stock_count_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "stock_count_line" ADD CONSTRAINT "stock_count_line_count_id_fkey" FOREIGN KEY ("count_id") REFERENCES "stock_count"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- pos_app: the ledger, waste, counts and checks are append-only. A lot only
-- changes its quantity left, and a transfer changes once, when received.
GRANT SELECT, INSERT ON TABLE "stock_event", "stock_waste", "stock_count", "stock_count_line", "stock_check" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "stock_lot", "stock_transfer", "stock_transfer_line" TO pos_app;
