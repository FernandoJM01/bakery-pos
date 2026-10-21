#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTRACT_PATH="${APP_DIR}/../contracts/openapi.yaml"
TEMP_SPEC="${APP_DIR}/.temp_openapi_normalized.yaml"

cd "${APP_DIR}"

echo "==> Normalizing OpenAPI schema for swagger_parser..."
node -e "
const fs = require('fs');
const YAML = require('${APP_DIR}/../server/node_modules/yaml');
const spec = YAML.parse(fs.readFileSync('${CONTRACT_PATH}', 'utf8'));

for (const [p, item] of Object.entries(spec.paths || {})) {
  if (item.parameters) {
    const params = item.parameters;
    delete item.parameters;
    for (const m of ['get', 'post', 'put', 'patch', 'delete']) {
      if (item[m]) {
        item[m].parameters = [...(item[m].parameters || []), ...params];
      }
    }
  }
}

fs.writeFileSync('${TEMP_SPEC}', YAML.stringify(spec));
"

echo "==> Running swagger_parser..."
dart run swagger_parser -f swagger_parser.yaml --schema_path "${TEMP_SPEC}"

rm -f "${TEMP_SPEC}"

echo "==> Running build_runner for generated serializers..."
dart run build_runner build --delete-conflicting-outputs

echo "==> API client generated successfully."
