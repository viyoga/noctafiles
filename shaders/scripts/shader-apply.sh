#!/usr/bin/env bash
# Apply a Hyprland screen shader from ~/.config/hypr/shaders/
# Usage: shader-apply.sh <name|off>
#   e.g. shader-apply.sh 04_crt
#        shader-apply.sh off
set -euo pipefail

SHADER_DIR="$HOME/.config/hypr/shaders"
arg="${1:-off}"

if [[ "$arg" == "off" || -z "$arg" ]]; then
  hyprctl eval 'hl.config({decoration={screen_shader=""}})' >/dev/null
  notify-send "Shader" "Off" 2>/dev/null || true
  exit 0
fi

# allow bare name or with .glsl
name="$arg"
[[ "$name" == *.glsl ]] || name="$name.glsl"
path="$SHADER_DIR/$name"

if [[ ! -f "$path" ]]; then
  notify-send "Shader" "Not found: $arg" 2>/dev/null || true
  echo "Shader not found: $path" >&2
  exit 1
fi

# Use Lua API (Hyprland 0.56.x) — matches existing /hypr dmenu entry style
hyprctl eval "hl.config({decoration={screen_shader='$path'}})" >/dev/null
notify-send "Shader" "${name%.glsl}" 2>/dev/null || true
