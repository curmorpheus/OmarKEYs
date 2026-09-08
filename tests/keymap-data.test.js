const { test } = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const src = fs.readFileSync(path.join(__dirname, "..", "KeymapData.js"), "utf8")
  .replace(/^\.pragma library\s*/, "")
const context = {}
vm.createContext(context)
vm.runInContext(src + "\nthis.filtered = filtered; this.columns = columns; this.splitKeys = splitKeys; this.sections = sections; this.isRunnable = isRunnable; this.shortcut = shortcut; this.navList = navList; this.sectionStarts = sectionStarts; this.setConfig = setConfig; this.setSections = setSections; this.catalog = catalog; this.catalogFor = catalogFor; this.groupedCatalog = groupedCatalog; this.displayKeys = displayKeys; this.shortKey = shortKey; this.displayNames = displayNames; this.rowMatchesModifiers = rowMatchesModifiers; this.normalizeModifierMode = normalizeModifierMode; this.isIconGlyph = isIconGlyph; this.modifierIcon = modifierIcon; this.normalizeKeyboardOS = normalizeKeyboardOS; this.keyClass = keyClass; this.sortKeyOf = sortKeyOf; this.omarchyIcon = omarchyIcon; this.keyTypeOf = keyTypeOf; this.displayClasses = displayClasses;", context)

test("splitKeys splits Super chords", () => {
  assert.equal(JSON.stringify(context.splitKeys("Super + K")), JSON.stringify(["Super", "K"]))
  assert.equal(JSON.stringify(context.splitKeys("Print")), JSON.stringify(["Print"]))
})

test("filtered matches keys, actions, and titles", () => {
  const byKeys = context.filtered("super + k")
  assert.ok(byKeys.some((s) => s.rows.some((r) => r.action === "OmarKEYS")))
  const byTitle = context.filtered("workspaces")
  assert.equal(byTitle[0].title, "Workspaces")
})

test("columns splits sections left/right", () => {
  const cols = context.columns("")
  assert.ok(cols.left.length >= 1)
  assert.ok(cols.right.length >= 1)
  assert.equal(cols.left.length + cols.right.length, context.sections.length)
  assert.equal(cols.left[0].sectionIndex, 0)
  assert.equal(cols.right[0].sectionIndex, 1)
  assert.equal(cols.left[0].title, "Main")
})

test("runnable shortcuts parse for Enter-to-run", () => {
  assert.equal(context.isRunnable("Super + Return"), true)
  assert.equal(context.isRunnable("Super + 1-9, 0"), false)
  const sc = context.shortcut("Super + Shift + Return")
  assert.equal(sc.mods, "SUPER SHIFT")
  assert.equal(sc.key, "Return")
})

test("navList and sectionStarts cover filtered rows", () => {
  const items = context.navList("")
  assert.ok(items.length > 10)
  const starts = context.sectionStarts(items)
  assert.equal(starts[0], 0)
  assert.ok(starts.length === context.filtered("").length)
  assert.ok(starts.length >= 10)
  assert.equal(items[starts[0]].sectionTitle, "Main")
  assert.equal(items[starts[1]].sectionTitle, "Menus and launchers")
})

test("digit blocks map onto the first ten sections", () => {
  // Pinned to topic order: this is about which section a digit lands on,
  // not about how rows are sorted inside one. The default sort is by key.
  context.setConfig({ sortBy: "section", grouping: "topic" })
  const items = context.navList("")
  const starts = context.sectionStarts(items)
  const titles = starts.map((i) => items[i].sectionTitle)
  assert.equal(titles[0], "Main")
  assert.equal(titles[9], "Notifications")
  assert.ok(items[0].runnable)
  assert.equal(items[0].shortcut.key, "space")
  context.setConfig({})
})

test("config hold time and double-tap appear on Main", () => {
  context.setConfig({ doubleTap: true, holdSeconds: 5 })
  const on = context.navList("")
  assert.ok(on.some((row) => row.keys === "Hold Super 5s"))
  assert.ok(on.some((row) => row.keys === "Double-tap Super"))
  context.setConfig({ doubleTap: false, holdSeconds: 8 })
  const off = context.navList("")
  assert.ok(off.some((row) => row.keys === "Hold Super 8s"))
  assert.ok(!off.some((row) => row.keys === "Double-tap Super"))
  context.setConfig({ doubleTap: true, holdSeconds: 5 })
})

