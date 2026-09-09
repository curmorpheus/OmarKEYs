import QtQuick
import qs.Commons
import "KeymapData.js" as KeymapData

Flickable {
  id: board
  property Item host: null

  clip: true
  contentWidth: width
  contentHeight: columnsRow.height
  boundsBehavior: Flickable.StopAtBounds
  activeFocusOnTab: false

  function revealItem(item) {
    if (!item || board.height <= 0)
      return
    var p = item.mapToItem(board.contentItem, 0, 0)
    if (!p)
      return
    var y = p.y
    if (y < 0 || y > board.contentHeight)
      return
    var bottom = y + Math.max(1, item.height)
    var pad = Style.spacing.sm
    if (y < board.contentY)
      board.contentY = Math.max(0, y - pad)
    else if (bottom > board.contentY + board.height)
      board.contentY = Math.min(
        Math.max(0, board.contentHeight - board.height),
        bottom - board.height + pad)
  }

  Row {
    id: columnsRow
    width: parent.width
    spacing: Style.space(12)

    Column {
      id: leftCol
      width: (columnsRow.width - columnsRow.spacing) / 2
      spacing: Style.space(8)

      Repeater {
        model: host ? host.leftSections : []
        delegate: KeymapSection {
          required property int index
          required property var modelData
          width: leftCol.width
          title: modelData.title
          mark: host.omarchyActive ? KeymapData.omarchyIcon() : ""
          // A section can name its own source -- the all-apps view tags
          // each one with the kind whose sheet it came from. Otherwise the
          // app being viewed names it, unless the card is already titled
          // with that name, which would just say it twice.
          qualifier: modelData.qualifier ? modelData.qualifier
            : ((!host.omarchyActive && host.activeLabel
              && modelData.title !== host.activeLabel)
              ? "[" + host.activeLabel + "]" : "")
          sectionNumber: index * 2 + 1
          rows: modelData.rows
          selectedKeys: host.selectedKeys
          selectedAction: host.selectedAction
          fontFamily: host.fontFamily
          foreground: host.foreground
          borderColor: host.border
          chipBg: host.chipBg
          chipFg: host.chipFg
          panelBg: host.background
          selectedBg: Qt.rgba(host.chipFg.r, host.chipFg.g, host.chipFg.b, 0.32)
          selectedFg: host.chipFg
          chipStyle: host.chipStyle
          keyboardType: host.keyboardType
          iconBorders: host.iconBorders
          rowLayout: host.rowLayout
          fontScale: host.fontScale
          iconScale: host.iconScale
          onRowClicked: function(keys, action) { host.selectRow(keys, action) }
          onRowActivated: function(keys, action) { host.activateRow(keys, action) }
          // Hold the references rather than resolving them later: by the
          // time a deferred call runs, a rebuild may have destroyed this
          // delegate, and then the name "board" resolves to nothing.
          onRowHighlighted: function(item) {
            var target = board
            Qt.callLater(function() {
              if (target && item)
                target.revealItem(item)
            })
          }
        }
      }
    }

    Column {
      id: rightCol
      width: (columnsRow.width - columnsRow.spacing) / 2
      spacing: Style.space(8)

      Repeater {
        model: host ? host.rightSections : []
        delegate: KeymapSection {
          required property int index
          required property var modelData
          width: rightCol.width
          title: modelData.title
          mark: host.omarchyActive ? KeymapData.omarchyIcon() : ""
          // A section can name its own source -- the all-apps view tags
          // each one with the kind whose sheet it came from. Otherwise the
          // app being viewed names it, unless the card is already titled
          // with that name, which would just say it twice.
          qualifier: modelData.qualifier ? modelData.qualifier
            : ((!host.omarchyActive && host.activeLabel
              && modelData.title !== host.activeLabel)
              ? "[" + host.activeLabel + "]" : "")
          sectionNumber: index * 2 + 2
          rows: modelData.rows
          selectedKeys: host.selectedKeys
          selectedAction: host.selectedAction
          fontFamily: host.fontFamily
          foreground: host.foreground
          borderColor: host.border
          chipBg: host.chipBg
          chipFg: host.chipFg
          panelBg: host.background
          selectedBg: Qt.rgba(host.chipFg.r, host.chipFg.g, host.chipFg.b, 0.32)
          selectedFg: host.chipFg
          chipStyle: host.chipStyle
          keyboardType: host.keyboardType
          iconBorders: host.iconBorders
          rowLayout: host.rowLayout
          fontScale: host.fontScale
          iconScale: host.iconScale
          onRowClicked: function(keys, action) { host.selectRow(keys, action) }
          onRowActivated: function(keys, action) { host.activateRow(keys, action) }
          // Hold the references rather than resolving them later: by the
          // time a deferred call runs, a rebuild may have destroyed this
          // delegate, and then the name "board" resolves to nothing.
          onRowHighlighted: function(item) {
            var target = board
            Qt.callLater(function() {
              if (target && item)
                target.revealItem(item)
            })
          }
        }
      }
    }
  }
}
