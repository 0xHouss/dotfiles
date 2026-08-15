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
  `omarchy-brightness-display off` five seconds in

Cloning means upstream fixes to the lock screen do not arrive automatically;
`omarchy-plugin-update` is how you pull them in.

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
