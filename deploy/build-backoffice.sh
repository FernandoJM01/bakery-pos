#!/bin/sh
# Builds the back office (Flutter web) into deploy/backoffice using Docker,
# so the bakery computer needs no Flutter install.
set -eu
cd "$(dirname "$0")/.."
docker run --rm -v "$PWD/app:/app" -w /app ghcr.io/cirruslabs/flutter:stable \
  sh -c "flutter pub get && flutter build web --release --target lib/main_backoffice.dart"
rm -rf deploy/backoffice && cp -r app/build/web deploy/backoffice
echo "back office copied to deploy/backoffice"
