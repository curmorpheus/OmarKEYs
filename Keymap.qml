import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "KeymapData.js" as KeymapData

Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool grabKeys: false
  property string filterText: ""
  property var leftSections: []
  property var rightSections: []
  property var navItems: []
  property int selected: 0
  property string selectedKeys: ""
  property string selectedAction: ""
  property string pendingMods: ""
  property string pendingKey: ""
  property string pendingDispatcher: ""
  property string pendingArg: ""
  // The window that was focused when the overlay opened. Rows that send
  // keys are aimed at it explicitly, so a chord lands in the app you were
  // using rather than wherever focus drifted by the time we replay it.
  property string contextAddress: ""
  property bool contextAddressLatched: false
  property bool doubleTap: true
  property int holdSeconds: 5
  property var hiddenGroups: []
  // Apps switched off in the tree, by window class. A hidden app leaves the
  // list rather than sitting there dimmed: this is a live window list, so a
  // permanent dimmed entry is just clutter of a different kind. Showing the
  // Active Apps branch brings them all back.
  property var hiddenApps: []
  property var groupList: []
  property var omarchyTree: []
  property string modSuper: "any"
  property string modShift: "any"
  property string modCtrl: "any"
  property string modAlt: "any"
  property string selectedSectionTitle: ""
  property bool launching: false
  property int focusTick: 0
  property bool contextArmed: false
  property var contextToplevel: null
  property string keymapHash: ""
  property var omarchySections: []
  property var clients: []
  property string activeSource: "omarchy"
  property bool editMode: false
  property bool capturing: false
  property string captureOldKeys: ""
  property string captureAction: ""
  property string editStatus: ""
  readonly property bool omarchyActive: root.activeSource === "omarchy"

  readonly property bool allGroupsVisible: {
    var list = root.groupList
    if (!list || !list.length)
      return true
    for (var i = 0; i < list.length; i++) {
      if (list[i].hidden)
        return false
    }
    return true
  }
  readonly property bool allModsAny: root.modSuper === "any" && root.modShift === "any" && root.modCtrl === "any" && root.modAlt === "any"
  readonly property bool allModsMust: root.modSuper === "must" && root.modShift === "must" && root.modCtrl === "must" && root.modAlt === "must"
  readonly property bool allModsHide: root.modSuper === "hide" && root.modShift === "hide" && root.modCtrl === "hide" && root.modAlt === "hide"
  readonly property string sourceDir: (root.manifest && root.manifest.__sourceDir)
    || ((Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.romills.omarkeys")
  readonly property string configPath: (Quickshell.env("HOME") || "") + "/.config/omarchy/omarkeys.json"

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color chipBg: Color.menu.selectedBackground
  property color chipFg: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding

  function pluginId() {
    return (root.manifest && root.manifest.id) || "io.github.romills.omarkeys"
  }

  function configObject() {
    return {
      doubleTap: root.doubleTap,
      holdSeconds: root.holdSeconds,
      hiddenGroups: root.hiddenGroups,
      hiddenApps: root.hiddenApps,
      modifiers: {
        Super: root.modSuper,
        Shift: root.modShift,
        Ctrl: root.modCtrl,
        Alt: root.modAlt
      }
    }
  }

  function open(payloadJson) {
    root.filterText = ""
    root.grabKeys = false
    root.launching = false
    root.contextArmed = false
    root.contextToplevel = ToplevelManager.activeToplevel
    root.contextAddress = ""
    root.contextAddressLatched = false
    root.branchMenuOpen = false
    root.selected = 0
    root.applyConfigToData()
    root.refreshKeymap()
    root.refreshGitInfo()
    root.rebuild()
    root.opened = true
  }

  function applyConfigToData() {
    KeymapData.setConfig(root.configObject())
  }

  function applyConfigText(text) {
    try {
      var cfg = JSON.parse(text)
      if (cfg && typeof cfg === "object") {
        if (cfg.doubleTap === false)
          root.doubleTap = false
        else if (cfg.doubleTap === true)
          root.doubleTap = true
        var hold = Number(cfg.holdSeconds)
        if (hold >= 1 && hold <= 10)
          root.holdSeconds = Math.round(hold)
        if (Object.prototype.toString.call(cfg.hiddenGroups) === "[object Array]")
          root.hiddenGroups = cfg.hiddenGroups.slice()
        if (Object.prototype.toString.call(cfg.hiddenApps) === "[object Array]")
          root.hiddenApps = cfg.hiddenApps.slice()
        if (cfg.modifiers && typeof cfg.modifiers === "object") {
          root.modSuper = KeymapData.normalizeModifierMode(cfg.modifiers.Super)
          root.modShift = KeymapData.normalizeModifierMode(cfg.modifiers.Shift)
          root.modCtrl = KeymapData.normalizeModifierMode(cfg.modifiers.Ctrl)
          root.modAlt = KeymapData.normalizeModifierMode(cfg.modifiers.Alt)
        }
      }
    } catch (e) {
    }
    root.applyConfigToData()
    root.rebuild()
  }

  function saveConfig() {
    root.applyConfigToData()
    configFile.setText(JSON.stringify(root.configObject(), null, 2) + "\n")
    root.rebuild()
  }

  function applyDump(text) {
    var data = null
    try {
      data = JSON.parse(text)
    } catch (e) {
      return
    }
    if (!data)
      return
    if (data.clients) {
      root.clients = data.clients
      // Latch once per open: later refreshes must not re-point this at
      // something that took focus while the overlay was already up.
      if (!root.contextAddressLatched) {
        for (var c = 0; c < data.clients.length; c++) {
          if (data.clients[c].focused && data.clients[c].address) {
            root.contextAddress = data.clients[c].address
            root.contextAddressLatched = true
            break
          }
        }
      }
    }
    var same = data.hash && data.hash === root.keymapHash
    if (data.sections && data.sections.length) {
      root.omarchySections = data.sections
      root.keymapHash = data.hash || root.keymapHash
    }
    if (root.omarchyActive) {
      KeymapData.setSections(root.omarchySections)
      root.applyConfigToData()
      root.rebuild(true)
      if (!same && root.opened)
        root.requestFocus()
    }
  }

  function refreshKeymap() {
    if (dumpProc.running)
      dumpProc.running = false
    dumpProc.running = true
  }

  property string sheetPath: ""
  property string activeLabel: ""

  function emptySheetSections(label) {
    var name = label || "this window"
    return [{
      title: label || "This app",
      rows: [{ keys: "—", action: "No bundled keymap sheet for \"" + name + "\" yet" }]
    }]
  }

  FileView {
    id: sheetFile
    path: root.sheetPath
    printErrors: false
    onLoaded: {
      try {
        var data = JSON.parse(text())
        if (data && data.sections)
          KeymapData.setSections(data.sections)
        else
          throw new Error("empty")
      } catch (e) {
        KeymapData.setSections(root.emptySheetSections(root.activeLabel))
      }
      root.rebuild()
    }
    onLoadFailed: {
      if (!root.sheetPath)
        return
      KeymapData.setSections(root.emptySheetSections(root.activeLabel))
      root.rebuild()
    }
  }

  FileView {
    id: bindingsWatch
    path: (Quickshell.env("HOME") || "") + "/.config/hypr/bindings.lua"
    watchChanges: true
    printErrors: false
    onFileChanged: if (root.opened) root.refreshKeymap()
  }

  FileView {
    id: editsWatch
    path: (Quickshell.env("HOME") || "") + "/.config/hypr/omarkeys-edits.lua"
    watchChanges: true
    printErrors: false
    onFileChanged: if (root.opened) root.refreshKeymap()
  }

  Timer {
    id: reloadTimer
    interval: 3000
    repeat: true
    running: root.opened
    onTriggered: root.refreshKeymap()
  }

  FileView {
    id: configFile
    path: root.configPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.applyConfigText(text())
    onLoadFailed: root.saveConfig()
    onFileChanged: reload()
  }

  Process {
    id: dumpProc
    command: [root.sourceDir + "/dump-keymap"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyDump(text)
    }
  }

  property string gitBranch: ""
  property string gitHash: ""
  property var gitBranches: []
  property bool gitDirty: false
  property bool gitUpdateAvailable: false
  property int gitBehind: 0
  property string gitError: ""
  property bool gitBusy: false
  property bool branchMenuOpen: false
  // Set when a switch/sync succeeds: the QML on disk changed, so the
  // shell has to restart for it to take effect.
  property bool gitReloadPending: false

  function refreshGitInfo() {
    root.runGit(["status"], false)
  }

  // Release channels. Main and Beta are the two choices most people need;
  // Nightly is the escape hatch that opens up every working branch.
  readonly property string mainBranch: "main"
  readonly property string betaBranch: "beta"

  function channelFor(branch) {
    if (branch === root.mainBranch)
      return "main"
    if (branch === root.betaBranch)
      return "beta"
    return "nightly"
  }

  readonly property string gitChannel: root.channelFor(root.gitBranch)

  function channelLabel(channel) {
    if (channel === "main")
      return "Main"
    if (channel === "beta")
      return "Beta"
    return "Nightly"
  }

  function switchChannel(channel) {
    if (channel === "main")
      root.switchBranch(root.mainBranch)
    else if (channel === "beta")
      root.switchBranch(root.betaBranch)
  }

  // Everything that is not one of the two release channels. Those have
  // their own rows in the menu, so listing them again only adds noise.
  readonly property var nightlyBranches: {
    var out = []
    var list = root.gitBranches || []
    for (var i = 0; i < list.length; i++) {
      if (list[i] !== root.mainBranch && list[i] !== root.betaBranch)
        out.push(list[i])
    }
    return out
  }

  function toggleBranchMenu() {
    root.branchMenuOpen = !root.branchMenuOpen
    // Opening is the moment the branch list matters, so refresh it then
    // rather than paying for git on every overlay open.
    if (root.branchMenuOpen)
      root.refreshGitInfo()
    else
      root.gitError = ""
  }

  function checkForUpdates() {
    root.gitError = ""
    root.runGit(["fetch"], false)
  }

  function switchBranch(name) {
    if (!name || name === root.gitBranch)
      return
    root.gitError = ""
    root.runGit(["switch", String(name)], true)
  }

  function syncBranch() {
    root.gitError = ""
    root.runGit(["sync"], true)
  }

  function runGit(args, reloadOnSuccess) {
    if (root.gitBusy)
      return
    root.gitBusy = true
    root.gitReloadPending = !!reloadOnSuccess
    gitProc.command = [root.sourceDir + "/plugin-git"].concat(args)
    gitProc.running = true
  }

  function applyGitPayload(text) {
    var data = null
    try {
      data = JSON.parse(text)
    } catch (e) {
      root.gitError = "could not read git status"
      return
    }
    if (!data)
      return
    root.gitBranch = data.branch || ""
    root.gitHash = data.hash || ""
    root.gitBranches = data.branches || []
    root.gitDirty = data.dirty === true
    root.gitBehind = data.behind || 0
    root.gitUpdateAvailable = data.updateAvailable === true
    // syncError is soft: the switch itself succeeded, only the follow-up
    // fast-forward did not, so it must not block the reload below.
    root.gitError = data.error || data.fetchError || data.syncError || ""
    // Only a clean switch/sync warrants restarting the shell; a refusal
    // leaves the checkout untouched, so there is nothing to reload.
    if (root.gitReloadPending && data.ok && !data.error) {
      root.gitReloadPending = false
      // Through a login shell: omarchy lives in /usr/share/omarchy/bin,
      // which is on the user's PATH but not necessarily on the shell
      // process's. Detached, so it survives the restart it triggers.
      Quickshell.execDetached(["bash", "-lc", "omarchy restart shell"])
    }
    root.gitReloadPending = false
  }

  Process {
    id: gitProc
    command: [root.sourceDir + "/plugin-git", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.gitBusy = false
        root.applyGitPayload(text)
      }
    }
    onExited: function(code) {
      root.gitBusy = false
      if (code !== 0 && !root.gitError)
        root.gitError = "plugin-git failed (" + code + ")"
    }
  }

  Component.onCompleted: {
    root.refreshKeymap()
    root.refreshGitInfo()
  }

  Timer {
    id: runTimer
    interval: 120
    repeat: false
    onTriggered: {
      var script = root.sourceDir + "/run-shortcut"
      var target = root.contextAddress ? "address:" + root.contextAddress : ""
      if (root.pendingDispatcher)
        Quickshell.execDetached([script, "--dispatch", root.pendingDispatcher, root.pendingArg, target])
      else
        Quickshell.execDetached([script, root.pendingMods, root.pendingKey, target])
    }
  }

  Process {
    id: editProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var out = String(text || "").trim()
        if (out === "ok") {
          root.editStatus = "Saved · history committed"
          root.capturing = false
          root.refreshKeymap()
        } else {
          root.editStatus = "Reload failed · restored previous version"
          root.capturing = false
        }
      }
    }
    onExited: function(code) {
      if (code !== 0 && root.capturing)
        root.editStatus = "Edit failed · restored previous version"
      root.capturing = false
    }
  }

  function grab() {
    root.grabKeys = true
    root.requestFocus()
    if (!root.contextArmed)
      armContextTimer.restart()
  }

  Timer {
    id: grabWatch
    interval: 50
    repeat: true
    running: root.opened && !root.grabKeys && !root.launching
    onTriggered: root.grab()
  }

  Timer {
    id: armContextTimer
    interval: 180
    repeat: false
    onTriggered: {
      if (!root.opened || !root.grabKeys)
        return
      root.contextToplevel = ToplevelManager.activeToplevel
      root.contextArmed = true
    }
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() {
      if (!root.opened || !root.contextArmed || root.launching)
        return
      if (ToplevelManager.activeToplevel !== root.contextToplevel)
        root.dismiss()
    }
  }

  function requestFocus() {
    root.focusTick++
  }

  function close() {
    root.contextArmed = false
    root.grabKeys = false
    root.opened = false
    root.branchMenuOpen = false
    root.clearSolo()
  }

  function dismiss() {
    root.contextArmed = false
    root.grabKeys = false
    root.opened = false
    root.branchMenuOpen = false
    root.clearSolo()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide(root.pluginId())
  }

  function toggle() {
    if (root.opened)
      root.dismiss()
    else
      root.open("{}")
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selected = 0
    root.rebuild()
  }

  function rebuild(keepSelection) {
    var keepKeys = root.selectedKeys
    var keepAction = root.selectedAction
    root.applyConfigToData()
    root.groupList = KeymapData.catalog()
    var omarchySource = (root.omarchySections && root.omarchySections.length) ? root.omarchySections : KeymapData.sections
    root.omarchyTree = KeymapData.groupedCatalog(omarchySource)
    var cols = KeymapData.columns(root.filterText)
    root.leftSections = cols.left
    root.rightSections = cols.right
    root.navItems = KeymapData.navList(root.filterText)
    if (keepSelection)
      root.selectKeys(keepKeys, keepAction)
    if (root.selected >= root.navItems.length)
      root.selected = Math.max(0, root.navItems.length - 1)
    root.syncSelection()
    if (root.opened && !keepSelection)
      root.requestFocus()
  }

  function selectSource(id) {
    root.capturing = false
    root.editStatus = ""
    root.activeSource = id || "omarchy"
    if (!root.omarchyActive)
      root.editMode = false
    root.filterText = ""
    root.selected = 0
    if (root.omarchyActive) {
      root.sheetPath = ""
      KeymapData.setSections(root.omarchySections.length ? root.omarchySections : KeymapData.sections)
      root.rebuild()
      return
    }
    var sheet = ""
    var label = id
    var list = root.clients
    for (var i = 0; i < list.length; i++) {
      if (list[i].class === id) {
        sheet = list[i].sheet || ""
        label = list[i].label || id
        break
      }
    }
    root.activeLabel = label
    if (!sheet) {
      KeymapData.setSections(root.emptySheetSections(label))
      root.rebuild()
      return
    }
    root.sheetPath = root.sourceDir + "/sheets/" + sheet
  }

  function appIsHidden(cls) {
    for (var i = 0; i < root.hiddenApps.length; i++) {
      if (root.hiddenApps[i] === cls)
        return true
    }
    return false
  }

  readonly property var visibleClients: {
    var out = []
    var list = root.clients || []
    for (var i = 0; i < list.length; i++) {
      if (!root.appIsHidden(list[i].class))
        out.push(list[i])
    }
    return out
  }

  function toggleApp(cls) {
    var next = []
    var hiding = !root.appIsHidden(cls)
    for (var i = 0; i < root.hiddenApps.length; i++) {
      if (root.hiddenApps[i] !== cls)
        next.push(root.hiddenApps[i])
    }
    if (hiding)
      next.push(cls)
    root.hiddenApps = next
    root.saveConfig()
  }

  function showAllApps() {
    root.hiddenApps = []
    root.saveConfig()
  }

  function groupIsHidden(title) {
    for (var i = 0; i < root.hiddenGroups.length; i++) {
      if (root.hiddenGroups[i] === title)
        return true
    }
    return false
  }

  function toggleGroup(title) {
    root.preSoloHidden = null
    var next = []
    var hiding = !root.groupIsHidden(title)
    for (var i = 0; i < root.hiddenGroups.length; i++) {
      if (root.hiddenGroups[i] !== title)
        next.push(root.hiddenGroups[i])
    }
    if (hiding)
      next.push(title)
    root.hiddenGroups = next
    root.saveConfig()
  }

  // Snapshot of hiddenGroups taken before the first solo, so closing the
  // overlay can put the user's real group settings back.
  property var preSoloHidden: null

  // Click a branch in the tree to show only that branch: every Omarchy
  // group outside `titles` is hidden, so the board shows just the one
  // area/group you picked. This is a *view* filter — deliberately not
  // written to the config, and undone on close, so a stray click cannot
  // leave the keymap permanently mostly-hidden.
  function soloGroups(titles) {
    if (root.preSoloHidden === null)
      root.preSoloHidden = root.hiddenGroups.slice()
    var keep = {}
    for (var i = 0; i < titles.length; i++)
      keep[titles[i]] = true
    var next = []
    // omarchyTree already holds every group, bucketed by area.
    var areas = root.omarchyTree || []
    for (var a = 0; a < areas.length; a++) {
      var groups = areas[a].groups || []
      for (var g = 0; g < groups.length; g++) {
        if (!keep[groups[g].title])
          next.push(groups[g].title)
      }
    }
    root.hiddenGroups = next
    root.applyConfigToData()
    root.rebuild()
  }

  function clearSolo() {
    if (root.preSoloHidden === null)
      return
    root.hiddenGroups = root.preSoloHidden.slice()
    root.preSoloHidden = null
    root.applyConfigToData()
    root.rebuild()
  }

  function setGroupsVisible(titles, show) {
    root.preSoloHidden = null
    var set = {}
    for (var i = 0; i < titles.length; i++)
      set[titles[i]] = true
    var next = []
    for (var j = 0; j < root.hiddenGroups.length; j++) {
      if (!set[root.hiddenGroups[j]])
        next.push(root.hiddenGroups[j])
    }
    if (!show) {
      for (var k = 0; k < titles.length; k++)
        next.push(titles[k])
    }
    root.hiddenGroups = next
    root.saveConfig()
  }

  function modifierMode(name) {
    if (name === "Super") return root.modSuper
    if (name === "Shift") return root.modShift
    if (name === "Ctrl") return root.modCtrl
    if (name === "Alt") return root.modAlt
    return "any"
  }

  function cycleModifier(name) {
    var cur = root.modifierMode(name)
    var next = cur === "any" ? "must" : (cur === "must" ? "hide" : "any")
    if (name === "Super") root.modSuper = next
    else if (name === "Shift") root.modShift = next
    else if (name === "Ctrl") root.modCtrl = next
    else if (name === "Alt") root.modAlt = next
    root.saveConfig()
  }

  function setAllModifiers(mode) {
    var next = mode === "must" || mode === "hide" ? mode : "any"
    root.modSuper = next
    root.modShift = next
    root.modCtrl = next
    root.modAlt = next
    root.saveConfig()
  }

  function setAllGroupsVisible(show) {
    root.preSoloHidden = null
    if (show) {
      root.hiddenGroups = []
    } else {
      var next = []
      var list = root.groupList
      for (var i = 0; i < list.length; i++)
        next.push(list[i].title)
      root.hiddenGroups = next
    }
    root.saveConfig()
  }

  function focusGroup(title) {
    if (root.groupIsHidden(title))
      root.toggleGroup(title)
    for (var i = 0; i < root.navItems.length; i++) {
      if (root.navItems[i].sectionTitle === title) {
        root.selected = i
        root.syncSelection()
        return
      }
    }
  }

  function syncSelection() {
    var item = root.navItems[root.selected]
    if (!item) {
      root.selectedKeys = ""
      root.selectedAction = ""
      root.selectedSectionTitle = ""
      return
    }
    root.selectedKeys = item.keys
    root.selectedAction = item.action
    root.selectedSectionTitle = item.sectionTitle || ""
  }

  function moveSelection(delta) {
    if (!root.navItems.length)
      return
    var n = root.navItems.length
    root.selected = (root.selected + delta + n) % n
    root.syncSelection()
  }

  function jumpSection(number) {
    var starts = KeymapData.sectionStarts(root.navItems)
    var idx = number - 1
    if (number === 0)
      idx = 9
    if (idx < 0 || idx >= starts.length)
      return
    root.selected = starts[idx]
    root.syncSelection()
  }

  function jumpNeighborSection(delta) {
    var starts = KeymapData.sectionStarts(root.navItems)
    if (!starts.length)
      return
    var current = 0
    for (var i = 0; i < starts.length; i++) {
      if (starts[i] <= root.selected)
        current = i
    }
    var next = current + delta
    if (next < 0)
      next = starts.length - 1
    if (next >= starts.length)
      next = 0
    root.selected = starts[next]
    root.syncSelection()
  }

  function selectKeys(keys, action) {
    for (var i = 0; i < root.navItems.length; i++) {
      if (root.navItems[i].keys === keys && root.navItems[i].action === action) {
        root.selected = i
        root.syncSelection()
        return
      }
    }
  }

  function toHyprChord(keys) {
    var parts = KeymapData.splitKeys(keys)
    var out = []
    for (var i = 0; i < parts.length; i++) {
      var p = parts[i]
      if (p === "Super") out.push("SUPER")
      else if (p === "Shift") out.push("SHIFT")
      else if (p === "Ctrl" || p === "Control") out.push("CTRL")
      else if (p === "Alt") out.push("ALT")
      else out.push(String(p).toUpperCase())
    }
    return out.join(" + ")
  }

  function qtKeyName(event) {
    if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z)
      return String.fromCharCode(65 + (event.key - Qt.Key_A))
    if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9)
      return String(event.key - Qt.Key_0)
    if (event.key === Qt.Key_Space) return "SPACE"
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) return "RETURN"
    if (event.key === Qt.Key_Tab) return "TAB"
    if (event.key === Qt.Key_Backspace) return "BACKSPACE"
    if (event.key === Qt.Key_Delete) return "DELETE"
    if (event.key === Qt.Key_Escape) return "ESCAPE"
    if (event.key === Qt.Key_Print) return "PRINT"
    if (event.key === Qt.Key_Home) return "HOME"
    if (event.key === Qt.Key_End) return "END"
    if (event.key === Qt.Key_Left) return "LEFT"
    if (event.key === Qt.Key_Right) return "RIGHT"
    if (event.key === Qt.Key_Up) return "UP"
    if (event.key === Qt.Key_Down) return "DOWN"
    if (event.key === Qt.Key_Comma) return "COMMA"
    if (event.key === Qt.Key_Period) return "PERIOD"
    if (event.key === Qt.Key_Minus) return "MINUS"
    if (event.key === Qt.Key_Equal) return "EQUAL"
    if (event.key === Qt.Key_Slash) return "SLASH"
    return ""
  }

  function eventToHyprChord(event) {
    if (root.isSuperKey(event) && !(event.modifiers & (Qt.ShiftModifier | Qt.ControlModifier | Qt.AltModifier)))
      return ""
    var key = root.qtKeyName(event)
    if (!key || key === "ESCAPE")
      return ""
    var mods = []
    if (event.modifiers & Qt.MetaModifier) mods.push("SUPER")
    if (event.modifiers & Qt.ShiftModifier) mods.push("SHIFT")
    if (event.modifiers & Qt.ControlModifier) mods.push("CTRL")
    if (event.modifiers & Qt.AltModifier) mods.push("ALT")
    if (!mods.length && !key)
      return ""
    return (mods.length ? mods.join(" + ") + " + " : "") + key
  }

  function startCapture(keys, action) {
    if (!root.omarchyActive || !root.editMode)
      return
    if (!KeymapData.isRunnable(keys)) {
      root.editStatus = "That row cannot be remapped"
      return
    }
    root.captureOldKeys = keys
    root.captureAction = action
    root.capturing = true
    root.editStatus = "Press the new shortcut for “" + action + "”"
  }

  function applyCapture(newHypr) {
    if (!root.capturing || !newHypr)
      return
    var oldHypr = root.toHyprChord(root.captureOldKeys)
    if (!oldHypr)
      return
    root.editStatus = "Saving…"
    editProc.command = [
      root.sourceDir + "/apply-edit", "remap",
      "--old-keys", oldHypr,
      "--old-action", root.captureAction,
      "--new-keys", newHypr,
      "--action", root.captureAction
    ]
    editProc.running = false
    editProc.running = true
  }

  function setEditMode(on) {
    if (!root.omarchyActive)
      on = false
    root.editMode = !!on
    root.capturing = false
    if (root.editMode)
      root.editStatus = "Edit: select a command, then press its new chord"
    else
      root.editStatus = ""
  }

  function executeSelected() {
    if (root.editMode) {
      var editItem = root.navItems[root.selected]
      if (editItem)
        root.startCapture(editItem.keys, editItem.action)
      return
    }
    if (root.launching || !root.opened)
      return
    var item = root.navItems[root.selected]
    if (!item)
      return
    // Dimmed rows are dimmed because we cannot issue them; running the
    // chord anyway would just close the overlay and do nothing.
    if (item.runnable === false)
      return
    // Prefer the binding's own action. Replaying the chord only works for
    // app sheet rows, which are the app's shortcuts rather than Hyprland
    // binds - a synthetic key sent to a window never reaches Hyprland's
    // bind matcher, so dispatching by chord silently did nothing.
    if (item.dispatcher) {
      root.pendingDispatcher = item.dispatcher
      root.pendingArg = item.dispatchArg || ""
      root.pendingMods = ""
      root.pendingKey = ""
      root.launching = true
      root.dismiss()
      runTimer.restart()
      return
    }
    var sc = item.shortcut
    if (!sc || !sc.key)
      sc = KeymapData.shortcut(item.keys)
    if (!sc || !sc.key)
      return
    root.pendingDispatcher = ""
    root.pendingArg = ""
    root.pendingMods = sc.mods || ""
    root.pendingKey = sc.key
    root.launching = true
    root.dismiss()
    runTimer.restart()
  }

  function activateRow(keys, action) {
    root.selectKeys(keys, action)
    if (root.editMode)
      root.startCapture(keys, action)
    else
      root.executeSelected()
  }

  function isSuperKey(event) {
    return event.key === Qt.Key_Meta
        || event.key === Qt.Key_Super_L
        || event.key === Qt.Key_Super_R
  }

  function chordMods(event) {
    return event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)
  }

  function handleKey(event) {
    if (root.capturing) {
      if (event.key === Qt.Key_Escape) {
        root.capturing = false
        root.editStatus = "Capture cancelled"
        event.accepted = true
        return
      }
      var chord = root.eventToHyprChord(event)
      if (chord) {
        root.applyCapture(chord)
        event.accepted = true
      } else {
        event.accepted = true
      }
      return
    }
    if (event.key === Qt.Key_Escape) {
      if (root.branchMenuOpen)
        root.branchMenuOpen = false
      else if (root.filterText)
        root.setFilter("")
      else
        root.dismiss()
      event.accepted = true
    } else if (event.key === Qt.Key_W
        && (event.modifiers & Qt.MetaModifier)
        && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.ShiftModifier))) {
      root.dismiss()
      event.accepted = true
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      root.executeSelected()
      event.accepted = true
    } else if (event.key === Qt.Key_Down) {
      root.moveSelection(1)
      event.accepted = true
    } else if (event.key === Qt.Key_Up) {
      root.moveSelection(-1)
      event.accepted = true
    } else if (event.key === Qt.Key_Home) {
      if (root.navItems.length) {
        root.selected = 0
        root.syncSelection()
      }
      event.accepted = true
    } else if (event.key === Qt.Key_End) {
      if (root.navItems.length) {
        root.selected = root.navItems.length - 1
        root.syncSelection()
      }
      event.accepted = true
    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
      root.jumpNeighborSection(1)
      event.accepted = true
    } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
      root.jumpNeighborSection(-1)
      event.accepted = true
    } else if ((event.modifiers & Qt.ControlModifier)
        && !(event.modifiers & (Qt.AltModifier | Qt.MetaModifier | Qt.ShiftModifier))) {
      var jump = -1
      if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9)
        jump = event.key - Qt.Key_0
      else if (event.key === Qt.Key_0)
        jump = 0
      else if (event.key >= Qt.Key_Keypad1 && event.key <= Qt.Key_Keypad9)
        jump = event.key - Qt.Key_Keypad0
      else if (event.key === Qt.Key_Keypad0)
        jump = 0
      if (jump >= 0) {
        root.jumpSection(jump)
        event.accepted = true
      }
    }
    if (event.accepted)
      return
    if (root.isSuperKey(event)) {
      event.accepted = true
    } else if (Util.editsFilter(event, root.filterText)) {
      root.setFilter(Util.editedFilter(event, root.filterText))
      event.accepted = true
    } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127
        && !root.chordMods(event)) {
      root.setFilter(root.filterText + event.text)
      event.accepted = true
    } else if (!root.chordMods(event) && event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
      var letter = String.fromCharCode(65 + (event.key - Qt.Key_A))
      if (!(event.modifiers & Qt.ShiftModifier))
        letter = letter.toLowerCase()
      root.setFilter(root.filterText + letter)
      event.accepted = true
    } else if (!root.chordMods(event) && event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
      root.setFilter(root.filterText + String(event.key - Qt.Key_0))
      event.accepted = true
    } else if (event.key === Qt.Key_Space && !root.chordMods(event)) {
      root.setFilter(root.filterText + " ")
      event.accepted = true
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: panel
        required property var modelData
        screen: modelData
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "romills-omarkeys"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (root.grabKeys && Hyprland.focusedMonitor && modelData && Hyprland.focusedMonitor.name === modelData.name)
          ? WlrKeyboardFocus.Exclusive
          : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        readonly property int cardWidth: Math.min(Style.space(1100), width - Style.gapsOut * 2)
        readonly property int cardHeight: Math.min(Style.space(760), height - Style.gapsOut * 2)
        readonly property bool hasKeyboard: Hyprland.focusedMonitor && modelData
          && Hyprland.focusedMonitor.name === modelData.name

        function takeFocus() {
          if (root.opened && panel.hasKeyboard)
            keyCatcher.forceActiveFocus()
        }

        Connections {
          target: root
          function onGrabKeysChanged() {
            if (root.grabKeys)
              Qt.callLater(panel.takeFocus)
          }
          function onOpenedChanged() {
            if (root.opened)
              Qt.callLater(panel.takeFocus)
          }
          function onFocusTickChanged() {
            if (root.opened)
              Qt.callLater(panel.takeFocus)
          }
        }

        Connections {
          target: Hyprland
          function onFocusedMonitorChanged() {
            if (root.opened && root.grabKeys && panel.hasKeyboard)
              Qt.callLater(panel.takeFocus)
          }
        }

        Rectangle {
          anchors.fill: parent
          color: root.scrim
        }

        MouseArea {
          anchors.fill: parent
          onClicked: root.dismiss()
        }

        BorderSurface {
          id: card
          width: panel.cardWidth
          height: panel.cardHeight
          radius: root.cornerRadius
          anchors.centerIn: parent
          color: root.background
          borderSpec: root.borderSpec
          padding: root.contentMargin

          MouseArea { anchors.fill: parent; onClicked: {} }

          Shortcut {
            sequences: ["Return", "Enter"]
            enabled: root.opened && root.grabKeys && panel.hasKeyboard
            onActivated: root.executeSelected()
          }

          Item {
            id: keyCatcher
            anchors.fill: parent
            focus: root.grabKeys && panel.hasKeyboard
            Keys.priority: Keys.BeforeItem
            Keys.onPressed: function(event) { root.handleKey(event) }
            Keys.onReleased: function(event) {
              if (root.isSuperKey(event))
                event.accepted = true
            }

            Column {
              id: body
              anchors.fill: parent
              anchors.topMargin: card.contentTopInset
              anchors.rightMargin: card.contentRightInset
              anchors.bottomMargin: card.contentBottomInset
              anchors.leftMargin: card.contentLeftInset
              spacing: Style.spacing.md

              Item {
                width: parent.width
                height: Math.max(Style.space(28), headerLabel.implicitHeight)

                Text {
                  id: headerLabel
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.right: hintLabel.left
                  anchors.rightMargin: Style.spacing.md
                  text: root.filterText || "OmarKEYS"
                  textFormat: Text.PlainText
                  color: root.foreground
                  opacity: root.filterText ? 1 : 0.58
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  elide: Text.ElideRight
                }

                Text {
                  id: hintLabel
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  text: "↑↓ command · Ctrl+1–9 window · type to search · Enter run"
                  textFormat: Text.PlainText
                  color: root.foreground
                  opacity: 0.72
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }
              }

              Row {
                id: mainRow
                width: parent.width
                height: parent.height - headerLabel.parent.height - settingsBar.height - body.spacing * 2
                spacing: Style.spacing.md

                KeymapSidebar {
                  id: sideBar
                  host: root
                  height: parent.height
                }

                KeymapBoard {
                  id: listFlick
                  host: root
                  width: parent.width - sideBar.width - mainRow.spacing
                  height: parent.height
                }
              }

              KeymapSettingsBar {
                id: settingsBar
                host: root
                width: parent.width
              }
            }
          }

          Text {
            id: buildInfo
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Style.spacing.sm
            visible: !!(root.gitBranch || root.gitHash)
            textFormat: Text.PlainText
            // Lead with the channel: that is the part most people care
            // about. The branch name only adds information on Nightly,
            // where it is not implied by the channel.
            text: (root.branchMenuOpen ? "▾ " : "▴ ")
              + root.channelLabel(root.gitChannel)
              + (root.gitChannel === "nightly" && root.gitBranch ? " · " + root.gitBranch : "")
              + (root.gitHash ? " @ " + root.gitHash : "")
              + (root.gitUpdateAvailable ? " •" : "")
            color: root.gitUpdateAvailable ? root.chipFg : root.foreground
            opacity: buildInfoArea.containsMouse || root.branchMenuOpen ? 0.9 : 0.35
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption

            MouseArea {
              id: buildInfoArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleBranchMenu()
            }
          }

          KeymapBranchMenu {
            host: root
            visible: root.branchMenuOpen
            anchors.right: parent.right
            anchors.bottom: buildInfo.top
            anchors.rightMargin: Style.spacing.sm
            anchors.bottomMargin: Style.space(4)
          }
        }
      }
    }
  }
}
