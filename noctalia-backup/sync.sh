#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/Desktop/noctalia-backup"
CFG="$HOME/.config/noctalia"
STATE="$HOME/.local/state/noctalia"
NOCTAFILES="$HOME/dev/noctafiles"

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

# 1. Local commit to Desktop backup folder
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1 || true
fi

# 2. Sync to noctafiles monorepo and push to GitHub
if [ -d "$NOCTAFILES" ]; then
  mkdir -p "$NOCTAFILES/noctalia-backup"
  cp "$REPO/config.toml" "$NOCTAFILES/noctalia-backup/config.toml"
  cp "$REPO/settings.toml" "$NOCTAFILES/noctalia-backup/settings.toml"
  cp -r "$REPO/templates/." "$NOCTAFILES/noctalia-backup/templates/"
  cp -r "$REPO/palettes/." "$NOCTAFILES/noctalia-backup/palettes/"
  cp "$REPO/user-templates.toml" "$NOCTAFILES/noctalia-backup/user-templates.toml"
  cp -r "$REPO/scripts/." "$NOCTAFILES/noctalia-backup/scripts/" 2>/dev/null || true
  cp -r "$REPO/assets/." "$NOCTAFILES/noctalia-backup/assets/" 2>/dev/null || true
  cp "$REPO/noctalia-config.toml" "$NOCTAFILES/noctalia-backup/noctalia-config.toml"
  cp "$REPO/sync.sh" "$NOCTAFILES/noctalia-backup/sync.sh"

  cd "$NOCTAFILES"
  if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "Auto backup (noctalia): $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1
    HASH="$(git rev-parse --short HEAD)"
    if git push origin main 2>/dev/null; then
      notify "Backed up to noctafiles ($HASH)"
    else
      notify "Committed $HASH to noctafiles (push skipped)"
    fi
  else
    notify "No changes"
  fi
fi