import QtQuick
import qs.Commons
import qs.Ui

// Everything you set rather than read, in one popup off the bottom-left
// corner - the mirror of the channel picker on the right. It used to be
// split between a modifier block eating the bottom of the sidebar and a
// settings bar across the foot of the window, both permanently on screen
// for controls that are touched rarely.
Rectangle {
  id: menu

  property Item host: null

  readonly property color foreground: host ? host.foreground : Color.menu.text
  readonly property color chipFg: host ? host.chipFg : Color.menu.selectedText
  readonly property color borderColor: host ? host.border : Color.menu.border
  readonly property string fontFamily: host ? host.fontFamily : Style.font.menuFamily
  readonly property int labelSize: Style.font.caption

  width: Style.space(300)
  height: Math.min(Style.space(420), content.implicitHeight + Style.spacing.sm * 2)
  radius: 6
  color: host ? host.background : Color.menu.background
  border.width: 1
  border.color: menu.borderColor

  // Swallow clicks so setting something does not fall through to the scrim
  // and dismiss the overlay.
  MouseArea { anchors.fill: parent; onClicked: {} }

  Column {
    id: content
    anchors.fill: parent
    anchors.margins: Style.spacing.sm
    spacing: Style.space(6)

    Text {
      width: parent.width
      text: "Display"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Repeater {
      model: [
        { id: "chips",  label: "Keys" },
        { id: "layout", label: "Order" },
        { id: "sort",   label: "Sort" },
        { id: "search", label: "Find" }
      ]
      delegate: Item {
        required property var modelData
        readonly property string value: {
          if (!menu.host)
            return ""
          if (modelData.id === "chips")
            return menu.host.chipStyle === "short" ? "short"
              : (menu.host.chipStyle === "icons" ? "icons" : "full")
          if (modelData.id === "layout")
            return menu.host.rowLayout === "action" ? "action first" : "keys first"
          if (modelData.id === "sort")
            return menu.host.sortBy === "action" ? "by name" : "by group"
          return menu.host.searchMode === "keys" ? "keys"
            : (menu.host.searchMode === "action" ? "name" : "all")
        }
        width: content.width
        height: Math.max(Style.space(20), optionName.implicitHeight + 4)

        Text {
          id: optionName
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          text: modelData.label
          textFormat: Text.PlainText
          color: menu.foreground
          opacity: 0.75
          font.family: menu.fontFamily
          font.pixelSize: menu.labelSize
        }

        Text {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: parent.value
          textFormat: Text.PlainText
          color: menu.chipFg
          opacity: optionArea.containsMouse ? 1 : 0.85
          font.family: menu.fontFamily
          font.pixelSize: menu.labelSize
        }

        MouseArea {
          id: optionArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            var h = menu.host
            if (!h)
              return
            if (modelData.id === "chips")
              h.cycleChipStyle()
            else if (modelData.id === "layout")
              h.cycleRowLayout()
            else if (modelData.id === "sort")
              h.cycleSortBy()
            else
              h.cycleSearchMode()
          }
        }
      }
    }

    Item {
      width: content.width
      height: Math.max(Style.space(22), textSizeLabel.implicitHeight + 4)

      Text {
        id: textSizeLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Text size"
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      PanelSlider {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(130)
        minimum: 0.8
        maximum: 1.8
        step: 0.05
        activeFocusOnTab: false
        value: menu.host ? menu.host.fontScale : 1.0
        fillColor: menu.chipFg
        knobColor: menu.chipFg
        trackColor: Qt.rgba(menu.chipFg.r, menu.chipFg.g, menu.chipFg.b, 0.22)
        tickColor: menu.color
        onMoved: function(v) { if (menu.host) menu.host.fontScale = v }
        onReleased: function(v) { if (menu.host) menu.host.setFontScale(v) }
      }
    }

    Rectangle {
      width: content.width
      height: 1
      color: menu.borderColor
      opacity: 0.5
    }

    Text {
      width: parent.width
      text: "Modifiers"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(8)

      Repeater {
        model: ["any", "must", "hide"]
        delegate: Text {
          required property string modelData
          readonly property bool active: !menu.host ? false
            : modelData === "any" ? menu.host.allModsAny
            : modelData === "must" ? menu.host.allModsMust
            : menu.host.allModsHide
          text: modelData === "any" ? "<b>A</b>ll"
            : (modelData === "must" ? "<b>M</b>ust" : "<b>H</b>ide")
          textFormat: Text.StyledText
          color: active ? menu.chipFg : menu.foreground
          opacity: active ? 1 : 0.55
          font.family: menu.fontFamily
          font.pixelSize: menu.labelSize
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (menu.host) menu.host.setAllModifiers(modelData)
          }
        }
      }
    }

    // Measures the widest cap so all four match, as a keyboard's would.
    Text {
      id: capMetric
      visible: false
      text: "Super"
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
    }

    Grid {
      id: modGrid
      width: content.width
      columns: 2
      columnSpacing: 0
      rowSpacing: Style.space(4)

      Repeater {
        model: ["Super", "Shift", "Ctrl", "Alt"]
        delegate: Item {
          id: cell
          required property string modelData
          readonly property string mode: !menu.host ? "any"
            : modelData === "Super" ? menu.host.modSuper
            : modelData === "Shift" ? menu.host.modShift
            : modelData === "Ctrl" ? menu.host.modCtrl
            : menu.host.modAlt
          readonly property string mark: mode === "must" ? "M" : (mode === "hide" ? "H" : "A")

          width: modGrid.width / 2
          height: capMetric.implicitHeight + Style.space(8)
          opacity: cell.mode === "hide" ? 0.55 : 1

          Rectangle {
            id: keyCap
            // Centres the key and its state as one group in the half-column.
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -(Style.space(3) + markLabel.implicitWidth) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: capMetric.implicitWidth + Style.space(12)
            height: capMetric.implicitHeight + Style.space(8)
            radius: 5
            border.width: 1
            border.color: cell.mode === "any" ? menu.borderColor : menu.chipFg
            color: modArea.containsMouse
              ? Qt.rgba(menu.chipFg.r, menu.chipFg.g, menu.chipFg.b, 0.22)
              : Qt.rgba(menu.borderColor.r, menu.borderColor.g, menu.borderColor.b, 0.18)

            Text {
              anchors.centerIn: parent
              text: cell.modelData
              textFormat: Text.PlainText
              color: cell.mode === "any" ? menu.foreground : menu.chipFg
              font.family: menu.fontFamily
              font.pixelSize: menu.labelSize
              font.bold: cell.mode !== "any"
            }
          }

          Text {
            id: markLabel
            anchors.left: keyCap.right
            anchors.leftMargin: Style.space(3)
            anchors.verticalCenter: parent.verticalCenter
            text: cell.mark
            textFormat: Text.PlainText
            color: cell.mode === "any" ? menu.foreground : menu.chipFg
            opacity: cell.mode === "any" ? 0.75 : 1
            font.family: menu.fontFamily
            font.pixelSize: menu.labelSize
            font.bold: true
          }

          MouseArea {
            id: modArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              var h = menu.host
              if (h)
                h.cycleModifier(cell.modelData)
            }
          }
        }
      }
    }

    Rectangle {
      width: content.width
      height: 1
      color: menu.borderColor
      opacity: 0.5
    }

    Text {
      width: parent.width
      text: "Opening"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Item {
      width: content.width
      height: Math.max(Style.space(22), doubleTapLabel.implicitHeight + 4)

      Text {
        id: doubleTapLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Double-tap Super"
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      ToggleSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: menu.host ? menu.host.doubleTap : true
        foreground: menu.foreground
        accent: menu.chipFg
        trackHeight: 16
        activeFocusOnTab: false
        onToggled: {
          var h = menu.host
          if (!h)
            return
          h.doubleTap = !h.doubleTap
          h.saveConfig()
        }
      }
    }

    Item {
      width: content.width
      height: Math.max(Style.space(22), holdLabel.implicitHeight + 4)

      Text {
        id: holdLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Hold Super " + (menu.host ? menu.host.holdSeconds : 5) + "s"
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      PanelSlider {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(130)
        minimum: 1
        maximum: 10
        step: 1
        integer: true
        tickCount: 10
        activeFocusOnTab: false
        value: menu.host ? menu.host.holdSeconds : 5
        fillColor: menu.chipFg
        knobColor: menu.chipFg
        trackColor: Qt.rgba(menu.chipFg.r, menu.chipFg.g, menu.chipFg.b, 0.22)
        tickColor: menu.color
        onMoved: function(v) { if (menu.host) menu.host.holdSeconds = Math.round(v) }
        onReleased: function(v) {
          var h = menu.host
          if (!h)
            return
          h.holdSeconds = Math.round(v)
          h.saveConfig()
        }
      }
    }
  }
}
