# OmarKEYS

Omarchy overlay plugin. Repo root *is* the plugin (`manifest.json` here)
so `omarchy plugin add <git-url>` works.

## Layout

| Path | Role |
|---|---|
| `manifest.json` | Plugin id `romills.omarkeys`, overlay entry |
| `Keymap.qml` | Overlay UI |
| `KeymapSection.qml` | Section card |
| `KeymapData.js` | Grouped bindings + filter helpers |
| `hyprland.lua` | Super double-tap / hold / Super+K |
| `install.sh` | Symlink plugin, wire Hyprland, enable |

## Validation

```sh
omarchy plugin validate .
node --test tests/keymap-data.test.js
git diff --check
```

After editing `hyprland.lua` on a live install:

```sh
hyprctl reload
hyprctl configerrors
```

## Install on this machine

```sh
./install.sh
```

That symlinks this repo to `~/.config/omarchy/plugins/romills.omarkeys`
and `dofile`s `hyprland.lua` from `~/.config/hypr/bindings.lua`.
