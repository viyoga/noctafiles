#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
# Fastfetch Noctalia Rice Installer
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
BIN_DIR="${HOME}/.local/bin"

echo "⚡ Fastfetch Setup"
echo "──────────────────────────────────────────────"

mkdir -p "$TARGET_DIR" "$BIN_DIR"

# Copy configs and ASCII arts
cp -rf "$SCRIPT_DIR/config.jsonc" "$TARGET_DIR/"
cp -rf "$SCRIPT_DIR/arch" "$TARGET_DIR/"
cp -rf "$SCRIPT_DIR/animals" "$TARGET_DIR/"
cp -rf "$SCRIPT_DIR/geometry" "$TARGET_DIR/"
cp -rf "$SCRIPT_DIR/bin" "$TARGET_DIR/"

# Symlink or copy wrapper script to ~/.local/bin/fastfetch
chmod +x "$SCRIPT_DIR/bin/fastfetch"
ln -sf "$TARGET_DIR/bin/fastfetch" "$BIN_DIR/fastfetch"

echo "✔ Installed fastfetch config & ASCII categories to $TARGET_DIR"
echo "✔ Symlinked wrapper to $BIN_DIR/fastfetch"
echo "──────────────────────────────────────────────"
echo "✨ Installation complete! Run 'fastfetch' or 'fastfetch --list'"
