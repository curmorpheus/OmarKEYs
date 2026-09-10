# Verifying changes

OmarKEYS sits on two stacks that lie to you in specific ways: Hyprland's input
path and Quickshell's layer surfaces. Both look simple from the source and
behave differently on a real desktop.

This is what that cost us, written down so it costs the next person less. The
platform facts below were each found the expensive way — a fix shipped, reviewed
and believed, then contradicted by one keypress.

## Platform facts that are not obvious from the source

**`input.keyboard.key` reports XKB keycodes, not evdev.** The bridge pushes
`keyEvent.keycode + 8` ([`LuaEventHandler.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/config/lua/LuaEventHandler.cpp#L179-L184)).
`KEY_LEFTMETA` 125 arrives as **133**, `KEY_LEFTALT` 56 as **64**. Get this
backwards and the code compiles, the tests pass, and nothing works. Confirm it
by logging a real press before building on it.

**A keycode is a physical position; XKB options rewrite the keysym.** So no fixed
table of keycodes describes every keyboard. `altwin:swap_lalt_lwin` leaves an
ordinary Alt sitting on the position you were about to call Super. If you need to
know what a key *means*, ask the keymap; do not assume the position.

**`hl.is_key_down()` inside the handler describes the state *before* the current
event.** Hyprland emits the Lua event, then the keybind manager records the
press, and `is_key_down` scans what the keybind manager recorded. On a press it
is `false` for the very key being pressed. Reading it one tick later
(`hl.timer`, 1 ms) gives the state the event produced.

**An input method duplicates every key event.** fcitx5 and ibus register their
own virtual keyboard and re-emit what you press, so one physical press arrives
twice. Check with `hyprctl devices` — a `hl-virtual-keyboard-fcitx5` in the
keyboards list means every handler here runs twice per key. Any logic that counts
events, rather than reacting to them, has to tolerate the echo.

**A layer surface is not a toplevel.** Ordinary pointer movement across a layer
does not change `ToplevelManager.activeToplevel`. Remove the layer from a screen
and the pointer reaches a real window there, which does — and with Hyprland's
`follow_mouse = 1`, merely *looking* at another monitor then counts as an app
switch.

**`WlrLayershell::deleteOnInvisible()` returns `true`.** Hiding a `PanelWindow`
destroys its layer surface and showing it builds a new one, so `visible` on a
panel is not a cheap toggle — it emits `layer.closed` / `layer.opened`, which
`hyprland.lua` counts. Hiding an `Item` *inside* the window does none of that.
Prefer hiding the content.

**Compositor focus and Qt item focus move independently.** A binding can hand the
exclusive keyboard grab to a different panel while its `keyCatcher` never takes
item focus — the card looks right and accepts no keys. If you move what is
showing, call `requestFocus()`.

**Learned or latched state here is global, not per-device.** There is no
per-keyboard signal in the Lua API, so a fact learned from one keyboard applies
to all of them. Two keyboards that disagree about a keycode cannot both be
represented.

## How to check a change

The ordering matters more than the tooling.

**1. Verify the premise on hardware before writing the fix.** The most expensive
error in this file's history was reading the keycode namespace wrong from the
source. It invalidated the fix *and* its test suite, because the test encoded the
same assumption the code did. One temporary `hl.on` handler logging real
keypresses settled it in a minute.

**2. Get a rough version onto a real desktop before polishing.** Reviews of an
approach that live testing then kills are wasted. Three of four revisions to the
multi-monitor fix came from moving a mouse and unplugging a monitor; none were
reachable by reading code.

**3. Do not let the harness encode your assumption.** A stub proves only that the
code agrees with your model of the platform. The Super harness called the handler
once per press because that is what its author believed; fcitx5 calls it twice,
and every review of the harness confirmed the wrong thing. Where a stub stands in
for the compositor, drive the real path at least once.

**4. Mutation-test the guards.** A passing suite does not mean an invariant is
pinned. Three cases in the Super suite passed with the guard they claimed to
protect deleted outright. Remove each guard in turn and confirm something fails:

```sh
sed 's/<the guard>/<weaker form>/' hyprland.lua > /tmp/m.lua
OMARKEYS_LUA=/tmp/m.lua lua5.4 tests/super-detection.test.lua   # must fail
```

**5. Write the reproduction recipe carefully.** A recipe that exercises the old
path can "confirm" a fix that does nothing. After `altwin:swap_lalt_lwin`, the
physical *Super* position types `Alt_L` — testing there proves nothing; the
physical *Alt* position is the one that has to be learned.

## Running the suites

```sh
node --test tests/*.test.js       # includes the Lua suite via a wrapper
lua5.4 tests/super-detection.test.lua
omarchy plugin validate .
git diff --check
```

After editing `hyprland.lua` on a live install: `hyprctl reload`, then
`hyprctl configerrors`. QML changes need `omarchy restart shell`.

To watch what the compositor is actually doing, a temporary handler in
`~/.config/hypr/input.lua` beats reasoning:

```lua
hl.on("input.keyboard.key", function(code, _, state)
  -- log modifier keycodes only; do not write a keylogger
end)
```

Remove it and its log when done.

## Reviewing with more than one agent

Useful, but not the cheap part. Three model reviews and a security pass all
cleared the Super fix; the bug that shipped was found by one keypress. Reach for
this when the change is going somewhere you cannot easily test, not as a
substitute for testing.

If you do, the shape that worked:

- **Give each reviewer a different question.** Running two on the same brief
  mostly buys correlated blind spots. The finding that mattered came from a brief
  that said *look for what a first pass would miss* and *challenge the reasoning*,
  not from adding a model.
- **Ask explicitly about assumptions and constants.** Every reviewer audits the
  algorithm; none question the literals it starts from. The longest-lived bug
  here was two hardcoded numbers nobody looked at.
- **Ask for a style-and-fit pass separately.** No correctness review reports that
  a test file is not wired into the runner, or that review numbering leaked into
  test names.
- **Sandboxed agents usually have no network.** Fetch the upstream sources they
  ask for and point them at local copies instead of approving repeated failures.

With [Herdr](https://herdr.dev), each reviewer gets its own pane:

```sh
herdr pane split --current --direction right --cwd "$PWD"
herdr agent start reviewer --kind codex --pane w1:p3     # or --kind grok
herdr agent prompt reviewer "Read <brief path> and do exactly what it says."
herdr agent get reviewer     # idle | working | blocked | done
herdr agent read reviewer    # blocked means it wants an approval
```

Put the brief in a file and point the agent at it — multi-line prompts do not
survive a TUI. Approve commands individually rather than taking
"always-approve": these agents run with your permissions in your checkout. If a
review is long, have it write the result to a file; terminal scrollback truncates.