test("dump-keymap reads live Hyprland bindings", () => {
  const { execFileSync } = require("node:child_process")
  const raw = execFileSync("python3", [path.join(__dirname, "..", "dump-keymap")], { encoding: "utf8" })
  const data = JSON.parse(raw)
  assert.ok(Array.isArray(data.sections))
  const start = data.sections.find((s) => s.title === "Main")
  assert.ok(start)
  assert.ok(start.rows.some((r) => /omarchy menu/i.test(r.action)))
  assert.ok(start.rows.some((r) => r.keys.includes("Super")))
  const menu = start.rows.find((r) => /omarchy menu/i.test(r.action))
  assert.ok(menu)
  assert.ok(menu.bindKey)
  assert.ok(Array.isArray(data.clients))
})

test("hidden groups stay in the catalog but leave the grid", () => {
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: ["Windows"] })
  const names = context.catalog().map((g) => g.title)
  assert.ok(names.includes("Windows"))
  assert.ok(context.catalog().some((g) => g.title === "Windows" && g.hidden))
  assert.ok(!context.filtered("").some((s) => s.title === "Windows"))
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: [] })
})

test("modifier any/must/hide filters chords", () => {
  assert.equal(context.normalizeModifierMode(false), "hide")
  assert.equal(context.normalizeModifierMode(true), "any")
  context.setConfig({
    doubleTap: true,
    holdSeconds: 5,
    hiddenGroups: [],
    modifiers: { Super: "hide", Shift: "any", Ctrl: "any", Alt: "any" }
  })
  const hiddenSuper = context.navList("")
  assert.ok(!hiddenSuper.some((r) => /super/i.test(r.keys)))
  assert.ok(hiddenSuper.some((r) => /print|tab|delete/i.test(r.keys)))
  context.setConfig({
    doubleTap: true,
    holdSeconds: 5,
    hiddenGroups: [],
    modifiers: { Super: "must", Shift: "any", Ctrl: "any", Alt: "any" }
  })
  const mustSuper = context.navList("")
  assert.ok(mustSuper.length > 0)
  assert.ok(mustSuper.every((r) => /super/i.test(r.keys)))
  context.setConfig({
    doubleTap: true,
    holdSeconds: 5,
    hiddenGroups: [],
    modifiers: { Super: "must", Shift: "hide", Ctrl: "any", Alt: "any" }
  })
  const mustSuperHideShift = context.navList("")
  assert.ok(mustSuperHideShift.some((r) => r.keys === "Super + Space"))
  assert.ok(!mustSuperHideShift.some((r) => /\bshift\b/i.test(r.keys)))
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: [] })
})

test("hiding every group empties the grid", () => {
  const titles = context.catalog().map((g) => g.title)
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: titles })
  assert.equal(context.filtered("").length, 0)
  assert.equal(context.catalog().length, titles.length)
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: [] })
})

test("navList carries a bind's own dispatcher so rows dispatch, not replay keys", () => {
  // Regression: rows used to expose only mods/key, so the overlay replayed
  // the chord as a synthetic key. Hyprland's bind matcher never sees those,
  // so every Omarchy binding silently did nothing.
  context.setSections([{
    title: "Main",
    rows: [
      { keys: "Super + Return", action: "Terminal", mods: "SUPER", bindKey: "RETURN",
        dispatcher: "exec", arg: "omarchy-launch-terminal" },
      { keys: "Ctrl + T", action: "New tab" }
    ]
  }])
  const items = context.navList("")
  const terminal = items.find((i) => i.action === "Terminal")
  assert.equal(terminal.dispatcher, "exec")
  assert.equal(terminal.dispatchArg, "omarchy-launch-terminal")
  assert.equal(terminal.runnable, true)
  // App sheet rows have no dispatcher and still fall back to key replay,
  // which is correct for an app's own shortcut.
  const tab = items.find((i) => i.action === "New tab")
  assert.equal(tab.dispatcher, "")
  assert.ok(tab.shortcut && tab.shortcut.key)
  context.setSections(null)
})

