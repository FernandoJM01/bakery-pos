-- Back office password lockout (brief 5.3: 10 wrong passwords in 15 minutes
-- lock for 15 minutes), kept apart from the till PIN counters.
ALTER TABLE "staff" ADD COLUMN "failed_password_attempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN "password_failure_window_start" TIMESTAMPTZ(6),
ADD COLUMN "password_locked_until" TIMESTAMPTZ(6);
