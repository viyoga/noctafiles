#!/bin/sh
# Noctalia-generated cmatrix wrapper — DO NOT EDIT.
# Edit the template instead: ~/.config/noctalia/templates/cmatrix.sh
# Re-rendered on every palette change via `noctalia msg templates-apply`.
#
# Background: {{ colors.terminal_background.default.hex }} (provided by the kitty
#   template — cmatrix uses the terminal default bg via use_default_colors).
# Characters: {{ colors.primary.default.hex }} (primary) / {{ colors.primary.default.hex | lighten 12 }} (bright head).
# cmatrix only understands 8 fixed curses colors, so this wrapper remaps the
# terminal's green slots (color 2 / 10, i.e. cmatrix default `-C green`) to the
# current primary via Kitty OSC 4 sequences, then restores them on exit.

ORIG_GREEN="{{ colors.terminal_normal_green.default.hex }}"
ORIG_BRIGHT_GREEN="{{ colors.terminal_bright_green.default.hex }}"
THEMED_GREEN="{{ colors.primary.default.hex }}"
THEMED_BRIGHT="{{ colors.primary.default.hex | lighten 12 }}"

restore() {
  printf '\033]4;2;%s\033\\' "$ORIG_GREEN" 2>/dev/null
  printf '\033]4;10;%s\033\\' "$ORIG_BRIGHT_GREEN" 2>/dev/null
}
trap restore EXIT INT TERM HUP

printf '\033]4;2;%s\033\\' "$THEMED_GREEN" 2>/dev/null
printf '\033]4;10;%s\033\\' "$THEMED_BRIGHT" 2>/dev/null

/usr/bin/cmatrix "$@"
STATUS=$?

restore
exit $STATUS
