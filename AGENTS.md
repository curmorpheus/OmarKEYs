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
| `plugin-git` | Branch/update state for the corner picker; switch + sync |
| `KeymapBranchMenu.qml` | Corner branch picker: switch branch, sync to latest |
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

## Branches

Multiple agents work this repo in parallel on one machine, each in its own
git worktree so branch switches never yank files out from under another
tool's open buffers.

| Branch | Owner | Role |
|---|---|---|
| `main` | Grok | Released/stable; Grok pulls `develop` into `main` |
| `develop` | Claude (this agent) | Integration branch; only accepts approved merges from `develop-claude` and `develop-cursor` |
| `develop-claude` | Claude | Claude's working integration branch; feature branches merge here first, brought into `develop` once approved |
| `develop-cursor` | Cursor | Cursor's own integration branch; opens a PR into `develop` when ready to hand work back |
| `feature/phase2-sidebar-tree` | Claude | Off `develop-claude` |
| `feature/phase3-view-edit-ui` | Claude (second session) | Off `develop-claude` |

Rules: only the branch owner commits directly to it. Everyone else lands
changes via PR/merge after review. Claude's own feature work lands on
`develop-claude`, not `develop`, and only moves to `develop` once approved.
Cursor never pushes straight to `develop` or `main` — it PRs from
`develop-cursor`. Grok is the only one who merges into `main`. Claim a
PLAN.md item by prefixing it with the owner (e.g. `(cursor)`) before
starting so two agents don't duplicate work.

## Install on this machine

```sh
./install.sh
```

That symlinks this repo to `~/.config/omarchy/plugins/io.github.romills.omarkeys`
and `dofile`s `hyprland.lua` from `~/.config/hypr/bindings.lua`.
