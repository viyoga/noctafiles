# 🌌 Hyprland Screen Shaders & Noctalia Integration

A curated collection of 17 real-time GLSL post-processing screen shaders for **Hyprland** with instant switching and seamless **Noctalia** launcher (`/shaders`) integration.

Originally adapted from [dusklinux/dusky](https://github.com/dusklinux/dusky/tree/main/.config/hypr/shaders).

---

## 🎨 Shader Catalog

| # | Shader | Effect Description |
| :---: | :--- | :--- |
| `01` | **`01_red_tint`** | Warm red monochrome tint |
| `02` | **`02_green_tint`** | Terminal Matrix green tint |
| `03` | **`03_blue_tint`** | Deep midnight / cool blue tint |
| `04` | **`04_crt`** | Retro CRT display with scanlines, curvature, and vignette |
| `05` | **`05_sketch`** | High-contrast hand-drawn pencil sketch & contour lines |
| `06` | **`06_wobble`** | Dynamic sine-wave water ripple & heat distortion |
| `07` | **`07_chromatic_aberration`** | Radial RGB lens dispersion / color fringe |
| `08` | **`08_newspaper`** | Halftone newspaper print dots & stippling effect |
| `09` | **`09_pixelated`** | Retro 8-bit / 16-bit mosaic pixelation grid |
| `10` | **`10_grayscale`** | Clean monochrome black-and-white |
| `11` | **`11_invert`** | Full photographic negative color inversion |
| `12` | **`12_posterization`** | Quantized color banding / pop-art poster style |
| `13` | **`13_sepia`** | Antique vintage warm sepia photograph |
| `14` | **`14_vibrance`** | Perceptually balanced color pop & vibrance boost |
| `15` | **`15_anaglyph_offset`** | Retro 3D red/cyan stereoscopic anaglyph split |
| `16` | **`16_vignette`** | Cinematic radial edge darkening |
| `17` | **`17_saturation_contrast`** | Enhanced dynamic range & punchy contrast |

---

## 🚀 Installation

Run the installer from this folder:

```bash
cd shaders
./install.sh
```

This installs:
* All `.glsl` files into `~/.config/hypr/shaders/`
* `shader-apply.sh` into `~/.config/hypr/scripts/shader-apply.sh`

---

## ⚡ Usage

### 1. From Terminal
```bash
# Apply a shader:
~/.config/hypr/scripts/shader-apply.sh 04_crt

# Turn off active shader:
~/.config/hypr/scripts/shader-apply.sh off
```

### 2. From Noctalia Launcher (`/shaders`)
Open Noctalia launcher (`Super + Space` or `Super + /`), type `/shaders`, and pick any preset from the list or select **Off**.

Configuration in `~/.config/noctalia/config.toml`:
```toml
[shell.launcher.dmenu.entry.shaders]
label = "Screen Shaders"
prefix = "shaders"
glyph = "sparkles"
global = false
freeform = false
command = """
  printf "Off\\n"; ls ~/.config/hypr/shaders/*.glsl | xargs -n1 basename | sed 's/\\.glsl$//'
"""
exec = """
  "$HOME/.config/hypr/scripts/shader-apply.sh" "$(echo "{selection}" | sed 's/^Off$/off/')"
"""
```

---

## 🔗 Upstream & Credits
* **Upstream Dotfiles:** [dusklinux/dusky](https://github.com/dusklinux/dusky)
* **Shaders Source:** [dusklinux/dusky (.config/hypr/shaders)](https://github.com/dusklinux/dusky/tree/main/.config/hypr/shaders)
