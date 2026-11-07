# omarchy

Omarchy shell customizations.

## `houss.lock`

A clone of the first-party `omarchy.lock` plugin, created with
`omarchy-plugin-clone omarchy.lock`, that:

- restores the old hyprlock look (date, clock, avatar, name, greeting,
  battery icon), scaled from the 1080px-tall design to whatever the lock
  surface actually is — this display is 1920x1080 at scale 1.6, so the
  surface is 675 logical pixels tall
- keeps its assets, `pfp.png` and `battery-status`, in this folder and
  resolves them with `Qt.resolvedUrl`, so the plugin is self-contained and
  survives being moved or restowed
- keeps the display lit for the whole lock, by never arming the
  `idleBlankTimer` that the stock plugin uses to run
  `omarchy-brightness-display off` five seconds in (fifteen after a resume);
  `armBlankTimer(delayMs)` only stops the timer. With no blank, the
  fingerprint reader is never paused either

`Service.qml` differs from upstream only by `armBlankTimer`, and `LockView.qml`
only by the additions above plus the input field's `innerColor` and
`radius: 8`. `FingerprintModel.js` is byte-identical to upstream (last synced
with Omarchy 4.5.0) and must sit beside `Service.qml`, which imports it
relatively. Upstream's `poster.sh` is not copied: `Service.qml` runs it from
`$OMARCHY_PATH/shell/plugins/lock/`. The manifest drops upstream's
`capabilities`, which only first-party plugins get; the clone inherits them
through `clonedFrom`.

Cloning means upstream fixes to the lock screen do not arrive automatically,
and `omarchy-plugin-update` cannot pull them in: it only updates plugins that
are git checkouts. After an `omarchy` package upgrade, diff each clone against
its source in `/usr/share/omarchy/shell/plugins/` and carry the changes over
by hand.

## `houss.workspaces`

A clone of the first-party `omarchy.workspaces` bar widget that restores the
old waybar behaviour:

- workspaces 1-10 are always drawn, occupied or not
- workspace 10 is labelled `10`, not `0`
- each bar shows only its own monitor's set — eDP-1 gets 1-5, HDMI-A-1 gets
  6-10 — like waybar's `persistent-workspaces` with `all-outputs: false`

The per-monitor map is in `Workspaces.qml` and has to agree with the
`workspace_rule` pinning in `hypr/hyprland.lua`, which is what actually sends
new workspaces to the right screen. Unlisted monitors fall back to all ten.

## `houss.tailscale`

A clone of `omarchy.tailscale` whose only change is `accountLabel` in
`Model.js`. Tailscale defaults a profile's nickname to the login it was
created with, so one identity belonging to two tailnets produces two rows
labelled identically in the panel's CONNECTIONS section. The label now falls
back to the tailnet unless a nickname was actually customised.

Every other file is byte-identical to upstream (last synced with
Omarchy 4.5.0), so an upstream change to them can be copied over as is.
Upstream's `accountLabel` takes a translator argument since 4.5; the fork
keeps it and only changes the fallback order.

## `houss.bluetooth`

A clone of `omarchy.bluetooth` that fixes turning Bluetooth back on, on this
Dell. `omarchy-bluetooth-power off` blocks every Bluetooth rfkill, including
the `dell-bluetooth` platform switch, and the firmware answers by cutting
power to the USB module. The adapter then leaves BlueZ, and the stock widget
hides itself with no way back on (upstream basecamp/omarchy#7936).

- `bluetooth-power` turns off by blocking only the `hci*` rfkills, so the
  module stays on the bus and BlueZ just reports `Powered: no`. systemd-rfkill
  saves hci0's block under its own path, so "off" still survives a reboot.
  On still goes through `omarchy-bluetooth-power on`.
- `Panel.qml` treats a missing adapter as "off" instead of "no hardware": the
  widget and switch stay visible and the toggle sends `on`. That covers a
  type-wide block set by anything else.

`Model.js` is byte-identical to upstream (last synced with Omarchy 4.0.4).

## `houss.menu`

A clone of `omarchy.menu`, the Omarchy command menu. Since it declares
`clonedFrom: omarchy.menu`, `omarchy-menu` and every other call that targets
`omarchy.menu` open it instead of the stock one. Only `Menu.qml` changes, in
two ways:

- an `ssh` provider lists every concrete `Host` in `~/.ssh/config` (wildcard
  patterns skipped) through `bin/ssh-hosts`, and picking one opens a terminal
  running `bin/ssh-connect <host>`. The script sources `~/.config/bash/envs`
  when `SSH_AUTH_SOCK` is unset, because the shell's environment lacks the
  agent socket that the bash config exports, and it keeps the window open when
  ssh fails. The submenu itself is the `ssh` row in the tracked
  `extensions/omarchy-menu.jsonc`. The scripts are found through the
  manifest's `__sourceDir`, which the host passes to third-party plugins.
- it reads a second extension file,
  `~/.config/omarchy/extensions/omarchy-menu.local.jsonc`, merged after the
  tracked `omarchy-menu.jsonc` so its ids win. That file is a real file
  outside the repo, for personal entries (games, private hosts). It is
  handled like upstream's user file: the previous rows are kept while a write
  is half-finished, a missing file counts as loaded, the guard batch waits
  until all three menu files have loaded, and `refresh()` rereads it.

The fork used to carry its own `AppLibrary.qml` and `AppSearch.js` for the
Apps rows. They were dropped in the 4.5 sync because the host gives every
plugin whose manifest lists the `menu` kind an app library
(`pluginAppLibraryFor` in `shell/shell.qml`), and nothing gates it on trust.

Edits to the menu are not hot-reloaded, for the same reason as
`houss.workspaces`: the menu is `keepLoaded`, and
`omarchy-shell shell rescanPlugins` rebuilds it from the already-compiled
component. A change takes effect at the next omarchy-shell restart.

To resync after an upgrade, copy upstream's
`/usr/share/omarchy/shell/plugins/menu/` and put back the two changes above:
`BarWidget.qml` and `MenuModel.js` are byte-identical to upstream, and the
manifest differs only by id, name, author and `clonedFrom`. Last synced with
Omarchy 4.5.0.

## shell.json is deliberately not stowed

`omarchy-shell-config` rewrites `~/.config/omarchy/shell.json` with
`mv "$TMP" "$CONFIG_FILE"`. That atomic rename replaces a symlink with a
regular file, so a stowed `shell.json` would silently stop being used the
first time any `omarchy-plugin-*` or bar settings command ran.

`shell.json.reference` is a snapshot for rebuilding it by hand. On a new
machine, the plugin is wired up with:

    omarchy-plugin-clone omarchy.lock   # registers it and disables omarchy.lock

which writes the `plugins[]`, `disabledPlugins[]`, and `cloneSourceRestores[]`
entries itself. The `idle` block (screensaver 150s, lock 300s) is stock.
