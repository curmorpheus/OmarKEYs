import QtQuick
import qs.Commons
import "KeymapData.js" as KeymapData

// A chord drawn the way the board would draw it, for the options that
// change how a chord looks. Reading "icons" or "border on" tells you the
// setting's name; this tells you what you are about to get.
Row {
  id: sample

  property string keys: "Super + K"
  property string chipStyle: "icons"
  property string keyboardType: "windows"
  property bool iconBorders: false
  property string fontFamily: Style.font.menuFamily
  property color chipBg: Color.menu.selectedBackground
  property color chipFg: Color.menu.selectedText
  property color borderColor: Color.menu.border
  property real iconScale: 1.35
  // The board's scale, not one of its own. A preview drawn at a fixed size
  // stops being a preview the moment the Size slider moves.
  property real fontScale: 1.0

  readonly property var chipLabels:
    KeymapData.displayKeys(sample.keys, sample.chipStyle, sample.keyboardType)
  readonly property var chipClasses: KeymapData.displayClasses(sample.keys)

  spacing: 4

  Repeater {
    model: sample.chipLabels
    delegate: Rectangle {
      // Both required together: asking for one stops QML injecting the
      // other, which leaves every chip blank.
      required property int index
      required property var modelData
      readonly property bool isIcon: KeymapData.isIconGlyph(modelData)
      readonly property string chipClass: sample.chipClasses[index] || "key"
      readonly property bool capped:
        !isIcon || (sample.iconBorders && chipClass === "key")

      implicitWidth: chipText.implicitWidth + (capped ? 10 : 4)
      implicitHeight: Math.max(Style.space(18), chipText.implicitHeight + 4)
      radius: 4
      color: capped ? sample.chipBg : "transparent"
      border.width: capped ? 1 : 0
      border.color: sample.borderColor

      Text {
        id: chipText
        anchors.centerIn: parent
        text: modelData
        textFormat: Text.PlainText
        color: sample.chipFg
        font.family: sample.fontFamily
        // Identical to KeymapRow's: same base, same scale, same icon
        // compensation, so what you see here is what the board draws.
        font.pixelSize: Math.round(Style.font.caption * sample.fontScale
          * (isIcon ? sample.iconScale : 1))
        font.bold: true
      }
    }
  }
}
