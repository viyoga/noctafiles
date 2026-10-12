# lutgen-zsh 🎨

> Interactive, multi-palette wallpaper recoloring utility for Zsh powered by [lutgen](https://github.com/ozwaldorf/lutgen) and [fzf](https://github.com/junegunn/fzf).

Quickly browse wallpapers, pick multiple color palettes with live ANSI previews, batch-recolor with non-destructive sequential indexing, and preview the results directly inside your terminal using Kitty graphics or Chafa.

---

## ✨ Features

- **Interactive Wallpaper Browser**:
  - Launch without arguments to browse your wallpapers with instant terminal previews.
  - Supports Kitty graphics protocol (`kitten icat`) with unicode placeholders in `fzf`, and falls back to `chafa` on any terminal.
- **Multi-Palette Selection (`fzf -m`)**:
  - Press `Tab` to select multiple target palettes simultaneously (e.g. Catppuccin, Gruvbox, Everforest, Nord).
  - Live ANSI color swatches in the fzf preview window.
- **Batch & Recursive Recoloring**:
  - Pass single images, multiple images, or entire directories (`lutgen ~/Pictures/wallpapers`).
  - Auto-discovers images (`png`, `jpg`, `jpeg`, `webp`, `avif`, `bmp`) via `fd` or `find`.
- **Non-Destructive Sequential Indexing**:
  - Automatically indexes generated files (`<palette>-1.png`, `<palette>-2.png`, etc.) without overwriting existing recolored wallpapers.
- **Terminal Previews**:
  - Shows 1 to 3 sample preview cards directly in your terminal after processing.
- **CLI Passthrough**:
  - Native `lutgen` subcommands and flags (`apply`, `generate`, `palette`, `--help`, etc.) pass through seamlessly when invoked with flags.

---

## 📦 Requirements

- **[Zsh](https://www.zsh.org/)** (v5.0+)
- **[lutgen](https://github.com/ozwaldorf/lutgen)** (Rust CLI)
- **[fzf](https://github.com/junegunn/fzf)**
- Image previewer: **[Kitty](https://sw.kovidgoyal.net/kitty/)** (`kitten icat`) or **[chafa](https://hpjansson.org/chafa/)**
- Optional: `fd` (for faster file discovery)

---

## 🚀 Installation

### Using [Zinit](https://github.com/zdharma-continuum/zinit)
```zsh
zinit light viyoga/lutgen-zsh
```

### Using [Oh My Zsh](https://ohmyz.sh/)
```bash
git clone https://github.com/viyoga/lutgen-zsh.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/lutgen-zsh
```
Add `lutgen-zsh` to your plugins list in `~/.zshrc`:
```zsh
plugins=(... lutgen-zsh)
```

### Manual Installation
```bash
git clone https://github.com/viyoga/lutgen-zsh.git ~/.config/zsh/plugins/lutgen-zsh
```
Add to `~/.zshrc`:
```zsh
source ~/.config/zsh/plugins/lutgen-zsh/lutgen.zsh
```

---

## 🕹️ Usage

### Interactive Mode
Run `lutgen` with no arguments to open the interactive wallpaper selector:
```bash
lutgen
```
1. Select one or more wallpapers using `Tab`, press `Enter`.
2. Select one or more color palettes using `Tab`, press `Enter`.
3. Sit back and watch the batch progress and live terminal previews!

### Direct Paths
```bash
# Single wallpaper
lutgen ~/Pictures/forest.png

# An entire folder of images
lutgen ~/Pictures/anime-scenery/

# Multiple images at once
lutgen photo1.jpg photo2.png
```

### Native Passthrough
All native `lutgen` flags and subcommands work without interference:
```bash
lutgen --version
lutgen palette catppuccin-mocha
lutgen apply -p gruvbox -o out.png in.png
```

---

## ⚙️ Configuration

Customize directories in your `~/.zshrc`:

```zsh
# Where recolored wallpapers are saved (default: $HOME/Pictures/wallpapers or noctalia-walls)
export LUTGEN_OUTPUT_DIR="$HOME/Pictures/wallpapers"

# Where your custom palette .txt files are stored (default: ~/.config/lutgen)
export LUTGEN_PALETTES_DIR="$HOME/.config/lutgen"

# Base directory for the fzf wallpaper selector (default: $HOME/Pictures)
export LUTGEN_PICTURES_DIR="$HOME/Pictures"
```

---

## 🎨 Palettes

This repository includes 40 curated palette text files in [`palettes/`](palettes/). You can copy them to `~/.config/lutgen/` or add your own hex lists:
```text
# Example palette file (~/.config/lutgen/nord.txt):
#2e3440
#3b4252
#434c5e
#4c566a
#d8dee9
#88c0d0
#81a1c1
#5e81ac
```

---

## 📄 License

[MIT](LICENSE) © [viyoga](https://github.com/viyoga)
