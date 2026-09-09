.pragma library

var sections = [
  {
    title: "Main",
    rows: [
      { keys: "Super + Space", action: "Omarchy menu" },
      { keys: "Super + Return", action: "Terminal" },
      { keys: "Super + Shift + Return", action: "Browser" },
      { keys: "Super + Shift + F", action: "File manager" },
      { keys: "Super + K", action: "OmarKEYS" },
      { keys: "Double-tap Super", action: "OmarKEYS" },
      { keys: "Hold Super 5s", action: "OmarKEYS" },
      { keys: "Super + Escape", action: "System menu" },
      { keys: "Super + W", action: "Close window" },
      { keys: "Super + Ctrl + L", action: "Lock screen" }
    ]
  },
  {
    title: "Menus and launchers",
    rows: [
      { keys: "Super + Alt + Space", action: "Apps menu" },
      { keys: "Super + Shift + Ctrl + Space", action: "Theme menu" },
      { keys: "Super + Ctrl + Space", action: "Background switcher" },
      { keys: "Super + Ctrl + O", action: "Toggle menu" },
      { keys: "Super + Ctrl + H", action: "Hardware menu" },
      { keys: "Super + Ctrl + C", action: "Capture menu" },
      { keys: "Super + Shift + Space", action: "Toggle top bar" },
      { keys: "Super + Ctrl + 1-9", action: "Bar panel 1-9" }
    ]
  },
  {
    title: "Windows",
    rows: [
      { keys: "Super + F", action: "Fullscreen" },
      { keys: "Super + Ctrl + F", action: "Tiled fullscreen" },
      { keys: "Super + Alt + F", action: "Full width" },
      { keys: "Super + T", action: "Float / tile" },
      { keys: "Super + J", action: "Toggle split" },
      { keys: "Super + O", action: "Pop out (float and pin)" },
      { keys: "Super + P", action: "Pseudo window" },
      { keys: "Super + L", action: "Toggle workspace layout" },
      { keys: "Super + Backspace", action: "Toggle transparency" },
      { keys: "Super + Shift + Backspace", action: "Toggle gaps" },
      { keys: "Super + Ctrl + Backspace", action: "Square single-window" },
      { keys: "Ctrl + Alt + Delete", action: "Close all windows" }
    ]
  },
  {
    title: "Focus and move",
    rows: [
      { keys: "Super + arrows", action: "Focus window that way" },
      { keys: "Super + Shift + arrows", action: "Swap window that way" },
      { keys: "Alt + Tab", action: "Next window" },
      { keys: "Shift + Alt + Tab", action: "Previous window" },
      { keys: "Ctrl + Alt + Tab", action: "Next monitor" },
      { keys: "Shift + Ctrl + Alt + Tab", action: "Previous monitor" },
      { keys: "Super + left drag", action: "Move window" },
      { keys: "Super + right drag", action: "Resize window" }
    ]
  },
  {
    title: "Workspaces",
    rows: [
      { keys: "Super + 1-9, 0", action: "Switch to workspace 1-10" },
      { keys: "Super + Shift + 1-9, 0", action: "Move window there" },
      { keys: "Super + Shift + Alt + 1-9, 0", action: "Move window silently" },
      { keys: "Super + Tab", action: "Next workspace" },
      { keys: "Super + Shift + Tab", action: "Previous workspace" },
      { keys: "Super + Ctrl + Tab", action: "Former workspace" },
      { keys: "Super + Shift + Alt + arrows", action: "Move workspace to that monitor" },
      { keys: "Super + scroll", action: "Scroll workspace" }
    ]
  },
  {
    title: "Resize",
    rows: [
      { keys: "Super + - / =", action: "Expand / shrink left" },
      { keys: "Super + Shift + - / =", action: "Shrink up / expand down" },
      { keys: "Super + Ctrl or Alt + those", action: "A lot / a little" },
      { keys: "Super + Alt + Home", action: "Save window width" },
      { keys: "Super + Home", action: "Restore window width" }
    ]
  },
  {
    title: "Groups and scratchpad",
    rows: [
      { keys: "Super + G", action: "Toggle grouping" },
      { keys: "Super + Alt + 1-5", action: "Group window 1-5" },
      { keys: "Super + Alt + Tab", action: "Next window in group" },
      { keys: "Super + Alt + arrows", action: "Move into group that way" },
      { keys: "Super + Alt + G", action: "Move out of group" },
      { keys: "Super + S", action: "Toggle scratchpad" },
      { keys: "Super + Alt + S", action: "Send to scratchpad" }
    ]
  },
  {
    title: "Clipboard and text",
    rows: [
      { keys: "Super + C / X / V", action: "Copy / cut / paste" },
      { keys: "Super + Ctrl + V", action: "Clipboard manager" },
      { keys: "Super + Ctrl + E", action: "Emojis" },
      { keys: "Super + Print", action: "Color picker" },
      { keys: "F9", action: "Dictation push-to-talk" },
      { keys: "Super + Ctrl + X", action: "Toggle dictation" }
    ]
  },
  {
    title: "Capture and share",
    rows: [
      { keys: "Print", action: "Screenshot" },
      { keys: "Alt + Print", action: "Screen recording" },
      { keys: "Super + Ctrl + Print", action: "OCR text from screen" },
      { keys: "Super + Ctrl + S", action: "Share" },
      { keys: "Super + Ctrl + .", action: "Transcode" },
      { keys: "Super + Alt + [ / ]", action: "Webcam overlay size" },
      { keys: "Shift + Alt + D", action: "Download video from web app" },
      { keys: "Shift + Alt + L", action: "Copy URL from web app" }
    ]
  },
  {
    title: "Notifications",
    rows: [
      { keys: "Super + ,", action: "Dismiss last" },
      { keys: "Super + Shift + ,", action: "Dismiss all" },
      { keys: "Super + Alt + ,", action: "Invoke last" },
      { keys: "Super + Ctrl + ,", action: "Silence notifications" },
      { keys: "Super + Shift + Alt + ,", action: "Notification history" },
      { keys: "Super + Ctrl + R", action: "Set reminder" },
      { keys: "Super + Ctrl + Alt + R", action: "Show reminders" },
      { keys: "Super + Shift + Ctrl + R", action: "Clear reminders" }
    ]
  },
  {
    title: "Display and look",
    rows: [
      { keys: "Super + /", action: "Scale monitor up" },
      { keys: "Super + Alt + /", action: "Scale monitor down" },
      { keys: "Super + Ctrl + D", action: "Display panel" },
      { keys: "Super + Ctrl + Delete", action: "Toggle laptop display" },
      { keys: "Super + Ctrl + Alt + Delete", action: "Toggle laptop mirroring" },
      { keys: "Super + Ctrl + N", action: "Night light" },
      { keys: "Super + Ctrl + I", action: "Lock on idle" },
      { keys: "Super + Ctrl + Z", action: "Zoom in" }
    ]
  },
  {
    title: "Bar panels",
    rows: [
      { keys: "Super + Ctrl + A", action: "Audio" },
      { keys: "Super + Ctrl + B", action: "Bluetooth" },
      { keys: "Super + Ctrl + W", action: "Network" },
      { keys: "Super + Ctrl + P", action: "Power" },
      { keys: "Super + Ctrl + T", action: "Activity" },
      { keys: "Super + Ctrl + Q", action: "Calculator" },
      { keys: "Super + Ctrl + Alt + T", action: "Time" },
      { keys: "Super + Ctrl + Alt + W", action: "Weather" }
    ]
  },
  {
    title: "Apps",
    rows: [
      { keys: "Super + Alt + Return", action: "Tmux" },
      { keys: "Super + Ctrl + Return", action: "Herdr" },
      { keys: "Super + Shift + N", action: "Editor" },
      { keys: "Super + Shift + O", action: "Obsidian" },
      { keys: "Super + Shift + D", action: "Docker" },
      { keys: "Super + Shift + M", action: "Music" },
      { keys: "Super + Shift + /", action: "Passwords" },
      { keys: "Super + Shift + Ctrl + A", action: "Agent" },
      { keys: "Super + Shift + A", action: "ChatGPT" },
      { keys: "Super + Shift + Alt + A", action: "Grok" },
      { keys: "Super + Shift + E", action: "Email" },
      { keys: "Super + Shift + G", action: "Signal" },
      { keys: "Super + Shift + Y", action: "YouTube" },
      { keys: "Super + Shift + X", action: "X" }
    ]
  },
  {
    title: "Media and hardware",
    rows: [
      { keys: "Volume keys", action: "Volume up, down, mute" },
      { keys: "Alt + volume", action: "Precise volume" },
      { keys: "Shift + mute", action: "Switch audio output" },
      { keys: "Play / pause / next / prev", action: "Media transport" },
      { keys: "Brightness keys", action: "Display brightness" },
      { keys: "Shift + brightness", action: "Min / max brightness" },
      { keys: "Keyboard light keys", action: "Keyboard backlight" },
      { keys: "Mic mute / calculator / power", action: "Hardware extras" }
    ]
  }
]

