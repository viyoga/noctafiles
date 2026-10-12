#!/usr/bin/env bash
set -euo pipefail
file="${XDG_CONFIG_HOME:-$HOME/.config}/prettyzap/colors.toml"
# Enforce permanent font - always set to Iosevka NF (fixes Roboto fallback)
if grep -q '^font_family' "$file"; then
    sed -i 's/^font_family.*/font_family = "Iosevka NF"/' "$file"
else
    printf 'font_family = "Iosevka NF"\n' >> "$file"
fi
# Also ensure file ends with newline for parser
tail -c1 "$file" | read -r _ || echo >> "$file"