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

  // Channel or Versions, one at a time. They answer the same question in
  // two ways, and showing both at once halved the width each had to say
  // it in.
  property string tab: "channel"

  // Which release track the lists below describe. Not a switch that moves
  // the checkout: it filters what is offered, so a track with nothing
  // released shows nothing and says why. 2.0 is being built on its own
  // branch and has reached no channel yet; when it does it appears here on
  // its own, because both lists are filtered on what branches and tags
  // actually carry rather than on a hardcoded name.
  property string track: (host && host.gitTrack === "2.0") ? "2" : "1"
  // Open by default when already on a working branch, so you can see
  // where you are without hunting for the disclosure.

  width: Style.space(300)
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

    // What is loaded, and the one action you take on it. The cloud is the
    // check/sync button the full-width bar used to be; its label says
    // which of the two clicking it will do.
    Row {
      width: parent.width
      spacing: Style.space(8)

      Item {
        id: updateCell
        width: Style.space(52)
        height: cloudGlyph.height + updateLabel.height + Style.space(2)

        Text {
          id: cloudGlyph
          anchors.horizontalCenter: parent.horizontalCenter
          text: "\udb81\udd2a"
          textFormat: Text.PlainText
          color: (host && (host.gitUpdateAvailable || host.shellStale))
            ? menu.chipFg : menu.foreground
          opacity: menu.busy ? 0.4 : (updateArea.containsMouse ? 1 : 0.8)
          font.family: menu.fontFamily
          font.pixelSize: Math.round(menu.labelSize * 3.2)
        }

        Text {
          id: updateLabel
          anchors.top: cloudGlyph.bottom
          anchors.topMargin: Style.space(2)
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          // Restart outranks update: until the shell reloads you are not
          // running what the hash above says you are, and syncing again
          // would not change that.
          text: menu.busy ? "…"
            : ((host && host.shellStale) ? "restart"
              : ((host && host.gitUpdateAvailable) ? "update" : "check"))
          textFormat: Text.PlainText
          color: (host && (host.gitUpdateAvailable || host.shellStale))
            ? menu.chipFg : menu.foreground
          opacity: 0.7
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
            if (h.shellStale)
              h.restartShell()
            else if (h.gitUpdateAvailable)
              h.syncBranch()
            else
              h.checkForUpdates()
          }
        }
      }

      // One fact per line, each labelled. As a single run they ran
      // together into something that had to be parsed rather than read.
      Column {
        width: parent.width - updateCell.width - Style.space(8)
        spacing: Style.space(2)

        Repeater {
          model: [
            { label: "Updated", value: (host && host.gitDate) ? host.gitDate : "—" },
            { label: "Branch", value: !host ? "—"
              : host.channelLabel(host.gitChannel)
                + (host.gitChannel === "untested" && host.gitBranch
                  ? "  ·  " + host.gitBranch : "") },
            { label: "Hash", value: (host && host.gitHash) ? host.gitHash : "—" }
          ]
          delegate: Text {
            required property var modelData
            width: parent.width
            text: modelData.label + ": " + modelData.value
            textFormat: Text.PlainText
            color: menu.foreground
            font.family: menu.fontFamily
            font.pixelSize: menu.labelSize
            elide: Text.ElideRight
          }
        }
      }
    }

    // The checkout moved after this shell loaded, so the hash above is not
    // the code on screen. Worth saying outright: it looks exactly like a
    // change that failed to arrive.
    Text {
      width: parent.width
      visible: !!(host && host.shellStale)
      text: "Running " + (host ? host.loadedHash : "") + " — restart to load "
        + (host ? host.gitHash : "")
      textFormat: Text.PlainText
      color: menu.chipFg
      wrapMode: Text.WordWrap
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
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

    // The release track, above the tabs: 1.0 is what ships today, 2.0 is
    // the editable-keymaps line. This filters the lists; it does not
    // switch the checkout. The 2.0 *channel* below is what checks out
    // branch 2.0.
    Row {
      width: parent.width
      spacing: Style.space(6)

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Track"
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.6
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      Repeater {
        model: [{ id: "1", label: "1.0" }, { id: "2", label: "2.0" }]
        delegate: Rectangle {
          required property var modelData
          readonly property bool selected: menu.track === modelData.id
          width: trackLabel.implicitWidth + Style.space(10)
          height: trackLabel.implicitHeight + Style.space(4)
          radius: 3
          color: selected ? menu.chipFg
            : (trackArea.containsMouse ? menu.borderColor : "transparent")
          border.width: selected ? 0 : 1
          border.color: menu.borderColor

          Text {
            id: trackLabel
            anchors.centerIn: parent
            text: modelData.label
            textFormat: Text.PlainText
            color: selected ? menu.color : menu.foreground
            opacity: selected ? 1 : 0.75
            font.family: menu.fontFamily
            font.pixelSize: menu.labelSize
            font.bold: selected
          }

          MouseArea {
            id: trackArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menu.track = modelData.id
          }
        }
      }
    }

    Text {
      width: parent.width
      visible: menu.track === "2"
      text: "2.0 is development only — not on Beta or Main yet"
      textFormat: Text.PlainText
      color: menu.foreground
      opacity: 0.6
      wrapMode: Text.WordWrap
      font.family: menu.fontFamily
      font.pixelSize: menu.labelSize
      font.italic: true
    }

    // Two tabs, inverted like every other heading here: the selected one
    // is filled, the other is an outline you can click.
    Row {
      width: parent.width
      spacing: Style.space(6)

      Repeater {
        model: [
          { id: "channel", label: "Channel" },
          { id: "versions", label: "Versions" }
        ]
        delegate: Rectangle {
          required property var modelData
          readonly property bool selected: menu.tab === modelData.id
          width: (menu.width - Style.spacing.sm * 2 - Style.space(6)) / 2
          height: tabLabel.implicitHeight + Style.space(6)
          radius: 3
          color: selected ? menu.chipFg
            : (tabArea.containsMouse ? menu.borderColor : "transparent")
          border.width: selected ? 0 : 1
          border.color: menu.borderColor

          Text {
            id: tabLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: modelData.label
            textFormat: Text.PlainText
            color: selected ? menu.color : menu.foreground
            font.family: menu.fontFamily
            font.pixelSize: menu.labelSize
            font.bold: true
            font.capitalization: Font.AllUppercase
          }

          MouseArea {
            id: tabArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menu.tab = modelData.id
          }
        }
      }
    }

    // Channel: exactly the list it was before versions existed.
    Column {
      width: parent.width
      visible: menu.tab === "channel"
      spacing: Style.space(4)

      Text {
        width: parent.width
        visible: !!host && host.channelTrack("main") !== menu.track
          && host.channelTrack("beta") !== menu.track
          && host.channelTrack("nightly") !== menu.track
          && host.channelTrack("2.0") !== menu.track
        text: "OmarKEYS " + menu.track + ".0 has not reached a channel yet."
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.5
        wrapMode: Text.WordWrap
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      Repeater {
        model: [
          { id: "main", label: "Main", note: "stable" },
          { id: "beta", label: "Beta", note: "tested, ahead of stable" },
          { id: "nightly", label: "Nightly", note: "develop" },
          { id: "2.0", label: "2.0", note: "editable keymaps" }
        ]
        delegate: Rectangle {
          required property var modelData
          readonly property bool current: !!(host && host.gitChannel === modelData.id)
          readonly property string age: !host ? ""
            : host.versionAge(host.branchForChannel(modelData.id))
          // A channel appears under the track its branch is carrying.
          visible: !!host && host.channelTrack(modelData.id) === menu.track
          width: parent.width
          height: visible ? Math.max(Style.space(22), channelLabel.implicitHeight + 6) : 0
          radius: 4
          color: channelArea.containsMouse && !menu.busy ? menu.borderColor : "transparent"

          Text {
            id: channelLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: (current ? "• " : "  ") + modelData.label
              + "   " + modelData.note + (age ? "  ·  " + age : "")
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
              if (!h || h.gitBusy || current)
                return
              h.switchChannel(modelData.id)
            }
          }
        }
      }
    }

    // Versions: a tree, grouped by main version. Only releases whose tree
    // carries the version marker are here at all -- plugin-git drops the
    // rest, because a build with no picker in it cannot switch back out.
    Column {
      width: parent.width
      visible: menu.tab === "versions"
      spacing: Style.space(4)

      Text {
        width: parent.width
        visible: !host || !host.versionTree || host.versionTree.length === 0
        text: "No " + menu.track + ".0 release yet. One appears here when a version is tagged."
        textFormat: Text.PlainText
        color: menu.foreground
        opacity: 0.5
        wrapMode: Text.WordWrap
        font.family: menu.fontFamily
        font.pixelSize: menu.labelSize
      }

      Flickable {
        width: parent.width
        visible: !!(host && host.versionTree && host.versionTree.length)
        height: visible ? Math.min(Style.space(190), versionTreeCol.height) : 0
        clip: true
        contentWidth: width
        contentHeight: versionTreeCol.height
        boundsBehavior: Flickable.StopAtBounds
        activeFocusOnTab: false

        Column {
          id: versionTreeCol
          width: parent.width
          spacing: Style.space(3)

          Repeater {
            model: host ? host.versionTree : []
            delegate: Column {
              required property var modelData
              // 1.13.x under track 1, 2.x under track 2.
              visible: !!host && host.trackOf(modelData.title) === menu.track
              width: versionTreeCol.width
              spacing: 1

              Text {
                width: parent.width
                text: "▾ " + modelData.title
                textFormat: Text.PlainText
                color: menu.chipFg
                font.family: menu.fontFamily
                font.pixelSize: menu.labelSize
                font.bold: true
              }

              Repeater {
                model: modelData.releases
                delegate: Rectangle {
                  required property var modelData
                  readonly property bool current: !!(host && host.gitDetached
                    && host.gitDescribe === modelData.tag)
                  width: versionTreeCol.width
                  height: Math.max(Style.space(20), releaseLabel.implicitHeight + 4)
                  radius: 4
                  color: releaseArea.containsMouse && !current && !menu.busy && !menu.dirty
                    ? menu.borderColor : "transparent"

                  Text {
                    id: releaseLabel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 18
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: (current ? "• " : "") + modelData.tag
                      + (modelData.date ? "  ·  " + modelData.date : "")
                    textFormat: Text.PlainText
                    color: current ? menu.chipFg : menu.foreground
                    opacity: menu.dirty && !current ? 0.45 : 1
                    font.family: menu.fontFamily
                    font.pixelSize: menu.labelSize
                    font.bold: current
                    elide: Text.ElideRight
                  }

                  MouseArea {
                    id: releaseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      var h = menu.host
                      if (!h || h.gitBusy || current)
                        return
                      h.loadVersion(modelData.tag)
                    }
                  }
                }
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
