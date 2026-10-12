---
tags:
  - linux
  - noctalia
  - reference
  - backup
---

# Noctalia — Complete Guide & Backup

> Everything an agent needs to understand Noctalia, how it works, where things live,
> and how to restore this system's setup from this repo.
> Written 2026-08-18. System: Arch Linux + Hyprland (Wayland), user `kabir`.
> Repo: `viyoga/noctalia-backup` (PRIVATE).

---

## 1. What is Noctalia?

Noctalia is a **desktop shell** for Linux (currently v5, which replaced the older
Quickshell-based v4). It runs on top of a Wayland compositor — here **Hyprland** — and provides:

- a **bar** (top bar with workspaces, clock, tray, network, volume, battery, control-center, session)
- a **dock**, **launcher**, **control center**, and **desktop widgets**
- **OSD**, **notifications**, **lockscreen** integration
- a **theme engine**: takes a color palette, computes a Material-3 color scheme, and
  re-themes the whole desktop **and third-party apps** via templates
- a **plugin system** (bongocat, wallhaven, screen_recorder, notes, timer, kaomoji, etc.)
- **IPC**: `noctalia msg ...` commands for scripting/keybinds
- a **Settings GUI** (launched via `noctalia msg settings-toggle`) that writes overrides
  to `settings.toml`

It is **not** a compositor. Hyprland stays the compositor; Noctalia draws the shell UI and
manages theming. Both are configured under `~/.config/`.

Current installed version: `noctalia v5.0.0 (v5.0.0-beta.8-138-gb5c1bfaace0c)`
(AUR package `noctalia-git 5.0.0.r5282.gb5c1bfaac-1`). This is the latest as of the backup date.

---

## 2. How configuration works (the two layers)

Noctalia config is split into **two layers** that get merged:

1. **Hand-written config** — `~/.config/noctalia/` (the "curated" layer)
   - Noctalia reads **every `*.toml` file** directly in this folder, sorts them
     alphabetically, merges them. A single `config.toml` is typical.
   - Files here are **never rewritten** by Noctalia.
   - May use an `[include]` table to pull in subdirectories/files:
     ```toml
     [include]
     files = ["widgets/", "bars/top.toml", "~/.config/shared/base.toml"]
     ```
   - `autoload = false` under `[include]` disables automatic loading of the other root files.

2. **GUI-managed overrides** — `~/.local/state/noctalia/settings.toml` (app-owned)
   - Written by the Settings UI, setup flows, and IPC commands that persist.
   - **Loads last, so it wins** over your hand-written config.
   - If it stores a value identical to a lower layer, Noctalia removes the redundant key.
   - If `settings.toml` is a symlink, Noctalia writes through the link target.

**Merge order:** built-in defaults → your `*.toml` files → `settings.toml` overrides.

**Why a GUI change seems "ignored":** check `settings.toml` — it overrides `config.toml`.
**Debug tip:** move `settings.toml` aside and reload to see the pure hand-written config.

---

## 3. File locations (storage owners)

| Owner | Path | Purpose | Backed up? |
|---|---|---|---|
| **Yours** | `~/.config/noctalia/config.toml` | hand-written base config | ✅ |
| **Yours** | `~/.config/noctalia/templates/` | user template inputs | ✅ |
| **Yours** | `~/.config/noctalia/palettes/` | custom palettes (`*.json`) | ✅ |
| **Yours** | `~/.config/noctalia/user-templates.toml` | legacy template catalog | ✅ |
| Noctalia | `~/.local/state/noctalia/settings.toml` | GUI overrides (wins) | ✅ |
| Noctalia | `~/.local/state/noctalia/state.toml` | internal UI state / last-used | ❌ regenerable |
| Noctalia | `~/.local/state/noctalia/community-palettes/` | downloaded palettes catalog | ❌ re-downloads |
| Noctalia | `~/.local/state/noctalia/community-templates/` | downloaded templates catalog | ❌ re-downloads |
| Noctalia | `~/.local/state/noctalia/plugins/` | plugin git-sources + materialized files | ❌ re-fetches |
| Noctalia | `~/.local/state/noctalia/clipboard/`, `notification_history/`, `screen_time/`, `wallhaven/` | runtime data | ❌ |
| Credentials | Secret Service / keyring | CalDAV passwords, encrypted-storage key | ❌ |
| Yours | `~/Pictures/noctalia-walls/` (**33GB**) | wallpaper collection | ❌ user-managed |

Environment overrides: `NOCTALIA_CONFIG_HOME`, `NOCTALIA_STATE_HOME`, `NOCTALIA_DATA_HOME`
(and the XDG equivalents) can relocate these roots — used for profiles/NixOS read-only config.

---

## 4. Theming

