-- CreateIndex
CREATE INDEX "auth_session_rotated_token_hashes_idx" ON "auth_session" USING GIN ("rotated_token_hashes");
