-- M4 cash: shifts, cash movements and counts, filled by the shift.opened,
-- cash.movement and shift.closed sync handlers.

-- CreateEnum
CREATE TYPE "ShiftStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "CashMovementKind" AS ENUM ('IN', 'OUT');

-- CreateEnum
CREATE TYPE "CashCountStage" AS ENUM ('OPEN', 'CLOSE');

-- CreateTable
CREATE TABLE "cash_shift" (
    "id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "status" "ShiftStatus" NOT NULL DEFAULT 'OPEN',
    "z_number" INTEGER,
    "opened_at" TIMESTAMPTZ(6) NOT NULL,
    "opened_by_staff_id" UUID NOT NULL,
    "float_cents" INTEGER NOT NULL,
    "closed_at" TIMESTAMPTZ(6),
    "closed_by_staff_id" UUID,
    "expected_cents" INTEGER,
    "counted_cents" INTEGER,
    "variance_cents" INTEGER,
    "flagged" BOOLEAN NOT NULL DEFAULT false,
    "note" VARCHAR(500),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_shift_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "cash_shift_closed_check" CHECK (
      ("status" = 'OPEN') = ("closed_at" IS NULL)
      AND ("status" = 'OPEN') = ("z_number" IS NULL)
    )
);

-- CreateTable
CREATE TABLE "cash_movement" (
    "id" UUID NOT NULL,
    "shift_id" UUID NOT NULL,
    "kind" "CashMovementKind" NOT NULL,
    "amount_cents" INTEGER NOT NULL,
    "reason" VARCHAR(30) NOT NULL,
    "note" VARCHAR(120),
    "staff_id" UUID NOT NULL,
    "approver_staff_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_movement_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "cash_movement_amount_check" CHECK ("amount_cents" > 0)
);

-- CreateTable
CREATE TABLE "cash_count" (
    "shift_id" UUID NOT NULL,
    "stage" "CashCountStage" NOT NULL,
    "denomination_cents" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "cash_count_pkey" PRIMARY KEY ("shift_id", "stage", "denomination_cents")
);

-- CreateTable
CREATE TABLE "cash_shift_note" (
    "id" UUID NOT NULL,
    "shift_id" UUID NOT NULL,
    "staff_id" UUID NOT NULL,
    "note" VARCHAR(500) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_shift_note_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "refund" ADD COLUMN "shift_id" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "cash_shift_device_id_z_number_key" ON "cash_shift"("device_id", "z_number");

-- One open shift per till (M4 brief section 2). Prisma cannot declare this.
CREATE UNIQUE INDEX "cash_shift_one_open_per_device" ON "cash_shift"("device_id") WHERE "status" = 'OPEN';

-- CreateIndex
CREATE INDEX "cash_shift_branch_id_opened_at_idx" ON "cash_shift"("branch_id", "opened_at");

-- CreateIndex
CREATE INDEX "cash_shift_opened_at_idx" ON "cash_shift"("opened_at");

-- CreateIndex
CREATE INDEX "cash_movement_shift_id_idx" ON "cash_movement"("shift_id");

-- CreateIndex
CREATE INDEX "cash_shift_note_shift_id_idx" ON "cash_shift_note"("shift_id");

-- CreateIndex
CREATE INDEX "sale_shift_id_idx" ON "sale"("shift_id");

-- CreateIndex
CREATE INDEX "refund_shift_id_idx" ON "refund"("shift_id");

-- AddForeignKey
ALTER TABLE "cash_shift" ADD CONSTRAINT "cash_shift_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_shift" ADD CONSTRAINT "cash_shift_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_shift" ADD CONSTRAINT "cash_shift_opened_by_staff_id_fkey" FOREIGN KEY ("opened_by_staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_shift" ADD CONSTRAINT "cash_shift_closed_by_staff_id_fkey" FOREIGN KEY ("closed_by_staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_movement" ADD CONSTRAINT "cash_movement_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_movement" ADD CONSTRAINT "cash_movement_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_count" ADD CONSTRAINT "cash_count_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_shift_note" ADD CONSTRAINT "cash_shift_note_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "cash_shift_note" ADD CONSTRAINT "cash_shift_note_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "sale" ADD CONSTRAINT "sale_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "refund" ADD CONSTRAINT "refund_shift_id_fkey" FOREIGN KEY ("shift_id") REFERENCES "cash_shift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- pos_app: a shift changes once, at close. Movements, counts and notes are
-- append-only, so a count can never be edited (E6). No deletes.
GRANT SELECT, INSERT, UPDATE ON TABLE "cash_shift" TO pos_app;
GRANT SELECT, INSERT ON TABLE "cash_movement", "cash_count", "cash_shift_note" TO pos_app;
