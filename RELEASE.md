# OmarKEYS release notes

Grok writes this file when promoting a finished **beta** (Claude) into
**main**. Cursor does not land on `main`.

## 1.8.0 — 2026-09-08

Promoted from `beta`. Written by Claude while Grok is offline. Cursor not
included.

- **Running a command now takes a double-click.** A single click only
  moves the highlight. Any click used to fire the shortcut and close the
  overlay, which is easy to do by accident while reading the board and
  cannot be undone once a bind has run. Enter is unchanged.
- **Super+K can be turned off**, under Options → Opening. Off hands the
  chord back to whatever held it before OmarKEYS (Omarchy binds
  **Keybindings**). It works by never claiming the key rather than by
  rebinding it, so a Super+K you remapped yourself comes back untouched.
  Applying it runs `hyprctl reload`, since the bind lives in
  `hyprland.lua` and that only re-reads its config when Hyprland does.
  Hold Super has no off switch, so this cannot lock you out.
- Documentation caught up with the code. The README had been describing
  an Edit mode that does not ship, the pre-1.6.0 sidebar, and a settings
  bar that 1.7.0 deleted; the manifest description claimed arrows and
  Ctrl+1–9 pick a window, which neither does.

## 1.7.0 — 2026-09-08

Promoted from `beta` (`a5a7d6d`). Never released to `main` on its own;
folded into 1.8.0. Cursor not included.

- Modifiers and the opening gestures moved out of the sidebar and the
  bottom bar into an **Options popup**, opened from the bottom-left
  corner. Close ✕, centred headings, and a **Restore defaults** that also
  clears hidden groups, hidden apps and the search box.
- Four display options: key chips **full / short / icons**, keys or the
  action leading the row, sort **by group or by name**, and search across
  **all / keys / name**.
- Icon chips are drawn from the overlay's own Nerd Font rather than
  emoji, which resolve to a fallback font with different metrics.
  Hovering a row names each glyph in words beside it.
- Left/right/middle mouse collapse to one chip; the wheel gets a mouse
  glyph with a direction arrow.
- Text-size and icon-size sliders, each reset by clicking its label.
- The overlay sizes itself to the display instead of a fixed default.
- Gesture rows name the key they apply to (Double-tap → Super).
- "No keymap sheet" is pinned to the bottom of the tree.
- Fixed: descriptions vanished when toggling Order; every key chip
  rendered blank; hovering a row widened the keys column and slid the
  chips out from under the cursor.

## 1.6.1 — 2026-09-07

Promoted from `beta` (`85f10d0`). Cursor not included.

- Each window of a multi-window app gets its own row, named by the
  program running in it: `Ghostty` expands to `claude` and a shell,
  rather than one row counted `(2)`. The program comes from the
  terminal's foreground process group; where a terminal multiplexes
  windows under one pid, attribution falls back to matching the shell's
  working directory against the window title and declines to guess when
  that is ambiguous.
- Double-click an app to focus its window.
- Chrome PWAs are named from the window title, so `Claude Code` and
  `Grok` instead of extension ids.

## 1.6.0 — 2026-09-07

Promoted from `beta`. Cursor not included.

- Active Apps groups by kind: apps sharing a keymap sheet sit together,
  so five Chrome PWAs are one **Web apps** branch rather than five
  entries repeating Chromium's shortcuts. Apps with no sheet are listed
  under **No keymap sheet**.
- Chrome PWAs are named from their window title, not their extension id
  (`Claude Code`, not `Chromium · fmpnliohjhemenmnlpbf`).
- Show/Hide replaces the toggle switches at every level of the tree.
  Plain text, revealed on row hover, and a hidden branch keeps its label
  and greys out, so hiding can always be undone.
- Every parent carries a caret: collapsed when everything under it is
  hidden, expanded while any of it still shows.
- Double-click an app to focus its window.
- Command rows give more width to the action, so fewer labels truncate.

## 1.5.1 — 2026-09-07

Promoted from `beta` (`9db25ad`). Cursor not included.

- Modifier filters are a 2×2 key-chip grid, ruled off from the tree;
  legend reads All / Must / Hide.
- Switching a channel fetches and fast-forwards it first, so Beta/Main
  do not silently load a stale local tip.
- `install.sh` installs a real directory (symlink folders fail
  `omarchy plugin update`); `--dev` keeps the symlink for local work.
- Lua binds round-trip table args; un-issuable rows are dimmed.
- Key-sending rows target the window that was focused before the overlay
  opened.

## 1.5.0 — 2026-09-07

Promoted from `beta` (`375da99`).

### Overlay

- Super+W closes OmarKEYS while it is open (temporarily remapped; does
  not close the window behind the layer). Esc, Super tap, and click-dim
  still dismiss.
- Keyboard grab after Super is released; overlay hides if the focused
  window changes.

### Keymap

- Enter or click runs the highlighted **Omarchy bind by dispatching its
  action**, not by replaying the chord (chord replay never reached
  Hyprland's matcher). App-sheet rows still send keys to the focused
  window.
- Ranges, gestures, and descriptive rows stay inert and dimmed.

### Sidebar

- Real tree: Omarchy buckets into five areas (Launch & navigate,
  Windows & workspaces, Clipboard & capture, System & media, Apps).
- **Active Apps** is Omarchy's sibling; click a window to load its
  sheet. Named empty state when an app has no sheet; "No windows
  detected" when none are open.
- Click an area or group to solo it on the board (view-only; hide
  settings are restored when the overlay closes).

### Channels

- Corner picker is Main / Beta / Nightly. Claude owns beta; Grok
  promotes beta to main.

### Not in this release

- Phase 3 View | Edit UI
- Cursor working-copy / Cloud Agent changes (`develop-cursor`)
