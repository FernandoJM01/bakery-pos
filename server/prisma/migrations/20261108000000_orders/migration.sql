-- M6 orders: customers, standing orders and pre-orders, the daily order
-- tickets and the prepaid balance ledger.

-- AlterEnum
ALTER TYPE "PaymentMethod" ADD VALUE 'PREPAID';

-- CreateEnum
CREATE TYPE "OrderKind" AS ENUM ('STANDING', 'ONE_OFF');
CREATE TYPE "OrderStatus" AS ENUM ('ACTIVE', 'PAUSED', 'ENDED');
CREATE TYPE "MissedRule" AS ENUM ('CHARGE', 'NO_CHARGE');
CREATE TYPE "TicketStatus" AS ENUM ('PENDING', 'PICKED_UP', 'MISSED', 'SKIPPED');
CREATE TYPE "PrepaidKind" AS ENUM ('PAYMENT', 'PICKUP', 'MISSED', 'ADJUSTMENT');

-- CreateTable
CREATE TABLE "customer" (
    "id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "phone" VARCHAR(20),
    "rfc" VARCHAR(13),
    "notes" VARCHAR(500),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "customer_order" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "kind" "OrderKind" NOT NULL,
    "weekdays" INTEGER NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "pickup_time" VARCHAR(5) NOT NULL,
    "missed_rule" "MissedRule" NOT NULL DEFAULT 'CHARGE',
    "status" "OrderStatus" NOT NULL DEFAULT 'ACTIVE',
    "paused_from" DATE,
    "paused_until" DATE,
    "note" VARCHAR(500),
    "created_by_staff_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "customer_order_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "customer_order_weekdays_check" CHECK ("weekdays" BETWEEN 0 AND 127)
);

CREATE TABLE "customer_order_line" (
    "order_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "customer_order_line_pkey" PRIMARY KEY ("order_id", "variant_id"),
    CONSTRAINT "customer_order_line_quantity_check" CHECK ("quantity" > 0)
);

CREATE TABLE "order_skip" (
    "order_id" UUID NOT NULL,
    "date" DATE NOT NULL,

    CONSTRAINT "order_skip_pkey" PRIMARY KEY ("order_id", "date")
);

CREATE TABLE "order_ticket" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "due_date" DATE NOT NULL,
    "pickup_time" VARCHAR(5) NOT NULL,
    "status" "TicketStatus" NOT NULL DEFAULT 'PENDING',
    "total_cents" INTEGER NOT NULL,
    "sale_id" UUID,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "order_ticket_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "order_ticket_line" (
    "ticket_id" UUID NOT NULL,
    "line_no" INTEGER NOT NULL,
    "variant_id" UUID NOT NULL,
    "product_name" VARCHAR(120) NOT NULL,
    "variant_name" VARCHAR(120) NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price_cents" INTEGER NOT NULL,
    "iva_rate_id" UUID NOT NULL,
    "iva_bp" INTEGER NOT NULL,
    "ieps_rate_id" UUID,
    "ieps_bp" INTEGER NOT NULL,

    CONSTRAINT "order_ticket_line_pkey" PRIMARY KEY ("ticket_id", "line_no")
);

CREATE TABLE "prepaid_entry" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "kind" "PrepaidKind" NOT NULL,
    "amount_cents" INTEGER NOT NULL,
    "ticket_id" UUID,
    "shift_id" UUID,
    "device_id" UUID,
    "staff_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prepaid_entry_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "sale" ADD COLUMN "order_ticket_id" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "customer_phone_key" ON "customer"("phone");
CREATE INDEX "customer_name_idx" ON "customer"("name");
CREATE INDEX "customer_order_customer_id_idx" ON "customer_order"("customer_id");
CREATE INDEX "customer_order_branch_id_status_idx" ON "customer_order"("branch_id", "status");
CREATE UNIQUE INDEX "order_ticket_order_id_due_date_key" ON "order_ticket"("order_id", "due_date");
CREATE INDEX "order_ticket_branch_id_due_date_idx" ON "order_ticket"("branch_id", "due_date");
CREATE UNIQUE INDEX "order_ticket_sale_id_key" ON "order_ticket"("sale_id");
CREATE INDEX "prepaid_entry_customer_id_idx" ON "prepaid_entry"("customer_id");
CREATE INDEX "prepaid_entry_shift_id_idx" ON "prepaid_entry"("shift_id");
CREATE UNIQUE INDEX "sale_order_ticket_id_key" ON "sale"("order_ticket_id");

-- AddForeignKey
ALTER TABLE "customer_order" ADD CONSTRAINT "customer_order_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "customer_order" ADD CONSTRAINT "customer_order_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "customer_order_line" ADD CONSTRAINT "customer_order_line_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "customer_order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "customer_order_line" ADD CONSTRAINT "customer_order_line_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "order_skip" ADD CONSTRAINT "order_skip_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "customer_order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "order_ticket" ADD CONSTRAINT "order_ticket_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "customer_order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "order_ticket" ADD CONSTRAINT "order_ticket_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "order_ticket_line" ADD CONSTRAINT "order_ticket_line_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "order_ticket"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "prepaid_entry" ADD CONSTRAINT "prepaid_entry_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "prepaid_entry" ADD CONSTRAINT "prepaid_entry_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "order_ticket"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "prepaid_entry" ADD CONSTRAINT "prepaid_entry_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "sale" ADD CONSTRAINT "sale_order_ticket_id_fkey" FOREIGN KEY ("order_ticket_id") REFERENCES "order_ticket"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- pos_app: the balance is a ledger, insert-only. Orders and tickets change;
-- a ticket's lines are rebuilt while it is pending, so they can be deleted.
GRANT SELECT, INSERT, UPDATE ON TABLE "customer", "customer_order", "order_ticket" TO pos_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "customer_order_line", "order_skip", "order_ticket_line" TO pos_app;
GRANT SELECT, INSERT ON TABLE "prepaid_entry" TO pos_app;
