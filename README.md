# OmarKEYS

A Super+K alternative for [Omarchy](https://omarchy.org/). Topic-organized
keymap overlay, summoned without eating Super+other shortcuts.

**Open**

- Double-tap Super
- Hold Super for one second
- Super+K

**Close**

- Tap Super
- Escape
- Click the dimmed background

Type while it is open to filter.

## Install

Needs Omarchy Quattro (Hyprland Lua + `omarchy-shell` plugins).

```bash
git clone <this-repo> ~/Work/omarkeys
cd ~/Work/omarkeys
./install.sh
```

`install.sh` will:

1. Symlink this repo to `~/.config/omarchy/plugins/romills.omarkeys`
2. Enable the overlay plugin
3. Point `~/.config/hypr/bindings.lua` at `hyprland.lua`
4. Reload Hyprland

Or add it like any other Omarchy plugin, then still run `./install.sh` so
the Super gestures are wired (the overlay alone has no Super hold/double-tap).

```bash
omarchy plugin add <git-url> --enable
./install.sh
```

## Uninstall

```bash
./install.sh --uninstall
```

## Layout

This repository root *is* the Omarchy plugin (`manifest.json` at the top).
Hyprland activation lives in `hyprland.lua` and is `dofile`d from your
user bindings file so Super+chords stay unmodified.

## License

MIT
