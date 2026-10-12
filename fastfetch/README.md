# fastfetch

personal fastfetch configuration.

## Structure

```text
~/.config/fastfetch/
├── config.jsonc
├── bin/
│   └── fastfetch       # Category switcher & random logo selector wrapper
├── arch/               # Arch Linux ASCII logos
├── animals/            # Kitty, cat, cow, deer, bird ASCII art
└── geometry/           # Geometric & abstract ASCII art
```

## Usage

Place or symlink into `~/.config/fastfetch/`:

```bash
git clone https://github.com/viyoga/fastfetch.git ~/.config/fastfetch
```

Run with the helper script:

```bash
# Random logo from all categories
./bin/fastfetch

# Specific category
./bin/fastfetch animals
./bin/fastfetch arch
./bin/fastfetch geometry

# List available logos
./bin/fastfetch --list
```
