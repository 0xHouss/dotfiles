import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "houss.workspaces"

  // The `bar` property is the shared Bar object, not the per-monitor panel, so
  // the enclosing window is what identifies this instance's screen.
  readonly property var hostWindow: root.QsWindow ? root.QsWindow.window : null
  readonly property string screenName: hostWindow && hostWindow.screen
    ? String(hostWindow.screen.name || "")
    : ""
  readonly property var monitor: hostWindow && hostWindow.screen
    ? Hyprland.monitorFor(hostWindow.screen)
    : Hyprland.focusedMonitor
  readonly property string monitorName: root.monitor ? String(root.monitor.name || "") : ""

  // Persistent workspaces per monitor, mirroring the old waybar
  // `persistent-workspaces` block. This has to agree with the workspace_rule
  // pinning in hypr/hyprland.lua, which is what actually sends new workspaces
  // to the right screen — this list only decides what the bar draws.
  // Monitors that are not listed fall back to showing all ten.
  //
  // Workspace ids stay global (1-10 across all monitors), unlike Omarchy 4.5's
  // per-monitor blocks of ten; hyprland.lua overrides o.workspaces to match.
  readonly property var persistentByMonitor: ({
    "eDP-1": [1, 2, 3, 4, 5],
    "HDMI-A-1": [6, 7, 8, 9, 10]
  })

  function otherMonitorConnected() {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      var monitor = monitors[i]
      if (monitor && String(monitor.name || "") !== root.screenName) return true
    }
    return false
  }

  function persistentIds() {
    if (!root.otherMonitorConnected()) return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var ids = root.persistentByMonitor[root.screenName]
    return ids ? ids.slice() : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  }

  function activeWorkspaceId() {
    return root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : -1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = root.persistentIds()
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (!workspace) continue

      var id = workspace.id
      if (id <= 0 || id > 10 || ids.indexOf(id) !== -1) continue

      // A live workspace outside this monitor's persistent set is only drawn
      // if it actually sits on this monitor, matching waybar's
      // `all-outputs: false`.
      var monitor = workspace.monitor
      if (root.screenName && monitor && String(monitor.name || "") !== root.screenName) continue

      ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  // A wheel notch moves one entry along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    // Holds at either end rather than wrapping, so a touchpad swipe that runs
    // long stops on the last workspace.
    var ids = root.workspaceIds()
    var index = ids.indexOf(root.activeWorkspaceId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  // The workspace each monitor shows carries its layout: a square tiles, a
  // circle scrolls, and a triangle floats. Clicking it cycles to the next one,
  // as Super + L does.
  property string activeMode: "dwindle"
  property bool modeStale: false

  function modeGlyph(mode) {
    if (mode === "scrolling") return "󰝥"
    if (mode === "floating") return "󰔶"
    return "󱓻"
  }

  // A layout only changes through the layout commands, which ask for a refresh,
  // or a config reload, so each workspace's mode is read once and cached rather
  // than running the script on every workspace switch.
  property var modeCache: ({})
  property int modeGeneration: 0
  property int modeProcWorkspace: -1
  property int modeProcGeneration: 0

  function showActiveMode() {
    var mode = root.modeCache[root.activeWorkspaceId()]
    if (mode !== undefined) root.activeMode = mode
    else readMode()
  }

  function readMode() {
    if (modeProc.running) {
      root.modeStale = true
      return
    }
    var id = root.activeWorkspaceId()
    if (id === -1) return
    root.modeProcWorkspace = id
    root.modeProcGeneration = root.modeGeneration
    modeProc.command = ["omarchy-hyprland-workspace-layout-current", String(id)]
    modeProc.running = true
  }

  function refresh() {
    root.modeCache = ({})
    root.modeGeneration++
    readMode()
  }

  // The layout commands act on the focused workspace, so a click on another
  // monitor's bar focuses that monitor first.
  function cycleLayout() {
    if (!root.bar) return
    var command = "omarchy-hyprland-workspace-layout-toggle"
    if (root.monitor && !root.monitor.focused) {
      command = "hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ monitor = \"" + root.monitorName + "\" })") + " >/dev/null && " + command
    }
    root.bar.run(command)
  }

  Component.onCompleted: refresh()
  onMonitorChanged: root.showActiveMode()

  Connections {
    target: root.monitor
    function onActiveWorkspaceChanged() { root.showActiveMode() }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "configreloaded") root.refresh()
      // Quickshell credits every workspace switch to the focused monitor, as
      // the event doesn't say which one switched, and misses the workspace a
      // monitor falls back to when its own is moved away. Moving workspaces
      // between monitors switches the others, so ask Hyprland for the truth.
      // A workspace that changes number is only learned by asking too. Every
      // bar shares what Hyprland answers, so one asks after a plain switch.
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  Process {
    id: modeProc
    stdout: StdioCollector {
      onStreamFinished: {
        var mode = text.trim()
        // A read that started before a refresh may predate the change.
        if (!mode || root.modeProcGeneration !== root.modeGeneration) return
        root.modeCache[root.modeProcWorkspace] = mode
        if (root.modeProcWorkspace === root.activeWorkspaceId()) root.activeMode = mode
      }
    }
    onExited: {
      if (!root.modeStale) return
      root.modeStale = false
      // Deferred: the process still reports running while it signals exit.
      Qt.callLater(root.showActiveMode)
    }
  }

  // Super + L and the default layout change the mode without a focus change,
  // so they ask every bar to read it again. The layout scripts call the
  // first-party target name, which this widget answers in place of
  // omarchy.workspaces; an IPC target routes to one instance, so it relays
  // the refresh to the widget on every other monitor's bar.
  ShellIpc {
    target: "omarchy.workspaces"

    function refresh(): void { root.broadcast("refresh") }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        // The workspace this bar's monitor shows, whichever monitor has focus.
        readonly property bool shown: root.monitor !== null && root.monitor.activeWorkspace !== null && root.monitor.activeWorkspace.id === modelData

        bar: root.bar
        text: shown ? root.modeGlyph(root.activeMode) : String(modelData)
        opacity: occupied || shown ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() {
          if (shown) root.cycleLayout()
          else root.focusWorkspace(modelData)
        }
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
      }
    }
  }
}
