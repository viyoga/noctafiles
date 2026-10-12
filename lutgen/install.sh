#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
# Lutgen-Zsh Noctalia Wallpaper Recolor Installer
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/lutgen"
BIN_DIR="${HOME}/.local/bin"
ZSHRC="${HOME}/.zshrc"

echo "🎨 Lutgen-Zsh Setup"
echo "──────────────────────────────────────────────"

mkdir -p "$TARGET_CONFIG" "$BIN_DIR"

# Install palettes
cp -rf "$SCRIPT_DIR/palettes/"* "$TARGET_CONFIG/"
echo "✔ Installed 40 custom palettes to $TARGET_CONFIG"

# Install preview helper
chmod +x "$SCRIPT_DIR/bin/lutgen-preview"
cp -f "$SCRIPT_DIR/bin/lutgen-preview" "$BIN_DIR/lutgen-preview"
echo "✔ Installed preview binary to $BIN_DIR/lutgen-preview"

# Check if sourced in ~/.zshrc or ~/.config/zsh
ZSH_CUSTOM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [ -d "$ZSH_CUSTOM_DIR" ]; then
  cp -f "$SCRIPT_DIR/lutgen.zsh" "$ZSH_CUSTOM_DIR/lutgen.zsh"
  echo "✔ Copied lutgen.zsh to $ZSH_CUSTOM_DIR/lutgen.zsh"
else
  mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/lutgen"
  cp -f "$SCRIPT_DIR/lutgen.zsh" "${XDG_CONFIG_HOME:-$HOME/.config}/lutgen/lutgen.zsh"
  if ! grep -q "lutgen.zsh" "$ZSHRC" 2>/dev/null; then
    echo "source \"\${XDG_CONFIG_HOME:-\$HOME/.config}/lutgen/lutgen.zsh\"" >> "$ZSHRC"
    echo "✔ Added source line to ~/.zshrc"
  fi
fi

echo "──────────────────────────────────────────────"
echo "✨ Installation complete! Reload Zsh (exec zsh) and type 'lutgen'"