var liveSections = null
var currentConfig = {
  doubleTap: true,
  holdSeconds: 5,
  hiddenGroups: [],
  modifiers: { Super: "any", Shift: "any", Ctrl: "any", Alt: "any" }
}

function setSections(next) {
  liveSections = (next && next.length) ? next : null
}

// Long key names push the action column off the row, so a chip can be
// abbreviated. Anything not listed falls back to its first 5 characters,
// which keeps XF86-style names from running away.
// X11 spells its punctuation out, so a bind on "[" arrives as
// "bracketleft". The symbol is shorter than the word AND clearer than an
// abbreviation of it, so this replaces the name at every chip style
// rather than living in the short-form table.
var KEY_SYMBOLS = {
  bracketleft: "[", bracketright: "]",
  braceleft: "{", braceright: "}",
  parenleft: "(", parenright: ")",
  semicolon: ";", apostrophe: "'", quotedbl: "\"",
  grave: "`", asciitilde: "~", backslash: "\\", bar: "|",
  comma: ",", period: ".", slash: "/", question: "?",
  minus: "-", underscore: "_", equal: "=", plus: "+",
  colon: ":", less: "<", greater: ">",
  exclam: "!", at: "@", numbersign: "#", dollar: "$",
  percent: "%", asciicircum: "^", ampersand: "&", asterisk: "*"
}

