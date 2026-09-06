import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: bar
  property Item host: null

  readonly property color foreground: host ? host.foreground : Color.menu.text
  readonly property color chipFg: host ? host.chipFg : Color.menu.selectedText
  readonly property color background: host ? host.background : Color.menu.background
  readonly property string fontFamily: host ? host.fontFamily : Style.font.menuFamily

  height: Math.max(Style.space(36), settingsRow.implicitHeight)
  MouseArea { anchors.fill: parent; onClicked: {} }

  Row {
    id: settingsRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: Style.spacing.md

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Double-tap Super"
      textFormat: Text.PlainText
      color: bar.foreground
      font.family: bar.fontFamily
      font.pixelSize: Style.font.caption
    }

    ToggleSwitch {
      anchors.verticalCenter: parent.verticalCenter
      checked: host ? host.doubleTap : true
      foreground: bar.foreground
      accent: bar.chipFg
      trackHeight: 18
      activeFocusOnTab: false
      onToggled: {
        if (!host)
          return
        host.doubleTap = !host.doubleTap
        host.saveConfig()
      }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Hold Super " + (host ? host.holdSeconds : 5) + "s"
      textFormat: Text.PlainText
      color: bar.foreground
      font.family: bar.fontFamily
      font.pixelSize: Style.font.caption
    }

    PanelSlider {
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(180)
      minimum: 1
      maximum: 10
      step: 1
      integer: true
      tickCount: 10
      activeFocusOnTab: false
      value: host ? host.holdSeconds : 5
      fillColor: bar.chipFg
      knobColor: bar.chipFg
      trackColor: Qt.rgba(bar.chipFg.r, bar.chipFg.g, bar.chipFg.b, 0.22)
      tickColor: bar.background
      onMoved: function(v) { if (host) host.holdSeconds = Math.round(v) }
      onReleased: function(v) {
        if (!host)
          return
        host.holdSeconds = Math.round(v)
        host.saveConfig()
      }
    }
  }
}
