import QtQuick
import qs.Commons

Rectangle {
  id: section

  property string title: ""
  property int sectionNumber: 0
  property var rows: []
  property string selectedKeys: ""
  property string selectedAction: ""
  property string fontFamily: Style.font.menuFamily
  property color foreground: Color.menu.text
  property color borderColor: Color.menu.border
  property color chipBg: Color.menu.selectedBackground
  property color chipFg: Color.menu.selectedText
  property color selectedBg: Color.menu.selectedBackground
  property color selectedFg: Color.menu.selectedText
  // What an inverted heading puts its text in.
  property color panelBg: Color.menu.background
  // Which keymap this card came from, shown at the head of the group: the
  // Omarchy mark, or the app whose sheet is loaded. Only one is ever set.
  property string mark: ""
  property string qualifier: ""
  property string chipStyle: "full"
  property string keyboardType: "windows"
  property bool iconBorders: false
  property string rowLayout: "keys"
  property real fontScale: 1.0
  property real iconScale: 1.35
  signal rowClicked(string keys, string action)
  signal rowActivated(string keys, string action)
  signal rowHighlighted(var item)

  readonly property string numberLabel: {
    if (section.sectionNumber >= 1 && section.sectionNumber <= 9)
      return "[Ctrl-" + section.sectionNumber + "]"
    if (section.sectionNumber === 10)
      return "[Ctrl-0]"
    return ""
  }

  // Symmetric: the content is inset by the same pad on every side, where
  // it used to sit 4 from the top and 2 from the bottom.
  readonly property real pad: Style.space(8)
  implicitHeight: sectionCol.implicitHeight + section.pad * 2
  radius: 6
  color: "transparent"
  border.width: 1
  border.color: section.borderColor

  Column {
    id: sectionCol
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: section.pad
    spacing: Style.space(6)

    // Ungrouped rows arrive as one untitled block; an empty heading would
    // still reserve its line and a blank gap above the rows.
    Item {
      width: sectionCol.width
      visible: section.title.length > 0
      height: visible ? titleRow.height : 0

      // Inverted, like the tree's group headings: a tinted bar so a card
      // reads as a block rather than as a line of text above some rows.
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: titleRow.implicitWidth + Style.space(14)
        height: titleRow.implicitHeight + Style.space(4)
        radius: 3
        color: Qt.rgba(section.chipFg.r, section.chipFg.g, section.chipFg.b, 0.62)

      Row {
        id: titleRow
        anchors.centerIn: parent
        spacing: 8

        Text {
          visible: section.mark.length > 0
          text: section.mark
          textFormat: Text.PlainText
          color: section.panelBg
          font.family: section.fontFamily
          // A glyph reads smaller than a letter at the same pixel size.
          font.pixelSize: Math.round(Style.font.caption * section.fontScale * 1.2)
        }

        Text {
          visible: section.qualifier.length > 0
          text: section.qualifier
          textFormat: Text.PlainText
          color: section.panelBg
          opacity: 0.855
          font.family: section.fontFamily
          font.pixelSize: Math.round(Style.font.caption * section.fontScale)
          font.bold: true
        }

        Text {
          text: section.title
          textFormat: Text.PlainText
          color: section.panelBg
          font.family: section.fontFamily
          font.pixelSize: Math.round(Style.font.caption * section.fontScale)
          font.bold: true
          font.capitalization: Font.AllUppercase
        }

        Text {
          visible: section.numberLabel.length > 0
          text: section.numberLabel
          textFormat: Text.PlainText
          color: section.panelBg
          font.family: section.fontFamily
          font.pixelSize: Math.round(Style.font.caption * section.fontScale)
          font.bold: true
          opacity: 0.85
        }
      }
      }
    }

    Repeater {
      model: section.rows
      delegate: KeymapRow {
        width: sectionCol.width
        selected: modelData.keys === section.selectedKeys
          && modelData.action === section.selectedAction
        fontFamily: section.fontFamily
        foreground: section.foreground
        borderColor: section.borderColor
        chipBg: section.chipBg
        chipFg: section.chipFg
        selectedBg: section.selectedBg
        selectedFg: section.selectedFg
        topic: modelData.topic || ""
        chipStyle: section.chipStyle
        keyboardType: section.keyboardType
        iconBorders: section.iconBorders
        rowLayout: section.rowLayout
        fontScale: section.fontScale
        iconScale: section.iconScale
        onClicked: function(keys, action) { section.rowClicked(keys, action) }
        onActivated: function(keys, action) { section.rowActivated(keys, action) }
        onHighlighted: function(item) { section.rowHighlighted(item) }
      }
    }
  }
}
