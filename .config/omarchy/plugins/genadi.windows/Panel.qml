import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "genadi.windows"

  readonly property string order: String(setting("sortBy", "workspace")) === "recent" ? "recent" : "workspace"
  readonly property bool showTitles: setting("showTitles", true) === true
  readonly property string barGlyph: String(setting("icon", "\uf2d2"))

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property var appLibrary: bar && bar.shell ? bar.shell.appLibrary : null

  readonly property string activeAddress: Hyprland.activeToplevel ? String(Hyprland.activeToplevel.address || "") : ""

  readonly property var rows: {
    var values = Hyprland.toplevels ? (Hyprland.toplevels.values || []) : []
    return Model.rowsFor(values, root.order === "recent" ? root.mru : [], root.order)
  }
  readonly property int rowCount: rows.length

  property var mru: []
  readonly property int mruLimit: 32

  property int rowIndex: 0
  property bool cursorActive: false

  property int urgentCount: 0
  readonly property bool hasUrgent: urgentCount > 0

  function indexOfActive() {
    for (var i = 0; i < rows.length; i++) if (rows[i].address === activeAddress) return i
    return 0
  }

  function toplevelAt(index) {
    var row = rows[index]
    return row ? row.toplevel : null
  }

  function ensureCursor() {
    if (rowCount === 0) { rowIndex = 0; return }
    if (rowIndex >= rowCount) rowIndex = rowCount - 1
    if (rowIndex < 0) rowIndex = 0
  }

  function moveCursor(delta) {
    cursorActive = true
    ensureCursor()
    if (delta === 0 || rowCount === 0) return
    rowIndex = (rowIndex + delta + rowCount) % rowCount
    scrollCursorIntoView()
  }

  function setCursor(index) {
    cursorActive = true
    rowIndex = index
  }

  function focusToplevel(toplevel) {
    if (!toplevel) return
    if (toplevel.wayland) toplevel.wayland.activate()
    else if (bar) bar.run("hyprctl dispatch "
      + Util.shellQuote("hl.dsp.focus({ window = \"address:" + toplevel.address + "\" })"))
    close()
  }

  function closeToplevel(toplevel) {
    if (toplevel && toplevel.wayland) toplevel.wayland.close()
  }

  function focusPrevious() {
    var live = ({})
    for (var i = 0; i < rows.length; i++) live[rows[i].address] = true
    var address = Model.previousAddress(root.mru, live)
    if (address === "") return
    for (var j = 0; j < rows.length; j++) {
      if (rows[j].address === address) { focusToplevel(rows[j].toplevel); return }
    }
  }

  function entryByExecHost(host) {
    if (String(host || "").length === 0) return null
    var values = DesktopEntries.applications ? (DesktopEntries.applications.values || []) : []
    var needle = "//" + host
    for (var i = 0; i < values.length; i++) {
      var e = values[i]
      var exec = e && e.execString ? String(e.execString) : ""
      if (exec.indexOf(needle) !== -1) return e
    }
    return null
  }

  function desktopEntryFor(appId) {
    var id = String(appId || "")
    if (id.length === 0) return null

    var byHost = entryByExecHost(Model.webAppHost(id))
    if (byHost) return byHost

    var candidates = Model.lookupCandidates(id)
    for (var i = 0; i < candidates.length; i++) {
      try {
        var entry = DesktopEntries.heuristicLookup(candidates[i])
        if (entry) return entry
      } catch (e2) { }
    }

    var host = Model.webAppHost(id)
    if (host !== "") return entryByName(Model.hostLabel(host))
    return candidates.length > 0 ? entryByIdPrefix(candidates[candidates.length - 1]) : null
  }

  function entryByName(name) {
    var needle = String(name || "").toLowerCase()
    if (needle.length === 0) return null
    var values = DesktopEntries.applications ? (DesktopEntries.applications.values || []) : []
    for (var i = 0; i < values.length; i++) {
      var e = values[i]
      if (e && e.name && String(e.name).toLowerCase() === needle) return e
    }
    return null
  }

  function entryByIdPrefix(tail) {
    var prefix = String(tail || "").toLowerCase()
    if (prefix.length === 0) return null
    var values = DesktopEntries.applications ? (DesktopEntries.applications.values || []) : []
    for (var i = 0; i < values.length; i++) {
      var e = values[i]
      var id = e && e.id ? String(e.id).toLowerCase() : ""
      if (id.indexOf(prefix + "-") === 0 || id.indexOf(prefix + ".") === 0) return e
    }
    return null
  }

  function iconSourceFor(entry, appId) {
    var icon = entry && entry.icon ? String(entry.icon) : String(appId || "")
    if (appLibrary && typeof appLibrary.iconSource === "function") return appLibrary.iconSource(icon)
    var themed = icon.length > 0 ? Quickshell.iconPath(icon, true) : ""
    return themed.length > 0 ? themed : Quickshell.iconPath("application-x-executable", true)
  }

  function scrollItemIntoView(item) {
    if (!listFlick || !item) return
    Qt.callLater(function () {
      if (!item) return
      var margin = Style.space(6)
      var point = item.mapToItem(listFlick.contentItem, 0, 0)
      var top = point.y
      var bottom = top + item.height
      var viewTop = listFlick.contentY
      var viewBottom = viewTop + listFlick.height
      var maxY = Math.max(0, listFlick.contentHeight - listFlick.height)
      if (top < viewTop + margin) listFlick.contentY = Math.max(0, top - margin)
      else if (bottom > viewBottom - margin) listFlick.contentY = Math.min(maxY, bottom + margin - listFlick.height)
    })
  }

  function scrollCursorIntoView() {
    if (rowIndex >= 0 && rowIndex < rowRepeater.count) scrollItemIntoView(rowRepeater.itemAt(rowIndex))
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onRowsChanged: ensureCursor()
  onRowIndexChanged: scrollCursorIntoView()
  onOpenedChanged: if (opened) {
    cursorActive = false
    if (listFlick) listFlick.contentY = 0
    rowIndex = indexOfActive()
    if (appLibrary && typeof appLibrary.refreshIcons === "function") appLibrary.refreshIcons()
    Qt.callLater(function () { keyCatcher.forceActiveFocus() })
  }

  Connections {
    target: Hyprland
    function onActiveToplevelChanged() {
      var t = Hyprland.activeToplevel
      root.mru = Model.pushMru(root.mru, t ? t.address : "", root.mruLimit)
    }
  }

  Instantiator {
    model: Hyprland.toplevels
    delegate: QtObject {
      required property var modelData
      readonly property bool urgent: !!(modelData && modelData.urgent)
      property bool counted: false
      function sync() {
        if (urgent === counted) return
        root.urgentCount += urgent ? 1 : -1
        counted = urgent
      }
      onUrgentChanged: sync()
      Component.onCompleted: sync()
      Component.onDestruction: if (counted) root.urgentCount -= 1
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.barGlyph
    active: root.hasUrgent
    tooltipText: Model.countLabel(root.rowCount)
    onPressed: function (buttonCode) {
      if (buttonCode === Qt.RightButton) root.focusPrevious()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(520))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function (dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dy)
      }
      onActivateRequested: if (root.cursorActive) root.focusToplevel(root.toplevelAt(root.rowIndex))
      onDeleteRequested: if (root.cursorActive) root.closeToplevel(root.toplevelAt(root.rowIndex))
      onCloseRequested: root.close()
      onTabRequested: function (direction) { root.switchPanel(direction) }
      onTextKey: function (t) {
        if (!/^[1-9]$/.test(t)) return
        var index = Number(t) - 1
        if (index < root.rowCount) root.focusToplevel(root.toplevelAt(index))
      }

      Flickable {
        id: listFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: listFlick.width
          spacing: Style.space(8)

          Item {
            width: parent.width
            implicitHeight: Math.max(titleText.implicitHeight, countText.implicitHeight)

            Text {
              id: titleText
              anchors.left: parent.left
              anchors.right: countText.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              text: "Windows"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.subtitle
              font.weight: Font.Medium
              elide: Text.ElideRight
            }

            Text {
              id: countText
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: root.rowCount > 0 ? String(root.rowCount) : ""
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }

          PanelSeparator { foreground: root.foreground }

          Text {
            visible: root.rowCount === 0
            width: parent.width
            text: "No open windows."
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            horizontalAlignment: Text.AlignHCenter
          }

          Column {
            id: rowColumn
            visible: root.rowCount > 0
            width: parent.width
            spacing: Style.space(2)

            Repeater {
              id: rowRepeater
              model: root.rows
              WindowEntry {
                required property var modelData
                required property int index
                width: rowColumn.width
                row: modelData
                rowIndex: index
              }
            }
          }
        }
      }
    }
  }

  component WindowEntry: Column {
    id: entry

    required property var row
    required property int rowIndex

    readonly property var toplevel: row ? row.toplevel : null
    readonly property string header: Model.headerFor(root.rows, rowIndex, root.order)
    readonly property var desktopEntry: root.desktopEntryFor(row ? row.appId : "")
    readonly property string appName: desktopEntry && desktopEntry.name
      ? String(desktopEntry.name)
      : Model.prettyAppId(row ? row.appId : "")
    readonly property string windowTitle: toplevel ? String(toplevel.title || "") : ""
    readonly property bool isActive: toplevel ? toplevel.activated === true : false
    readonly property bool isUrgent: toplevel ? toplevel.urgent === true : false
    readonly property bool hasCursor: root.cursorActive && root.rowIndex === rowIndex
    readonly property string detail: {
      if (!root.showTitles) return ""
      return windowTitle.length === 0 || windowTitle === appName ? "" : windowTitle
    }

    spacing: Style.space(6)

    Item {
      width: 1
      height: Style.space(4)
      visible: entry.header !== "" && entry.rowIndex > 0
    }

    PanelSectionHeader {
      visible: entry.header !== ""
      text: entry.header.toUpperCase()
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    CursorSurface {
      width: parent.width
      hasCursor: entry.hasCursor
      current: entry.isActive
      foreground: entry.isUrgent ? root.urgent : root.foreground
      implicitHeight: Math.max(rowText.implicitHeight, rowIcon.height) + Style.spacing.rowPaddingX

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onEntered: root.setCursor(entry.rowIndex)
        onClicked: function (mouse) {
          if (mouse.button === Qt.MiddleButton) root.closeToplevel(entry.toplevel)
          else root.focusToplevel(entry.toplevel)
        }
      }

      Image {
        id: rowIcon
        anchors.left: parent.left
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        width: Style.font.iconLarge
        height: Style.font.iconLarge
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width * Screen.devicePixelRatio
        sourceSize.height: height * Screen.devicePixelRatio
        source: root.iconSourceFor(entry.desktopEntry, entry.row ? entry.row.appId : "")
        asynchronous: true
      }

      Column {
        id: rowText
        anchors.left: rowIcon.right
        anchors.leftMargin: Style.space(8)
        anchors.right: rowTrail.left
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(1)

        Text {
          width: parent.width
          text: entry.appName
          color: entry.isUrgent ? root.urgent : root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.weight: entry.isActive ? Font.Medium : Font.Normal
          elide: Text.ElideRight
        }

        Text {
          visible: entry.detail !== ""
          width: parent.width
          text: entry.detail
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      Row {
        id: rowTrail
        anchors.right: parent.right
        anchors.rightMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(6)

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: root.order === "recent" && text !== ""
          text: entry.row ? String(entry.row.workspaceBadge || "") : ""
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        PanelActionButton {
          anchors.verticalCenter: parent.verticalCenter
          opacity: entry.hasCursor ? 1 : 0
          enabled: entry.hasCursor
          iconText: "\uf00d"
          tooltipText: "Close window"
          foreground: root.foreground
          hoverColor: root.urgent
          fontFamily: root.fontFamily
          onClicked: root.closeToplevel(entry.toplevel)
        }
      }
    }
  }
}
