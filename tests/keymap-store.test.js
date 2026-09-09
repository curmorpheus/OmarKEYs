const { test } = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")
const { spawnSync } = require("node:child_process")

const script = path.join(__dirname, "..", "keymap-store")
const shippedStub = `/usr/share/omarchy/config/hypr/bindings.lua`

function makeHome() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "omarkeys-store-"))
  const config = path.join(root, "config")
  const state = path.join(root, "state")
  fs.mkdirSync(path.join(config, "hypr"), { recursive: true })
  fs.mkdirSync(path.join(state, "omarchy"), { recursive: true })
  const personal = [
    "-- Keep only your personal keybinding overrides here.",
    'o.bind("SUPER + M", "Blip messages", "true")',
    ""
  ].join("\n")
  fs.writeFileSync(path.join(config, "hypr", "bindings.lua"), personal)
  return { root, config, state }
}

function run(home, args) {
  const result = spawnSync(script, args, {
    encoding: "utf8",
    env: {
      ...process.env,
      HOME: home.root,
      XDG_CONFIG_HOME: home.config,
      XDG_STATE_HOME: home.state,
      OMARKEYS_SKIP_RELOAD: "1"
    }
  })
  let json = null
  try {
    json = JSON.parse(result.stdout || "null")
  } catch (e) {
    json = null
  }
  return { code: result.status, stdout: result.stdout, stderr: result.stderr, json }
}

test("snapshot captures two different baselines and does not overwrite them", () => {
  assert.ok(fs.existsSync(shippedStub), "needs Omarchy shipped bindings stub")
  const home = makeHome()
  const first = run(home, ["snapshot"])
  assert.equal(first.code, 0, first.stderr)
  assert.equal(first.json.ok, true)
  assert.equal(first.json.omarchy.id, "omarchy")
  assert.equal(first.json.user.id, "user")
  assert.notEqual(first.json.omarchy.stubHash, first.json.user.hash,
    "Omarchy defaults and the user's file must not be treated as the same")

  const omarchyStub = fs.readFileSync(
    path.join(home.config, "omarchy/omarkeys/baselines/omarchy/bindings.lua"), "utf8")
  const userStub = fs.readFileSync(
    path.join(home.config, "omarchy/omarkeys/baselines/user/bindings.lua"), "utf8")
  assert.match(userStub, /SUPER \+ M/)
  assert.doesNotMatch(omarchyStub, /SUPER \+ M/)
  assert.match(omarchyStub, /personal keybinding overrides/)

  const defaultDir = path.join(home.config, "omarchy/omarkeys/baselines/omarchy/default-bindings")
  assert.ok(fs.existsSync(path.join(defaultDir, "tiling.lua")))

  // A later snapshot must not clobber the first-install user baseline.
  fs.writeFileSync(path.join(home.config, "hypr", "bindings.lua"), "o.bind(\"SUPER + X\", \"later\")\n")
  const second = run(home, ["snapshot"])
  assert.equal(second.json.user.hash, first.json.user.hash)
  const userAgain = fs.readFileSync(
    path.join(home.config, "omarchy/omarkeys/baselines/user/bindings.lua"), "utf8")
  assert.match(userAgain, /SUPER \+ M/)
  assert.doesNotMatch(userAgain, /SUPER \+ X/)
})

test("snapshot strips OmarKEYS wiring out of the user baseline", () => {
  const home = makeHome()
  const wired = [
    "-- personal",
    'o.bind("SUPER + M", "Blip", "true")',
    "",
    "-- OmarKEYS",
    'dofile((os.getenv("HOME") or "") .. "/.config/omarchy/plugins/io.github.romills.omarkeys/hyprland.lua")',
    "-- OmarKEYS edits",
    'dofile((os.getenv("HOME") or "") .. "/.config/hypr/omarkeys-edits.lua")',
    ""
  ].join("\n")
  fs.writeFileSync(path.join(home.config, "hypr", "bindings.lua"), wired)
  const out = run(home, ["snapshot"])
  assert.equal(out.json.ok, true, out.stderr)
  const user = fs.readFileSync(
    path.join(home.config, "omarchy/omarkeys/baselines/user/bindings.lua"), "utf8")
  assert.match(user, /SUPER \+ M/)
  assert.doesNotMatch(user, /hyprland\.lua/)
  assert.doesNotMatch(user, /omarkeys-edits/)
})

test("save then load restores edits and personal binds, and wires OmarKEYS back", () => {
  const home = makeHome()
  run(home, ["snapshot"])
  fs.writeFileSync(path.join(home.config, "hypr", "omarkeys-edits.lua"),
    'hl.unbind("SUPER + W")\no.bind("SUPER + Q", "Close window")\n')
  const saved = run(home, ["save", "laptop"])
  assert.equal(saved.json.ok, true, saved.stderr)
  assert.equal(saved.json.keymap.id, "laptop")
  assert.equal(saved.json.current, "laptop")

  // Clobber live files, then load.
  fs.writeFileSync(path.join(home.config, "hypr", "bindings.lua"), "-- wiped\n")
  fs.writeFileSync(path.join(home.config, "hypr", "omarkeys-edits.lua"), "-- empty\n")
  const loaded = run(home, ["load", "laptop"])
  assert.equal(loaded.json.ok, true, loaded.stderr)
  const bindings = fs.readFileSync(path.join(home.config, "hypr", "bindings.lua"), "utf8")
  const edits = fs.readFileSync(path.join(home.config, "hypr", "omarkeys-edits.lua"), "utf8")
  assert.match(bindings, /SUPER \+ M/)
  assert.match(bindings, /hyprland\.lua/)
  assert.match(bindings, /omarkeys-edits\.lua/)
  assert.match(edits, /SUPER \+ Q/)
})

test("load omarchy baseline clears remaps and restores the shipped stub", () => {
  const home = makeHome()
  run(home, ["snapshot"])
  fs.writeFileSync(path.join(home.config, "hypr", "omarkeys-edits.lua"),
    'o.bind("SUPER + Q", "something")\n')
  const loaded = run(home, ["load", "omarchy"])
  assert.equal(loaded.json.ok, true, loaded.stderr)
  assert.equal(loaded.json.current, "omarchy")
  const bindings = fs.readFileSync(path.join(home.config, "hypr", "bindings.lua"), "utf8")
  const edits = fs.readFileSync(path.join(home.config, "hypr", "omarkeys-edits.lua"), "utf8")
  assert.doesNotMatch(bindings, /SUPER \+ M/)
  assert.match(bindings, /hyprland\.lua/)
  assert.doesNotMatch(edits, /SUPER \+ Q/)
})

test("reserved names cannot be saved over, and list reports both layers", () => {
  const home = makeHome()
  run(home, ["snapshot"])
  const refused = run(home, ["save", "user"])
  assert.equal(refused.json.ok, false)
  const listed = run(home, ["list"])
  assert.equal(listed.json.ok, true)
  assert.equal(listed.json.baselines.length, 2)
  assert.equal(listed.json.baselines[0].id, "omarchy")
  assert.equal(listed.json.baselines[1].id, "user")
  assert.equal(listed.json.keymaps.length, 0)
})
