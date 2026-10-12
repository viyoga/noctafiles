#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
# Firefox / LibreWolf Noctalia Chrome Installer
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOCTALIA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/config.toml"
NOCTALIA_TEMPLATES="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/templates"

echo "🦊 Noctalia Firefox / LibreWolf Setup"
echo "──────────────────────────────────────────────"

# 1. Detect target browser profiles
TARGET_CHROME=""
if [ -d "$HOME/.config/librewolf/librewolf" ]; then
  PROFILE=$(find "$HOME/.config/librewolf/librewolf" -maxdepth 1 -name "*.default*" | head -n 1)
  if [ -n "$PROFILE" ]; then
    TARGET_CHROME="$PROFILE/chrome"
    echo "✔ Found LibreWolf profile: $PROFILE"
  fi
elif [ -d "$HOME/.mozilla/firefox" ]; then
  PROFILE=$(find "$HOME/.mozilla/firefox" -maxdepth 1 -name "*.default-release" -o -name "*.default" | head -n 1)
  if [ -n "$PROFILE" ]; then
    TARGET_CHROME="$PROFILE/chrome"
    echo "✔ Found Firefox profile: $PROFILE"
  fi
fi

if [ -z "$TARGET_CHROME" ]; then
  echo "⚠️  No default profile directory auto-detected."
  read -rp "Please enter your profile directory path: " USER_PROFILE
  TARGET_CHROME="$USER_PROFILE/chrome"
fi

mkdir -p "$TARGET_CHROME"
echo "✔ Target chrome folder: $TARGET_CHROME"

# 2. Copy/update CSS stylesheets
cp -f "$SCRIPT_DIR/chrome/userChrome.css" "$TARGET_CHROME/userChrome.css"
cp -f "$SCRIPT_DIR/chrome/userContent.css" "$TARGET_CHROME/userContent.css"
cp -f "$SCRIPT_DIR/chrome/noctalia-colors.css" "$TARGET_CHROME/noctalia-colors.css"
echo "✔ Installed userChrome.css, userContent.css, and initial noctalia-colors.css"

# 3. Install Noctalia template
if [ -d "$NOCTALIA_TEMPLATES" ]; then
  cp -f "$SCRIPT_DIR/templates/librewolf.css" "$NOCTALIA_TEMPLATES/librewolf.css"
  echo "✔ Installed Noctalia template: $NOCTALIA_TEMPLATES/librewolf.css"
fi

# 4. Check if template is registered in Noctalia config
if [ -f "$NOCTALIA_CONFIG" ]; then
  if grep -q "\[theme.templates.user.librewolf\]" "$NOCTALIA_CONFIG"; then
    echo "✔ Noctalia template already declared in config.toml"
  else
    echo "ℹ Adding [theme.templates.user.librewolf] declaration to $NOCTALIA_CONFIG..."
    cat <<EOF >> "$NOCTALIA_CONFIG"

[theme.templates.user.librewolf]
input_path = "\$XDG_CONFIG_HOME/noctalia/templates/librewolf.css"
output_path = "$TARGET_CHROME/noctalia-colors.css"
pre_hook = "mkdir -p $TARGET_CHROME"
EOF
    echo "✔ Added template declaration to config.toml"
  fi

  if command -v noctalia >/dev/null 2>&1; then
    echo "✔ Applying Noctalia templates..."
    noctalia msg config-reload 2>/dev/null || true
    noctalia msg templates-apply 2>/dev/null || true
  fi
fi
# 5. Install Sonder Startpage WebExtension
EXT_DIR="$PROFILE/extensions"
mkdir -p "$EXT_DIR"
if [ -f "$SCRIPT_DIR/extension/sonder.xpi" ]; then
  cp -f "$SCRIPT_DIR/extension/sonder.xpi" "$EXT_DIR/sonder-newtab@local.ext.xpi"
  echo "✔ Installed Sonder extension to $EXT_DIR/sonder-newtab@local.ext.xpi"
fi

# 6. Install live stats & theme hot-reload daemon
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$BIN_DIR" "$SYSTEMD_USER_DIR"

if [ -f "$SCRIPT_DIR/daemon/sonder-stats-server.py" ]; then
  cp -f "$SCRIPT_DIR/daemon/sonder-stats-server.py" "$BIN_DIR/sonder-stats-server.py"
  chmod +x "$BIN_DIR/sonder-stats-server.py"
  echo "✔ Installed daemon to $BIN_DIR/sonder-stats-server.py"
fi

if [ -f "$SCRIPT_DIR/daemon/sonder-stats.service" ]; then
  cp -f "$SCRIPT_DIR/daemon/sonder-stats.service" "$SYSTEMD_USER_DIR/sonder-stats.service"
  echo "✔ Installed systemd service to $SYSTEMD_USER_DIR/sonder-stats.service"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now sonder-stats.service 2>/dev/null || true
    echo "✔ Enabled and started sonder-stats.service on http://127.0.0.1:9191"
  fi
fi

# 7. Install Noctalia Startpage template
if [ -d "$NOCTALIA_TEMPLATES" ] && [ -f "$SCRIPT_DIR/templates/sonder-newtab.css" ]; then
  cp -f "$SCRIPT_DIR/templates/sonder-newtab.css" "$NOCTALIA_TEMPLATES/sonder-newtab.css"
  echo "✔ Installed Noctalia startpage template: $NOCTALIA_TEMPLATES/sonder-newtab.css"
fi

if [ -f "$NOCTALIA_CONFIG" ]; then
  if grep -q "\[theme.templates.user.sonder-newtab\]" "$NOCTALIA_CONFIG"; then
    echo "✔ Noctalia sonder-newtab template already declared in config.toml"
  else
    SONDER_COLORS="$HOME/.config/sonder/noctalia-colors.css"
    cat <<EOF >> "$NOCTALIA_CONFIG"

[theme.templates.user.sonder-newtab]
input_path = "\$XDG_CONFIG_HOME/noctalia/templates/sonder-newtab.css"
output_path = "$SONDER_COLORS"
pre_hook = "mkdir -p \$HOME/.config/sonder"
EOF
    echo "✔ Added sonder-newtab template declaration to config.toml"
  fi

  if command -v noctalia >/dev/null 2>&1; then
    noctalia msg config-reload 2>/dev/null || true
    noctalia msg templates-apply 2>/dev/null || true
  fi
fi

echo "──────────────────────────────────────────────"
echo "✨ Installation complete!"
echo "⚠️  Ensure 'toolkit.legacyUserProfileCustomizations.stylesheets = true' in about:config"
echo "Restart your browser to enjoy the custom Noctalia rice and live startpage!"
