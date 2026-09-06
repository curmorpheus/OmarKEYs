# OmarKEYS plan

Living plan for the overlay. Done items stay here so we do not lose
the thread after a cleanup or GitHub push.

User comments on approval (plan.md:116):

- Why the limit on writing `bindings.lua`? If that is the worry, take a
  backup we can revert and keep a library of changes.
- Version-control each working version.

Those comments are implemented in `apply-edit`: snapshots, git history
under `~/.local/state/omarchy/omarkeys-history`, rollback on a failed
reload. Edits still land in `~/.config/hypr/omarkeys-edits.lua` rather
than rewriting the body of `bindings.lua`.

User comments (layer vs app / Super+W):

- Super+W closed the last focused window, not OmarKEYS.
- Should this be an app (so Super+W closes it) or a layer plugin?

Dealt with: OmarKEYS stays an overlay **layer plugin** (same family as
the menu and clipboard). Super+W is "close window"; a layer is not a
window, so that bind would kill the app behind the overlay. While the
layer is up, Super+W is **temporarily remapped** to close OmarKEYS.
The original "Close window" bind is restored when the overlay hides.

## Done

### Overlay (Super+K replacement)

- [x] Topic-organized overlay plugin (`io.github.romills.omarkeys`)
- [x] Open: Super+K, double-tap Super, hold Super (default 5s)
- [x] Close: tap Super, Esc, Super+W, click dim
- [x] Keyboard grab after Super-up; dismiss if the focused window changes
- [x] Super+W temp-mapped to the layer while open (does not close the window behind it)
- [x] Live Hyprland binds on open (`dump-keymap`)
- [x] Type to search (digits included; Ctrl+1–9 jumps groups)
- [x] Arrows, Enter or click to run the highlighted chord
- [x] Sidebar groups with show/hide and All/None
- [x] Modifier filter Any / Must / Hide; A/M/H sets all four
- [x] Double-tap toggle and hold slider
- [x] Settings in `~/.config/omarchy/omarkeys.json`
- [x] Code split: host, sidebar, board, row, settings bar
- [x] Public repo: https://github.com/romills/OmarKEYs
- [x] Ship `apply-edit` and `sheets/` (were gitignored; GitHub clones missed them)

### Phase 1 — Auto-reload

- [x] Refresh dump when the overlay opens
- [x] Watch `~/.config/hypr/bindings.lua` and refresh while open
- [x] Hash the dump so idle refreshes do not reset selection/search
- [x] Keep selection when the row still exists after a refresh

### Phase 2 — Data for the app tree

- [x] `dump-keymap` returns `clients` (class, label, focused, sheet)
- [x] Starter sheets: Chromium, Ghostty, Nautilus
- [x] `selectSource()` loads Omarchy dump or a sheet / empty state

### Phase 3 — Edit backend

- [x] `apply-edit remap` writes `omarkeys-edits.lua`
- [x] Backup + git history per working version; restore on reload error
- [x] Lua-escape bind strings; refuse chords that are not Hyprland-like
- [x] Capture/remap functions in `Keymap.qml` (`setEditMode`, `startCapture`)

## In progress

### Phase 2 — Sidebar tree UI

- [x] Omarchy as the default expanded branch, with current groups under it
- [x] Open windows branch from live clients; click loads that app’s sheet
- [x] Focused window marked in the tree
- [x] Groups / modifiers still apply to the active branch

## Future

### Finish Phase 2

- [ ] Empty-state copy when a window has no sheet
- [ ] Optional: auto-select the focused window (plan said v1 is click-to-open)

### Finish Phase 3 — View | Edit UI

- [ ] Header toggle View | Edit (Omarchy branch only)
- [ ] Dim non-editable rows; “press a new chord or Esc”
- [ ] Enter stays View-only
- [ ] Surface `apply-edit revert` / history in the overlay
- [ ] `install.sh` wires `omarkeys-edits.lua` on first install (first edit already appends the dofile)

### Later (out of the original three phases)

- [ ] More app sheets beyond Chromium / Ghostty / Nautilus
- [ ] A 3s timer while open so `hyprctl binds` picks up Lua reloads we did not write
- [ ] Watch `omarkeys-edits.lua` the same way as `bindings.lua`
- [ ] Do not scrape another program’s keymap from memory
- [ ] Do not edit dispatcher/args — chord remap of an existing action only
- [ ] Do not change Super+K / hold / double-tap from the chord editor
- [ ] GitHub release tag
- [ ] Manifest description catch-up
