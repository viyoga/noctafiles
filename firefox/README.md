# Firefox / LibreWolf Noctalia Rice 🦊🎨

> Minimalist 0ms desktop palette-synchronized rice for Firefox and LibreWolf with pure 0px square corners, centered URL bar, and elevated Sidebery integration.

---

## ✨ Features

- **Dynamic Noctalia Theming:**
  - Synchronizes with active Noctalia desktop palettes (dark/light/custom) via native CSS variables (`noctalia-colors.css`).
  - True 0ms cold boot: no flashing, no webextension startup lag.
- **Universal 0px Square Corners:**
  - Absolute rectangular minimalism across the URL bar, dropdowns, popup menus, vertical tabs, toolbar buttons, and dialogue windows.
- **Centered URL Bar (720px):**
  - Truly centered across the window width (`calc(50% - 360px)`), immune to Megabar breakout shift or toolbar expansion.
  - Idle search placeholder text is neatly centered.
  - Aligned autocomplete popup results with 1:1 pixel precision.
- **Elevated Sidebery Integration:**
  - Pulls the `#sidebar-box` up by 36px to dock directly into the empty top-left navbar space.
  - Container icons and settings button sit flush on the top toolbar level, allowing tabs to start directly from the content base.
- **Clean UI Strip:**
  - Hides back/forward buttons, bookmark star, native horizontal tabs (`#TabsToolbar`), and the native sidebar header.

---

## 📁 Structure

```text
firefox/
├── chrome/
│   ├── userChrome.css       # Complete UI stylesheet
│   ├── userContent.css      # Newtab, startpage & internal page stylesheet
│   └── noctalia-colors.css  # Rendered palette variables (auto-updated by Noctalia)
├── templates/
│   └── librewolf.css        # Noctalia template source for live palette rendering
└── install.sh               # Automated profile locator and installer
```

---

## 🚀 Quick Setup

### 1. Prerequisites (`about:config`)
Open your browser and navigate to `about:config`:
1. Search for `toolkit.legacyUserProfileCustomizations.stylesheets` and toggle to **`true`**.
2. *(Optional for instant extension page styling)*: set `svg.context-properties.content.enabled` to **`true`**.

### 2. Run the Installer
```bash
cd firefox
./install.sh
```

The installer will:
1. Locate your active LibreWolf or Firefox profile `chrome/` directory.
2. Copy `userChrome.css`, `userContent.css`, and `noctalia-colors.css`.
3. Install the Noctalia template into `~/.config/noctalia/templates/librewolf.css`.
4. Register `[theme.templates.user.librewolf]` in `~/.config/noctalia/config.toml` and apply live.

### 3. Restart
Restart your browser to enjoy the new setup!
