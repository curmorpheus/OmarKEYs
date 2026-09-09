const test = require("node:test")
const assert = require("node:assert")
const fs = require("node:fs")
const path = require("node:path")

const root = path.join(__dirname, "..")
const qmlFiles = fs.readdirSync(root).filter((f) => f.endsWith(".qml"))

// Assigning the same property twice in one object makes QML refuse to load
// the whole component -- and everything that uses it. That is how the
// overlay stopped opening once: a stray second `opacity` on one label took
// KeymapOptionsMenu down, which took Keymap.qml with it.
//
// qmllint does not report this at all, and there is no qmlcachegen here to
// compile against, so the runtime was the only thing that caught it. This
// is cheaper than restarting a shell to find out.
function duplicateProps(source) {
  const lines = source.split("\n")
  const found = []
  const seen = [new Map()]
  let depth = 0
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].split("//")[0]
    const opens = (line.match(/\{/g) || []).length
    const closes = (line.match(/\}/g) || []).length
    // A binding on its own line: `name: value`, not `name: Thing {`.
    const m = line.match(/^\s*([a-z][A-Za-z0-9_.]*)\s*:/)
    if (m && opens === 0) {
      const prop = m.group === undefined ? m[1] : m[1]
      const at = seen[depth] || (seen[depth] = new Map())
      if (at.has(prop))
        found.push(`line ${i + 1}: '${prop}' already set at line ${at.get(prop)}`)
      else
        at.set(prop, i + 1)
    }
    for (let o = 0; o < opens; o++) {
      depth++
      seen[depth] = new Map()
    }
    for (let c = 0; c < closes; c++) {
      seen[depth] = new Map()
      depth = Math.max(0, depth - 1)
    }
  }
  return found
}

test("no QML object sets the same property twice", () => {
  for (const file of qmlFiles) {
    const dupes = duplicateProps(fs.readFileSync(path.join(root, file), "utf8"))
    assert.deepEqual(dupes, [], `${file}\n  ${dupes.join("\n  ")}`)
  }
})

test("the duplicate check would have caught the one that broke the overlay", () => {
  const broken = [
    "Text {",
    "  id: holdLabel",
    "  opacity: host.holdEnabled ? 0.75 : 0.4",
    '  text: "Hold Super"',
    "  opacity: 0.75",
    "}"
  ].join("\n")
  const dupes = duplicateProps(broken)
  assert.equal(dupes.length, 1)
  assert.match(dupes[0], /'opacity' already set at line 3/)
})
