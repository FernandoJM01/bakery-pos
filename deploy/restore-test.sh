#!/bin/sh
# Restores the newest dump into a scratch database and compares row counts
# with the live database, then checks every photo in that dump has its file
# in the photo archive taken with it. Live data never changes. Run weekly.
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

photos="$dir/photos-$(basename "$dump" .dump | sed 's/^pos-//').tar.gz"
[ -f "$photos" ] || { echo "FAIL: no photo archive $photos" >&2; exit 1; }
photo_ids=$(psql -d pos_restore_test -c "SELECT id FROM photo")
archived=$(tar -tzf "$photos")

counts="SELECT 'branch', count(*) FROM branch UNION ALL
  SELECT 'staff', count(*) FROM staff UNION ALL
  SELECT 'device', count(*) FROM device UNION ALL
  SELECT 'audit_log', count(*) FROM audit_log UNION ALL
  SELECT 'photo', count(*) FROM photo ORDER BY 1"
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
for id in $photo_ids; do
  echo "$archived" | grep -qx "./$id.webp" ||
    { echo "FAIL: photo $id is not in $photos" >&2; exit 1; }
done
echo "photos in archive: $(echo "$photo_ids" | grep -c . || true)"
echo "OK: restore test passed"
