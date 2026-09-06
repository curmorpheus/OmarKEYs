const { test } = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const src = fs.readFileSync(path.join(__dirname, "..", "KeymapData.js"), "utf8")
  .replace(/^\.pragma library\s*/, "")
const context = {}
vm.createContext(context)
vm.runInContext(src + "\nthis.filtered = filtered; this.columns = columns; this.splitKeys = splitKeys; this.sections = sections;", context)

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
})
