# Bakery POS — Server

Backend API server for Bakery POS (Mexican bakery with 2 branches), built with NestJS 11, TypeScript strict, Node 22, and PostgreSQL 16 via Prisma.

## Database & Roles

The system uses PostgreSQL with role separation to enforce security boundaries (A14):

- **Migration/Admin role (`pos`):** Used during migrations (`prisma migrate dev`, `prisma migrate deploy`) and administrative tasks with full DDL/DML access.
- **Application role (`pos_app`):** The application runtime connects to the database as `pos_app` (in dev: `postgres://pos_app:pos_app_dev_only@127.0.0.1:5432/pos_dev`).
  - Standard CRUD (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) on operational tables (`branch`, `staff`, `staff_branch`, `permission`, `role_permission`, `device`, `auth_session`).
  - **Insert-only on `audit_log` (A14):** `UPDATE`, `DELETE`, and `TRUNCATE` permissions are revoked on `audit_log`. Any attempt to modify or delete audit rows is rejected at the database level (`42501 permission denied`).

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | Yes | PostgreSQL connection string (connect as `pos_app` for app runtime, or `pos` for migrations) |
| `JWT_SECRET` | Yes | Secret for signing staff and device JWTs (min 32 characters in production) |
| `DEVICE_TOKEN_PEPPER` | Yes | Server-side secret pepper for SHA-256 device tokens (min 32 characters in production) |
| `NODE_ENV` | No | `development` (default), `test`, or `production` |
| `PORT` | No | Server listen port (default: `3000`) |

## Setup & Development

```bash
# 1. Start local PostgreSQL
docker compose -f ../docker-compose.dev.yml up -d

# 2. Run migrations
npx prisma migrate deploy

# 3. Seed dev database (branches, permissions, test staff with argon2id PINs)
npm run seed

# 4. Start development server
npm run start:dev
```

## Production Owner Creation

In production (`NODE_ENV=production`), `npm run seed` refuses to run. Use the interactive CLI command instead:

```bash
npm run create-owner
```

This prompts interactively for Full Name, Display Name, Email, Password (min 10 chars), and PIN (4-6 digits). It hashes secrets with argon2id ($m=65536, t=3, p=1$), computes an independent offline PIN verifier, and outputs only the confirmed email and ID (prints nothing secret).

## Running Tests

```bash
# Unit tests & coverage
npm test -- --coverage

# E2E tests (including A14 audit_log insert-only verification)
npm run test:e2e

# Linting
npm run lint -- --max-warnings=0

# TypeScript typecheck
npx tsc --noEmit

# Security audit
npm audit --audit-level=high
```
