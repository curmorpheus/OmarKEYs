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

    // Layout experiments, cycled in place so two arrangements can be
    // compared without a rebuild between them.
    Repeater {
      model: [
        { id: "chips",  label: "Keys" },
        { id: "layout", label: "Order" },
        { id: "sort",   label: "Sort" },
        { id: "search", label: "Find" }
      ]
      delegate: Text {
        required property var modelData
        readonly property string value: {
          if (!host)
            return ""
          if (modelData.id === "chips")
            return host.chipStyle === "short" ? "short"
              : (host.chipStyle === "icons" ? "icons" : "full")
          if (modelData.id === "layout")
            return host.rowLayout === "action" ? "action first" : "keys first"
          if (modelData.id === "sort")
            return host.sortBy === "action" ? "by name" : "by group"
          return host.searchMode === "keys" ? "keys"
            : (host.searchMode === "action" ? "name" : "all")
        }
        anchors.verticalCenter: parent.verticalCenter
        text: modelData.label + " " + value
        textFormat: Text.PlainText
        color: bar.chipFg
        opacity: area.containsMouse ? 1 : 0.7
        font.family: bar.fontFamily
        font.pixelSize: Style.font.caption
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (!host)
              return
            if (modelData.id === "chips")
              host.cycleChipStyle()
            else if (modelData.id === "layout")
              host.cycleRowLayout()
            else if (modelData.id === "sort")
              host.cycleSortBy()
            else
              host.cycleSearchMode()
          }
        }
      }
    }

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
