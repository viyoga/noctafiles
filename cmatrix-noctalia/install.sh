#!/usr/bin/env bash
# install.sh — Installs the Noctalia template and wrapper for cmatrix
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NOCTALIA_DIR="$CONFIG_HOME/noctalia"
TEMPLATE_DEST="$NOCTALIA_DIR/templates/cmatrix.sh"
CONFIG_FILE="$NOCTALIA_DIR/config.toml"
BIN_DIR="$HOME/.local/bin"

echo "==> Installing cmatrix-noctalia..."

# 1. Verify dependencies
if ! command -v cmatrix >/dev/null 2>&1; then
  echo "Warning: 'cmatrix' is not installed. Please install it (e.g. 'sudo pacman -S cmatrix' or 'yay -S cmatrix-git')." >&2
fi

if ! command -v noctalia >/dev/null 2>&1; then
  echo "Warning: 'noctalia' command not found in PATH." >&2
fi

# 2. Copy template
mkdir -p "$NOCTALIA_DIR/templates" "$BIN_DIR"
cp "$SCRIPT_DIR/templates/cmatrix.sh" "$TEMPLATE_DEST"
echo "  ✓ Template installed to $TEMPLATE_DEST"

# 3. Add to Noctalia config if missing
if [ -f "$CONFIG_FILE" ]; then
  if ! grep -q '\[theme.templates.user.cmatrix\]' "$CONFIG_FILE"; then
    echo "  ==> Adding user template entry to $CONFIG_FILE..."
    cat << 'EOF' >> "$CONFIG_FILE"

[theme.templates.user.cmatrix]
input_path = "$XDG_CONFIG_HOME/noctalia/templates/cmatrix.sh"
output_path = "~/.local/bin/cmatrix-noctalia"
post_hook = "chmod +x ~/.local/bin/cmatrix-noctalia"
EOF
    echo "  ✓ Config updated"
  else
    echo "  ✓ Template entry already present in $CONFIG_FILE"
  fi
fi

# 4. Apply templates if noctalia is active
if command -v noctalia >/dev/null 2>&1; then
  echo "  ==> Rendering wrapper with current Noctalia theme..."
  noctalia msg config-reload 2>/dev/null || true
  noctalia msg templates-apply 2>/dev/null || true
fi

# Fallback copy if not yet generated
if [ ! -f "$BIN_DIR/cmatrix-noctalia" ] && [ -f "$SCRIPT_DIR/bin/cmatrix-noctalia" ]; then
  cp "$SCRIPT_DIR/bin/cmatrix-noctalia" "$BIN_DIR/cmatrix-noctalia"
  chmod +x "$BIN_DIR/cmatrix-noctalia"
fi

echo ""
echo "🎉 cmatrix-noctalia successfully installed!"
echo ""
echo "You can run it directly with:"
echo "    cmatrix-noctalia"
echo ""
echo "Tip: Add an alias to your ~/.zshrc or ~/.config/zsh/aliases.zsh:"
echo "    alias cmatrix='cmatrix-noctalia'"
echo "    alias cm='cmatrix-noctalia'"