// A chip is one of three things, and they do not want the same treatment:
// a key you press, an action the key performs, or a mouse button. Only
// the first is a keycap, so only the first takes a border.
var MODIFIER_PARTS = {
  Super: true, Shift: true, Ctrl: true, Control: true, Alt: true
}

// What a chord is *about*: the key you actually press. Sorting on the
// whole string files every Super bind under S, which is no order at all
// when almost everything starts with Super.
// "Double-tap" and "Hold 5s" are how a key is pressed, not a key. They
// are chips of their own so the row reads right, but a key sort must look
// past them or every gesture files under D and H instead of under the key
// it applies to.
function isGesturePart(part) {
  return /^(Double-tap|Hold \d+s)$/.test(String(part || ""))
}

function sortKeyOf(keys) {
  var parts = collapseMouse(splitKeys(keys))
  for (var i = parts.length - 1; i >= 0; i--) {
    if (!MODIFIER_PARTS[parts[i]] && !isGesturePart(parts[i]))
      return parts[i]
  }
  // Only modifiers and gestures left, so the last of them is the key the
  // gesture is performed on -- Super, for both of ours.
  for (var j = parts.length - 1; j >= 0; j--) {
    if (!isGesturePart(parts[j]))
      return parts[j]
  }
  return parts.length ? parts[parts.length - 1] : ""
}

// The four buckets "group by key type" sorts into, in the order they are
// shown. Numbers and letters are what you hunt for most; special keys are
// the named and punctuation caps; anything that is not a key on the
// keyboard at all -- mouse buttons, media keys, Super gestures -- goes
// last rather than being filed under a letter it does not have.
var KEY_TYPES = ["Numbers", "Alpha", "Special", "Non-keyboard"]

function keyTypeOf(keys) {
  var raw = String(keys || "")
  // A gesture is a way of holding a key, not a key, and its whole chord
  // survives splitKeys intact -- so it has to be spotted before the rest.
  if (/^(Double-tap|Hold )/i.test(raw))
    return "Non-keyboard"
  var key = sortKeyOf(raw)
  if (keyClass(key) !== "key")
    return "Non-keyboard"
  if (/^[0-9]/.test(key))
    return "Numbers"
  if (/^[A-Za-z]$/.test(key))
    return "Alpha"
  return "Special"
}

function keyClass(name) {
  var key = String(name || "")
  if (key === "LMB" || key === "RMB" || key === "MMB" || key.indexOf("Wheel") === 0)
    return "mouse"
  if (key.indexOf("XF86") === 0)
    return "action"
  return "key"
}

function keySymbol(name) {
  // Case-insensitive: the dump title-cases what it reads back, so the
  // same key arrives as "bracketleft" or "Bracketleft".
  return KEY_SYMBOLS[String(name || "").toLowerCase()] || ""
}

var SHORT_KEYS = {
  Super: "Sup", Shift: "Shft", Control: "Ctrl", Ctrl: "Ctrl", Alt: "Alt",
  Return: "Ret", Enter: "Ret", Escape: "Esc", Space: "Spc", Backspace: "Bksp",
  Delete: "DEL", Insert: "Ins", Print: "Prt", Home: "Home", End: "End",
  PageUp: "PgUp", PageDown: "PgDn", Left: "←", Right: "→", Up: "↑", Down: "↓",
  Tab: "Tab", "Wheel↓": "Whl↓", "Wheel↑": "Whl↑",
  // Chopping the keysym gave "Raise" for volume up and "Power" for the
  // power key; these say what the key does in the width available.
  XF86AudioRaiseVolume: "Vol+", XF86AudioLowerVolume: "Vol-",
  XF86AudioMute: "Mute", XF86AudioMicMute: "Mic",
  XF86MonBrightnessUp: "Bri+", XF86MonBrightnessDown: "Bri-",
  XF86KbdBrightnessUp: "Kbd+", XF86KbdBrightnessDown: "Kbd-",
  XF86KbdLightOnOff: "Kbd", XF86AudioPlay: "Play",
  XF86AudioPause: "Paus", XF86AudioNext: "Next", XF86AudioPrev: "Prev",
  XF86PowerOff: "Pwr", XF86Calculator: "Calc", XF86Eject: "Ejct",
  XF86TouchpadToggle: "Pad", XF86TouchpadOn: "Pad+", XF86TouchpadOff: "Pad-"
}

// Hyprland reports a mouse bind as separate words, so "Super + Left +
// Mouse + Button" arrives as four chips - and the "Left" would then be
// abbreviated to an arrow, which reads as the arrow key. Collapse the
// whole button into one chip before anything else touches it.
function splitGesture(part) {
  var text = String(part || "")
  var hold = text.match(/^Hold (.+) (\d+s)$/)
  if (hold)
    return ["Hold " + hold[2], hold[1]]
  var tap = text.match(/^(Double-tap) (.+)$/)
  if (tap)
    return [tap[1], tap[2]]
  return null
}

function collapseMouse(parts) {
  var out = []
  for (var i = 0; i < parts.length; i++) {
    var name = parts[i]
    var gesture = splitGesture(name)
    if (gesture) {
      out.push(gesture[0])
      out.push(gesture[1])
      continue
    }
    if (parts[i + 1] === "Mouse" && parts[i + 2] === "Button"
        && (name === "Left" || name === "Right" || name === "Middle")) {
      out.push(name === "Left" ? "LMB" : (name === "Right" ? "RMB" : "MMB"))
      i += 2
      continue
    }
    if (name === "mouse_down") { out.push("Wheel↓"); continue }
    if (name === "mouse_up") { out.push("Wheel↑"); continue }
    out.push(name)
  }
  return out
}

