# OmarKEYS

A Super+K alternative for [Omarchy](https://omarchy.org/). Topic-organized
keymap overlay, summoned without eating Super+other shortcuts.

Repo: https://github.com/romills/OmarKEYs. Work climbs one ladder —
`develop-claude` → `develop` → `beta` → `main` — and each channel in the
overlay's corner picker maps to one of its branches:

| Branch | Channel | Owner |
|---|---|---|
| `main` | Main | Grok promotes a finished beta and writes [RELEASE.md](RELEASE.md) |
| `beta` | Beta | Claude |
| `develop` | Nightly | Claude integrates; Cursor opens PRs into it from `develop-cursor` |
| `develop-claude` | Nightly | Claude's working branch |

Cursor does not land on `main`.

**Open**

- Double-tap Super (optional)
- Hold Super (default 5 seconds)
- Super+K (optional)

Hold Super always works, so turning the other two off cannot lock you out.

**Close**

- Tap Super
- Escape
- Super+W (temporarily mapped to the overlay so it does not close the window behind it)
- Click the dimmed background

Type while it is open to filter, including digits.

**Navigate**

- Arrow keys move the highlight (up/down command, left/right group)
- `Ctrl+1`–`Ctrl+9` jump to a numbered group (`Ctrl+0` is the 10th)
- Click highlights a row; **double-click** or Enter runs it. Running takes
  two deliberate actions so a click while reading cannot fire a shortcut
  and close the overlay under you.
- Greyed-out rows cannot be run: ranges, gestures, and any bind whose
  action OmarKEYS could not recover from your config

**Sidebar** — the tree

- **Omarchy** (expanded): five areas, each holding its topic groups
- **Active Apps**: live windows, grouped by the keymap sheet they share
  (Web apps, Terminals, File managers) and then by app. Click a window to
  load its sheet, double-click to focus it. Apps with no bundled sheet sit
  under **No keymap sheet**, pinned to the bottom.
- Click an area or group to *solo* it — everything else hides so the board
  shows only what you clicked. Clicking **Omarchy** restores all of them.
  Solo is view-only and is undone when the overlay closes.
- Every row carries a **Show**/**Hide** control, revealed when you hover it.
  Hiding a branch collapses and greys it but keeps its label, so it can
  always be brought back. Carets show the state: collapsed when everything
  under a parent is hidden, expanded while any of it still shows.

**Options** (bottom-left corner)

*Display*

| Option | Values | Default |
|---|---|---|
| Keys | full / short / icons | icons |
| Super | text / option / windows / superman | windows |
| Order | keys first / action first | action first |
| Sort | by group / by name | by name |
| Find | all / keys / name | all |
| Text size | slider, click the label to reset | 1.0 |
| Icon size | slider (icons only), click to reset | 1.35 |

With icons on, hovering a row spells each glyph out in words beside it.

**Super** has no one true symbol — it is the Windows key on most
keyboards and Option on a Mac layout — so it is a setting of its own:
the word, ⌥, the Windows key, or the Superpowers mark. Unlike the other
key chips it applies in every chip style, since picking a symbol is
pointless if it only shows in icon mode. All three glyphs are in the
overlay's own font.

*Filters* — Super, Shift, Ctrl and Alt in a 2×2 grid. A **clear** key is
**A**ll and carries no mark; click it to require it (**M**ust), again to
drop rows that use it (**H**ide), again to clear. Only the states you
chose are marked, so anything showing a letter is a filter you set. The
legend words set all four at once.

*Opening* — Super+K on/off, double-tap Super on/off, and hold-Super
duration (1–10s).

Turning **Super+K** off hands the chord back to whatever held it before
OmarKEYS (Omarchy binds it to **Keybindings**). It works by not claiming
the key rather than by rebinding it, so your own remap of Super+K survives
untouched. The bind lives in `hyprland.lua`, which only re-reads its config
when Hyprland does, so flipping this runs `hyprctl reload` — the same
reload the installer does, and it costs nothing else.

**Restore defaults** (bottom right of the popup) resets every one of the
above, plus hidden groups and apps and the search box.

**Channel** (bottom-right corner) reads `Channel @ hash`, with a `•` when
the channel you are on is behind its remote. Click it to switch channel or
sync — see [Updating](#updating).

App windows with a bundled sheet (Chromium, Ghostty, Nautilus) can be
selected in the overlay; those sheets live in `sheets/`.

Bindings are read live from Hyprland each time OmarKEYS opens, and
settings are stored in `~/.config/omarchy/omarkeys.json`.

## Dependencies and privileges

Omarchy plugins run unsandboxed inside the long-running shell process with
your user's permissions, so here is everything OmarKEYS reaches for.

**External commands**

| Command | Used for |
|---|---|
| `hyprctl` | Read binds and clients; dispatch the action of a row you run; reload the config when Super+K is toggled |
| `python3` | `dump-keymap`, `apply-edit`, `plugin-git`, and JSON quoting in `run-shortcut` |
| `lua` | Read the real action of each bind out of your Hyprland Lua config |
| `git` | Branch picker (status, fetch, checkout, fast-forward) and the edit history |
| `bash` | `run-shortcut`, `install.sh`, and invoking `omarchy restart shell` |
| `omarchy`, `omarchy-shell` | Enable/disable the plugin, rescan plugins, restart the shell |

**Files it writes**

| Path | What |
|---|---|
| `~/.config/omarchy/omarkeys.json` | Overlay settings (display options, hidden groups and apps, modifiers, gestures) |
| `~/.config/hypr/bindings.lua` | Installer appends one `dofile` line; backed up first |
| `~/.config/hypr/omarkeys-edits.lua` | Chord remaps — written only by `apply-edit` |
| `${XDG_STATE_HOME:-~/.local/state}/omarchy/omarkeys-history` | Git history of remaps, so an edit can be reverted |

The last two are the chord-remap backend. It ships and works from the
command line, but **nothing in the overlay calls it yet** — the View | Edit
UI is unbuilt (see [PLAN.md](PLAN.md)), so a stock install never writes
either path.

**Privilege boundaries**

- Running a row dispatches that binding's **own** action, taken from your
  Hyprland config — an `exec` bind runs its command as you. OmarKEYS adds no
  commands of its own; it can only trigger what you already bound.
- Rows whose action cannot be recovered are shown dimmed and do nothing, so
  the overlay never guesses at what a key might mean.
- **Network:** only the branch picker, and only to the plugin's own git
  remote, when you check for updates or sync. Nothing else phones home.
- The picker can change which branch of this plugin is checked out and then
  run `omarchy restart shell`. It never starts a second Quickshell process,
  never force-pushes, never resets, and refuses to act on a dirty checkout.
- No root, no setuid, no system services, no remote build step.

## Install

Needs Omarchy Quattro (Hyprland Lua + `omarchy-shell` plugins), plus
`python3`, `lua`, and `git` on `PATH`.

```bash
git clone <this-repo> ~/Work/omarkeys
cd ~/Work/omarkeys
./install.sh
```

`install.sh` will:

1. Clone this repo to `~/.config/omarchy/plugins/io.github.romills.omarkeys`
2. Enable the overlay plugin
3. Point `~/.config/hypr/bindings.lua` at `hyprland.lua`
4. Reload Hyprland

### Already installed with a symlink?

Earlier versions symlinked the checkout into the plugins folder. Omarchy's
validator refuses a plugin folder that *is* a symlink, so
`omarchy plugin update` fails on those installs and rolls back:

```
omarchy-plugin-validate: symlinks are not allowed inside a plugin folder
omarchy-plugin-update: update of '...' failed validation; rolled back
```

Nothing is broken and nothing is lost — the plugin keeps working, it just
cannot be updated in place. Re-run the installer to convert it:

```bash
cd ~/Work/omarkeys && git pull && ./install.sh
```

### Updating

`omarchy plugin update` works on a normal (clone) install, and so does the
overlay's own corner picker. They divide up like this:

| On channel | Use |
|---|---|
| Main | `omarchy plugin update`, or the picker |
| Beta / Nightly | the picker's **Sync** |

`omarchy plugin update` always fetches the default branch (`main`) and
fast-forwards the checked-out branch onto it, so running it while on Beta
leaves a branch named `beta` sitting on main's commit. Recover with
`git checkout main && git branch -D beta` in the plugin directory; the next
switch to Beta recreates it from `origin/beta`.

### Working on OmarKEYS itself

```bash
./install.sh --dev
```

Symlinks the checkout instead of cloning, so edits go live on
`omarchy restart shell`. `omarchy plugin update` and
`omarchy plugin validate` both reject a symlinked plugin folder, so use this
only on a machine where you are developing OmarKEYS.

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
| `KeymapSidebar.qml` | The tree: Omarchy areas/groups and Active Apps |
| `KeymapBoard.qml` | Two-column binding cards |
| `KeymapSection.qml` / `KeymapRow.qml` | One topic card and one command row |
| `KeymapHideButton.qml` | Show/Hide control, used at every level of the tree |
| `KeymapOptionsMenu.qml` | Options popup: display, modifiers, opening gestures |
| `KeymapBranchMenu.qml` | Corner channel picker: Main / Beta / Nightly |
| `KeymapData.js` | Filter, catalog, shortcut parse, fallback list |
| `dump-keymap` | Live Hyprland binds → JSON sections |
| `run-shortcut` | Runs a row after the overlay closes: dispatches the bind's own action, or sends the chord for app-sheet rows |
| `apply-edit` | Remap a chord into `omarkeys-edits.lua` (no UI yet) |
| `plugin-git` | Channel picker's git backend: status, fetch, switch, sync |
| `install.sh` | Install the plugin and wire the Hyprland gestures |
| `sheets/` | Bundled app keymaps (Chromium, Ghostty, Nautilus) |
| `tests/` | `node --test tests/keymap-data.test.js` |
| `hyprland.lua` | Super+K, double-tap, hold |

## License

MIT
