import Quickshell
import Quickshell.Hyprland
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
    return (root.manifest && root.manifest.id) || "romills.omarkeys"
  }

  function open(payloadJson) {
    root.filterText = ""
    root.grabKeys = false
    root.rebuild()
    root.opened = true
  }

  function grab() {
    root.grabKeys = true
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
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
    root.rebuild()
  }

  function rebuild() {
    var cols = KeymapData.columns(root.filterText)
    root.leftSections = cols.left
    root.rightSections = cols.right
  }

  function isSuperKey(event) {
    return event.key === Qt.Key_Meta
        || event.key === Qt.Key_Super_L
        || event.key === Qt.Key_Super_R
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

          Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true
            Keys.priority: Keys.BeforeItem
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                if (root.filterText)
                  root.setFilter("")
                else
                  root.dismiss()
                event.accepted = true
              } else if (root.isSuperKey(event)) {
                event.accepted = true
              } else if (Util.editsFilter(event, root.filterText)) {
                root.setFilter(Util.editedFilter(event, root.filterText))
                event.accepted = true
              } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
                root.setFilter(root.filterText + event.text)
                event.accepted = true
              }
            }
            Keys.onReleased: function(event) {
              if (root.isSuperKey(event))
                event.accepted = true
            }
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
                text: "Tap Super or Esc to close"
                textFormat: Text.PlainText
                color: root.foreground
                opacity: 0.55
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            Flickable {
              width: parent.width
              height: parent.height - headerLabel.parent.height - body.spacing
              clip: true
              contentWidth: width
              contentHeight: columnsRow.height
              boundsBehavior: Flickable.StopAtBounds

              Row {
                id: columnsRow
                width: parent.width
                spacing: Style.spacing.md

                Column {
                  id: leftCol
                  width: (columnsRow.width - columnsRow.spacing) / 2
                  spacing: Style.spacing.sm

                  Repeater {
                    model: root.leftSections
                    delegate: KeymapSection {
                      width: leftCol.width
                      title: modelData.title
                      rows: modelData.rows
                      fontFamily: root.fontFamily
                      foreground: root.foreground
                      borderColor: root.border
                      chipBg: root.chipBg
                      chipFg: root.chipFg
                    }
                  }
                }

                Column {
                  id: rightCol
                  width: (columnsRow.width - columnsRow.spacing) / 2
                  spacing: Style.spacing.sm

                  Repeater {
                    model: root.rightSections
                    delegate: KeymapSection {
                      width: rightCol.width
                      title: modelData.title
                      rows: modelData.rows
                      fontFamily: root.fontFamily
                      foreground: root.foreground
                      borderColor: root.border
                      chipBg: root.chipBg
                      chipFg: root.chipFg
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