test("a bind the overlay cannot issue stays non-runnable however runnable its chord looks", () => {
  // Context-sensitive binds (universal copy, zoom) are Lua closures, so
  // there is no action to dispatch; OmarKEYS' own bind is self-referential.
  // dump-keymap marks those runnable:false and that must win, otherwise the
  // row looks live, closes the overlay, and does nothing.
  context.setSections([{
    title: "Main",
    rows: [
      { keys: "Super + C", action: "Universal copy", runnable: false },
      { keys: "Super + Return", action: "Terminal", dispatcher: "exec", arg: "term" }
    ]
  }])
  const items = context.navList("")
  assert.equal(items.find((i) => i.action === "Universal copy").runnable, false)
  assert.equal(items.find((i) => i.action === "Terminal").runnable, true)
  context.setSections(null)
})

test("groupedCatalog buckets every section into exactly 5 areas, none dropped", () => {
  const areas = context.groupedCatalog(context.sections)
  assert.equal(areas.length, 5)
  const flatTitles = context.catalogFor(context.sections).map((g) => g.title).sort()
  const groupedTitles = areas.flatMap((a) => a.groups.map((g) => g.title)).sort()
  assert.deepEqual(groupedTitles, flatTitles)
})

test("groupedCatalog carries hidden flags through to nested groups", () => {
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: ["Workspaces"] })
  const areas = context.groupedCatalog(context.sections)
  const workspaces = areas.flatMap((a) => a.groups).find((g) => g.title === "Workspaces")
  assert.equal(workspaces.hidden, true)
  context.setConfig({ doubleTap: true, holdSeconds: 5, hiddenGroups: [] })
})

test("groupedCatalog still buckets everything when a section list omits Other", () => {
  const withoutOther = context.sections.filter((s) => s.title !== "Other")
  const areas = context.groupedCatalog(withoutOther)
  const groupedTitles = areas.flatMap((a) => a.groups.map((g) => g.title)).sort()
  assert.deepEqual(groupedTitles, context.catalogFor(withoutOther).map((g) => g.title).sort())
})

test("display options: short chips, action sort, and the two search modes", () => {
  // Option 1: chips shorten to <=5 chars so the action column keeps its width.
  context.setConfig({ chipStyle: "short" })
  // JSON.stringify, not deepEqual: values cross the vm realm boundary, so
  // their prototypes differ even when the contents match.
  assert.equal(JSON.stringify(context.displayKeys("Super + Shift + Backspace", "short", "text")),
    JSON.stringify(["Sup", "Shft", "Bksp"]))
  assert.equal(context.shortKey("XF86AudioRaiseVolume"), "Vol+")
  assert.ok(context.displayKeys("Super + Shift + Backspace", "short", "text").every((k) => k.length <= 5))
  // Full style is untouched.
  assert.equal(JSON.stringify(context.displayKeys("Super + Return", "full", "text")),
    JSON.stringify(["Super", "Return"]))

  // Sorting by description orders rows within their section.
  context.setConfig({ sortBy: "action" })
  const actions = context.filtered("")[0].rows.map((r) => r.action)
  assert.equal(JSON.stringify(actions),
    JSON.stringify(actions.slice().sort((a, b) => a.toLowerCase() < b.toLowerCase() ? -1 : 1)))

  // The two search modes are genuinely different: "super" is a modifier,
  // never a description, so searching descriptions must not match it.
  context.setConfig({ searchMode: "keys" })
  assert.ok(context.filtered("super").length > 0)
  context.setConfig({ searchMode: "action" })
  assert.equal(context.filtered("super").length, 0)
  context.setConfig({ searchMode: "action" })
  assert.ok(context.filtered("terminal").length > 0)

  context.setConfig({})
})

test("icon chips use in-font glyphs and fall back to text when unmapped", () => {
  // Nerd Font glyphs, not emoji: they live in the overlay's own font, so
  // they need no fallback family with different metrics.
  const vol = context.displayKeys("XF86AudioRaiseVolume", "icons")
  assert.equal(vol.length, 1)
  assert.ok(vol[0].codePointAt(0) >= 0xF0000, "expected a Nerd Font glyph")
  // A mouse button keeps its side, which a bare mouse glyph would lose.
  assert.ok(context.displayKeys("Super + Left + Mouse + Button", "icons", "text")[1].endsWith("L"))
  // Named keys are glyphs too, so a row does not mix icons with text arrows.
  const named = context.displayKeys("Super + Shift + Return", "icons", "text")
  assert.ok(named[2].codePointAt(0) >= 0xF0000, "Return should be a glyph")
  assert.ok(context.displayKeys("Super + Left", "icons", "text")[1].codePointAt(0) >= 0xF0000,
    "arrow keys should be glyphs, not text arrows")
  // With the keyboard set to text the modifiers stay words, and a plain
  // letter has no icon so it keeps its short text rather than going blank.
  assert.equal(JSON.stringify(context.displayKeys("Super + Shift + B", "icons", "text")),
    JSON.stringify(["Sup", "Shft", "B"]))
  assert.equal(context.displayKeys("Ctrl + B", "icons", "mac")[0], "\u2303")
  assert.equal(context.displayKeys("Alt + B", "icons", "mac")[0], "\u2325")
})

