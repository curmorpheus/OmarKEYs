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

  width: Style.space(380)
  height: Math.min(Style.space(640),
    content.implicitHeight + Style.spacing.md * 4 + restoreButton.height + Style.space(4))
  radius: 6
  color: host ? host.background : Color.menu.background
  border.width: 1
  border.color: menu.borderColor

  // Swallow clicks so setting something does not fall through to the scrim
  // and dismiss the overlay.
  MouseArea { anchors.fill: parent; onClicked: {} }

  Text {
    id: closeButton
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: Style.spacing.sm
    text: "✕"
    textFormat: Text.PlainText
    color: menu.foreground
    opacity: closeArea.containsMouse ? 1 : 0.5
    font.family: menu.fontFamily
    font.pixelSize: menu.labelSize

    MouseArea {
      id: closeArea
      anchors.fill: parent
      anchors.margins: -Style.space(4)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: if (menu.host) menu.host.optionsMenuOpen = false
    }
  }

  Text {
    id: restoreButton
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: Style.spacing.sm
    text: "Restore defaults"
    textFormat: Text.PlainText
    color: restoreArea.containsMouse ? menu.chipFg : menu.foreground
    opacity: restoreArea.containsMouse ? 1 : 0.5
    font.family: menu.fontFamily
    font.pixelSize: menu.labelSize

    MouseArea {
      id: restoreArea
      anchors.fill: parent
      anchors.margins: -Style.space(3)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: if (menu.host) menu.host.restoreDefaults()
    }
  }

  Column {
    id: content
    anchors.fill: parent
    anchors.margins: Style.spacing.md * 2
    anchors.leftMargin: Style.spacing.md * 2 + Style.space(8)
    anchors.rightMargin: Style.spacing.md * 2 + Style.space(8)
    anchors.bottomMargin: Style.spacing.md * 2 + restoreButton.height
    spacing: Style.space(14)

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
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
        height: Math.max(Style.space(24), optionName.implicitHeight + 8)

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

      // Click to return to default, which is also the middle of the range
      // so the knob's position reads as "normal" at a glance.
      Text {
        id: textSizeLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: (menu.host && Math.abs(menu.host.fontScale - 1) > 0.001)
          ? "Text size · reset" : "Text size"
        textFormat: Text.PlainText
        color: sizeResetArea.containsMouse ? menu.chipFg : menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize

        MouseArea {
          id: sizeResetArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: if (menu.host) menu.host.setFontScale(1.0)
        }
      }

      PanelSlider {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(130)
        // Symmetric about 1.0 so the default is the centre of the track.
        minimum: 0.6
        maximum: 1.4
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

    Item {
      readonly property bool live: !!(menu.host && menu.host.chipStyle === "icons")
      width: content.width
      height: Math.max(Style.space(22), iconSizeLabel.implicitHeight + 4)
      // Shown always, dimmed when it would do nothing, so the control does
      // not appear and disappear as the chip style cycles.
      opacity: live ? 1 : 0.35

      Text {
        id: iconSizeLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: !parent.live ? "Icon size (icons off)"
          : ((menu.host && Math.abs(menu.host.iconScale - 1.35) > 0.001)
            ? "Icon size · reset" : "Icon size")
        textFormat: Text.PlainText
        color: iconResetArea.containsMouse ? menu.chipFg : menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize

        MouseArea {
          id: iconResetArea
          anchors.fill: parent
          hoverEnabled: true
          enabled: parent.parent.live
          cursorShape: Qt.PointingHandCursor
          onClicked: if (menu.host) menu.host.setIconScale(1.35)
        }
      }

      PanelSlider {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(130)
        enabled: parent.live
        minimum: 1.0
        maximum: 2.0
        step: 0.05
        activeFocusOnTab: false
        value: menu.host ? menu.host.iconScale : 1.35
        fillColor: menu.chipFg
        knobColor: menu.chipFg
        trackColor: Qt.rgba(menu.chipFg.r, menu.chipFg.g, menu.chipFg.b, 0.22)
        tickColor: menu.color
        onMoved: function(v) { if (menu.host) menu.host.iconScale = v }
        onReleased: function(v) { if (menu.host) menu.host.setIconScale(v) }
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
      horizontalAlignment: Text.AlignHCenter
      text: "Filters"
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
      horizontalAlignment: Text.AlignHCenter
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
      height: Math.max(Style.space(22), superKLabel.implicitHeight + 4)

      Text {
        id: superKLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Super+K"
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.75
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      ToggleSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: menu.host ? menu.host.superK : true
        foreground: menu.foreground
        accent: menu.chipFg
        trackHeight: 16
        activeFocusOnTab: false
        // Not saveConfig(): turning this off has to reach Hyprland, which
        // only re-reads the config on reload.
        onToggled: {
          var h = menu.host
          if (h)
            h.setSuperK(!h.superK)
        }
      }
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
