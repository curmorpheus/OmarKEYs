import QtQuick
import qs.Commons

// Named keymap save/load, hanging off the Keymaps link in the sidebar.
// Baselines are always first: Omarchy's shipped defaults, then the user's
// config as it was before OmarKEYS. Named saves sit under those.
Rectangle {
  id: menu

  property Item host: null

  readonly property color foreground: host ? host.foreground : Color.menu.text
  readonly property color chipFg: host ? host.chipFg : Color.menu.selectedText
  readonly property color borderColor: host ? host.border : Color.menu.border
  readonly property string fontFamily: host ? host.fontFamily : Style.font.menuFamily
  readonly property int labelSize: Style.font.caption
  readonly property bool busy: host ? host.keymapBusy : false

  width: Style.space(280)
  height: Math.min(Style.space(320), content.implicitHeight + Style.spacing.sm * 2)
  radius: 6
  color: host ? host.background : Color.menu.background
  border.width: 1
  border.color: menu.borderColor

  MouseArea { anchors.fill: parent; onClicked: {} }

  Column {
    id: content
    anchors.fill: parent
    anchors.margins: Style.spacing.sm
    spacing: Style.space(4)

    Text {
      width: parent.width
      text: "Keymaps"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Text {
      width: parent.width
      text: "Omarchy defaults and My config are first-install snapshots. Named saves include remaps."
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.55
      wrapMode: Text.WordWrap
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
    }

    Text {
      width: parent.width
      visible: !!(host && host.keymapError)
      text: host ? host.keymapError : ""
      textFormat: Text.PlainText
      color: menu.foreground
      wrapMode: Text.WordWrap
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
    }

    Repeater {
      model: host ? (host.keymapBaselines || []).concat(host.keymapSaved || []) : []
      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool current: !!(host && host.keymapCurrent === modelData.id)
        width: content.width
        height: Math.max(Style.space(22), itemLabel.implicitHeight + 6)
        radius: 4
        color: itemArea.containsMouse && !menu.busy ? menu.borderColor : "transparent"

        Text {
          id: itemLabel
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: 6
          anchors.rightMargin: 6
          anchors.verticalCenter: parent.verticalCenter
          text: (current ? "• " : "  ") + (modelData.label || modelData.id)
            + (modelData.kind === "baseline" ? "   baseline" : "")
          textFormat: Text.PlainText
          color: current ? menu.chipFg : menu.foreground
          opacity: modelData.present === false ? 0.4 : 1
          font.family: menu.fontFamily
          font.pixelSize: menu.labelSize
          font.bold: current
          elide: Text.ElideRight
        }

        MouseArea {
          id: itemArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            var h = menu.host
            if (!h || h.keymapBusy || current || modelData.present === false)
              return
            h.loadKeymap(modelData.id)
          }
        }
      }
    }

    Text {
      width: parent.width
      visible: !!(host && (!host.keymapSaved || host.keymapSaved.length === 0))
      text: "No named saves yet."
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.45
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
    }

    Rectangle {
      width: parent.width
      height: saveLabel.implicitHeight + Style.space(6)
      radius: 3
      color: saveArea.containsMouse && !menu.busy ? menu.chipFg : "transparent"
      border.width: saveArea.containsMouse && !menu.busy ? 0 : 1
      border.color: menu.borderColor

      Text {
        id: saveLabel
        anchors.centerIn: parent
        text: menu.busy ? "…" : "Save current"
        textFormat: Text.PlainText
        color: saveArea.containsMouse && !menu.busy ? menu.color : menu.foreground
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
        font.bold: true
      }

      MouseArea {
        id: saveArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          var h = menu.host
          if (!h || h.keymapBusy)
            return
          h.saveKeymap("")
        }
      }
    }

    Text {
      width: parent.width
      text: "Loading a keymap reloads Hyprland"
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.5
      wrapMode: Text.WordWrap
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
    }
  }
}
