import QtQuick
import qs.Commons
import "KeymapData.js" as KeymapData

Rectangle {
  id: side
  property Item host: null
  property bool omarchyOpen: true
  property bool windowsOpen: true

  readonly property color foreground: host ? host.foreground : Color.menu.text
  readonly property color chipFg: host ? host.chipFg : Color.menu.selectedText
  readonly property color borderColor: host ? host.border : Color.menu.border
  readonly property string fontFamily: host ? host.fontFamily : Style.font.menuFamily

  // Tree depth sizing: root branches sit at the theme's caption size,
  // everything nested under them steps down proportionally so it keeps
  // scaling with the user's base font size.
  readonly property int rootFontSize: Style.font.caption
  // The Options popup opens above this link, which lives down here now.
  readonly property int optionsLinkHeight: optionsLink.height
  readonly property int subFontSize: Math.max(8, Math.round(Style.font.caption * 0.9))

  width: Style.space(200)
  radius: 6
  color: "transparent"
  border.width: 1
  border.color: side.borderColor

  MouseArea { anchors.fill: parent; onClicked: {} }

  Column {
    id: sideCol
    anchors.fill: parent
    anchors.margins: Style.spacing.sm
    spacing: Style.space(6)

    Flickable {
      width: parent.width
      height: parent.height - footer.height - sideCol.spacing
      clip: true
      contentWidth: width
      contentHeight: treeCol.height
      // Scrollable content will always clip somewhere; the margin keeps a
      // half-drawn row from sitting flush against the edge, where it reads
      // as broken rather than as "there is more".
      bottomMargin: Style.space(6)
      boundsBehavior: Flickable.StopAtBounds
      activeFocusOnTab: false

      Column {
        id: treeCol
        width: parent.width
        spacing: 2

        Item {
          width: parent.width
          height: Math.max(Style.space(24), omarchyLabel.implicitHeight + 6)

          HoverHandler { id: omarchyHover }

          // Hiding a branch takes its whole subtree off the board and
          // collapses it here, so one control does both.
          KeymapHideButton {
            id: omarchyToggle
            visible: omarchyHover.hovered || omarchyToggle.hovered
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            shown: side.omarchyOpen && !(host && host.allGroupsHidden)
            foreground: side.foreground
            accent: side.chipFg
            fontFamily: side.fontFamily
            fontSize: side.subFontSize
            onToggled: {
              var h = side.host
              var reveal = !(side.omarchyOpen && !(h && h.allGroupsHidden))
              side.omarchyOpen = reveal
              if (h)
                h.setAllGroupsVisible(reveal)
            }
          }

          Row {
            anchors.fill: parent
            anchors.rightMargin: omarchyToggle.width + 8
            spacing: 4

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              text: (side.omarchyOpen && !(host && host.allGroupsHidden)) ? "▾" : "▸"
              color: side.chipFg
              opacity: (host && host.allGroupsHidden) ? 0.4 : 1
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.omarchyOpen = !side.omarchyOpen
              }
            }

            Text {
              id: omarchyMark
              anchors.verticalCenter: parent.verticalCenter
              text: KeymapData.omarchyIcon()
              textFormat: Text.PlainText
              color: host && host.omarchyActive ? side.chipFg : side.foreground
              opacity: (host && host.allGroupsHidden) ? 0.4 : 1
              font.family: side.fontFamily
              // A glyph reads smaller than a letter at the same pixel size.
              font.pixelSize: Math.round(side.rootFontSize * 1.15)
            }

            Text {
              id: omarchyLabel
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 20 - omarchyMark.width
              text: "Omarchy"
              textFormat: Text.PlainText
              color: host && host.omarchyActive ? side.chipFg : side.foreground
              opacity: (host && host.allGroupsHidden) ? 0.4 : 1
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              font.bold: true
              elide: Text.ElideRight
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // Root of the branch: back to the whole Omarchy keymap,
                // undoing any area/group solo from a previous click.
                onClicked: {
                  var h = side.host
                  if (!h)
                    return
                  h.selectSource("omarchy")
                  h.setAllGroupsVisible(true)
                }
              }
            }
          }
        }

        Repeater {
          model: side.omarchyOpen && host ? host.omarchyTree : []
          delegate: Column {
            id: areaCol
            required property var modelData
            width: treeCol.width
            spacing: 2

            readonly property bool allVisible: {
              var groups = areaCol.modelData.groups || []
              for (var gi = 0; gi < groups.length; gi++) {
                if (groups[gi].hidden)
                  return false
              }
              return true
            }

            // Hiding an area takes its groups off the board; collapsing the
            // rows here follows from that rather than being separate state,
            // so the tree cannot disagree with what the board is showing.
            readonly property bool allHidden: {
              var groups = areaCol.modelData.groups || []
              if (!groups.length)
                return false
              for (var hi = 0; hi < groups.length; hi++) {
                if (!groups[hi].hidden)
                  return false
              }
              return true
            }

            // Area header (depth 1): the trunk line for this branch of
            // the tree — its group rows below share the same trunk x.
            Item {
              width: areaCol.width
              height: Math.max(Style.space(18), areaLabel.implicitHeight + 3)

              HoverHandler { id: areaHover }

              // A branch marks itself with a caret rather than the trunk
              // line its children use: collapsed when everything under it
              // is hidden, expanded while any of it still shows.
              Text {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                text: areaCol.allHidden ? "▸" : "▾"
                color: side.chipFg
                opacity: areaCol.allHidden ? 0.4 : 0.7
                font.family: side.fontFamily
                font.pixelSize: side.subFontSize
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    var h = side.host
                    if (!h)
                      return
                    var titles = []
                    var groups = areaCol.modelData.groups || []
                    for (var ci = 0; ci < groups.length; ci++)
                      titles.push(groups[ci].title)
                    h.setGroupsVisible(titles, areaCol.allHidden)
                  }
                }
              }

              KeymapHideButton {
                id: areaSwitch
                visible: areaHover.hovered || areaSwitch.hovered
                anchors.right: parent.right
                anchors.rightMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                shown: !areaCol.allHidden
                foreground: side.foreground
                accent: side.chipFg
                fontFamily: side.fontFamily
                fontSize: side.subFontSize
                onToggled: {
                  var h = side.host
                  if (!h)
                    return
                  var titles = []
                  var groups = areaCol.modelData.groups || []
                  for (var ti = 0; ti < groups.length; ti++)
                    titles.push(groups[ti].title)
                  h.setGroupsVisible(titles, areaCol.allHidden)
                }
              }

              Text {
                id: areaLabel
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: areaSwitch.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: areaCol.modelData.title
                textFormat: Text.PlainText
                color: side.foreground
                opacity: areaCol.allHidden ? 0.4 : 0.75
                font.family: side.fontFamily
                font.pixelSize: side.subFontSize
                font.bold: true
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  // Show only this area's groups on the board.
                  onClicked: {
                    var h = side.host
                    if (!h)
                      return
                    var titles = []
                    var groups = areaCol.modelData.groups || []
                    for (var ci = 0; ci < groups.length; ci++)
                      titles.push(groups[ci].title)
                    if (!h.omarchyActive)
                      h.selectSource("omarchy")
                    h.soloGroups(titles)
                  }
                }
              }
            }

            // Group rows (depth 2): same trunk x as the header above,
            // content indented past it.
            Repeater {
              model: areaCol.allHidden ? [] : areaCol.modelData.groups
              delegate: Item {
                required property var modelData
                width: areaCol.width
                height: Math.max(Style.space(18), groupLabel.implicitHeight + 3)

                // Reveals this row's control. A HoverHandler rather than a
                // MouseArea so it does not sit between the label and its
                // own click handler.
                HoverHandler { id: groupHover }

                Rectangle {
                  anchors.left: parent.left
                  anchors.leftMargin: 6
                  anchors.top: parent.top
                  anchors.bottom: parent.bottom
                  width: 1
                  color: side.borderColor
                  opacity: 0.35
                }

                KeymapHideButton {
                  id: groupSwitch
                  anchors.right: parent.right
                  anchors.rightMargin: 2
                  anchors.verticalCenter: parent.verticalCenter
                  visible: groupHover.hovered || groupSwitch.hovered
                  shown: !modelData.hidden
                  foreground: side.foreground
                  accent: side.chipFg
                  fontFamily: side.fontFamily
                  fontSize: side.subFontSize
                  onToggled: {
                    var h = side.host
                    if (h)
                      h.toggleGroup(modelData.title)
                  }
                }

                Text {
                  id: groupLabel
                  anchors.left: parent.left
                  anchors.leftMargin: 26
                  anchors.right: groupSwitch.left
                  anchors.rightMargin: 6
                  anchors.verticalCenter: parent.verticalCenter
                  text: modelData.title
                  textFormat: Text.PlainText
                  color: host && host.omarchyActive && modelData.title === host.selectedSectionTitle ? side.chipFg : side.foreground
                  opacity: modelData.hidden ? 0.4 : 1
                  font.family: side.fontFamily
                  font.pixelSize: side.subFontSize
                  font.bold: host && host.omarchyActive && modelData.title === host.selectedSectionTitle
                  elide: Text.ElideRight
                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    // Show only this group's table on the board.
                    onClicked: {
                      // soloGroups() rebuilds the tree model, which destroys
                      // this delegate mid-handler. Resolve everything we need
                      // up front so the calls after it are not running in a
                      // scope that no longer exists.
                      var h = side.host
                      if (!h)
                        return
                      var title = modelData.title
                      if (!h.omarchyActive)
                        h.selectSource("omarchy")
                      h.soloGroups([title])
                      h.focusGroup(title)
                    }
                  }
                }
              }
            }
          }
        }

        Item {
          width: parent.width
          height: Math.max(Style.space(24), windowsLabel.implicitHeight + 8)

          HoverHandler { id: windowsHover }

          KeymapHideButton {
            id: windowsToggle
            visible: windowsHover.hovered || windowsToggle.hovered
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            // Tracks content, not just expansion: a branch whose apps are
            // all hidden must still offer "Show", or hiding everything is
            // a one-way door.
            shown: side.windowsOpen && !(host && host.allAppsHidden)
            foreground: side.foreground
            accent: side.chipFg
            fontFamily: side.fontFamily
            fontSize: side.subFontSize
            onToggled: {
              var h = side.host
              var reveal = !(side.windowsOpen && !(h && h.allAppsHidden))
              side.windowsOpen = reveal
              if (h) {
                if (reveal)
                  h.showAllApps()
                else
                  h.setAppsVisible(h.allAppClasses, false)
              }
            }
          }

          Row {
            anchors.fill: parent
            anchors.rightMargin: windowsToggle.width + 8
            spacing: 4

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              text: (side.windowsOpen && !(host && host.allAppsHidden)) ? "▾" : "▸"
              color: side.chipFg
              opacity: (host && host.allAppsHidden) ? 0.4 : 1
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.windowsOpen = !side.windowsOpen
              }
            }

            Text {
              id: windowsLabel
              anchors.verticalCenter: parent.verticalCenter
              text: "Active Apps"
              textFormat: Text.PlainText
              color: side.chipFg
              opacity: (host && host.allAppsHidden) ? 0.4 : 1
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              font.bold: true
              font.capitalization: Font.AllUppercase
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.windowsOpen = !side.windowsOpen
              }
            }
          }
        }

        Item {
          visible: side.windowsOpen && host && (!host.clients || host.clients.length === 0)
          width: treeCol.width
          height: visible ? Math.max(Style.space(18), noWindowsLabel.implicitHeight + 3) : 0

          Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: side.borderColor
            opacity: 0.35
          }

          Text {
            id: noWindowsLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "No windows detected"
            textFormat: Text.PlainText
            color: side.foreground
            opacity: 0.5
            font.family: side.fontFamily
            font.pixelSize: side.subFontSize
            font.italic: true
          }
        }

        // Workspaces first: the same app groupings as before, but only the
        // windows actually on that workspace. An app with windows on two of
        // them appears under both, each time with just the ones there.
        Repeater {
          model: side.windowsOpen && host ? host.workspaceTree : []
          delegate: Column {
            id: wsCol
            required property var modelData
            property bool open: true
            width: treeCol.width
            spacing: 2

            Item {
              width: parent.width
              height: Math.max(Style.space(22), wsLabel.implicitHeight + 4)

              Text {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                text: wsCol.open ? "▾" : "▸"
                color: side.chipFg
                opacity: wsCol.modelData.hidden ? 0.4 : 0.7
                font.family: side.fontFamily
                font.pixelSize: side.subFontSize
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: wsCol.open = !wsCol.open
                }
              }

              Text {
                id: wsLabel
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: wsCol.modelData.title
                textFormat: Text.PlainText
                color: side.foreground
                opacity: wsCol.modelData.hidden ? 0.4 : 0.85
                font.family: side.fontFamily
                font.pixelSize: side.subFontSize
                font.bold: true
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  // Double-click goes to the workspace. A single click does
                  // nothing here on purpose: folding is the caret's job, and
                  // having the row fold under the first half of a
                  // double-click made switching flinch every time.
                  onDoubleClicked: {
                    var h = side.host
                    if (h)
                      h.focusWorkspace(wsCol.modelData.id)
                  }
                }
              }
            }

            Repeater {
              model: wsCol.open ? wsCol.modelData.kinds : []
              delegate: Column {
                id: kindCol
                required property var modelData
                width: treeCol.width
                spacing: 2

                Item {
                  width: kindCol.width
                  height: Math.max(Style.space(18), kindLabel.implicitHeight + 3)

                  HoverHandler { id: kindHover }

                  Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12
                    text: kindCol.modelData.hidden ? "▸" : "▾"
                    color: side.chipFg
                    opacity: kindCol.modelData.hidden ? 0.4 : 0.7
                    font.family: side.fontFamily
                    font.pixelSize: side.subFontSize
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      // A kind groups the apps that share one sheet, so any of
                      // them names it. Hiding is the button's job, revealed on
                      // hover -- clicking the row shows the keys, the way every
                      // other row in this branch does.
                      onClicked: {
                        var h = side.host
                        if (!h)
                          return
                        var apps = kindCol.modelData.apps || []
                        if (apps.length)
                          h.selectSource(apps[0].class)
                      }
                    }
                  }

                  KeymapHideButton {
                    id: kindToggle
                    visible: kindHover.hovered || kindToggle.hovered
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    shown: !kindCol.modelData.hidden
                    foreground: side.foreground
                    accent: side.chipFg
                    fontFamily: side.fontFamily
                    fontSize: side.subFontSize
                    onToggled: {
                      var h = side.host
                      if (!h)
                        return
                      var classes = []
                      var apps = kindCol.modelData.apps || []
                      for (var ci = 0; ci < apps.length; ci++)
                        classes.push(apps[ci].class)
                      h.setAppsVisible(classes, kindCol.modelData.hidden)
                    }
                  }

                  Text {
                    id: kindLabel
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    anchors.right: kindToggle.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: kindCol.modelData.title
                    textFormat: Text.PlainText
                    color: side.foreground
                    opacity: kindCol.modelData.hidden ? 0.4 : 0.75
                    font.family: side.fontFamily
                    font.pixelSize: side.subFontSize
                    font.bold: true
                    font.capitalization: Font.AllUppercase
                    elide: Text.ElideRight
                  }
                }

                Repeater {
                  model: kindCol.modelData.hidden ? [] : kindCol.modelData.apps
                  delegate: Column {
                    id: appCol
                    required property var modelData
                    width: kindCol.width
                    spacing: 2

                  Item {
                    width: appCol.width
                    height: Math.max(Style.space(18), winLabel.implicitHeight + 3)

                    Rectangle {
                      anchors.left: parent.left
                      anchors.leftMargin: 6
                      anchors.top: parent.top
                      anchors.bottom: parent.bottom
                      width: 1
                      color: side.borderColor
                      opacity: 0.35
                    }

                    Text {
                      id: winLabel
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.leftMargin: 38
                      anchors.rightMargin: 6
                      anchors.verticalCenter: parent.verticalCenter
                      text: (modelData.focused ? "· " : "") + (modelData.label || modelData.class)
                        // The count only says what the rows below already show,
                        // so it is for the unexpanded case alone.
                        + ((modelData.count > 1 && !(modelData.windows && modelData.windows.length > 1))
                          ? " (" + modelData.count + ")" : "")
                      textFormat: Text.PlainText
                      color: host && host.activeSource === modelData.class ? side.chipFg : side.foreground
                      opacity: modelData.sheet ? 1 : 0.55
                      font.family: side.fontFamily
                      font.pixelSize: side.subFontSize
                      font.bold: host && host.activeSource === modelData.class
                      elide: Text.ElideRight
                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        // Click shows the app's keymap; double-click goes to the
                        // window itself.
                        onClicked: {
                          var h = side.host
                          if (h)
                            h.selectSource(modelData.class)
                        }
                        onDoubleClicked: {
                          var h = side.host
                          if (h)
                            h.focusWindow(modelData.address)
                        }
                      }
                    }
                  }

                  // One window is the app row itself; more than one and each
                  // gets its own line, named by what is running in it.
                  Repeater {
                    model: (appCol.modelData.windows && appCol.modelData.windows.length > 1)
                      ? appCol.modelData.windows : []
                    delegate: Column {
                      id: winCol
                      required property var modelData
                      width: appCol.width
                      spacing: 2

                      Item {
                        width: winCol.width
                        height: Math.max(Style.space(17), exeLabel.implicitHeight + 3)

                        Rectangle {
                          anchors.left: parent.left
                          anchors.leftMargin: 6
                          anchors.top: parent.top
                          anchors.bottom: parent.bottom
                          width: 1
                          color: side.borderColor
                          opacity: 0.35
                        }

                        Text {
                          id: exeLabel
                          anchors.left: parent.left
                          anchors.right: parent.right
                          anchors.leftMargin: 50
                          anchors.rightMargin: 6
                          anchors.verticalCenter: parent.verticalCenter
                          // An idle shell has no program to name, so its title
                          // takes this line instead of an empty one.
                          text: (winCol.modelData.focused ? "· " : "")
                            + (winCol.modelData.exe || winCol.modelData.title)
                          textFormat: Text.PlainText
                          color: side.foreground
                          opacity: winCol.modelData.exe ? 1 : 0.8
                          font.family: side.fontFamily
                          font.pixelSize: side.subFontSize
                          elide: Text.ElideRight
                          MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            // Same as the app row above it: click shows that
                            // app's keymap, double-click goes to the window.
                            onClicked: {
                              var h = side.host
                              if (h)
                                h.selectSource(appCol.modelData.class)
                            }
                            onDoubleClicked: {
                              var h = side.host
                              if (h)
                                h.focusWindow(winCol.modelData.address)
                            }
                          }
                        }
                      }

                      // The window's own name, under the program running in it.
                      Item {
                        visible: !!winCol.modelData.exe
                        width: winCol.width
                        height: visible ? Math.max(Style.space(16), titleLabel.implicitHeight + 2) : 0

                        Rectangle {
                          anchors.left: parent.left
                          anchors.leftMargin: 6
                          anchors.top: parent.top
                          anchors.bottom: parent.bottom
                          width: 1
                          color: side.borderColor
                          opacity: 0.35
                        }

                        Text {
                          id: titleLabel
                          anchors.left: parent.left
                          anchors.right: parent.right
                          anchors.leftMargin: 62
                          anchors.rightMargin: 6
                          anchors.verticalCenter: parent.verticalCenter
                          text: winCol.modelData.title
                          textFormat: Text.PlainText
                          color: side.foreground
                          opacity: 0.6
                          font.family: side.fontFamily
                          font.pixelSize: side.subFontSize
                          elide: Text.ElideRight
                          MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            // Same as the app row above it: click shows that
                            // app's keymap, double-click goes to the window.
                            onClicked: {
                              var h = side.host
                              if (h)
                                h.selectSource(appCol.modelData.class)
                            }
                            onDoubleClicked: {
                              var h = side.host
                              if (h)
                                h.focusWindow(winCol.modelData.address)
                            }
                          }
                        }
                      }
                    }
                  }
                  }
                }
              }
            }
          }
        }
      }
    }


    // The settings you reach for while reading the board, without opening
    // the popup for them. Each icon shows its current mode and cycles on
    // click; the filter shares its row with what is being filtered on.
    Column {
      id: footer
      width: parent.width
      spacing: Style.space(5)

      Rectangle {
        width: parent.width
        height: 1
        color: side.borderColor
        opacity: 0.5
      }

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Options"
        textFormat: Text.PlainText
        color: side.chipFg
        font.family: side.fontFamily
        font.pixelSize: Math.round(side.rootFontSize * 1.2)
        font.bold: true
        font.capitalization: Font.AllUppercase
      }

      Row {
        id: controlRow
        width: parent.width

        Repeater {
          model: [
            { id: "group", glyph: "\udb80\udec3" },
            { id: "sort",  glyph: "\udb81\udcba" },
            { id: "order", glyph: "\udb82\udcdf" }
          ]
          delegate: Item {
            required property var modelData
            readonly property string mode: {
              var h = side.host
              if (!h)
                return ""
              if (modelData.id === "group")
                return h.grouping === "off" ? "off"
                  : (h.grouping === "keytype" ? "by key type" : "by topic")
              if (modelData.id === "sort")
                return h.sortBy === "action" ? "by name"
                  : (h.sortBy === "key" ? "by key" : "by group")
              return h.rowLayout === "action" ? "keys last" : "keys first"
            }
            width: controlRow.width / 3
            height: glyphText.height + modeText.height + Style.space(2)

            Text {
              id: glyphText
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.glyph
              textFormat: Text.PlainText
              color: cellArea.containsMouse ? side.chipFg : side.foreground
              opacity: cellArea.containsMouse ? 1 : 0.75
              font.family: side.fontFamily
              font.pixelSize: Math.round(side.rootFontSize * 3.4)
            }

            Text {
              id: modeText
              anchors.top: glyphText.bottom
              anchors.topMargin: Style.space(2)
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: mode
              textFormat: Text.PlainText
              color: cellArea.containsMouse ? side.chipFg : side.foreground
              opacity: 0.55
              font.family: side.fontFamily
              font.pixelSize: side.subFontSize
              elide: Text.ElideRight
            }

            MouseArea {
              id: cellArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                var h = side.host
                if (!h)
                  return
                if (modelData.id === "group")
                  h.cycleGrouping()
                else if (modelData.id === "sort")
                  h.cycleSortBy()
                else
                  h.cycleRowLayout()
              }
            }
          }
        }
      }

      // The filter keeps its own column under Grouping, mode label and
      // all, so it reads as the fourth of the same kind of control. What
      // it is filtering on takes the width of the other two.
      Row {
        id: filterRow
        width: parent.width

        Item {
          width: controlRow.width / 3
          height: filterGlyph.height + filterMode.height + Style.space(2)

          Text {
            id: filterGlyph
            anchors.horizontalCenter: parent.horizontalCenter
            text: "\udb80\ude32"
            textFormat: Text.PlainText
            color: filterModeArea.containsMouse ? side.chipFg : side.foreground
            opacity: filterModeArea.containsMouse ? 1 : 0.75
            font.family: side.fontFamily
            font.pixelSize: Math.round(side.rootFontSize * 3.4)
          }

          Text {
            id: filterMode
            anchors.top: filterGlyph.bottom
            anchors.topMargin: Style.space(2)
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: {
              var h = side.host
              if (!h)
                return ""
              return h.searchMode === "keys" ? "key"
                : (h.searchMode === "action" ? "description" : "all")
            }
            textFormat: Text.PlainText
            color: filterModeArea.containsMouse ? side.chipFg : side.foreground
            opacity: 0.55
            font.family: side.fontFamily
            font.pixelSize: side.subFontSize
            elide: Text.ElideRight
          }

          MouseArea {
            id: filterModeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (side.host) side.host.cycleSearchMode()
          }
        }

        // Across the other two columns, and as tall as the glyph beside
        // it so the two read as one control rather than a big icon with a
        // small box floating next to it.
        Rectangle {
          id: filterBox
          width: filterRow.width - controlRow.width / 3
          height: filterGlyph.height
          radius: 4
          color: "transparent"
          border.width: 1
          border.color: (side.host && side.host.filterCapturing) ? side.chipFg
            : (filterArea.containsMouse ? side.chipFg : side.borderColor)
          opacity: filterArea.containsMouse || (side.host && side.host.filterCapturing) ? 1 : 0.8

          Text {
            id: filterText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.space(5)
            anchors.rightMargin: Style.space(5)
            anchors.verticalCenter: parent.verticalCenter
            readonly property bool arming: !!(side.host && side.host.filterCapturing)
            readonly property string hint: {
              var h = side.host
              if (!h)
                return "type to filter"
              if (h.filterCapturing)
                return "press any key…"
              return h.searchMode === "keys" ? "click to capture"
                : (h.searchMode === "action" ? "type a word" : "type to filter")
            }
            text: (!arming && side.host && side.host.filterText)
              ? side.host.filterText : hint
            textFormat: Text.PlainText
            color: (arming || (side.host && side.host.filterText))
              ? side.chipFg : side.foreground
            opacity: (!arming && side.host && side.host.filterText) ? 1 : 0.5
            font.family: side.fontFamily
            // Sized to the width, not the height: the box is two thirds of
            // a 200px sidebar, and at 1.4x the hint elided to "click,
            // then …", which tells you nothing.
            font.pixelSize: side.subFontSize
            elide: Text.ElideRight
          }

          MouseArea {
            id: filterArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // In key mode the box takes the next keystroke whole, which is
            // the only way to filter on Return or Escape -- they do other
            // jobs the rest of the time. Elsewhere a click just clears.
            onClicked: {
              var h = side.host
              if (!h)
                return
              if (h.searchMode === "keys")
                h.toggleFilterCapture()
              else
                h.setFilter("")
            }
          }
        }
      }

      // Everything else, inside the tree's border rather than loose in
      // the card's padding beneath it.
      Text {
        id: optionsLink
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: (side.host && side.host.optionsMenuOpen ? "▾ " : "▴ ") + "All Options"
        textFormat: Text.PlainText
        color: side.foreground
        opacity: optionsLinkArea.containsMouse || (side.host && side.host.optionsMenuOpen)
          ? 0.9 : 0.45
        font.family: side.fontFamily
        font.pixelSize: Math.round(Style.font.body * 1.2)

        MouseArea {
          id: optionsLinkArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: if (side.host) side.host.toggleOptionsMenu()
        }
      }
    }
  }
}
