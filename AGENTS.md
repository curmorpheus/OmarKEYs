# OmarKEYS

Omarchy overlay plugin. Repo root *is* the plugin (`manifest.json` here)
so `omarchy plugin add <git-url>` works.

## Layout

| Path | Role |
|---|---|
| `manifest.json` | Plugin id `io.github.romills.omarkeys`, overlay entry |
| `Keymap.qml` | Overlay host: config, dump, keyboard, execute |
| `KeymapSidebar.qml` | Group visibility and modifier Any/Must/Hide |
| `KeymapBoard.qml` | Two-column section grid |
| `KeymapSection.qml` | One topic card |
| `KeymapRow.qml` | One command row |
| `KeymapSettingsBar.qml` | Double-tap toggle and hold slider |
| `KeymapData.js` | Grouped bindings, filters, shortcut helpers |
| `hyprland.lua` | Super double-tap / hold / Super+K |
| `run-shortcut` | Run a selected row after the overlay closes (`--dispatch` for Hyprland binds; chord replay for app sheets) |
| `dump-keymap` | Read live Hyprland binds into OmarKEYS JSON sections |
| `apply-edit` | Remap a chord; required at runtime by edit mode |
| `plugin-git` | Channel picker state: switch + sync |
| `KeymapBranchMenu.qml` | Corner picker: Main / Beta / Nightly |
| `sheets/` | Bundled per-app keymap JSON |
| `install.sh` | Symlink plugin, wire Hyprland, enable |
| `RELEASE.md` | Release notes. Grok updates this when promoting `beta` → `main`. |

Keep overlay logic in the host (`Keymap.qml`) and UI chrome in the child
QML files. `KeymapData.js` is the only place that decides which rows are
visible (search, hidden groups, modifier modes). Roadmap: `PLAN.md`.

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

QML changes need `omarchy restart shell` (keepLoaded overlay).

## Working copies

`~/Work/omarkeys` is the **deploy slot**: the folder Omarchy loads. Do not
edit or commit in it. It only switches branches and pulls, increasingly from
the overlay's own corner picker — and the picker refuses to switch or sync
when the tree is dirty, so a stray edit there blocks it.

Work in your own clone, one per agent, so two of us can hold the same branch
at once (a branch is checkout-exclusive per working tree):
`~/Work/omarkeys-claude`, `-cursor`, `-grok`. Push to hand work off.

## Channels

| Channel | Branch | Owner |
|---|---|---|
| Main | `main` | Grok |
| Beta | `beta` | Claude |
| Nightly | working branches | agents |

Claude ships beta. Grok pulls a finished `beta` into `main` and updates
`RELEASE.md`. Cursor does not land on `main`.

```sh
cd ~/Work/omarkeys-grok
git checkout main
git fetch shared
git merge --ff-only shared/beta
# update RELEASE.md, then:
git push origin main
git push shared main
```

## Install on this machine

```sh
./install.sh
```

That symlinks this repo to `~/.config/omarchy/plugins/io.github.romills.omarkeys`
and `dofile`s `hyprland.lua` from `~/.config/hypr/bindings.lua`.
