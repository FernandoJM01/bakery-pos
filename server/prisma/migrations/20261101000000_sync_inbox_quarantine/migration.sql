-- Sync inbox and quarantine (M2 brief 3 and 4.4)

-- CreateEnum
CREATE TYPE "sync_inbox_status" AS ENUM ('APPLIED', 'QUARANTINED');

-- CreateTable
CREATE TABLE "sync_inbox" (
    "record_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "type" VARCHAR(60) NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "status" "sync_inbox_status" NOT NULL,

CONSTRAINT "sync_inbox_pkey" PRIMARY KEY ("record_id")
);

-- CreateTable
CREATE TABLE "sync_quarantine" (
    "record_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "type" VARCHAR(60) NOT NULL,
    "payload" JSONB NOT NULL,
    "error_code" VARCHAR(40) NOT NULL,
    "error_message" VARCHAR(500) NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "resolved_at" TIMESTAMPTZ(6),
    "resolved_by" UUID,
    "resolution_note" VARCHAR(500),

CONSTRAINT "sync_quarantine_pkey" PRIMARY KEY ("record_id")
);

-- CreateIndex
CREATE INDEX "sync_inbox_device_id_idx" ON "sync_inbox"("device_id");

-- CreateIndex
CREATE INDEX "sync_quarantine_received_at_record_id_idx" ON "sync_quarantine"("received_at" DESC, "record_id" DESC);

-- AddForeignKey
ALTER TABLE "sync_inbox" ADD CONSTRAINT "sync_inbox_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_quarantine" ADD CONSTRAINT "sync_quarantine_record_id_fkey" FOREIGN KEY ("record_id") REFERENCES "sync_inbox"("record_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_quarantine" ADD CONSTRAINT "sync_quarantine_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- pos_app: the inbox is append-only; quarantine rows are only updated when
-- the owner resolves them. No deletes on either.
GRANT SELECT, INSERT ON TABLE "sync_inbox" TO pos_app;
GRANT SELECT, INSERT, UPDATE ON TABLE "sync_quarantine" TO pos_app;
