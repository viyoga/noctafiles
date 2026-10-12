# cmatrix-noctalia 🌧️

> Dynamic [Noctalia](https://docs.noctalia.dev/) theme palette integration wrapper for [`cmatrix`](https://github.com/abishekvashok/cmatrix).

Transform classic green Matrix digital rain into rich, theme-coordinated rain that automatically matches your active Noctalia desktop palette in real time.

---

## 💡 Why this exists

`cmatrix` is a classic curses terminal rain simulator built on fixed 8-color terminal palettes. Because it lacks native truecolor HEX rendering, running `cmatrix` inside themed terminal emulators often results in mismatched green rain against warm, cool, or custom desktop palettes.

`cmatrix-noctalia` bridges this gap seamlessly:
1. **Dynamic Color Remapping:** Upon launch, it uses terminal OSC 4 sequences (`\033]4;2;<hex>\033\\` and `\033]4;10;<hex>\033\\`) to remap the terminal's standard green slots to Noctalia's current `primary` and `bright` color tokens.
2. **True Background Integration:** Uses the terminal's native background (`use_default_colors`), blending cleanly with Kitty/terminal transparency and blur.
3. **Safe Cleanup:** Automatically traps `EXIT`, `INT`, `TERM`, and `HUP` signals to restore your terminal's original palette immediately when you quit.
4. **Live Template Integration:** Connected to Noctalia's template engine; re-renders instantly on any palette change via `noctalia msg templates-apply`.

---

## 📦 Requirements

- **[cmatrix](https://github.com/abishekvashok/cmatrix)** (`sudo pacman -S cmatrix` or `yay -S cmatrix-git`)
- **[Noctalia](https://docs.noctalia.dev/)** shell environment
- A terminal supporting OSC 4 palette remapping (e.g., Kitty, Alacritty, WezTerm, Ghostty, Foot)

---

## 🚀 Installation

### Automated Install

Clone the repository and run the installer:

```bash
git clone https://github.com/viyoga/cmatrix-noctalia.git ~/dev/cmatrix-noctalia
cd ~/dev/cmatrix-noctalia
./install.sh
```

The installer will:
1. Copy `templates/cmatrix.sh` into `~/.config/noctalia/templates/`.
2. Register `[theme.templates.user.cmatrix]` inside `~/.config/noctalia/config.toml` (if not already present).
3. Trigger `noctalia msg templates-apply` to render `~/.local/bin/cmatrix-noctalia` for your active palette.

---

## ⚙️ Manual Configuration

If you prefer adding it manually, add this to `~/.config/noctalia/config.toml`:

```toml
[theme.templates.user.cmatrix]
input_path  = "$XDG_CONFIG_HOME/noctalia/templates/cmatrix.sh"
output_path = "~/.local/bin/cmatrix-noctalia"
post_hook   = "chmod +x ~/.local/bin/cmatrix-noctalia"
```

Then reload and apply:

```bash
noctalia msg config-reload
noctalia msg templates-apply
```

---

## ⌨️ Recommended Aliases

Add the following to your `~/.zshrc` or `~/.config/zsh/aliases.zsh`:

```zsh
alias cmatrix='cmatrix-noctalia'
alias cm='cmatrix-noctalia'
```

---

## 🛠️ Usage

All standard `cmatrix` arguments are passed directly through:

```bash
cmatrix-noctalia           # Standard themed digital rain
cmatrix-noctalia -a        # Asynchronous scroll
cmatrix-noctalia -b        # Bold characters on
cmatrix-noctalia -u 2      # Faster scroll speed
```

---

## 📄 License

[MIT](LICENSE) © [viyoga](https://github.com/viyoga)
