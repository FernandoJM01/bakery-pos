#!/bin/sh
# Restores a dump into the live database, and the product photos archived
# with it (photos-<same stamp>.tar.gz). Stops the server first.
# Usage: ./restore.sh backups/pos-20261025-0230.dump
set -eu
cd "$(dirname "$0")"
dump="${1:?usage: ./restore.sh <file.dump>}"
[ -f "$dump" ] || { echo "not found: $dump" >&2; exit 1; }
photos="$(dirname "$dump")/photos-$(basename "$dump" .dump | sed 's/^pos-//').tar.gz"
[ -f "$photos" ] || { echo "not found: $photos (photos for this dump)" >&2; exit 1; }
printf 'This REPLACES all current data with %s. Type RESTAURAR to continue: ' "$dump"
read -r answer
[ "$answer" = "RESTAURAR" ] || { echo "cancelled"; exit 1; }

docker compose stop server web
docker compose exec -T db pg_restore -U pos -d pos --clean --if-exists \
  --single-transaction --no-owner < "$dump"
docker compose run --rm --no-deps -T --entrypoint sh server \
  -c 'find /data/photos -mindepth 1 -delete && tar -xzf - -C /data/photos' \
  < "$photos"
docker compose run --rm migrate
docker compose start server web
echo "restore finished; check http://127.0.0.1:8080/health"
