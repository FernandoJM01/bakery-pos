#!/bin/sh
# Restores the newest dump into a scratch database and compares row counts
# with the live database. Live data never changes. Run weekly.
set -eu
cd "$(dirname "$0")"
dir="${BACKUP_DIR:-./backups}"
dump=$(ls -1t "$dir"/pos-*.dump 2>/dev/null | head -n 1)
[ -n "$dump" ] || { echo "no dumps in $dir" >&2; exit 1; }
echo "testing $dump"

psql() { docker compose exec -T db psql -U pos -v ON_ERROR_STOP=1 -qtA "$@"; }
psql -d postgres -c "DROP DATABASE IF EXISTS pos_restore_test"
psql -d postgres -c "CREATE DATABASE pos_restore_test"
docker compose exec -T db pg_restore -U pos -d pos_restore_test --no-owner \
  --exit-on-error < "$dump"

counts="SELECT 'branch', count(*) FROM branch UNION ALL
  SELECT 'staff', count(*) FROM staff UNION ALL
  SELECT 'device', count(*) FROM device UNION ALL
  SELECT 'audit_log', count(*) FROM audit_log ORDER BY 1"
restored=$(psql -d pos_restore_test -c "$counts")
live=$(psql -d pos -c "$counts")
psql -d postgres -c "DROP DATABASE pos_restore_test"

echo "table|restored"; echo "$restored"
echo "$restored" | grep -q '^staff|[1-9]' || { echo "FAIL: no staff in dump" >&2; exit 1; }
# Live rows can only have grown since the dump was taken.
echo "$restored" | while IFS='|' read -r t n; do
  l=$(echo "$live" | grep "^$t|" | cut -d'|' -f2)
  [ "$n" -le "$l" ] || { echo "FAIL: $t restored $n > live $l" >&2; exit 1; }
done
echo "OK: restore test passed"
