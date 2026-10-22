-- AlterTable
ALTER TABLE "auth_session" ADD COLUMN     "rotated_token_hashes" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- CreateIndex
CREATE INDEX "audit_log_occurred_at_id_idx" ON "audit_log"("occurred_at", "id");

-- CreateIndex
CREATE INDEX "audit_log_branch_id_occurred_at_idx" ON "audit_log"("branch_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "auth_session_refresh_token_hash_key" ON "auth_session"("refresh_token_hash");

-- CreateIndex
CREATE INDEX "auth_session_staff_id_idx" ON "auth_session"("staff_id");

-- CreateIndex
CREATE UNIQUE INDEX "device_token_hash_key" ON "device"("token_hash");

-- CreateIndex
CREATE INDEX "staff_branch_branch_id_idx" ON "staff_branch"("branch_id");
