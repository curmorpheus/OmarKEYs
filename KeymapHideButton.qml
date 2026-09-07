import QtQuick
import qs.Commons

// A plain-text Show/Hide control used at every level of the sidebar tree.
// It names the action rather than the state - "Hide" while the thing is
// showing, "Show" once it is hidden - so it reads the same whether it sits
// on a root branch, an area, a group, or an app.
//
// No outline: four of these are visible on most rows, and boxing them all
// turned the sidebar into a grid of buttons competing with the tree itself.
// Hover and colour carry the affordance instead.
Item {
  id: button

  property bool shown: true
  property color foreground: Color.menu.text
  property color accent: Color.menu.selectedText
  property string fontFamily: Style.font.menuFamily
  property int fontSize: Style.font.caption
  signal toggled()

  // Padding is click target, not decoration - the text alone is a small
  // thing to hit.
  implicitWidth: label.implicitWidth + Style.space(6)
  implicitHeight: label.implicitHeight + Style.space(4)
  width: implicitWidth
  height: implicitHeight

  Text {
    id: label
    anchors.centerIn: parent
    text: button.shown ? "Hide" : "Show"
    textFormat: Text.PlainText
    color: (area.containsMouse || !button.shown) ? button.accent : button.foreground
    opacity: area.containsMouse ? 1 : (button.shown ? 0.65 : 0.9)
    font.family: button.fontFamily
    font.pixelSize: button.fontSize
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: button.toggled()
  }
}
