#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_XPI="${1:-sonder.xpi}"

rm -f "$OUTPUT_XPI"
zip -q -r "$OUTPUT_XPI" \
  manifest.json \
  newtab.html \
  css/noctalia-colors.css \
  css/styles.css \
  js/newtab.js \
  js/background.js \
  icons/icon16.png \
  icons/icon32.png \
  icons/icon48.png \
  icons/icon128.png \
  icons/logo.png \
  icons/logo.svg

echo "Successfully built: $SCRIPT_DIR/$OUTPUT_XPI"
