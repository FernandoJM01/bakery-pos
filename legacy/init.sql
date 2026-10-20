-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User Roles
CREATE TYPE user_role AS ENUM (
  'GLOBAL_ADMIN',
  'BRANCH_MANAGER',
  'CASHIER',
  'LOCAL_BAKER'
);

-- Event Types for Inventory / POS transactions
CREATE TYPE ledger_event_type AS ENUM (
  'BAKE_BATCH_PRODUCED',
  'SALE_COMPLETED',
  'REFUND_RETURNED',
  'WASTE_DISCARDED',
  'TRANSFER_IN',
  'TRANSFER_OUT',
  'AUDIT_ADJUSTMENT'
);

-- Branches
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(32) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  address TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Users & Authentication
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  username VARCHAR(64) NOT NULL UNIQUE,
  pin_hash VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(120) NOT NULL,
  role user_role NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Products Catalog
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sku VARCHAR(64) NOT NULL UNIQUE,
  barcode VARCHAR(64),
  name VARCHAR(120) NOT NULL,
  category VARCHAR(64) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'PIECE',
  price_cents INT NOT NULL CHECK (price_cents >= 0),
  cost_cents INT NOT NULL CHECK (cost_cents >= 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Append-Only Event Ledger
CREATE TABLE inventory_ledger (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_event_id VARCHAR(64) NOT NULL,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
  terminal_id VARCHAR(64) NOT NULL,
  event_type ledger_event_type NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity_change INT NOT NULL,
  batch_number VARCHAR(64),
  reference_id VARCHAR(64),
  metadata JSONB DEFAULT '{}'::jsonb,
  client_timestamp TIMESTAMPTZ NOT NULL,
  server_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_branch_client_event UNIQUE (branch_id, client_event_id)
);

-- Materialized Balances Table
CREATE TABLE inventory_balances (
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  current_stock INT NOT NULL DEFAULT 0,
  last_event_id UUID REFERENCES inventory_ledger(id),
  last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (branch_id, product_id)
);

-- Sales / Orders Summary
CREATE TABLE sales_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_order_id VARCHAR(64) NOT NULL,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
  cashier_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  terminal_id VARCHAR(64) NOT NULL,
  total_cents INT NOT NULL CHECK (total_cents >= 0),
  payment_method VARCHAR(32) NOT NULL DEFAULT 'CASH',
  cash_tendered_cents INT,
  change_due_cents INT,
  client_created_at TIMESTAMPTZ NOT NULL,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_branch_client_order UNIQUE (branch_id, client_order_id)
);

CREATE INDEX idx_ledger_sync ON inventory_ledger (branch_id, server_timestamp);
CREATE INDEX idx_ledger_product ON inventory_ledger (product_id, branch_id);
CREATE INDEX idx_balances_stock ON inventory_balances (branch_id, current_stock);

-- SEED INITIAL DATA
-- 1 Branch
INSERT INTO branches (id, code, name, address)
VALUES ('a0000000-0000-0000-0000-000000000001', 'BR-01', 'Downtown Bakery Oven #1', '123 Bakery Lane');

-- Users (PIN '1234' has SHA-256 hash '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4')
INSERT INTO users (id, branch_id, username, pin_hash, full_name, role)
VALUES 
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'cashier1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Maria Gonzalez', 'CASHIER'),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'baker1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Marco Rossi', 'LOCAL_BAKER'),
  ('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'manager1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Elena Rostova', 'BRANCH_MANAGER'),
  ('b0000000-0000-0000-0000-000000000004', NULL, 'admin', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Admin User', 'GLOBAL_ADMIN');

-- Products
INSERT INTO products (id, sku, barcode, name, category, unit, price_cents, cost_cents)
VALUES
  ('c0000000-0000-0000-0000-000000000001', 'BREAD-SOUR', '840001001', 'Sourdough Loaf', 'Breads', 'PIECE', 650, 200),
  ('c0000000-0000-0000-0000-000000000002', 'BREAD-BAGU', '840001002', 'Artisan Baguette', 'Breads', 'PIECE', 400, 120),
  ('c0000000-0000-0000-0000-000000000003', 'PAST-CROI', '840001003', 'Butter Croissant', 'Pastries', 'PIECE', 325, 90),
  ('c0000000-0000-0000-0000-000000000004', 'PAST-CHOC', '840001004', 'Pain au Chocolat', 'Pastries', 'PIECE', 375, 110),
  ('c0000000-0000-0000-0000-000000000005', 'PAST-CINN', '840001005', 'Cinnamon Roll', 'Pastries', 'PIECE', 400, 100),
  ('c0000000-0000-0000-0000-000000000006', 'CAKE-ECLR', '840001006', 'Chocolate Eclair', 'Cakes', 'PIECE', 450, 150),
  ('c0000000-0000-0000-0000-000000000007', 'BEV-COFF', '840001007', 'Flat White Coffee', 'Beverages', 'PIECE', 500, 80);

-- Initial Balances for Branch 1
INSERT INTO inventory_balances (branch_id, product_id, current_stock)
VALUES
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 24),
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 15),
  ('a0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', 18),
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000004', 12),
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000005', 8),
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000006', 10),
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000007', 50);
