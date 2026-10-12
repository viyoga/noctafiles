#!/usr/bin/env bash
# Reseed web-launcher icons that no favicon provider can supply.
# The plugin caches icons at <pluginDir>/cache/<domain>_<provider>.png and
# wipes that dir on every plugin update — manual drops there are temporary.
# This script copies canonical icons from ~/.config/noctalia/assets/ back
# into the cache (all 3 provider suffixes, only when missing) so localhost
# Syncthing + fmhy always have logos. Safe to run any time (idempotent).
# Wired into: [hooks] colors_changed + hypr autostart exec.
set -u
ASSETS="$HOME/.config/noctalia/assets/weblauncher-icons"
CACHE="$HOME/.local/state/noctalia/plugins/materialized/community/web-launcher/cache"
[ -d "$CACHE" ] || mkdir -p "$CACHE"
seed() { # $1 = asset file, $2 = cache-safe domain
  local src="$ASSETS/$1" base="$2" p dst
  [ -f "$src" ] || return 0
  for p in google duckduckgo direct; do
    dst="$CACHE/${base}_${p}.png"
    [ -f "$dst" ] || cp "$src" "$dst"
  done
}
seed "127.0.0.1_8384.png" "127.0.0.1_8384"
seed "fmhy.net.png" "fmhy.net"
