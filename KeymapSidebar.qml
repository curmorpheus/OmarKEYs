import QtQuick
import qs.Commons
import qs.Ui

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
      height: Math.max(40, parent.height - modBlock.height - modDivider.height - parent.spacing * 2)
      clip: true
      contentWidth: width
      contentHeight: treeCol.height
      boundsBehavior: Flickable.StopAtBounds
      activeFocusOnTab: false

      Column {
        id: treeCol
        width: parent.width
        spacing: 2

        Item {
          width: parent.width
          height: Math.max(Style.space(24), omarchyLabel.implicitHeight + 6)

          ToggleSwitch {
            id: omarchySwitch
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            visible: host && host.omarchyActive
            checked: host ? host.allGroupsVisible : true
            foreground: side.foreground
            accent: side.chipFg
            trackHeight: 16
            activeFocusOnTab: false
            onToggled: {
              var h = side.host
              if (h)
                h.setAllGroupsVisible(!h.allGroupsVisible)
            }
          }

          Row {
            anchors.fill: parent
            anchors.rightMargin: omarchySwitch.visible ? omarchySwitch.width + 8 : 4
            spacing: 4

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              text: side.omarchyOpen ? "▾" : "▸"
              color: side.chipFg
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.omarchyOpen = !side.omarchyOpen
              }
            }

            Text {
              id: omarchyLabel
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 16
              text: "Omarchy"
              textFormat: Text.PlainText
              color: host && host.omarchyActive ? side.chipFg : side.foreground
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

            // Area header (depth 1): the trunk line for this branch of
            // the tree — its group rows below share the same trunk x.
            Item {
              width: areaCol.width
              height: Math.max(Style.space(18), areaLabel.implicitHeight + 3)

              Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: side.borderColor
                opacity: 0.35
              }

              ToggleSwitch {
                id: areaSwitch
                anchors.right: parent.right
                anchors.rightMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                checked: areaCol.allVisible
                foreground: side.foreground
                accent: side.chipFg
                trackHeight: 12
                activeFocusOnTab: false
                onToggled: {
                  var h = side.host
                  if (!h)
                    return
                  var titles = []
                  var groups = areaCol.modelData.groups || []
                  for (var ti = 0; ti < groups.length; ti++)
                    titles.push(groups[ti].title)
                  var show = !areaCol.allVisible
                  h.setGroupsVisible(titles, show)
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
                opacity: 0.75
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
              model: areaCol.modelData.groups
              delegate: Item {
                required property var modelData
                width: areaCol.width
                height: Math.max(Style.space(18), groupLabel.implicitHeight + 3)

                Rectangle {
                  anchors.left: parent.left
                  anchors.leftMargin: 6
                  anchors.top: parent.top
                  anchors.bottom: parent.bottom
                  width: 1
                  color: side.borderColor
                  opacity: 0.35
                }

                ToggleSwitch {
                  id: groupSwitch
                  anchors.right: parent.right
                  anchors.rightMargin: 2
                  anchors.verticalCenter: parent.verticalCenter
                  checked: !modelData.hidden
                  foreground: side.foreground
                  accent: side.chipFg
                  trackHeight: 11
                  activeFocusOnTab: false
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

          Row {
            anchors.fill: parent
            spacing: 4

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              text: side.windowsOpen ? "▾" : "▸"
              color: side.chipFg
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
              font.family: side.fontFamily
              font.pixelSize: side.rootFontSize
              font.bold: true
              font.capitalization: Font.AllUppercase
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

        Repeater {
          model: side.windowsOpen && host ? host.clients : []
          delegate: Item {
            required property var modelData
            width: treeCol.width
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
              anchors.leftMargin: 14
              anchors.verticalCenter: parent.verticalCenter
              text: (modelData.focused ? "· " : "") + (modelData.label || modelData.class)
                + (modelData.count > 1 ? " (" + modelData.count + ")" : "")
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
                onClicked: {
                  var h = side.host
                  if (h)
                    h.selectSource(modelData.class)
                }
              }
            }
          }
        }
      }
    }

    Item {
      id: modDivider
      width: parent.width
      height: Style.space(9)

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: side.borderColor
        opacity: 0.5
      }
    }

    Column {
      id: modBlock
      width: parent.width
      spacing: Style.space(3)

      Text {
        text: "Modifiers"
        textFormat: Text.PlainText
        color: side.chipFg
        font.family: side.fontFamily
        font.pixelSize: side.subFontSize
        font.bold: true
        font.capitalization: Font.AllUppercase
      }

      Row {
        spacing: 8

        Repeater {
          model: ["any", "must", "hide"]
          delegate: Text {
            required property string modelData
            readonly property bool active: !host ? false
              : modelData === "any" ? host.allModsAny
              : modelData === "must" ? host.allModsMust
              : host.allModsHide
            text: modelData === "any" ? "A all" : (modelData === "must" ? "M all" : "H all")
            textFormat: Text.PlainText
            color: active ? side.chipFg : side.foreground
            opacity: active ? 1 : 0.55
            font.family: side.fontFamily
            font.pixelSize: side.subFontSize
            font.bold: active
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: if (host) host.setAllModifiers(modelData)
            }
          }
        }
      }

      // Four boxed chips, 2 x 2: each shows its modifier and the state it
      // is in, and clicking cycles A -> M -> H. Boxed because these are
      // controls you press, unlike the labels in the tree above.
      // Measures the widest cap so all four are the same size: a keyboard
      // has uniform keys, and content-sized chips would come out ragged
      // ("Super - A" against "Alt - A").
      Text {
        id: capMetric
        visible: false
        text: "Super"
        font.family: side.fontFamily
        font.pixelSize: side.subFontSize
      }

      Grid {
        id: modGrid
        anchors.horizontalCenter: parent.horizontalCenter
        columns: 2
        columnSpacing: Style.space(4)
        rowSpacing: Style.space(4)

        Repeater {
          model: ["Super", "Shift", "Ctrl", "Alt"]
          delegate: Item {
            id: cell
            required property string modelData
            readonly property string mode: !side.host ? "any"
              : modelData === "Super" ? side.host.modSuper
              : modelData === "Shift" ? side.host.modShift
              : modelData === "Ctrl" ? side.host.modCtrl
              : side.host.modAlt
            readonly property string mark: mode === "must" ? "M" : (mode === "hide" ? "H" : "A")

            width: keyCap.width + Style.space(3) + markLabel.implicitWidth
            height: keyCap.height
            opacity: cell.mode === "hide" ? 0.55 : 1

            Rectangle {
              id: keyCap
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: capMetric.implicitWidth + Style.space(12)
              height: capMetric.implicitHeight + Style.space(8)
              radius: 5
              border.width: 1
              border.color: cell.mode === "any" ? side.borderColor : side.chipFg
              // A faint fill so the cap reads as a raised key rather than
              // an outlined box, brightening under the cursor.
              color: modArea.containsMouse
                ? Qt.rgba(side.chipFg.r, side.chipFg.g, side.chipFg.b, 0.22)
                : Qt.rgba(side.borderColor.r, side.borderColor.g, side.borderColor.b, 0.18)

              Text {
                anchors.centerIn: parent
                text: cell.modelData
                textFormat: Text.PlainText
                color: cell.mode === "any" ? side.foreground : side.chipFg
                font.family: side.fontFamily
                font.pixelSize: side.subFontSize
                font.bold: cell.mode !== "any"
              }
            }

            // The state sits beside the key, not on it: the cap is the key
            // you are filtering, the letter is what you are doing to it.
            Text {
              id: markLabel
              anchors.left: keyCap.right
              anchors.leftMargin: Style.space(3)
              anchors.verticalCenter: parent.verticalCenter
              text: cell.mark
              textFormat: Text.PlainText
              color: cell.mode === "any" ? side.foreground : side.chipFg
              opacity: cell.mode === "any" ? 0.75 : 1
              font.family: side.fontFamily
              font.pixelSize: side.subFontSize
              font.bold: true
            }

            MouseArea {
              id: modArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                var h = side.host
                if (h)
                  h.cycleModifier(cell.modelData)
              }
            }
          }
        }
      }
    }
  }
}