### Palette sources (`theme.source`)
- `builtin` — e.g. `builtin = "Tokyo-Night"`
- `wallpaper` — extracted from the active wallpaper (`wallpaper_scheme = "soft"`)
- `community` — `community_palette = "Catppuccin Mocha Mauve-Lavender"` (downloaded catalogs)
- `custom` — `custom_palette = "xavier"` → `~/.config/noctalia/palettes/xavier.json`

Active at backup time (from `settings.toml`):
```toml
[theme]
builtin = "Tokyo-Night"
community_palette = "Catppuccin Mocha Mauve-Lavender"
custom_palette = "Caelus"
mode = "dark"
source = "wallpaper"
wallpaper_scheme = "soft"
```
(the user frequently switches between these sources via the UI.)

### Custom palette JSON structure
`~/.config/noctalia/palettes/*.json`:
```json
{
  "dark": {
    "mPrimary": "#EF934D",
    "mOnPrimary": "#0F0F0F",
    "mSecondary": "#7EC97E",
    "mOnSecondary": "#0F0F0F",
    "mTertiary": "#7EC9A3",
    "mOnTertiary": "#0F0F0F",
    "mError": "#F16E65",
    "mOnError": "#0F0F0F",
    "mSurface": "#0F0F0F",
    "mOnSurface": "#F4DECD",
    "mSurfaceVariant": "#1E1E1E",
    "mOnSurfaceVariant": "#BFAF9E",
    "mOutline": "#353535",
    "mShadow": "#000000",
    "mHover": "#292929",
    "mOnHover": "#F4DECD",
    "terminal": {}
  }
}
```
Custom palettes owned by this user: `bladerunner`, `Caelus`, `crimson-blood`, `everforest`,
`gruvbox`, `Hilltop`, `pink-crimson`, `xavier`.

### Material-3 color roles (template variables)
Templates use `{{ colors.<role>.default.hex }}`:
`primary`, `on_primary`, `secondary`, `on_secondary`, `tertiary`, `on_tertiary`,
`error`, `on_error`, `surface`, `on_surface`, `surface_variant`, `on_surface_variant`,
`outline`, `shadow`, `hover`, `on_hover`, `surface_container`, `surface_container_high`,
`primary_container`, and more (computed from the base palette).

---

## 5. Templates (how apps get themed)

A template is an `input_path` → `output_path` render job. Noctalia substitutes the
`{{ colors.*.default.hex }}` variables from the active theme and writes the output file.
Optional `post_hook` runs a shell command after rendering.

### Enabled template categories (from config.toml)
```toml
[theme.templates]
enable_builtin_templates = true
enable_community_templates = true
```
- Built-in: `gtk3`, `gtk4`, `hyprland`, `kitty`, `btop`, `cava`, `qt`
- Community: `opencode`, `spicetify`, `pywalfox-beta4`, `zen-browser`, `discord`,
  `neovim`, `obsidian`, `obs`, `zathura`, and more

### User templates in `config.toml`
Each defined as `[theme.templates.user.<name>]`:
| Template | Input | Output | post_hook |
|---|---|---|---|
| `gtk3` | `templates/gtk3.css` | `~/.config/gtk-3.0/gtk.css` | — |
| `gtk4` | `templates/gtk4.css` | `~/.config/gtk-4.0/gtk.css` | restarts xdg portals / nautilus / polkit |
| `hyprland` | `templates/hyprland/hyprland.lua` | (hypr config) | `bash .../hyprland/apply.sh apply` |
| `startpage` | `templates/startpage.css` | startpage style | — |
| `spicetify-text` | `templates/spicetify-text.ini` | spicetify text theme | `spicetify -q apply` |
| `fzf` | `templates/fzf.sh` | fzf colors | — |
| `rmpc` | `templates/rmpc.ron` | rmpc theme | — |
| `ghgrab` | `templates/ghgrab.toml` | ghgrab theme | — |
| `modernz` | `templates/modernz.conf` | mpv modernz OSD | — |
| `mpv_colors` | `templates/mpv-colors.conf` | mpv colors | — |
| `cava` | `templates/cava.ini` | cava config | — |

**IMPORTANT gotcha (learned 2026-08-18):** `post_hook`s fire when theme changes happen
through the **Settings/control-center UI**, but they do **NOT** fire for CLI/IPC commands like
`noctalia msg color-scheme-set`, `templates-apply`, or `config-reload`. If you script a theme
change over IPC, run the post-hook / template apply yourself afterward.

The hyprland template set (`~/.config/noctalia/templates/hyprland/`) contains `apply.sh`,
`hyprland.conf`, `hyprland.lua`. The rendered output lands in `~/.config/hypr/`.

---

## 6. Plugins

Enabled plugins live in `~/.local/state/noctalia/plugins/`:
- `sources/` — git repo caches (re-fetchable)
- `materialized/` — exported runtime files

