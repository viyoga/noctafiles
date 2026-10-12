#!/usr/bin/env python3
"""Convert omarchy themes (colors.toml) into Noctalia custom palettes.

Omarchy's colors.toml uses a friendly-name schema (accent/background/red/...);
Noctalia wants material roles (mPrimary/mSurface/...) plus a full terminal block.
Mapping is documented inline so it can be re-tuned.

Usage: omarchy2noctalia.py <src-root> <dest-dir> [--activate]
"""
import json
import os
import sys
import tomllib


def hexnorm(value: str) -> str:
    v = str(value).strip()
    if v.startswith("0x") or v.startswith("0X"):
        v = "#" + v[2:]
    if v.startswith("rgba"):
        raise ValueError("rgba not supported")
    if not v.startswith("#"):
        v = "#" + v
    if len(v) == 4:  # #abc -> #aabbcc
        v = "#" + "".join(c * 2 for c in v[1:])
    return v.lower()


def build(src: dict) -> dict:
    bg = hexnorm(src["background"])
    d_bg = hexnorm(src.get("dark_background", bg))
    dd_bg = hexnorm(src.get("darker_background", bg))
    lt_bg = hexnorm(src.get("lighter_background", bg))
    fg = hexnorm(src["foreground"])
    d_fg = hexnorm(src.get("dark_foreground", fg))
    accent = hexnorm(src["accent"])
    muted = hexnorm(src["muted"])

    def g(key: str, fallback: str) -> str:
        return hexnorm(src.get(key, fallback))

    normal = {
        "black": dd_bg,
        "red": g("red", accent),
        "green": g("green", fg),
        "yellow": g("yellow", fg),
        "blue": g("blue", fg),
        "magenta": g("magenta", accent),
        "cyan": g("cyan", fg),
        "white": d_fg,
    }
    bright = {
        "black": muted,
        "red": g("bright_red", normal["red"]),
        "green": g("bright_green", normal["green"]),
        "yellow": g("bright_yellow", normal["yellow"]),
        "blue": g("bright_blue", normal["blue"]),
        "magenta": g("bright_magenta", normal["magenta"]),
        "cyan": g("bright_cyan", normal["cyan"]),
        "white": g("bright_foreground", fg),
    }

    return {
        "dark": {
            "mPrimary": accent,
            "mOnPrimary": bg,
            "mSecondary": normal["yellow"],
            "mOnSecondary": bg,
            "mTertiary": normal["blue"],
            "mOnTertiary": bg,
            "mError": normal["red"],
            "mOnError": bg,
            "mSurface": bg,
            "mOnSurface": fg,
            "mSurfaceVariant": dd_bg if dd_bg != bg else lt_bg,
            "mOnSurfaceVariant": muted,
            "mOutline": muted,
            "mShadow": d_bg,
            "mHover": accent,
            "mOnHover": bg,
            "terminal": {
                "background": bg,
                "foreground": fg,
                "cursor": fg,
                "cursorText": bg,
                "selectionFg": bg,
                "selectionBg": g("selection", accent),
                "normal": normal,
                "bright": bright,
            },
        }
    }


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    src_root, dest = sys.argv[1], sys.argv[2]
    os.makedirs(dest, exist_ok=True)

    made, failed = [], []
    for name in sorted(os.listdir(src_root)):
        toml_path = os.path.join(src_root, name, "colors.toml")
        if not os.path.isfile(toml_path):
            continue
        try:
            with open(toml_path, "rb") as fh:
                src = tomllib.load(fh)
            palette = build(src)
            out = os.path.join(dest, f"{name.lower()}.json")
            with open(out, "w") as fh:
                json.dump(palette, fh, indent=4)
                fh.write("\n")
            made.append(name.lower())
        except Exception as exc:  # noqa: BLE001
            failed.append(f"{name}: {exc}")

    print(f"converted {len(made)} themes -> {dest}")
    if failed:
        print("FAILED:")
        for line in failed:
            print("  " + line)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())