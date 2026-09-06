import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
  id: side
  property Item host: null

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

    Item {
      id: groupsHeader
      width: parent.width
      height: Math.max(Style.space(22), allToggle.height)

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Groups"
        textFormat: Text.PlainText
        color: side.chipFg
        font.family: side.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
        font.capitalization: Font.AllUppercase
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: host && host.allGroupsVisible ? "All" : "None"
          textFormat: Text.PlainText
          color: side.foreground
          opacity: 0.7
          font.family: side.fontFamily
          font.pixelSize: Style.font.caption
        }

        ToggleSwitch {
          id: allToggle
          anchors.verticalCenter: parent.verticalCenter
          checked: host ? host.allGroupsVisible : true
          foreground: side.foreground
          accent: side.chipFg
          trackHeight: 16
          activeFocusOnTab: false
          onToggled: if (host) host.setAllGroupsVisible(!host.allGroupsVisible)
        }
      }
    }

    Flickable {
      width: parent.width
      height: Math.max(40, parent.height - groupsHeader.height - modBlock.height - parent.spacing * 2)
      clip: true
      contentWidth: width
      contentHeight: groupCol.height
      boundsBehavior: Flickable.StopAtBounds
      activeFocusOnTab: false

      Column {
        id: groupCol
        width: parent.width
        spacing: 2

        Repeater {
          model: host ? host.groupList : []
          delegate: Item {
            required property var modelData
            width: groupCol.width
            height: Math.max(Style.space(24), groupLabel.implicitHeight + 6)

            Row {
              anchors.fill: parent
              spacing: 6

              ToggleSwitch {
                anchors.verticalCenter: parent.verticalCenter
                checked: !modelData.hidden
                foreground: side.foreground
                accent: side.chipFg
                trackHeight: 16
                activeFocusOnTab: false
                onToggled: if (host) host.toggleGroup(modelData.title)
              }

              Text {
                id: groupLabel
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 40
                text: modelData.title
                textFormat: Text.PlainText
                color: host && modelData.title === host.selectedSectionTitle ? side.chipFg : side.foreground
                opacity: modelData.hidden ? 0.4 : 1
                font.family: side.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: host && modelData.title === host.selectedSectionTitle
                elide: Text.ElideRight

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: if (host) host.focusGroup(modelData.title)
                }
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