test("a mouse bind is one chip, and only real arrow keys become arrows", () => {
  // Hyprland reports "Super + Left + Mouse + Button" as four words; left as
  // four chips the button reads as an arrow key, and short mode abbreviated
  // that "Left" to an arrow outright.
  assert.equal(JSON.stringify(context.displayKeys("Super + Left + Mouse + Button", "full", "text")),
    JSON.stringify(["Super", "LMB"]))
  assert.equal(JSON.stringify(context.displayKeys("Super + Right + Mouse + Button", "short", "text")),
    JSON.stringify(["Sup", "RMB"]))
  assert.equal(JSON.stringify(context.displayKeys("Super + mouse_down", "full", "text")),
    JSON.stringify(["Super", "Wheel↓"]))
  // The arrow key itself still shortens to an arrow, which is the point.
  assert.equal(JSON.stringify(context.displayKeys("Super + Left", "short", "text")),
    JSON.stringify(["Sup", "←"]))
})

test("hovering an icon names it in words, not in raw key tokens", () => {
  // The point of the hover is to say what a glyph is; "XF86AudioRaiseVolume"
  // would be barely better than the glyph itself.
  assert.equal(JSON.stringify(context.displayNames("XF86AudioRaiseVolume")),
    JSON.stringify(["Volume up"]))
  assert.equal(JSON.stringify(context.displayNames("Super + mouse_down")),
    JSON.stringify(["Super", "Wheel down"]))
  assert.equal(JSON.stringify(context.displayNames("Super + Left + Mouse + Button")),
    JSON.stringify(["Super", "Left click"]))
  // Names line up with chips index for index, which is what the row relies on.
  const keys = "Super + Shift + XF86MonBrightnessUp"
  assert.equal(context.displayNames(keys).length, context.displayKeys(keys, "icons").length)
})

test("a gesture shows the key it applies to, at every chip style", () => {
  // "Double-tap Super" is one token, so abbreviating it cut the key off and
  // left "Doubl" - a gesture with nothing to perform it on.
  assert.equal(JSON.stringify(context.displayKeys("Double-tap Super", "full", "text")),
    JSON.stringify(["Double-tap", "Super"]))
  assert.equal(JSON.stringify(context.displayKeys("Double-tap Super", "short", "text")),
    JSON.stringify(["Double-tap", "Sup"]))
  // The hold time stays with the gesture, and follows the configured value.
  assert.equal(JSON.stringify(context.displayKeys("Hold Super 8s", "icons", "text")),
    JSON.stringify(["Hold 8s", "Sup"]))
  // Gestures are still not dispatchable; splitting them is display only.
  assert.equal(context.isRunnable("Double-tap Super"), false)
  assert.equal(context.isRunnable("Hold Super 5s"), false)
})

test("the keyboard set moves all four modifiers, in every chip style", () => {
  // Choosing a layout is pointless if its keycaps only show in icon mode,
  // so the set overrides full and short chips too.
  assert.equal(context.displayKeys("Super + K", "full", "text")[0], "Super")
  assert.equal(context.displayKeys("Super + K", "short", "text")[0], "Sup")

  // Mac is the only layout that symbols all four.
  const mac = context.displayKeys("Super + Ctrl + Shift + Alt + K", "full", "mac")
  assert.equal(JSON.stringify(mac.slice(0, 4)),
    JSON.stringify(["\u2318", "\u2303", "\u21e7", "\u2325"]))
  assert.equal(context.displayKeys("Super + K", "short", "mac")[0], "\u2318")
  assert.equal(context.displayKeys("Super + K", "icons", "mac")[0], "\u2318")

  // A PC keycap prints the words, so those sets only supply a Super logo
  // and the rest fall back to text.
  assert.equal(context.displayKeys("Super + K", "full", "windows")[0].codePointAt(0), 0xF05B3)
  assert.equal(context.displayKeys("Super + K", "full", "omarchy")[0].codePointAt(0), 0xF303)
  assert.equal(JSON.stringify(context.displayKeys("Super + Ctrl + K", "full", "windows").slice(1)),
    JSON.stringify(["Ctrl", "K"]))
  assert.equal(JSON.stringify(context.displayKeys("Super + Ctrl + K", "full", "omarchy").slice(1)),
    JSON.stringify(["Ctrl", "K"]))

  // Only modifiers are swapped; the rest of the chord is untouched.
  assert.equal(context.displayKeys("Super + K", "full", "mac")[1], "K")
})

