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
  signal clicked(string keys, string action)
  signal activated(string keys, string action)
  signal highlighted(var item)

  readonly property bool runnable: KeymapData.isRunnable(modelData.keys)

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
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width * 0.56 - 8
    spacing: 4

    Repeater {
      model: KeymapData.splitKeys(row.modelData.keys)
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
    anchors.left: keysRow.right
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: Style.spacing.sm
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
