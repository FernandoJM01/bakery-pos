#!/bin/sh
# Applies migrations as the admin role, then lets pos_app log in with
# POS_APP_PASSWORD. The init migration already creates pos_app (NOLOGIN) and
# its grants, so on a fresh database this is all the setup it needs.
set -eu
: "${MIGRATION_DATABASE_URL:?MIGRATION_DATABASE_URL is required}"
: "${POS_APP_PASSWORD:?POS_APP_PASSWORD is required}"
case "$POS_APP_PASSWORD" in
  *[!A-Za-z0-9_-]*)
    echo "POS_APP_PASSWORD may only contain letters, digits, '_' and '-'" >&2
    exit 1 ;;
esac

DATABASE_URL="$MIGRATION_DATABASE_URL" npx prisma migrate deploy
echo "ALTER ROLE pos_app WITH LOGIN PASSWORD '$POS_APP_PASSWORD';" |
  npx prisma db execute --stdin --url "$MIGRATION_DATABASE_URL"
echo "pos_app login enabled"