test("settings from the old Super-only picker keep their meaning", () => {
  // It shipped on develop as command/option/superman before this became a
  // keyboard choice; those should not snap back to the default.
  assert.equal(context.normalizeKeyboardOS("command"), "mac")
  assert.equal(context.normalizeKeyboardOS("option"), "mac")
  assert.equal(context.normalizeKeyboardOS("superman"), "windows")
  assert.equal(context.displayKeys("Super + K", "full", "command")[0].codePointAt(0), 0x2318)
  // Anything unrecognised lands on the default rather than drawing nothing.
  assert.equal(context.normalizeKeyboardOS("nonsense"), "windows")
  assert.equal(context.normalizeKeyboardOS(""), "windows")
  // A non-modifier never picks up a keycap.
  assert.equal(context.modifierIcon("K", "mac"), "")
})

test("a chip is a shape or a word, and the symbols are neither private-use", () => {
  // Nerd Font glyphs are found by range; the Mac symbols are real Unicode
  // and would fail that test, which is why the rule is shared rather than
  // re-derived as a codepoint check in the row.
  assert.equal(context.isIconGlyph("\u2318"), true, "Command is a shape")
  assert.equal(context.isIconGlyph("\u2303"), true, "Control is a shape")
  assert.equal(context.isIconGlyph("\u21e7"), true, "Shift is a shape")
  assert.equal(context.isIconGlyph("\u2325"), true, "Alt is a shape")
  assert.equal(context.isIconGlyph("\udb81\uddb3"), true, "private-use glyph")
  assert.equal(context.isIconGlyph("\uf2dd"), true, "BMP private-use glyph")
  assert.equal(context.isIconGlyph("Sup"), false)
  assert.equal(context.isIconGlyph("B"), false)
  assert.equal(context.isIconGlyph(""), false)
})

test("keys read as keys: punctuation is its symbol, media keys have names", () => {
  // X11 spells punctuation out, so a bind on "[" arrives as "bracketleft"
  // -- and the old short form chopped that to "Brack", which is not a key.
  assert.equal(context.displayKeys("Super + bracketleft", "full", "text")[1], "[")
  assert.equal(context.displayKeys("Super + Bracketright", "full", "text")[1], "]")
  // The symbol wins at every chip style: it is already the shortest form.
  assert.equal(context.displayKeys("Super + Bracketleft", "short", "text")[1], "[")
  assert.equal(context.displayKeys("Super + Bracketleft", "icons", "text")[1], "[")
  assert.equal(context.shortKey("bracketleft"), "[")
  assert.equal(context.shortKey("Semicolon"), ";")

  // A full chip spells the key out, but XF86AudioRaiseVolume is the X11
  // name rather than a spelling of anything.
  assert.equal(context.displayKeys("XF86AudioRaiseVolume", "full", "text")[0], "Volume up")
  assert.equal(context.displayKeys("XF86MonBrightnessDown", "full", "text")[0], "Brightness down")
  assert.equal(context.shortKey("XF86AudioMute"), "Mute")

  // Nothing is truncated into something that is no longer a key name.
  assert.equal(context.shortKey("1-9, 0"), "1-9, 0")
  assert.equal(context.shortKey("Bracketleft"), "[")
  assert.equal(context.displayKeys("Super + 1-9, 0", "short", "text")[1], "1-9, 0")
})