Plugin settings are stored in `settings.toml` under `[plugin_settings."<author>/<name>"]`.
Plugins enabled on this system include: `dunarand/bookmarks`, `kenn/keybind-cheatsheet`,
`noctalia/screen_recorder`, `noctalia/wallhaven`, `yocraft/web-launcher`, and more.

Plugins re-materialize from their git sources on install — nothing to back up.

---

## 7. IPC commands (key ones)

```bash
noctalia msg config-reload          # reload config.toml
noctalia msg templates-apply        # render all templates (does NOT run post_hooks)
noctalia msg color-scheme-get       # show active scheme
noctalia msg color-scheme-set <src> <name>   # change palette (no post_hooks either)
noctalia msg settings-toggle        # open Settings UI
noctalia msg reload                 # restart the shell
noctalia config validate            # validate merged config (exit 0 = valid)
noctalia config export              # merged user config (config + settings) → stdout
noctalia config export full         # full effective config incl. builtin defaults
```

---

## 8. The backup (done 2026-08-18)

**Repo:** `https://github.com/viyoga/noctalia-backup` (PRIVATE, owner `viyoga`)
**Local clone:** `~/noctalia-backup/` (git repo, branch `main`, pushed)

### Repo contents
| File/dir | Source | Purpose |
|---|---|---|
| `config.toml` | `~/.config/noctalia/config.toml` | hand-written config |
| `settings.toml` | `~/.local/state/noctalia/settings.toml` | GUI overrides (wins) |
| `templates/` | `~/.config/noctalia/templates/` | all user templates |
| `palettes/` | `~/.config/noctalia/palettes/` | all custom palettes |
| `user-templates.toml` | `~/.config/noctalia/user-templates.toml` | legacy catalog |
| `noctalia-config.toml` | `noctalia config export` | single merged snapshot (for NixOS) |
| `README.md` | — | restore instructions |

### Restore on Arch
```bash
# 1. install
yay -S noctalia-git
# 2. copy files into place
mkdir -p ~/.config/noctalia ~/.local/state/noctalia
cp config.toml user-templates.toml ~/.config/noctalia/
cp -r templates palettes ~/.config/noctalia/
cp settings.toml ~/.local/state/noctalia/
# 3. validate & reload
noctalia config validate
noctalia msg reload
```

### Restore on NixOS
Noctalia has a home-manager module that accepts a TOML path:
```nix
programs.noctalia.settings = ./noctalia-config.toml;
```
Then copy `templates/` + `palettes/` into `~/.config/noctalia/` (or manage via `home.file`).
Docs: https://docs.noctalia.dev/noctalia/getting-started/nixos/

### Caveats for restore / migration
1. **Absolute paths**: `settings.toml` and `noctalia-config.toml` contain `/home/kabir/...`
   paths (wallpapers, `~/Downloads/cropped_circle_image (1).png`, Obsidian vaults).
   Either keep username `kabir` on the new machine or edit the paths.
2. **Wallpapers are NOT in the repo** — `~/Pictures/noctalia-walls` is 33GB, handled
   separately by the user. The theme currently uses `source = "wallpaper"`, so if the
   wallpaper dir is absent the theme falls back.
3. **Version drift**: config is stamped for `config_version` of v5.0.0-beta.8-138. On a
   much newer Noctalia, run `noctalia config validate` and fix migration warnings.
4. Community palettes/templates/plugins **re-download automatically**; only the files in
   the repo are custom.
5. **What saved the system yesterday (2026-08-17/18):** Timeshift reverted system binaries
   in `/usr` (old noctalia r4741 binary) but **not `/home`** — so all config survived.
   The "fix" was reinstalling current `noctalia-git` to match the surviving config. No
   backup existed; that's why this repo was created.

### LocalSend note (unrelated, from same session)
The LocalSend windowclass differs by version: prebuilt 1.17.0 = `localsend`,
1.18.1 (AUR/current) = `org.localsend.localsend_app`. `~/.config/hypr/windowrules.lua`
matches both: `^(org\.localsend\.localsend_app|localsend)$`.

---

## 9. Official docs

- Main: https://docs.noctalia.dev/noctalia/
- Configuration: https://docs.noctalia.dev/noctalia/configuration/
- Theming: https://docs.noctalia.dev/noctalia/theming/
- Template reference: https://docs.noctalia.dev/noctalia/theming/templates/
- NixOS: https://docs.noctalia.dev/noctalia/getting-started/nixos/
- IPC: https://docs.noctalia.dev/noctalia/ipc/
- Hooks (post_hook): https://docs.noctalia.dev/noctalia/automation/hooks/

---

## Repo layout

- `config.toml`, `settings.toml`, `templates/`, `palettes/`, `user-templates.toml` — raw files, copy back exactly as listed in section 8
- `noctalia-config.toml` — single-file merged snapshot (`noctalia config export`) for NixOS
- This README — the full knowledge guide; read all of it first