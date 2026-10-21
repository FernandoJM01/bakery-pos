#!/usr/bin/env bash
set -euo pipefail

JS_FILE="build/web/main.dart.js"
if [ ! -f "$JS_FILE" ]; then
  echo "Web bundle not yet built. Building..."
  flutter build web --release --target lib/main_backoffice.dart
fi

echo "Checking $JS_FILE for forbidden CDN or argon2 web plugins..."

if grep -qi "cdn.jsdelivr.net" "$JS_FILE"; then
  echo "ERROR: Found cdn.jsdelivr.net in $JS_FILE!"
  exit 1
fi

if grep -qi "hash-wasm" "$JS_FILE"; then
  echo "ERROR: Found hash-wasm in $JS_FILE!"
  exit 1
fi

echo "SUCCESS: Web bundle is clean. No CDN imports or argon2 web plugins found."
