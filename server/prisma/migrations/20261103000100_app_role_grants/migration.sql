-- The first migration's default privileges gave pos_app UPDATE and DELETE on
-- every later table, so the narrower GRANTs in the catalog, sync and sales
-- migrations took nothing away. This revokes what those migrations meant.

-- From now on a new table must state what pos_app may do.
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE UPDATE, DELETE ON TABLES FROM pos_app;

-- Migration history is never the app's to touch.
REVOKE ALL ON TABLE "_prisma_migrations" FROM pos_app;

-- Sales change only through refund totals and status; refunds are append-only.
REVOKE DELETE ON TABLE "sale", "sale_line" FROM pos_app;
REVOKE UPDATE, DELETE ON TABLE "sale_discount", "sale_voided_line", "payment", "refund", "refund_line" FROM pos_app;

-- A shift changes once, at close; the rest of the cash record is append-only.
REVOKE DELETE ON TABLE "cash_shift" FROM pos_app;
REVOKE UPDATE, DELETE ON TABLE "cash_movement", "cash_count", "cash_shift_note" FROM pos_app;

-- The inbox moves a record to QUARANTINED; neither table loses rows.
REVOKE DELETE ON TABLE "sync_inbox", "sync_quarantine" FROM pos_app;
