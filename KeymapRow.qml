import QtQuick
import qs.Commons
import "KeymapData.js" as KeymapData

Rectangle {
  id: row

  required property var modelData
  property bool selected: false
  property string fontFamily: Style.font.menuFamily
  property color foreground: Color.menu.text
  property color borderColor: Color.menu.border
  property color chipBg: Color.menu.selectedBackground
  property color chipFg: Color.menu.selectedText
  property color selectedBg: Color.menu.selectedBackground
  property color selectedFg: Color.menu.selectedText
  // "full" | "short" chips, and whether keys or the action leads the row.
  property string chipStyle: "full"
  property string rowLayout: "keys"
  signal clicked(string keys, string action)
  signal activated(string keys, string action)
  signal highlighted(var item)

  // dump-keymap's verdict wins where it has one: a bind whose action we
  // could not recover cannot be issued from the overlay, however runnable
  // its chord looks. Falls back to reading the chord for app sheet rows.
  readonly property bool runnable: modelData.runnable === false
    ? false
    : KeymapData.isRunnable(modelData.keys)

  width: parent ? parent.width : 0
  height: Math.max(Style.space(22), actionLabel.implicitHeight + 4)
  radius: 4
  color: selected ? row.selectedBg : "transparent"
  border.width: selected ? 1 : 0
  border.color: selected ? row.selectedFg : row.borderColor
  opacity: runnable ? 1 : 0.55

  onSelectedChanged: {
    if (!selected)
      return
    var item = row
    Qt.callLater(function() { row.highlighted(item) })
  }

  Rectangle {
    visible: row.selected
    width: 3
    height: parent.height - 4
    anchors.left: parent.left
    anchors.leftMargin: 1
    anchors.verticalCenter: parent.verticalCenter
    radius: 1
    color: row.selectedFg
  }

  Row {
    id: keysRow
    anchors.left: row.rowLayout === "keys" ? parent.left : undefined
    anchors.leftMargin: row.rowLayout === "keys" ? 8 : 0
    anchors.right: row.rowLayout === "keys" ? undefined : parent.right
    anchors.rightMargin: row.rowLayout === "keys" ? 0 : 8
    anchors.verticalCenter: parent.verticalCenter
    // Chips rarely fill this column, and every pixel reserved past the last
    // chip is one the action label elides instead. 0.56 left a wide dead gap
    // on most rows while "Toggle window transparency" truncated; 0.46 still
    // clears the longest real chord (Super+Shift+Ctrl+Alt+Tab).
    width: parent.width * 0.46 - 8
    spacing: 4

    Repeater {
      model: KeymapData.displayKeys(row.modelData.keys, row.chipStyle)
      delegate: Rectangle {
        implicitWidth: chipText.implicitWidth + 10
        implicitHeight: Math.max(Style.space(18), chipText.implicitHeight + 4)
        radius: 4
        color: row.chipBg
        border.width: 1
        border.color: row.borderColor

        Text {
          id: chipText
          anchors.centerIn: parent
          text: modelData
          textFormat: Text.PlainText
          color: row.chipFg
          font.family: row.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }
      }
    }
  }

  Text {
    id: actionLabel
    anchors.left: row.rowLayout === "keys" ? keysRow.right : parent.left
    anchors.right: row.rowLayout === "keys" ? parent.right : keysRow.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: row.rowLayout === "keys" ? Style.spacing.sm : 8
    anchors.rightMargin: row.rowLayout === "keys" ? 0 : Style.spacing.sm
    text: row.modelData.action
    textFormat: Text.PlainText
    color: row.selected ? row.selectedFg : row.foreground
    font.family: row.fontFamily
    font.pixelSize: Style.font.body
    elide: Text.ElideRight
  }

  MouseArea {
    anchors.fill: parent
    onClicked: row.clicked(row.modelData.keys, row.modelData.action)
    onDoubleClicked: row.activated(row.modelData.keys, row.modelData.action)
  }
}
