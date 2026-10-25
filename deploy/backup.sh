#!/bin/sh
# Nightly compressed pg_dump at BACKUP_AT (local time), keeping
# BACKUP_KEEP_DAYS days. Run once by hand with: sh /backup.sh now
set -eu
dump() {
  file="/backups/pos-$(date +%Y%m%d-%H%M).dump"
  pg_dump --format=custom --compress=9 --file="$file.part"
  mv "$file.part" "$file"
  find /backups -name 'pos-*.dump' -mtime +"$BACKUP_KEEP_DAYS" -delete
  echo "backup written: $file"
}
if [ "${1:-}" = "now" ]; then dump; exit 0; fi
while true; do
  now=$(date +%s)
  next=$(date -d "$(date +%Y-%m-%d) $BACKUP_AT" +%s)
  [ "$next" -le "$now" ] && next=$((next + 86400))
  sleep $((next - now))
  dump || echo "backup FAILED" >&2
done
