#!/usr/bin/env python3
"""Merge Noctalia-rendered theme overrides into Sonora settings.json.

Only touches appearance.theme_overrides — every other setting is preserved.
Safe to run while Sonora is live (GPUI apps hot-reload settings.json).
"""
import json
import os
import sys

RENDERED = os.path.expanduser("~/.config/noctalia/.sonora-overrides.rendered.json")
SETTINGS = os.path.expanduser("~/.config/sonora/settings.json")


def main() -> int:
    try:
        with open(RENDERED) as f:
            overrides = json.load(f)
    except (OSError, ValueError) as e:
        print(f"sonora-merge: cannot read rendered overrides: {e}", file=sys.stderr)
        return 1
    # Refuse to merge if any template variable failed to resolve.
    if "{{" in json.dumps(overrides):
        print("sonora-merge: unresolved template variables, aborting", file=sys.stderr)
        return 1
    try:
        with open(SETTINGS) as f:
            settings = json.load(f)
    except (OSError, ValueError) as e:
        print(f"sonora-merge: cannot read settings.json: {e}", file=sys.stderr)
        return 1
    settings.setdefault("appearance", {}).setdefault("theme_overrides", {}).update(overrides)
    with open(SETTINGS, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print("sonora-merge: theme overrides applied")
    return 0


if __name__ == "__main__":
    sys.exit(main())