// Nerd Font glyphs, which matter because they live in the overlay's own
// font (Omarchy's monospace resolves to JetBrainsMono Nerd Font). Emoji
// would come from Noto Color Emoji as a *fallback*: a colour font with
// different metrics, which sits badly in a row of monospace chips. These
// are opt-in via the "icons" chip style, so a setup without a Nerd Font
// simply never selects it.
var KEY_ICONS = {
  XF86AudioRaiseVolume: "\udb81\udd7e",
  XF86AudioLowerVolume: "\udb81\udd7f",
  XF86AudioMute: "\udb81\udd81",
  XF86AudioMicMute: "\udb80\udf6d",
  XF86MonBrightnessUp: "\udb80\udcdf",
  XF86MonBrightnessDown: "\udb80\udcde",
  XF86KbdBrightnessUp: "\udb80\udf0c",
  XF86KbdBrightnessDown: "\udb80\udf0c",
  XF86KbdLightOnOff: "\udb81\udddc",
  XF86AudioPlay: "\udb80\udfe4",
  XF86AudioPause: "\udb80\udfe4",
  XF86AudioNext: "\udb81\udcad",
  XF86AudioPrev: "\udb81\udcae",
  XF86PowerOff: "\udb81\udc25",
  XF86Calculator: "\udb80\udcec",
  XF86Eject: "\udb82\udc39",
  XF86TouchpadToggle: "\udb80\udd68",
  XF86TouchpadOn: "\udb80\udd68",
  XF86TouchpadOff: "\udb80\udd68",
  LMB: "\udb80\udf7d L",
  RMB: "\udb80\udf7d R",
  MMB: "\udb80\udf7d M",
  "Wheel\u2193": "\udb80\udf7d \u2193",
  "Wheel\u2191": "\udb80\udf7d \u2191",
  Left: "\udb80\udc4d",
  Right: "\udb80\udc54",
  Up: "\udb80\udc5d",
  Down: "\udb80\udc45",
  Return: "\udb80\udf11",
  Enter: "\udb80\udf11",
  Tab: "\udb80\udf12",
  Space: "\udb84\udc50",
  Escape: "\udb84\udeb7",
  Backspace: "\udb80\udc6e",
  Home: "\udb80\udedc",
  Print: "\udb81\udc2a"
}

// What an icon is, in words. The raw token is no good here: hovering to
// find out what a glyph means and being told "XF86AudioRaiseVolume" is
// barely an improvement on the glyph.
var KEY_NAMES = {
  XF86AudioRaiseVolume: "Volume up",
  XF86AudioLowerVolume: "Volume down",
  XF86AudioMute: "Mute",
  XF86AudioMicMute: "Mic mute",
  XF86MonBrightnessUp: "Brightness up",
  XF86MonBrightnessDown: "Brightness down",
  XF86KbdBrightnessUp: "Keyboard light up",
  XF86KbdBrightnessDown: "Keyboard light down",
  XF86KbdLightOnOff: "Keyboard light",
  XF86AudioPlay: "Play",
  XF86AudioPause: "Pause",
  XF86AudioNext: "Next track",
  XF86AudioPrev: "Previous track",
  XF86PowerOff: "Power",
  XF86Calculator: "Calculator",
  XF86Eject: "Eject",
  XF86TouchpadToggle: "Touchpad",
  XF86TouchpadOn: "Touchpad on",
  XF86TouchpadOff: "Touchpad off",
  LMB: "Left click",
  RMB: "Right click",
  MMB: "Middle click",
  "Wheel\u2193": "Wheel down",
  "Wheel\u2191": "Wheel up"
}

function keyName(name) {
  var key = String(name || "")
  return KEY_NAMES[key] || key
}

function gestureLabel(part) {
  return splitGesture(part)
}

// Index for index with displayKeys, like displayNames: collapseMouse runs
// for all three, so a chip, its name and its class share a position.
function displayClasses(keys) {
  var parts = collapseMouse(splitKeys(keys))
  var out = []
  for (var i = 0; i < parts.length; i++)
    out.push(keyClass(parts[i]))
  return out
}

function displayNames(keys) {
  var parts = collapseMouse(splitKeys(keys))
  var out = []
  for (var i = 0; i < parts.length; i++)
    out.push(keyName(parts[i]))
  return out
}

// One modifier keycap looks like four different things depending on the
// keyboard in front of you, so the whole set moves together rather than
// Super picking a symbol on its own.
//
// Mac is the only layout that symbols all four; a PC keycap prints the
// words, which is why the Windows and Omarchy sets carry a logo for Super
// and leave the rest to fall back to text. Command, not Option, is Super:
// on a Mac keyboard under Linux it is Command that reports KEY_LEFTMETA,
// while Option arrives as Alt. The kernel's own hid_apple says so -- its
// swap_opt_cmd parameter reads "Swap the Option (Alt) and Command (Flag)
// keys". Every glyph here was checked against the overlay's font.
// The mark used wherever Omarchy itself is named: the tree's root row and
// the Omarchy keyboard set. Omarchy ships its own logo as block-drawing
// art rather than a font glyph, so this is the Arch mark -- Omarchy is
// Arch-based, and the glyph is in the overlay's font.
var OMARCHY_ICON = "\uf303"

