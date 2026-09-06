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
    }
  }
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

function catalog() {
  var source = withGestures(activeSections(), currentConfig)
  var out = []
  for (var i = 0; i < source.length; i++) {
    out.push({
      title: source[i].title,
      hidden: isHidden(source[i].title)
    })
  }
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
    var sec = { title: all[i].title, rows: all[i].rows.slice() }
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
      if (!q || String(row.keys).toLowerCase().indexOf(q) !== -1
          || String(row.action).toLowerCase().indexOf(q) !== -1
          || String(section.title).toLowerCase().indexOf(q) !== -1)
        rows.push(row)
    }
    if (rows.length)
      out.push({ title: section.title, rows: rows })
  }
  return out
}

function columns(query) {
  var all = filtered(query)
  var left = []
  var right = []
  for (var i = 0; i < all.length; i++) {
    var block = { title: all[i].title, rows: all[i].rows, sectionIndex: i }
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
        runnable: isRunnable(row.keys) && !!sc,
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
