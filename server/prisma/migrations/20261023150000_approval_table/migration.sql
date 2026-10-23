-- CreateTable
CREATE TABLE "approval" (
    "id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "action" VARCHAR(100) NOT NULL,
    "approver_staff_id" UUID NOT NULL,
    "requester_staff_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "approval_token_hash_key" ON "approval"("token_hash");

-- CreateIndex
CREATE INDEX "approval_approver_staff_id_idx" ON "approval"("approver_staff_id");

-- CreateIndex
CREATE INDEX "approval_requester_staff_id_idx" ON "approval"("requester_staff_id");

-- AddForeignKey
ALTER TABLE "approval" ADD CONSTRAINT "approval_approver_staff_id_fkey" FOREIGN KEY ("approver_staff_id") REFERENCES "staff"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval" ADD CONSTRAINT "approval_requester_staff_id_fkey" FOREIGN KEY ("requester_staff_id") REFERENCES "staff"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval" ADD CONSTRAINT "approval_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Grant permissions to pos_app
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "approval" TO pos_app;