function omarchyIcon() {
  return OMARCHY_ICON
}

var KEYBOARD_SETS = {
  text: {},
  mac: {
    Super: "\u2318",
    Control: "\u2303",
    Ctrl: "\u2303",
    Shift: "\u21e7",
    Alt: "\u2325"
  },
  windows: { Super: "\udb81\uddb3" },
  omarchy: { Super: OMARCHY_ICON }
}

// Values from when this was a Super-only glyph picker, so a saved setting
// keeps its meaning instead of snapping back to the default.
var LEGACY_KEYBOARD_OS = { command: "mac", option: "mac", superman: "windows" }

function normalizeKeyboardOS(value) {
  var key = String(value || "")
  if (LEGACY_KEYBOARD_OS[key])
    return LEGACY_KEYBOARD_OS[key]
  return KEYBOARD_SETS[key] ? key : "windows"
}

function modifierIcon(name, os) {
  return KEYBOARD_SETS[normalizeKeyboardOS(os)][String(name || "")] || ""
}

// Shapes that live outside the private use areas, so the chip cannot spot
// them by codepoint range. Kept beside the tables that produce them.
var SYMBOL_ICONS = {
  "\u2318": true, "\u2303": true, "\u21e7": true, "\u2325": true
}

function isIconGlyph(text) {
  var s = String(text || "")
  if (!s.length)
    return false
  if (SYMBOL_ICONS[s.charAt(0)])
    return true
  var cp = s.codePointAt(0)
  return cp >= 0xF0000 || (cp >= 0xE000 && cp <= 0xF8FF)
}



function iconKey(name) {
  return KEY_ICONS[String(name || "")] || ""
}

function shortKey(name) {
  var key = String(name || "")
  if (SHORT_KEYS[key])
    return SHORT_KEYS[key]
  var symbol = keySymbol(key)
  if (symbol)
    return symbol
  if (/^(Hold \d+s|Double-tap)$/.test(key))
    return key
  // No blind truncation. Cutting to five characters turned "Bracketleft"
  // into "Brack" and quietly dropped the 0 from the "1-9, 0" range --
  // shorter, but no longer the name of any key. Anything genuinely long
  // belongs in SHORT_KEYS, where a person chose the abbreviation.
  return key
}

// The chord the options panel shows as its sample. It has to look
// different in every chip style, or the sample says nothing about the
// setting it sits under: "Super + Ctrl + K" was identical at full, short
// and icons, because none of its parts has a short form or an icon.
// Shift shortens, Return does both. There is a test.
var SAMPLE_CHORD = "Super + Shift + Return"

function sampleChord() {
  return SAMPLE_CHORD
}

function displayKeys(keys, style, keyboardOS) {
  var parts = collapseMouse(splitKeys(keys))
  // The keyboard set overrides whatever the chip style would have drawn:
  // choosing a layout is pointless if its keycaps only show in icon mode.
  var os = keyboardOS || (currentConfig && currentConfig.keyboardType)
  var out = []
  for (var i = 0; i < parts.length; i++) {
    var mod = modifierIcon(parts[i], os)
    if (mod) {
      out.push(mod)
      continue
    }
    var symbol = keySymbol(parts[i])
    if (symbol) {
      out.push(symbol)
      continue
    }
    if (style === "icons") {
      // Anything without an icon keeps its short text, so the row stays
      // readable rather than half-blank.
      out.push(iconKey(parts[i]) || shortKey(parts[i]))
      continue
    }
    if (style === "short") {
      out.push(shortKey(parts[i]))
      continue
    }
    // Full chips spell the key out, but "XF86AudioRaiseVolume" is the
    // X11 name, not a spelling of anything. These have a human one.
    out.push(parts[i].indexOf("XF86") === 0 ? keyName(parts[i]) : parts[i])
  }
  return out
}

function setConfig(cfg) {
  var hidden = []
  if (cfg && cfg.hiddenGroups) {
    for (var i = 0; i < cfg.hiddenGroups.length; i++)
      hidden.push(String(cfg.hiddenGroups[i]))
  }
  var modsIn = (cfg && cfg.modifiers) || {}
  currentConfig = {
    doubleTap: !cfg || cfg.doubleTap !== false,
    holdSeconds: Math.max(1, Math.min(10, Number(cfg && cfg.holdSeconds) || 5)),
    hiddenGroups: hidden,
    modifiers: {
      Super: normalizeModifierMode(modsIn.Super),
      Shift: normalizeModifierMode(modsIn.Shift),
      Ctrl: normalizeModifierMode(modsIn.Ctrl),
      Alt: normalizeModifierMode(modsIn.Alt)
    },
    chipStyle: (cfg && (cfg.chipStyle === "short" || cfg.chipStyle === "full"))
      ? cfg.chipStyle : "icons",
    rowLayout: (cfg && cfg.rowLayout === "keys") ? "keys" : "action",
    sortBy: (cfg && (cfg.sortBy === "section" || cfg.sortBy === "action"))
      ? cfg.sortBy : "key",
    grouping: (cfg && (cfg.grouping === "off" || cfg.grouping === "keytype"))
      ? cfg.grouping : "topic",
    searchMode: (cfg && (cfg.searchMode === "keys" || cfg.searchMode === "action"))
      ? cfg.searchMode : "all",
    keyboardType: normalizeKeyboardOS(cfg
      && (cfg.keyboardType || cfg.keyboardOS || cfg.superIcon))
  }
}

