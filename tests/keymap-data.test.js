const { test } = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const src = fs.readFileSync(path.join(__dirname, "..", "KeymapData.js"), "utf8")
  .replace(/^\.pragma library\s*/, "")
const context = {}
vm.createContext(context)
vm.runInContext(src + "\nthis.filtered = filtered; this.columns = columns; this.splitKeys = splitKeys; this.sections = sections; this.isRunnable = isRunnable; this.shortcut = shortcut; this.navList = navList; this.sectionStarts = sectionStarts; this.setConfig = setConfig; this.setSections = setSections; this.catalog = catalog; this.rowMatchesModifiers = rowMatchesModifiers; this.normalizeModifierMode = normalizeModifierMode;", context)

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
  const items = context.navList("")
  const starts = context.sectionStarts(items)
  const titles = starts.map((i) => items[i].sectionTitle)
  assert.equal(titles[0], "Main")
  assert.equal(titles[9], "Notifications")
  assert.ok(items[0].runnable)
  assert.equal(items[0].shortcut.key, "space")
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
