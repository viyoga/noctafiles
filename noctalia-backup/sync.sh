#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/Desktop/noctalia-backup"
CFG="$HOME/.config/noctalia"
STATE="$HOME/.local/state/noctalia"

cd "$REPO"

cp "$CFG/config.toml" "$REPO/config.toml"
cp "$STATE/settings.toml" "$REPO/settings.toml"
cp -r "$CFG/templates/." "$REPO/templates/"
cp -r "$CFG/palettes/." "$REPO/palettes/"
cp "$CFG/user-templates.toml" "$REPO/user-templates.toml"
mkdir -p "$REPO/scripts" "$REPO/assets"
cp -r "$CFG/scripts/." "$REPO/scripts/" 2>/dev/null || true
cp -r "$CFG/assets/." "$REPO/assets/" 2>/dev/null || true
noctalia config export > "$REPO/noctalia-config.toml"

notify() {
  noctalia msg notification-show "Noctalia backup" "$1" >/dev/null 2>&1 || true
}

if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1
  HASH="$(git rev-parse --short HEAD)"
  if git push origin main 2>/dev/null; then
    notify "Backed up & pushed commit $HASH"
  else
    notify "Committed $HASH but push skipped (offline?)"
  fi
else
  notify "No changes"
fi