function chipStyle() {
  return currentConfig.chipStyle || "full"
}

function rowLayout() {
  return currentConfig.rowLayout || "keys"
}

function searchMode() {
  return currentConfig.searchMode || "all"
}

function sortBy() {
  return currentConfig.sortBy || "key"
}

function grouping() {
  return currentConfig.grouping || "topic"
}

function compareRows(a, b) {
  var mode = sortBy()
  var av, bv
  if (mode === "key") {
    av = sortKeyOf(a.keys).toLowerCase()
    bv = sortKeyOf(b.keys).toLowerCase()
    // Letters and digits first. Punctuation sorts below them in code
    // order, which would open the list with , - . / before any key you
    // are likely to be hunting for.
    var ar = /^[a-z0-9]/.test(av) ? 0 : 1
    var br = /^[a-z0-9]/.test(bv) ? 0 : 1
    if (ar !== br)
      return ar - br
  } else {
    av = String(a.action).toLowerCase()
    bv = String(b.action).toLowerCase()
  }
  if (av !== bv)
    return av < bv ? -1 : 1
  // Same key, so fall back to the action -- two rows on the same chord
  // should still land in a stable order rather than however they arrived.
  var aa = String(a.action).toLowerCase()
  var ba = String(b.action).toLowerCase()
  return aa < ba ? -1 : (aa > ba ? 1 : 0)
}

// Which field the query is tested against. "Search by modifiers" means the
// chord text, so Super+Shift narrows to those; "by description" means the
// action, so typing a word never matches a stray key name.
// Filtering by key means the key you pressed, not the letters its name
// happens to contain. A substring match over the whole chord made "k"
// find Bac(k)space and "s" find Super, Shift, Space and Escape -- which
// is every row, so the filter did nothing.
function keyMatchesQuery(keys, q) {
  var query = String(q || "").toLowerCase()
  if (!query)
    return true
  var parts = collapseMouse(splitKeys(keys))
  // A captured keystroke arrives as a whole chord ("super + shift + k"),
  // so every key in it has to be in the row -- otherwise capturing
  // Super+K would show every K bind whatever else it needs held down.
  var wanted = splitKeys(query)
  if (!wanted.length)
    return true
  for (var w = 0; w < wanted.length; w++) {
    var hit = false
    for (var i = 0; i < parts.length && !hit; i++) {
      if (partMatchesKey(parts[i], wanted[w]))
        hit = true
    }
    if (!hit)
      return false
  }
  return true
}

// Whole keys only, never a fragment of one.
function partMatchesKey(part, query) {
  var key = String(part || "")
  if (key.toLowerCase() === query)
    return true
  // Punctuation arrives spelled out, so "[" has to find "bracketleft".
  var symbol = keySymbol(key)
  if (symbol && symbol.toLowerCase() === query)
    return true
  // A range or list is several keys written as one ("1-9", "1-9, 0"), so
  // a digit inside it counts as that key. Without this, pressing 3 finds
  // nothing at all while the workspace binds are sitting right there.
  if (!/^[0-9,\s-]+$/.test(key) || !/^[0-9]$/.test(query))
    return false
  var wanted = Number(query)
  var segs = key.split(",")
  for (var s = 0; s < segs.length; s++) {
    var seg = segs[s].replace(/^\s+|\s+$/g, "")
    var span = seg.match(/^([0-9])-([0-9])$/)
    if (span) {
      if (wanted >= Number(span[1]) && wanted <= Number(span[2]))
        return true
    } else if (seg === query) {
      return true
    }
  }
  return false
}

function rowMatchesQuery(row, sectionTitle, q) {
  if (!q)
    return true
  var mode = searchMode()
  var keys = String(row.keys).toLowerCase()
  var action = String(row.action).toLowerCase()
  if (mode === "keys")
    return keyMatchesQuery(row.keys, q)
  if (mode === "action")
    return action.indexOf(q) !== -1
  // "All" reads the length of what you typed. One character is a key --
  // nobody searches descriptions for "k", and as a substring it matched
  // most of the board. More than one is a word, so it searches
  // everything, keys included: "delete" should still find Delete.
  if (String(q).length === 1)
    return keyMatchesQuery(row.keys, q)
  return keys.indexOf(q) !== -1 || action.indexOf(q) !== -1
    || String(sectionTitle).toLowerCase().indexOf(q) !== -1
}

function normalizeModifierMode(value) {
  if (value === "must" || value === "hide" || value === "any")
    return value
  if (value === false)
    return "hide"
  return "any"
}

function rowUsesModifier(row, name) {
  var blob = String((row && row.mods) || "") + " " + String((row && row.keys) || "")
  var low = blob.toLowerCase()
  if (name === "Super")
    return /\bsuper\b/.test(low)
  if (name === "Shift")
    return /\bshift\b/.test(low)
  if (name === "Ctrl")
    return /\bctrl\b|\bcontrol\b/.test(low)
  if (name === "Alt")
    return /\balt\b/.test(low)
  return false
}

