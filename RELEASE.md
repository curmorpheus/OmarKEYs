# OmarKEYS release notes

Grok writes this file when promoting a finished **beta** (Claude) into
**main**. Cursor does not land on `main`.

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
