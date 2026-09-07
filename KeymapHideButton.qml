import QtQuick
import qs.Commons

// A labelled Show/Hide control used at every level of the sidebar tree.
// It names the action rather than the state - "Hide" while the thing is
// showing, "Show" once it is hidden - so it reads the same whether it is
// sitting on a root branch, an area, a group, or an app.
Rectangle {
  id: button

  property bool shown: true
  property color foreground: Color.menu.text
  property color accent: Color.menu.selectedText
  property color borderColor: Color.menu.border
  property string fontFamily: Style.font.menuFamily
  property int fontSize: Style.font.caption
  signal toggled()

  implicitWidth: label.implicitWidth + Style.space(8)
  implicitHeight: label.implicitHeight + Style.space(4)
  width: implicitWidth
  height: implicitHeight
  radius: 4
  border.width: 1
  border.color: button.borderColor
  opacity: button.shown ? 1 : 0.75
  color: area.containsMouse
    ? Qt.rgba(button.accent.r, button.accent.g, button.accent.b, 0.22)
    : "transparent"

  Text {
    id: label
    anchors.centerIn: parent
    text: button.shown ? "Hide" : "Show"
    textFormat: Text.PlainText
    color: button.shown ? button.foreground : button.accent
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
