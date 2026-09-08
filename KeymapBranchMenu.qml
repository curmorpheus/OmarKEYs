import QtQuick
import qs.Commons

// Branch picker hanging off the build label in the overlay's bottom
// corner: pick a branch to load, see when the remote has newer commits,
// and fast-forward to them. Mutating actions go through `plugin-git`,
// which refuses rather than discarding work.
Rectangle {
  id: menu

  property Item host: null

  readonly property color foreground: host ? host.foreground : Color.menu.text
  readonly property color chipFg: host ? host.chipFg : Color.menu.selectedText
  readonly property color borderColor: host ? host.border : Color.menu.border
  readonly property string fontFamily: host ? host.fontFamily : Style.font.menuFamily
  readonly property int labelSize: Style.font.caption
  readonly property bool busy: host ? host.gitBusy : false
  readonly property bool dirty: host ? host.gitDirty : false
  // Open by default when already on a working branch, so you can see
  // where you are without hunting for the disclosure.
  property bool untestedOpen: !!(host && host.gitChannel === "untested")

  width: Style.space(280)
  height: Math.min(Style.space(320), content.implicitHeight + Style.spacing.sm * 2)
  radius: 6
  color: host ? host.background : Color.menu.background
  border.width: 1
  border.color: menu.borderColor

  // Swallow clicks so picking a branch does not fall through to the
  // scrim underneath and dismiss the whole overlay.
  MouseArea { anchors.fill: parent; onClicked: {} }

  Column {
    id: content
    anchors.fill: parent
    anchors.margins: Style.spacing.sm
    spacing: Style.space(4)

    Text {
      width: parent.width
      text: "Loaded"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    Text {
      width: parent.width
      text: (host ? host.channelLabel(host.gitChannel) : "unknown")
        + (host && host.gitBranch ? "  ·  " + host.gitBranch : "")
        + (host && host.gitHash ? " @ " + host.gitHash : "")
        + (host && host.gitDate ? "  ·  " + host.gitDate : "")
      textFormat: Text.PlainText
      color: menu.foreground
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      elide: Text.ElideMiddle
    }

    // Anything that would make a switch or sync refuse is worth saying
    // before the user clicks and gets a bare git error.
    Text {
      width: parent.width
      visible: menu.dirty
      text: "Uncommitted changes — switching is blocked"
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.7
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.italic: true
      wrapMode: Text.WordWrap
    }

    Text {
      width: parent.width
      visible: !!(host && host.gitError)
      text: host ? host.gitError : ""
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.85
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      wrapMode: Text.WordWrap
    }

    // Update row: only offers the button when there is something to pull.
    Rectangle {
      width: parent.width
      height: Math.max(Style.space(22), updateLabel.implicitHeight + 6)
      radius: 4
      color: updateArea.containsMouse && !menu.busy ? menu.borderColor : "transparent"
      border.width: 1
      border.color: menu.borderColor
      opacity: menu.busy ? 0.5 : 1

      Text {
        id: updateLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: menu.busy ? "Working…"
          : (host && host.gitUpdateAvailable)
            ? "Sync to latest (" + (host ? host.gitBehind : 0) + " new)"
            : "Check for updates"
        textFormat: Text.PlainText
        color: (host && host.gitUpdateAvailable) ? menu.chipFg : menu.foreground
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
        font.bold: !!(host && host.gitUpdateAvailable)
        elide: Text.ElideRight
      }

      MouseArea {
        id: updateArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          var h = menu.host
          if (!h || h.gitBusy)
            return
          if (h.gitUpdateAvailable)
            h.syncBranch()
          else
            h.checkForUpdates()
        }
      }
    }

    Text {
      width: parent.width
      text: "Channel"
      textFormat: Text.PlainText
      color: menu.chipFg
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.bold: true
      font.capitalization: Font.AllUppercase
    }

    // The three channels are each the tip of one branch, so each is one
    // click. Untested is a disclosure: it opens the rest of the branches
    // rather than switching, so nobody lands on one by accident.
    Repeater {
      model: [
        { id: "main", label: "Main", note: "stable" },
        { id: "beta", label: "Beta", note: "tested, ahead of stable" },
        { id: "nightly", label: "Nightly", note: "develop" },
        { id: "untested", label: "Untested", note: "every other branch" }
      ]
      delegate: Rectangle {
        required property var modelData
        readonly property bool current: !!(host && host.gitChannel === modelData.id)
        readonly property bool isUntested: modelData.id === "untested"
        width: content.width
        height: Math.max(Style.space(22), channelLabel.implicitHeight + 6)
        radius: 4
        color: channelArea.containsMouse && !menu.busy ? menu.borderColor : "transparent"

        Text {
          id: channelLabel
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: 6
          anchors.rightMargin: 6
          anchors.verticalCenter: parent.verticalCenter
          // The note says what the channel is; the age says whether it is
          // worth switching to, which is the actual question being asked.
          readonly property string age: (isUntested || !host) ? ""
            : host.versionAge(host.branchForChannel(modelData.id))
          text: (current ? "• " : "  ")
            + modelData.label
            + (isUntested ? (menu.untestedOpen ? "  ▾" : "  ▸") : "")
            + "   " + modelData.note
            + (age ? "  ·  " + age : "")
          textFormat: Text.PlainText
          color: current ? menu.chipFg : menu.foreground
          opacity: (menu.dirty && !current) ? 0.45 : 1
          font.family: menu.fontFamily
          font.pixelSize: menu.labelSize
          font.bold: current
          elide: Text.ElideRight
        }

        MouseArea {
          id: channelArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            var h = menu.host
            if (!h || h.gitBusy)
              return
            if (isUntested) {
              menu.untestedOpen = !menu.untestedOpen
              return
            }
            if (current)
              return
            h.switchChannel(modelData.id)
          }
        }
      }
    }

    Flickable {
      width: parent.width
      visible: menu.untestedOpen
      height: visible ? Math.min(Style.space(150), branchCol.height) : 0
      clip: true
      contentWidth: width
      contentHeight: branchCol.height
      boundsBehavior: Flickable.StopAtBounds
      activeFocusOnTab: false

      Column {
        id: branchCol
        width: parent.width
        spacing: 1

        Repeater {
          // Main, Beta and Nightly already have their own rows above.
          model: host ? host.untestedBranches : []
          delegate: Rectangle {
            required property var modelData
            readonly property bool current: !!(host && modelData === host.gitBranch)
            readonly property string age: host ? host.versionAge(modelData) : ""
            width: branchCol.width
            height: Math.max(Style.space(20), branchLabel.implicitHeight + 4)
            radius: 4
            color: branchArea.containsMouse && !current && !menu.busy && !menu.dirty
              ? menu.borderColor
              : "transparent"

            Text {
              id: branchLabel
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: 16
              anchors.rightMargin: 6
              anchors.verticalCenter: parent.verticalCenter
              text: (current ? "• " : "") + modelData + (age ? "  ·  " + age : "")
              textFormat: Text.PlainText
              color: current ? menu.chipFg : menu.foreground
              opacity: (menu.dirty && !current) ? 0.45 : 1
              font.family: menu.fontFamily
              font.pixelSize: menu.labelSize
              font.bold: current
              elide: Text.ElideMiddle
            }

            MouseArea {
              id: branchArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                var h = menu.host
                if (!h || h.gitBusy || current)
                  return
                h.switchBranch(modelData)
              }
            }
          }
        }
      }
    }

    Text {
      width: parent.width
      text: "Switching or syncing restarts the shell"
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.55
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      wrapMode: Text.WordWrap
    }
  }
}
