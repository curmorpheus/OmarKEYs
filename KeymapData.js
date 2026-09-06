.pragma library

var sections = [
  {
    title: "Start here",
    rows: [
      { keys: "Super + Space", action: "Omarchy menu" },
      { keys: "Super + Return", action: "Terminal" },
      { keys: "Super + Shift + Return", action: "Browser" },
      { keys: "Super + Shift + F", action: "File manager" },
      { keys: "Super + K", action: "OmarKEYS" },
      { keys: "Double-tap Super", action: "OmarKEYS" },
      { keys: "Hold Super 1s", action: "OmarKEYS" },
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

function filtered(query) {
  var q = String(query || "").toLowerCase().trim()
  var out = []
  for (var s = 0; s < sections.length; s++) {
    var rows = []
    var section = sections[s]
    for (var r = 0; r < section.rows.length; r++) {
      var row = section.rows[r]
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
    if (i % 2 === 0)
      left.push(all[i])
    else
      right.push(all[i])
  }
  return { left: left, right: right }
}

function splitKeys(keys) {
  return String(keys || "").split(/\s*\+\s*/).filter(function(part) {
    return part.length > 0
  })
}
