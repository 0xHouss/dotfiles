-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Apps ---------------------------------------------------------------------
o.bind("SUPER + B", "Browser", { launch = "zen-browser", focus = "Zen" })

hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })

-- File managers: Yazi in a terminal, Nautilus for the GUI.
o.bind("SUPER + E", "Yazi", { tui = "yazi" })
o.bind("SUPER + SHIFT + E", "Nautilus", { launch = "nautilus --new-window" })

-- Instant note replaces the editor on this key; the editor stays unbound.
hl.unbind("SUPER + SHIFT + N")
o.bind("SUPER + SHIFT + N", "Instant Note", {
  tui = (os.getenv("HOME") or "") .. "/.local/bin/create-instant-note",
})

o.bind("SUPER + D", "Discord", { launch = "vesktop", focus = "^vesktop$" })

hl.unbind("SUPER + O") -- Pop window out
o.bind("SUPER + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })

-- Bitwarden, on the key monitor scaling used to hold.
hl.unbind("SUPER + SLASH") -- Monitor scaling up
hl.unbind("SUPER + ALT + SLASH") -- Monitor scaling down
o.bind("SUPER + SLASH", "Passwords", { launch = "bitwarden-desktop" })

o.bind("SUPER + SHIFT + S", "SSH manager", { tui = "sshm" })

o.bind("CTRL + SHIFT + ESCAPE", "Activity", { tui = "btop" })

-- Web apps -----------------------------------------------------------------
o.bind("SUPER + A", "Claude", { webapp = "https://claude.ai", focus = true })

hl.unbind("SUPER + C") -- Universal copy
o.bind("SUPER + C", "Calendar", { webapp = "https://calendar.notion.so/", focus = true })

hl.unbind("SUPER + G") -- Toggle window grouping
o.bind("SUPER + G", "Email", { webapp = "https://mail.notion.so/", focus = true })

hl.unbind("SUPER + ALT + G") -- Move active window out of group
o.bind("SUPER + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

o.bind("SUPER + M", "Music", { webapp = "https://music.youtube.com/", focus = true })
o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/" })

hl.unbind("SUPER + X") -- Universal cut
o.bind("SUPER + X", "X", { webapp = "https://x.com/" })
o.bind("SUPER + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })

-- Menus --------------------------------------------------------------------
-- Swapped from the defaults: apps launcher on bare SUPER+SPACE, the full
-- Omarchy menu behind SUPER+ALT+SPACE.
hl.unbind("SUPER + SPACE") -- Omarchy menu
o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")

hl.unbind("SUPER + ALT + SPACE") -- Apps menu
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

-- System -------------------------------------------------------------------
hl.unbind("SUPER + L") -- Toggle workspace layout
o.bind("SUPER + L", "Lock screen", "omarchy-system-lock")

-- Media control without reaching for the media keys. F9 replaces the
-- voxtype push-to-talk binding; dictation is still on SUPER+CTRL+X.
hl.unbind("F9")
o.bind("F9", "Pause", "omarchy-shell media playPause", { locked = true })
o.bind("ALT + N", "Next track", "omarchy-shell media next", { locked = true })
o.bind("ALT + P", "Previous track", "omarchy-shell media previous", { locked = true })