test("a chip knows whether it is a key, an action, or a mouse button", () => {
  // Only a key you press is a keycap, so only it takes a border. A glyph
  // standing for what the key does is not a cap, nor is a mouse button.
  assert.equal(context.keyClass("K"), "key")
  assert.equal(context.keyClass("Super"), "key")
  assert.equal(context.keyClass("Delete"), "key")
  assert.equal(context.keyClass("XF86AudioMute"), "action")
  assert.equal(context.keyClass("XF86MonBrightnessUp"), "action")
  assert.equal(context.keyClass("LMB"), "mouse")
  assert.equal(context.keyClass("RMB"), "mouse")
  assert.equal(context.keyClass("Wheel\u2193"), "mouse")

  // Classes line up index for index with the chips they describe, which
  // means collapseMouse has to have run for both.
  assert.equal(JSON.stringify(context.displayClasses("Super + Left + Mouse + Button")),
    JSON.stringify(["key", "mouse"]))
  assert.equal(context.displayClasses("Super + Left + Mouse + Button").length,
    context.displayKeys("Super + Left + Mouse + Button", "icons", "mac").length)
})

test("Delete reads DEL rather than a glyph that looks like a close button", () => {
  assert.equal(context.displayKeys("Super + Delete", "icons", "text")[1], "DEL")
  assert.equal(context.displayKeys("Super + Delete", "short", "text")[1], "DEL")
  assert.equal(context.shortKey("Delete"), "DEL")
  // Still a word, so it is drawn as a capped chip rather than a loose glyph.
  assert.equal(context.isIconGlyph("DEL"), false)
})

test("sort by key files a chord under the key you press", () => {
  // Sorting the whole chord string files every Super bind under S, which
  // is no order at all when almost everything starts with Super.
  assert.equal(context.sortKeyOf("Super + Shift + K"), "K")
  assert.equal(context.sortKeyOf("Super + Ctrl + Alt + Delete"), "Delete")
  assert.equal(context.sortKeyOf("K"), "K")
  // A collapsed mouse button is the key here, not the word "Button".
  assert.equal(context.sortKeyOf("Super + Left + Mouse + Button"), "LMB")
  // All modifiers: nothing else to file it under, so use what is there.
  assert.equal(context.sortKeyOf("Super + Shift"), "Shift")
  assert.equal(context.sortKeyOf(""), "")

  // Letters and digits lead. Punctuation sorts below them in code order,
  // which would otherwise open the list with , - . / before any key you
  // are likely to be hunting for.
  context.setSections([{ title: "One", rows: [
    { keys: "Super + comma", action: "c" },
    { keys: "Super + B", action: "b" },
    { keys: "Super + 1", action: "a" }
  ]}])
  context.setConfig({ sortBy: "key", grouping: "topic" })
  assert.equal(JSON.stringify(context.filtered("")[0].rows.map((r) => context.sortKeyOf(r.keys))),
    JSON.stringify(["1", "B", "comma"]))

  context.setSections([{ title: "One", rows: [
    { keys: "Super + Z", action: "alpha" },
    { keys: "Super + A", action: "zulu" }
  ]}])
  context.setConfig({ sortBy: "key", grouping: "topic" })
  assert.equal(JSON.stringify(context.filtered("").map((s) => s.rows.map((r) => r.keys))),
    JSON.stringify([["Super + A", "Super + Z"]]), "by key")
  context.setConfig({ sortBy: "action", grouping: "topic" })
  assert.equal(JSON.stringify(context.filtered("").map((s) => s.rows.map((r) => r.keys))),
    JSON.stringify([["Super + Z", "Super + A"]]), "by name")
})

test("grouping off is one untitled run, split down the middle", () => {
  context.setSections([
    { title: "One", rows: [{ keys: "Super + B", action: "bravo" }] },
    { title: "Two", rows: [{ keys: "Super + A", action: "alpha" },
                           { keys: "Super + C", action: "charlie" }] }
  ])
  context.setConfig({ grouping: "topic", sortBy: "action" })
  const grouped = context.filtered("")
  assert.equal(grouped.length, 2, "topics stay apart")
  assert.equal(JSON.stringify(grouped.map((s) => s.title)), JSON.stringify(["One", "Two"]))

  context.setConfig({ grouping: "off", sortBy: "action" })
  const flat = context.filtered("")
  assert.equal(flat.length, 1, "one block")
  assert.equal(flat[0].title, "", "untitled, so the board draws no heading")
  assert.equal(JSON.stringify(flat[0].rows.map((r) => r.action)),
    JSON.stringify(["alpha", "bravo", "charlie"]), "sorted across topics, not within them")

  // One block would otherwise pile into the left column and leave the
  // right one empty.
  const cols = context.columns("")
  assert.equal(cols.left.length, 1)
  assert.equal(cols.right.length, 1)
  assert.equal(cols.left[0].rows.length + cols.right[0].rows.length, 3)
  assert.equal(cols.left[0].rows.length, 2, "odd counts lean left")
})

