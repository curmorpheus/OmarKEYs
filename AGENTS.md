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
| `run-shortcut` | Replay a selected chord after the overlay closes |
| `dump-keymap` | Read live Hyprland binds into OmarKEYS JSON sections |
| `apply-edit` | Remap a chord; required at runtime by edit mode |
| `sheets/` | Bundled per-app keymap JSON; required for app sources |
| `install.sh` | Symlink plugin, wire Hyprland, enable |

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

## Grok's repository

This clone is **Grok's line**. Claude and Cursor do not commit here.

| Path | Who | Purpose |
|---|---|---|
| `~/Work/omarkeys-grok` | Grok | This repo. Edit and commit here. |
| `~/Work/omarkeys-claude` | Claude | Shared-repo clone |
| `~/Work/omarkeys-cursor` | Cursor | Shared-repo clone |
| `~/Work/omarkeys` | nobody | Deploy slot only (`~/.config/omarchy/plugins/io.github.romills.omarkeys`). Do not edit. |

| Remote | URL | Role |
|---|---|---|
| `origin` | https://github.com/romills/OmarKEYs-grok.git | Grok's repo. `main` is Grok's released/stable line. |
| `shared` | https://github.com/romills/OmarKEYs.git | Claude/Cursor repo. `develop` is their integration branch. |

### Branches

| Branch | Owner | Role |
|---|---|---|
| `main` (this repo) | Grok | Released/stable. Only Grok merges into it. |
| `develop` (shared repo) | Claude (integration) | Approved Claude/Cursor work. Grok pulls this into `main` when ready. |
| `develop-claude` (shared) | Claude | Claude's working branch |
| `develop-cursor` (shared) | Cursor | Cursor's working branch |

Grok is the only one who pulls `develop` into `main`:

```sh
cd ~/Work/omarkeys-grok
git checkout main
git fetch shared
git merge --no-ff shared/develop
git push origin main
```

Do not push Grok commits to `shared` unless handing a patch back. Local `develop` tracks `shared/develop` for inspection only.

## Install on this machine

```sh
./install.sh
```

That symlinks this repo to `~/.config/omarchy/plugins/io.github.romills.omarkeys`
and `dofile`s `hyprland.lua` from `~/.config/hypr/bindings.lua`.
