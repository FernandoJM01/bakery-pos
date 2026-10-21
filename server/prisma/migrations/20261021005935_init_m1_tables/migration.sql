-- CreateEnum
CREATE TYPE "role" AS ENUM ('OWNER', 'BRANCH_MANAGER', 'CASHIER', 'BAKER');

-- CreateEnum
CREATE TYPE "device_type" AS ENUM ('TILL', 'PRODUCTION');

-- CreateEnum
CREATE TYPE "device_status" AS ENUM ('PENDING', 'ACTIVE', 'REVOKED');

-- CreateTable
CREATE TABLE "branch" (
    "id" UUID NOT NULL,
    "code" VARCHAR(10) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "address" VARCHAR(300),
    "timezone" VARCHAR(50) NOT NULL DEFAULT 'America/Mexico_City',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "branch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff" (
    "id" UUID NOT NULL,
    "full_name" VARCHAR(120) NOT NULL,
    "display_name" VARCHAR(30) NOT NULL,
    "role" "role" NOT NULL,
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    "pin_hash" VARCHAR(255) NOT NULL,
    "offline_pin_verifier" VARCHAR(255) NOT NULL,
    "pin_updated_at" TIMESTAMPTZ(6) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "failed_pin_attempts" INTEGER NOT NULL DEFAULT 0,
    "locked_until" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "staff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_branch" (
    "staff_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,

    CONSTRAINT "staff_branch_pkey" PRIMARY KEY ("staff_id","branch_id")
);

-- CreateTable
CREATE TABLE "permission" (
    "key" VARCHAR(100) NOT NULL,
    "description" VARCHAR(255) NOT NULL,

    CONSTRAINT "permission_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "role_permission" (
    "role" "role" NOT NULL,
    "permission_key" VARCHAR(100) NOT NULL,

    CONSTRAINT "role_permission_pkey" PRIMARY KEY ("role","permission_key")
);

-- CreateTable
CREATE TABLE "device" (
    "id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "name" VARCHAR(40) NOT NULL,
    "type" "device_type" NOT NULL,
    "status" "device_status" NOT NULL DEFAULT 'PENDING',
    "enrollment_code_hash" VARCHAR(255),
    "enrollment_expires_at" TIMESTAMPTZ(6),
    "token_hash" VARCHAR(255),
    "last_seen_at" TIMESTAMPTZ(6),
    "app_version" VARCHAR(40),
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revoked_at" TIMESTAMPTZ(6),

    CONSTRAINT "device_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_session" (
    "id" UUID NOT NULL,
    "staff_id" UUID NOT NULL,
    "device_id" UUID,
    "refresh_token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log" (
    "id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "branch_id" UUID,
    "device_id" UUID,
    "actor_staff_id" UUID,
    "approver_staff_id" UUID,
    "action" VARCHAR(100) NOT NULL,
    "entity_type" VARCHAR(100),
    "entity_id" VARCHAR(100),
    "data" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "branch_code_key" ON "branch"("code");

-- CreateIndex
CREATE UNIQUE INDEX "staff_email_key" ON "staff"("email");

-- AddForeignKey
ALTER TABLE "staff_branch" ADD CONSTRAINT "staff_branch_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_branch" ADD CONSTRAINT "staff_branch_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permission" ADD CONSTRAINT "role_permission_permission_key_fkey" FOREIGN KEY ("permission_key") REFERENCES "permission"("key") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device" ADD CONSTRAINT "device_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device" ADD CONSTRAINT "device_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_session" ADD CONSTRAINT "auth_session_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_session" ADD CONSTRAINT "auth_session_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "device"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_actor_staff_id_fkey" FOREIGN KEY ("actor_staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_approver_staff_id_fkey" FOREIGN KEY ("approver_staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- Application role with insert-only permissions on audit_log (A14)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pos_app') THEN
        -- No password here: migrations also run in production. Each
        -- environment enables login out of band (see server/README.md).
        CREATE ROLE pos_app NOLOGIN;
    END IF;
END
$$;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO pos_app;

-- Grant CRUD on all tables to application role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO pos_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pos_app;

-- Grant sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO pos_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO pos_app;

-- Revoke UPDATE, DELETE, TRUNCATE on audit_log so it is insert-only (A14)
REVOKE UPDATE, DELETE, TRUNCATE ON TABLE "audit_log" FROM pos_app;