function rowMatchesModifiers(row) {
  var modes = currentConfig.modifiers || {}
  var names = ["Super", "Shift", "Ctrl", "Alt"]
  for (var i = 0; i < names.length; i++) {
    var name = names[i]
    var mode = modes[name] || "any"
    var uses = rowUsesModifier(row, name)
    if (mode === "must" && !uses)
      return false
    if (mode === "hide" && uses)
      return false
  }
  return true
}

function isHidden(title) {
  var hidden = currentConfig.hiddenGroups || []
  for (var i = 0; i < hidden.length; i++) {
    if (hidden[i] === title)
      return true
  }
  return false
}

function catalogFor(sectionList) {
  var source = sectionList && sectionList.length ? sectionList : []
  var out = []
  for (var i = 0; i < source.length; i++) {
    out.push({
      title: source[i].title,
      hidden: isHidden(source[i].title)
    })
  }
  return out
}

function catalog() {
  return catalogFor(withGestures(activeSections(), currentConfig))
}

// Five top-level areas the sidebar tree groups Omarchy's topic groups
// under. Keep this in sync with SECTION_RULES in dump-keymap — every
// title dump-keymap can emit (14 rules + its own "Other" fallback)
// should appear exactly once below.
var areaMap = [
  { title: "Launch & navigate", groups: ["Main", "Menus and launchers", "Bar panels"] },
  { title: "Windows & workspaces", groups: ["Windows", "Focus and move", "Workspaces", "Resize", "Groups and scratchpad"] },
  { title: "Clipboard & capture", groups: ["Clipboard and text", "Capture and share"] },
  { title: "System & media", groups: ["Notifications", "Display and look", "Media and hardware", "Other"] },
  { title: "Apps", groups: ["Apps"] }
]

function groupedCatalog(sectionList) {
  var flat = catalogFor(sectionList)
  var byTitle = {}
  for (var i = 0; i < flat.length; i++)
    byTitle[flat[i].title] = flat[i]
  var used = {}
  var out = []
  for (var a = 0; a < areaMap.length; a++) {
    var groups = []
    var names = areaMap[a].groups
    for (var j = 0; j < names.length; j++) {
      var entry = byTitle[names[j]]
      if (entry) {
        groups.push(entry)
        used[names[j]] = true
      }
    }
    if (groups.length)
      out.push({ title: areaMap[a].title, groups: groups })
  }
  // Defensive: a group title not covered by areaMap above (e.g. one
  // added to SECTION_RULES / sections without updating this map) still
  // shows up here instead of silently vanishing from the tree.
  var leftovers = []
  for (var k = 0; k < flat.length; k++) {
    if (!used[flat[k].title])
      leftovers.push(flat[k])
  }
  if (leftovers.length)
    out.push({ title: "Other", groups: leftovers })
  return out
}

function activeSections() {
  return liveSections && liveSections.length ? liveSections : sections
}

function gestureRows(cfg) {
  var hold = (cfg && cfg.holdSeconds) || 5
  var rows = []
  if (!cfg || cfg.doubleTap !== false)
    rows.push({ keys: "Double-tap Super", action: "OmarKEYS" })
  rows.push({ keys: "Hold Super " + hold + "s", action: "OmarKEYS" })
  return rows
}

function withGestures(all, cfg) {
  var extra = gestureRows(cfg)
  var out = []
  var injected = false
  for (var i = 0; i < all.length; i++) {
    var sec = { title: all[i].title, rows: all[i].rows.slice(),
      qualifier: all[i].qualifier || "" }
    if (!injected && sec.title === "Main") {
      var rows = []
      var placed = false
      for (var r = 0; r < sec.rows.length; r++) {
        var row = sec.rows[r]
        if (/double-tap super|hold super/i.test(String(row.keys)))
          continue
        rows.push(row)
        if (!placed && (String(row.keys) === "Super + K" || /omarkeys/i.test(String(row.action)))) {
          for (var e = 0; e < extra.length; e++)
            rows.push(extra[e])
          placed = true
        }
      }
      if (!placed) {
        for (var e2 = 0; e2 < extra.length; e2++)
          rows.push(extra[e2])
      }
      sec.rows = rows
      injected = true
    }
    out.push(sec)
  }
  return out
}

