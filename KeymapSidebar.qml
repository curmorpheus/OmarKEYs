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
      height: Math.max(40, parent.height - modBlock.height - parent.spacing)
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

          Row {
            anchors.fill: parent
            spacing: 4

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              text: side.omarchyOpen ? "▾" : "▸"
              color: side.chipFg
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.omarchyOpen = !side.omarchyOpen
              }
            }

            Text {
              id: omarchyLabel
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 70
              text: "Omarchy"
              textFormat: Text.PlainText
              color: host && host.omarchyActive ? side.chipFg : side.foreground
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              elide: Text.ElideRight
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (host) host.selectSource("omarchy")
              }
            }

            ToggleSwitch {
              anchors.verticalCenter: parent.verticalCenter
              visible: host && host.omarchyActive
              checked: host ? host.allGroupsVisible : true
              foreground: side.foreground
              accent: side.chipFg
              trackHeight: 16
              activeFocusOnTab: false
              onToggled: if (host) host.setAllGroupsVisible(!host.allGroupsVisible)
            }
          }
        }

        Repeater {
          model: side.omarchyOpen && host ? host.omarchyGroupList : []
          delegate: Item {
            required property var modelData
            width: treeCol.width
            height: Math.max(Style.space(22), groupLabel.implicitHeight + 4)

            Row {
              anchors.fill: parent
              anchors.leftMargin: 14
              spacing: 6

              ToggleSwitch {
                anchors.verticalCenter: parent.verticalCenter
                checked: !modelData.hidden
                foreground: side.foreground
                accent: side.chipFg
                trackHeight: 14
                activeFocusOnTab: false
                onToggled: if (host) host.toggleGroup(modelData.title)
              }

              Text {
                id: groupLabel
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 36
                text: modelData.title
                textFormat: Text.PlainText
                color: host && host.omarchyActive && modelData.title === host.selectedSectionTitle ? side.chipFg : side.foreground
                opacity: modelData.hidden ? 0.4 : 1
                font.family: side.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: host && host.omarchyActive && modelData.title === host.selectedSectionTitle
                elide: Text.ElideRight
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (!host)
                      return
                    if (!host.omarchyActive)
                      host.selectSource("omarchy")
                    host.focusGroup(modelData.title)
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
              font.pixelSize: Style.font.caption
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: side.windowsOpen = !side.windowsOpen
              }
            }

            Text {
              id: windowsLabel
              anchors.verticalCenter: parent.verticalCenter
              text: "Open windows"
              textFormat: Text.PlainText
              color: side.chipFg
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.capitalization: Font.AllUppercase
            }
          }
        }

        Item {
          visible: side.windowsOpen && host && (!host.clients || host.clients.length === 0)
          width: treeCol.width
          height: visible ? Math.max(Style.space(22), noWindowsLabel.implicitHeight + 4) : 0

          Text {
            id: noWindowsLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "No windows detected"
            textFormat: Text.PlainText
            color: side.foreground
            opacity: 0.5
            font.family: side.fontFamily
            font.pixelSize: Style.font.caption
            font.italic: true
          }
        }

        Repeater {
          model: side.windowsOpen && host ? host.clients : []
          delegate: Item {
            required property var modelData
            width: treeCol.width
            height: Math.max(Style.space(22), winLabel.implicitHeight + 4)

            Text {
              id: winLabel
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: 16
              anchors.verticalCenter: parent.verticalCenter
              text: (modelData.focused ? "· " : "") + (modelData.label || modelData.class)
                + (modelData.count > 1 ? " (" + modelData.count + ")" : "")
              textFormat: Text.PlainText
              color: host && host.activeSource === modelData.class ? side.chipFg : side.foreground
              opacity: modelData.sheet ? 1 : 0.55
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: host && host.activeSource === modelData.class
              elide: Text.ElideRight
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (host) host.selectSource(modelData.class)
              }
            }
          }
        }
      }
    }

    Column {
      id: modBlock
      width: parent.width
      spacing: 2

      Text {
        text: "Modifiers"
        textFormat: Text.PlainText
        color: side.chipFg
        font.family: side.fontFamily
        font.pixelSize: Style.font.caption
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
            text: modelData === "any" ? "A any" : (modelData === "must" ? "M must" : "H hide")
            textFormat: Text.PlainText
            color: active ? side.chipFg : side.foreground
            opacity: active ? 1 : 0.55
            font.family: side.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: active
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: if (host) host.setAllModifiers(modelData)
            }
          }
        }
      }

      Repeater {
        model: ["Super", "Shift", "Ctrl", "Alt"]
        delegate: Item {
          required property string modelData
          readonly property string mode: !host ? "any"
            : modelData === "Super" ? host.modSuper
            : modelData === "Shift" ? host.modShift
            : modelData === "Ctrl" ? host.modCtrl
            : host.modAlt
          width: modBlock.width
          height: Math.max(Style.space(24), modLabel.implicitHeight + 6)

          Row {
            anchors.fill: parent
            spacing: 6

            Text {
              id: modLabel
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - modeMark.implicitWidth - 8
              text: modelData
              textFormat: Text.PlainText
              color: mode === "must" ? side.chipFg : side.foreground
              opacity: mode === "hide" ? 0.4 : 1
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: mode === "must"
            }

            Text {
              id: modeMark
              anchors.verticalCenter: parent.verticalCenter
              text: mode === "must" ? "M" : (mode === "hide" ? "H" : "A")
              textFormat: Text.PlainText
              color: mode === "must" ? side.chipFg : side.foreground
              opacity: mode === "hide" ? 0.4 : 0.75
              font.family: side.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (host) host.cycleModifier(modelData)
          }
        }
      }
    }
  }
}
