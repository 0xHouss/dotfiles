-- Personal keybindings.
--
-- Omarchy's preinstalled app/web app bindings are turned off in
-- hyprland.lua (omarchy_preinstalled_bindings = false), so apps live on
-- bare SUPER here instead of the SUPER+SHIFT tier. Core window-manager
-- bindings are untouched except where unbound below.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Terminals ----------------------------------------------------------------
-- SUPER+RETURN (Terminal) is a core binding and stays as-is.
o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })

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

-- System -------------------------------------------------------------------
hl.unbind("SUPER + L") -- Toggle workspace layout
o.bind("SUPER + L", "Lock screen", "omarchy-system-lock")

-- Media control without reaching for the media keys. F9 replaces the
-- voxtype push-to-talk binding; dictation is still on SUPER+CTRL+X.
hl.unbind("F9")
o.bind("F9", "Pause", "omarchy-shell media playPause", { locked = true })
o.bind("ALT + N", "Next track", "omarchy-shell media next", { locked = true })
o.bind("ALT + P", "Previous track", "omarchy-shell media previous", { locked = true })
