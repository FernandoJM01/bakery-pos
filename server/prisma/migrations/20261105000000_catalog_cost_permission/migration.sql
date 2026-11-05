-- Branch managers enter product costs (decided by Fernando, 4 Nov 2026).
INSERT INTO "permission" ("key", "description") VALUES
    ('catalog.cost', 'Set the unit cost of products')
ON CONFLICT ("key") DO NOTHING;

INSERT INTO "role_permission" ("role", "permission_key") VALUES
    ('OWNER', 'catalog.cost'),
    ('BRANCH_MANAGER', 'catalog.cost')
ON CONFLICT DO NOTHING;
