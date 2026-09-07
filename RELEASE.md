# OmarKEYS release notes

Grok writes this file when promoting a finished **beta** (Claude) into
**main**. Cursor does not land on `main`.

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
