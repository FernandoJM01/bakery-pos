#!/bin/sh
# Nightly compressed pg_dump at BACKUP_AT (local time), plus an archive of
# the product photos with the same time stamp, keeping BACKUP_KEEP_DAYS days.
# Run once by hand with: sh /backup.sh now
set -eu
dump() {
  stamp=$(date +%Y%m%d-%H%M)
  file="/backups/pos-$stamp.dump"
  photos="/backups/photos-$stamp.tar.gz"
  pg_dump --format=custom --compress=9 --file="$file.part"
  mv "$file.part" "$file"
  # Photos after the dump: the server writes the file before the row, so
  # every photo row in the dump has its file in the archive.
  tar -czf "$photos.part" -C /photos .
  mv "$photos.part" "$photos"
  find /backups \( -name 'pos-*.dump' -o -name 'photos-*.tar.gz' \) \
    -mtime +"$BACKUP_KEEP_DAYS" -delete
  echo "backup written: $file and $photos"
}
if [ "${1:-}" = "now" ]; then dump; exit 0; fi
while true; do
  now=$(date +%s)
  next=$(date -d "$(date +%Y-%m-%d) $BACKUP_AT" +%s)
  [ "$next" -le "$now" ] && next=$((next + 86400))
  sleep $((next - now))
  dump || echo "backup FAILED" >&2
done
