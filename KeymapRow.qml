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
  property string superIcon: "text"
  property string rowLayout: "keys"
  property real fontScale: 1.0
  property real iconScale: 1.35
  readonly property bool keysFirst: rowLayout !== "action"
  // Both renderings of the same chord, index for index: collapseMouse runs
  // for either style, so a chip and its full name share a position.
  readonly property var chipLabels: KeymapData.displayKeys(modelData.keys, row.chipStyle, row.superIcon)
  readonly property var chipNames: KeymapData.displayNames(modelData.keys)
  // An icon says what key it is only once you know the glyph, so hovering
  // the line spells it out beside it.
  readonly property bool namingKeys: rowHover.hovered && chipStyle === "icons"
  // Geometry, not toggled anchors: assigning undefined to an anchor does
  // not clear one already set, so swapping the columns left both sides
  // anchored and squeezed the description to nothing.
  // Constant, deliberately: resizing this on hover moved the chips out
  // from under the cursor. The column reserves room for the names instead,
  // so a hovered row grows its text into space that was already there and
  // nothing shifts.
  readonly property real keysWidth: Math.max(0, width * 0.52 - 8)
  readonly property real actionWidth: Math.max(0, width - keysWidth - 16 - Style.spacing.sm)
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

  HoverHandler { id: rowHover }

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
    x: row.keysFirst ? 8 : row.width - row.keysWidth - 8
    anchors.verticalCenter: parent.verticalCenter
    width: row.keysWidth
    spacing: 4

    Repeater {
      model: row.chipLabels
      delegate: Rectangle {
        // A glyph is its own shape; boxing it fights the icon and squeezes
        // it smaller than the text it sits beside.
        // Both are required together: declaring one required property
        // stops QML injecting the others, so asking for index alone left
        // modelData undefined and every chip blank.
        required property int index
        required property var modelData
        // Nerd Font glyphs sit in both private use areas, and the option
        // key is a real Unicode symbol -- all of them are shapes, not
        // words, so none of them wants a box drawn round it.
        readonly property bool isIcon: {
          var cp = String(modelData).codePointAt(0)
          return cp >= 0xF0000 || (cp >= 0xE000 && cp <= 0xF8FF) || cp === 0x2325
        }
        readonly property string fullName: row.chipNames[index] || ""
        implicitWidth: chipContent.implicitWidth + (isIcon ? 4 : 10)
        implicitHeight: Math.max(Style.space(18), chipContent.implicitHeight + 4)
        radius: 4
        color: isIcon ? "transparent" : row.chipBg
        border.width: isIcon ? 0 : 1
        border.color: row.borderColor

        // The name is its own item rather than appended text, so it can sit
        // quieter than the glyph it explains.
        Row {
          id: chipContent
          anchors.centerIn: parent
          spacing: Style.space(5)

          Text {
            id: chipText
            anchors.verticalCenter: parent.verticalCenter
            text: modelData
            textFormat: Text.PlainText
            color: row.chipFg
            font.family: row.fontFamily
            // Icons read smaller than letters at the same pixel size.
            font.pixelSize: Math.round(Style.font.caption * row.fontScale
              * (isIcon ? row.iconScale : 1))
            font.bold: true
          }

          Text {
            id: chipName
            anchors.verticalCenter: parent.verticalCenter
            visible: isIcon && row.namingKeys && fullName.length > 0
            text: fullName
            textFormat: Text.PlainText
            color: row.foreground
            opacity: 0.55
            font.family: row.fontFamily
            font.pixelSize: Math.round(Style.font.caption * row.fontScale)
          }
        }
      }
    }
  }

  Text {
    id: actionLabel
    x: row.keysFirst ? row.keysWidth + 8 + Style.spacing.sm : 8
    width: row.actionWidth
    anchors.verticalCenter: parent.verticalCenter
    text: row.modelData.action
    textFormat: Text.PlainText
    color: row.selected ? row.selectedFg : row.foreground
    font.family: row.fontFamily
    font.pixelSize: Math.round(Style.font.body * row.fontScale)
    elide: Text.ElideRight
  }

  // clicked selects, activated runs. A double click emits clicked once for
  // the first press and then activated, so the row is always highlighted
  // before it fires.
  MouseArea {
    anchors.fill: parent
    onClicked: row.clicked(row.modelData.keys, row.modelData.action)
    onDoubleClicked: row.activated(row.modelData.keys, row.modelData.action)
  }
}