test("the Omarchy mark is one glyph, shared by the tree and the keyboard set", () => {
  // Omarchy ships its own logo as block-drawing art rather than a font
  // glyph, so this is the Arch mark -- and the tree row and the keyboard
  // set must not drift apart into two different symbols.
  assert.equal(context.omarchyIcon().codePointAt(0), 0xF303)
  assert.equal(context.modifierIcon("Super", "omarchy"), context.omarchyIcon())
  // In the overlay's font, so it draws as a shape rather than a box.
  assert.equal(context.isIconGlyph(context.omarchyIcon()), true)
})

test("grouping by key type buckets on the key you press", () => {
  assert.equal(context.keyTypeOf("Super + 4"), "Numbers")
  assert.equal(context.keyTypeOf("Super + Ctrl + 1-9, 0"), "Numbers")
  assert.equal(context.keyTypeOf("Super + Shift + K"), "Alpha")
  assert.equal(context.keyTypeOf("Super + Return"), "Special")
  assert.equal(context.keyTypeOf("Super + bracketleft"), "Special")
  assert.equal(context.keyTypeOf("Super + F9"), "Special", "a function key is not a letter")
  // Not keys on a keyboard: a mouse button, a media key, and a gesture --
  // the gesture survives splitKeys whole, so it is caught before the rest.
  assert.equal(context.keyTypeOf("Super + Left + Mouse + Button"), "Non-keyboard")
  assert.equal(context.keyTypeOf("XF86AudioMute"), "Non-keyboard")
  assert.equal(context.keyTypeOf("Double-tap Super"), "Non-keyboard")
  assert.equal(context.keyTypeOf("Hold Super 5s"), "Non-keyboard")

  context.setSections([
    { title: "One", rows: [{ keys: "Super + K", action: "k" },
                           { keys: "XF86AudioMute", action: "mute" }] },
    { title: "Two", rows: [{ keys: "Super + 4", action: "four" },
                           { keys: "Super + Return", action: "ret" }] }
  ])
  context.setConfig({ grouping: "keytype", sortBy: "action" })
  const g = context.filtered("")
  assert.equal(JSON.stringify(g.map((s) => s.title)),
    JSON.stringify(["Numbers", "Alpha", "Special", "Non-keyboard"]), "fixed order")
  assert.equal(JSON.stringify(g.map((s) => s.rows.length)), JSON.stringify([1, 1, 1, 1]))
  // Buckets gather across topics, and an empty one is left out entirely.
  context.setSections([{ title: "One", rows: [{ keys: "Super + K", action: "k" }] }])
  context.setConfig({ grouping: "keytype", sortBy: "action" })
  assert.equal(JSON.stringify(context.filtered("").map((s) => s.title)),
    JSON.stringify(["Alpha"]), "no bare headings for empty buckets")
})

test("rows carry their topic out when the headings no longer show it", () => {
  context.setSections([
    { title: "Windows", rows: [{ keys: "Super + W", action: "close" }] },
    { title: "Media", rows: [{ keys: "XF86AudioMute", action: "mute" }] }
  ])

  // Grouped by topic the heading says it, so the row does not need to.
  context.setConfig({ grouping: "topic", sortBy: "action" })
  assert.equal(context.filtered("")[0].rows[0].topic, undefined)

  // Ungrouped and by key type, the heading is gone or is a key bucket, so
  // the topic only survives on the row.
  for (const mode of ["off", "keytype"]) {
    context.setConfig({ grouping: mode, sortBy: "action" })
    const rows = context.filtered("").flatMap((s) => s.rows)
    const byAction = Object.fromEntries(rows.map((r) => [r.action, r.topic]))
    assert.equal(byAction.close, "Windows", mode)
    assert.equal(byAction.mute, "Media", mode)
  }

  // Tagged on copies: switching back must not leave the source sections
  // carrying a topic from the mode they were last viewed in.
  context.setConfig({ grouping: "topic", sortBy: "action" })
  assert.equal(context.filtered("")[0].rows[0].topic, undefined, "source untouched")
})
