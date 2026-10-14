#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
# Hyprland Screen Shaders & Noctalia Launcher Integration
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_SHADER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/shaders"
HYPR_SCRIPT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"

echo "🌌 Hyprland Screen Shaders Setup"
echo "──────────────────────────────────────────────"

mkdir -p "$HYPR_SHADER_DIR" "$HYPR_SCRIPT_DIR"

# Install all 17 GLSL screen shaders
cp -rf "$SCRIPT_DIR/glsl/"*.glsl "$HYPR_SHADER_DIR/"
echo "✔ Installed 17 GLSL shaders to $HYPR_SHADER_DIR"

# Install shader applicator script
cp -f "$SCRIPT_DIR/scripts/shader-apply.sh" "$HYPR_SCRIPT_DIR/shader-apply.sh"
chmod +x "$HYPR_SCRIPT_DIR/shader-apply.sh"
echo "✔ Installed shader-apply.sh to $HYPR_SCRIPT_DIR"

echo "──────────────────────────────────────────────"
echo "✨ Installation complete! You can switch shaders using:"
echo "   $HYPR_SCRIPT_DIR/shader-apply.sh 04_crt"
echo "   $HYPR_SCRIPT_DIR/shader-apply.sh off"
echo "   Or via Noctalia launcher: type '/shaders' and select a preset."
