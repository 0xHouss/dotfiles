import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
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

  // Persistent workspaces per monitor, mirroring the old waybar
  // `persistent-workspaces` block. This has to agree with the workspace_rule
  // pinning in hypr/hyprland.lua, which is what actually sends new workspaces
  // to the right screen — this list only decides what the bar draws.
  // Monitors that are not listed fall back to showing all ten.
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
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: focused ? "󱓻" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