function filtered(query) {
  var q = String(query || "").toLowerCase().trim()
  var source = withGestures(activeSections(), currentConfig)
  var out = []
  for (var s = 0; s < source.length; s++) {
    var rows = []
    var section = source[s]
    if (isHidden(section.title))
      continue
    for (var r = 0; r < section.rows.length; r++) {
      var row = section.rows[r]
      if (!rowMatchesModifiers(row))
        continue
      if (rowMatchesQuery(row, section.title, q))
        rows.push(row)
    }
    if (sortBy() !== "section")
      rows = rows.slice().sort(compareRows)
    if (rows.length)
      // qualifier rides along: the all-apps view tags each section with
      // the kind it came from, and rebuilding the object would drop it.
      out.push({ title: section.title, rows: rows, qualifier: section.qualifier || "" })
  }
  if (grouping() === "topic")
    return out

  // Both remaining modes regroup across topics, so the topic sections are
  // only ever a staging step here. Each row carries its topic out with it:
  // once the headings are gone that is the only place it survives, and the
  // row is the one place left to say it. Copies, so the source sections
  // are not tagged for the mode they happen to be viewed in.
  var flat = []
  for (var i = 0; i < out.length; i++) {
    for (var r2 = 0; r2 < out[i].rows.length; r2++) {
      var src = out[i].rows[r2]
      var copy = {}
      for (var field in src)
        copy[field] = src[field]
      copy.topic = out[i].title
      flat.push(copy)
    }
  }
  flat.sort(compareRows)

  if (grouping() === "keytype") {
    var buckets = {}
    for (var f = 0; f < flat.length; f++) {
      var type = keyTypeOf(flat[f].keys)
      if (!buckets[type])
        buckets[type] = []
      buckets[type].push(flat[f])
    }
    var typed = []
    for (var t = 0; t < KEY_TYPES.length; t++) {
      // An empty bucket is left out rather than shown as a bare heading.
      if (buckets[KEY_TYPES[t]])
        typed.push({ title: KEY_TYPES[t], rows: buckets[KEY_TYPES[t]] })
    }
    return typed
  }

  // Ungrouped: one untitled run. Topic order is what the sections were
  // for, so with them off an unsorted list would be in no order at all.
  return flat.length ? [{ title: "", rows: flat }] : []
}

function columns(query) {
  var all = filtered(query)
  var left = []
  var right = []
  // Ungrouped: there is one block, so alternating sections would leave the
  // right column empty. Split the run down the middle instead.
  if (all.length === 1 && all[0].title === "") {
    var rows = all[0].rows
    var half = Math.ceil(rows.length / 2)
    if (half)
      left.push({ title: "", rows: rows.slice(0, half), sectionIndex: 0 })
    if (rows.length > half)
      right.push({ title: "", rows: rows.slice(half), sectionIndex: 0 })
    return { left: left, right: right }
  }
  for (var i = 0; i < all.length; i++) {
    // qualifier rides along here too: this is the last object rebuild
    // between the merged app sheets and the board.
    var block = { title: all[i].title, rows: all[i].rows, sectionIndex: i,
      qualifier: all[i].qualifier || "" }
    if (i % 2 === 0)
      left.push(block)
    else
      right.push(block)
  }
  return { left: left, right: right }
}

function splitKeys(keys) {
  return String(keys || "").split(/\s*\+\s*/).filter(function(part) {
    return part.length > 0
  })
}

function isRunnable(keys) {
  var k = String(keys || "")
  if (!k)
    return false
  if (/\d-\d/.test(k) || /arrows|drag|scroll|volume keys|brightness keys|keyboard light|play \/ pause|mic mute|double-tap|hold super/i.test(k))
    return false
  if (/\s\/\s/.test(k))
    return false
  return true
}

var KEY_SYMS = {
  Return: "Return",
  Enter: "Return",
  Space: "space",
  Escape: "Escape",
  Backspace: "BackSpace",
  Print: "Print",
  Home: "Home",
  Delete: "Delete",
  Tab: "Tab",
  ",": "comma",
  ".": "period",
  "-": "minus",
  "=": "equal",
  "/": "slash",
  "[": "bracketleft",
  "]": "bracketright"
}

var MOD_SYMS = {
  Super: "SUPER",
  Shift: "SHIFT",
  Ctrl: "CTRL",
  Control: "CTRL",
  Alt: "ALT"
}

function shortcut(keys) {
  if (!isRunnable(keys))
    return null
  var parts = splitKeys(keys)
  var mods = []
  var key = ""
  for (var i = 0; i < parts.length; i++) {
    var p = parts[i]
    if (MOD_SYMS[p])
      mods.push(MOD_SYMS[p])
    else
      key = KEY_SYMS[p] || p
  }
  if (!key)
    return null
  return { mods: mods.join(" "), key: key }
}

function navList(query) {
  var all = filtered(query)
  var items = []
  for (var s = 0; s < all.length; s++) {
    for (var r = 0; r < all[s].rows.length; r++) {
      var row = all[s].rows[r]
      var sc = null
      if (row.bindKey)
        sc = { mods: row.mods || "", key: row.bindKey }
      else
        sc = shortcut(row.keys)
      items.push({
        section: s,
        sectionTitle: all[s].title,
        keys: row.keys,
        action: row.action,
        // A Hyprland bind's own action, when dump-keymap recovered it.
        // Preferred over replaying the chord: synthetic keys sent to a
        // window never reach Hyprland's bind matcher.
        dispatcher: row.dispatcher || "",
        dispatchArg: row.arg || "",
        // dump-keymap sets runnable false on binds the overlay cannot
        // issue; that verdict wins over anything the chord text implies.
        runnable: row.runnable === false
          ? false
          : ((isRunnable(row.keys) && !!sc) || !!row.dispatcher),
        shortcut: sc
      })
    }
  }
  return items
}

function sectionStarts(items) {
  var starts = []
  var last = null
  for (var i = 0; i < items.length; i++) {
    if (items[i].section !== last) {
      starts.push(i)
      last = items[i].section
    }
  }
  return starts
}
