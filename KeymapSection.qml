import QtQuick
import qs.Commons
import "KeymapData.js" as KeymapData

Rectangle {
  id: section

  property string title: ""
  property var rows: []
  property string fontFamily: Style.font.menuFamily
  property color foreground: Color.menu.text
  property color borderColor: Color.menu.border
  property color chipBg: Color.menu.selectedBackground
  property color chipFg: Color.menu.selectedText

  implicitHeight: sectionCol.implicitHeight + Style.spacing.md
  radius: 6
  color: "transparent"
  border.width: 1
  border.color: section.borderColor

  Column {
    id: sectionCol
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: Style.spacing.sm
    spacing: Style.space(5)

    Text {
      text: section.title
      textFormat: Text.PlainText
      color: Color.menu.selectedText
      font.family: section.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Repeater {
      model: section.rows
      delegate: Item {
        width: sectionCol.width
        height: Math.max(Style.space(22), actionLabel.implicitHeight)

        Row {
          id: keysRow
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width * 0.56
          spacing: 4

          Repeater {
            model: KeymapData.splitKeys(modelData.keys)
            delegate: Rectangle {
              implicitWidth: chipText.implicitWidth + 10
              implicitHeight: Math.max(Style.space(18), chipText.implicitHeight + 4)
              radius: 4
              color: section.chipBg
              border.width: 1
              border.color: section.borderColor

              Text {
                id: chipText
                anchors.centerIn: parent
                text: modelData
                textFormat: Text.PlainText
                color: section.chipFg
                font.family: section.fontFamily
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
          text: modelData.action
          textFormat: Text.PlainText
          color: section.foreground
          font.family: section.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }
      }
    }
  }
}
