# OmarKEYS

A Super+K alternative for [Omarchy](https://omarchy.org/). Topic-organized
keymap overlay, summoned without eating Super+other shortcuts.

**Open**

- Double-tap Super (optional)
- Hold Super (default 5 seconds)
- Super+K

**Close**

- Tap Super
- Escape
- Click the dimmed background

Type while it is open to filter, including digits.

**Navigate**

- Arrow keys move the highlight (up/down command, left/right group)
- `Ctrl+1`–`Ctrl+9` jump to a numbered group (`Ctrl+0` is the 10th)
- Enter or click runs the highlighted shortcut
- Greyed-out rows (ranges, holds, double-tap) cannot be run

**Sidebar**

- Groups: show or hide topic cards; All/None for every group
- Modifiers: each of Super, Shift, Ctrl, Alt is Any / Must / Hide.
  Click a name to cycle it, or click **A any**, **M must**, **H hide** to set all four.

**Settings** (bottom of the overlay)

- Double-tap Super on/off
- Hold Super duration, 1–10 seconds
- Edit mode (Omarchy source): pick a command, then press its new chord

App windows with a bundled sheet (Chromium, Ghostty, Nautilus) can be
selected in the overlay; those sheets live in `sheets/`.

Bindings are read live from Hyprland each time OmarKEYS opens. Settings
are stored in `~/.config/omarchy/omarkeys.json`. Remaps write
`~/.config/hypr/omarkeys-edits.lua` and keep a git history under
`~/.local/state/omarchy/omarkeys-history`.

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

| Path | Role |
|---|---|
| `Keymap.qml` | Overlay host: config, live dump, keys, execute |
| `KeymapSidebar.qml` | Groups and modifier filters |
| `KeymapBoard.qml` | Two-column binding cards |
| `KeymapSection.qml` / `KeymapRow.qml` | One topic card and one command row |
| `KeymapSettingsBar.qml` | Double-tap and hold controls |
| `KeymapData.js` | Filter, catalog, shortcut parse, fallback list |
| `dump-keymap` | Live Hyprland binds → JSON sections |
| `apply-edit` | Remap a chord into `omarkeys-edits.lua` |
| `sheets/` | Bundled app keymaps (Chromium, Ghostty, Nautilus) |
| `run-shortcut` | Replay a chord after the overlay closes |
| `hyprland.lua` | Super+K, double-tap, hold |

## License

MIT
