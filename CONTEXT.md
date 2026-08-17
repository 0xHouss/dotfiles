# Context

## The machine

An Omarchy laptop: Arch, Hyprland, `omarchy-shell` (quickshell) for the bar,
lock screen and menus, bash + starship, tmux, Neovim, yazi. Built-in display
`eDP-1`, external `HDMI-A-1`.

## The organizing idea: overrides, not configs

Omarchy ships complete defaults in `/usr/share/omarchy/default/` and loads the
user's files *after* them. Almost nothing here is a config from scratch — each
package is the delta on top of a working default, so package updates keep
improving the base. Two consequences worth holding onto:

- When something behaves unexpectedly, the cause may be a default that is
  simply never overridden here. Check `$OMARCHY_PATH/default/` before
  concluding a setting is missing.
- Replacing a default is usually an explicit *un*-set first: `hl.unbind` before
  rebinding a key, `unalias` before redefining an alias.

## Packages

**bash** — `.bashrc` sources Omarchy's rc through `$OMARCHY_PATH` (falling back
to `/usr/share/omarchy` when `/etc/omarchy.conf`, written by `omarchy-dev-link`,
is absent), then `~/.config/bash/rc`. That rc is the only fan-out point: it
sources `envs`, `shell`, `aliases`, `functions`, `init`, and binds `inputrc`.
Shell functions are one file per tool in `fns/`, all sourced by `functions`.

**hyprland** — Hyprland configured in Lua (migrated from `.conf` in `a64ca5c`).
`hyprland.lua` is the entry point: it runs Omarchy's bootstrap, loads the
defaults, then requires `monitors`, `input`, `bindings`, `looknfeel`,
`autostart`. Two globals are in scope — `hl` for raw Hyprland and `o` for
Omarchy helpers; `.luarc.json` points the language server at
`/usr/share/hypr/stubs` and declares both.

`omarchy_preinstalled_bindings = false` drops the shipped app and web-app
bindings, which is what frees bare `SUPER` for the apps in `bindings.lua`; core
window-manager bindings stay, so taking one of those keys means `hl.unbind`
first. Workspaces are pinned 1-5 to `eDP-1` and 6-10 to `HDMI-A-1`; that split
has to agree with the per-monitor map in the `houss.workspaces` plugin, which
only decides what the bar *draws*.

**omarchy** — `omarchy-shell` plugins, all clones of first-party ones made with
`omarchy-plugin-clone`. `omarchy/README.md` documents what each clone changes,
why cloning was the route, and why `shell.json` is deliberately not stowed —
read it before touching anything in this package. `.stow-local-ignore` keeps
that README and `shell.json.reference` out of `$HOME`.

**nvim** — lazy.nvim. `init.lua` requires `lua/config/`, which loads options,
lazy, keymaps, autocmds, usercmds; plugin specs are one file per plugin in
`lua/plugins/`. `matte-candy` in `colors/` is a standalone colorscheme, not a
plugin. `lazy-lock.json` is committed, so plugin versions move only in explicit
"update plugin lockfile" commits. `lua/config/remote_clipboard.lua` routes yanks
through OSC 52 so copies survive tmux and SSH.

**yazi** — plugins are vendored into `plugins/` with versions pinned in
`package.toml`. `jumplist.yazi` and `undo.yazi` are gitignored: they are
symlinks to local dev clones in `~/Work/yazi-plugins`.

**bin** — personal scripts stowed to `~/.local/bin`: `create-instant-note`
(dated note in the Obsidian vault, bound to `SUPER+SHIFT+N`) and `yt-download`.

**applications** — `.desktop` entries for web apps, each launched through
`omarchy-launch-webapp` with an icon from the sibling `icons/` folder. Entries
here exist so apps appear in the launcher; the keybound ones are separately
declared in `hyprland/.config/hypr/bindings.lua`.

**tmux**, **starship**, **user-dirs**, **hyprland-preview-share-picker** —
single-file packages. The share-picker stylesheet path is relative to its own
config file and reaches into the current Omarchy theme.

## Not currently stowed

`waybar/` and `backgrounds/` are tracked but not linked into `$HOME`. Waybar was
replaced by the `omarchy-shell` bar; its config survives as the reference for
what the bar used to do (and `houss.workspaces` exists to restore part of that
behaviour). Restowing either is a deliberate act, not a repair.
