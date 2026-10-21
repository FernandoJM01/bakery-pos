#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTRACT_PATH="${APP_DIR}/../contracts/openapi.yaml"
TEMP_SPEC="${APP_DIR}/.temp_openapi_normalized.yaml"

cd "${APP_DIR}"

echo "==> Normalizing OpenAPI schema for swagger_parser..."
dart run tool/normalize_openapi.dart "${CONTRACT_PATH}" "${TEMP_SPEC}"

echo "==> Running swagger_parser..."
dart run swagger_parser -f swagger_parser.yaml --schema_path "${TEMP_SPEC}"

rm -f "${TEMP_SPEC}"

echo "==> Running build_runner for generated serializers..."
dart run build_runner build --delete-conflicting-outputs

echo "==> Formatting generated code..."
dart format lib/core/api/generated

echo "==> API client generated successfully."
