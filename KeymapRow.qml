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
  property string keyboardType: "windows"
  // Set only when the board is not grouped by topic: with the headings
  // gone this is the only place a row's topic survives.
  property string topic: ""
  property bool iconBorders: false
  property string rowLayout: "keys"
  property real fontScale: 1.0
  property real iconScale: 1.35
  readonly property bool keysFirst: rowLayout !== "action"
  // Both renderings of the same chord, index for index: collapseMouse runs
  // for either style, so a chip and its full name share a position.
  readonly property var chipLabels: KeymapData.displayKeys(modelData.keys, row.chipStyle, row.keyboardType)
  readonly property var chipNames: KeymapData.displayNames(modelData.keys)
  readonly property var chipClasses: KeymapData.displayClasses(modelData.keys)
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
  readonly property real actionWidth: Math.max(0, width - keysWidth - 16 - Style.spacing.sm
    - row.topicSpace)
  // Never more than a third of the column: the description is what the row
  // is for, and a long topic must not crowd it out.
  readonly property real topicSpace: row.topic.length > 0
    ? Math.min(topicMetric.implicitWidth, (width - keysWidth) * 0.33) + Style.space(8)
    : 0
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
        // A shape, not a word: boxing it fights the glyph. The rule lives
        // beside the icon tables, since that is what decides it.
        readonly property bool isIcon: KeymapData.isIconGlyph(modelData)
        readonly property string fullName: row.chipNames[index] || ""
        readonly property string chipClass: row.chipClasses[index] || "key"
        // A cap is drawn round a key you press. A glyph standing for what
        // the key does, or for a mouse button, is not a key on a keyboard,
        // so it stays loose whatever this is set to.
        readonly property bool capped: !isIcon || (row.iconBorders && chipClass === "key")
        // Padding scales with the text and does not depend on the cap.
        // Fixed pixels stopped being proportional as the Size slider
        // climbed, and padding only capped chips made a chord jump width
        // when Border was toggled.
        readonly property int pad: Math.round(10 * row.fontScale)
        implicitWidth: chipContent.implicitWidth + pad
        implicitHeight: Math.max(Style.space(18) * row.fontScale,
          chipContent.implicitHeight + Math.round(4 * row.fontScale))
        radius: 4
        color: capped ? row.chipBg : "transparent"
        border.width: capped ? 1 : 0
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

  // Measured unelided and off-screen: sizing the action column from the
  // visible label's width, when that label is itself sized from the
  // column, is a binding loop waiting to happen.
  Text {
    id: topicMetric
    visible: false
    text: row.topic
    font.family: row.fontFamily
    font.pixelSize: Math.round(Style.font.caption * row.fontScale * 0.92)
  }

  // Quieter and smaller than the description it trails: it says where the
  // row came from, not what it does.
  Text {
    id: topicLabel
    visible: row.topic.length > 0
    x: actionLabel.x + actionLabel.width + Style.space(8)
    width: Math.max(0, row.topicSpace - Style.space(8))
    anchors.verticalCenter: parent.verticalCenter
    text: row.topic
    textFormat: Text.PlainText
    color: row.selected ? row.selectedFg : row.foreground
    opacity: 0.4
    font.family: row.fontFamily
    font.pixelSize: Math.round(Style.font.caption * row.fontScale * 0.92)
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
