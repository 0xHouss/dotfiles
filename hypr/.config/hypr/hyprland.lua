-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false

-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Global workspaces, as before Omarchy 4.5: 1-5 on the built-in display, 6-10
-- on the external, and Super + N always means workspace N. The bar side of this
-- is the houss.workspaces plugin, whose per-monitor map has to match.
--
-- Omarchy 4.5 gives every monitor its own 1-10 instead (blocks of ten:
-- 1-10, 11-20, ...) in default/hypr/monitor-workspaces.lua, which can't be
-- turned off. Its hooks on start, config reload and monitor plug/unplug call
-- o.workspaces.reconcile, which renumbers workspaces into those blocks, so
-- stub it. The table functions are also what `hyprctl dispatch
-- 'o.workspaces.focus(1)'` callers reach, such as omarchy-hyprland-window-close-all.
o.workspaces.reconcile = function() end

o.workspaces.focus = function(workspace)
	return hl.dsp.focus({ workspace = tostring(workspace) })
end

o.workspaces.move_window = function(workspace, follow)
	return hl.dsp.window.move({ workspace = tostring(workspace), follow = follow ~= false })
end

o.workspaces.move_to_monitor = function(direction)
	return function()
		-- Hyprland reports a move toward no monitor as an error on screen.
		local target = hl.get_monitor(direction)
		if target then
			hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))
		end
	end
end

-- The default number keys were bound to per-monitor slots when Omarchy's
-- bindings loaded, so replacing the functions above doesn't reach them.
for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))
	o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, o.workspaces.move_window(workspace))
	o.rebind(
		"SUPER + SHIFT + ALT + " .. key,
		"Move window silently to workspace " .. workspace,
		o.workspaces.move_window(workspace, false)
	)
end

for direction, name in pairs({ l = "left", r = "right", u = "up", d = "down" }) do
	o.rebind(
		"SUPER + SHIFT + ALT + " .. name:upper(),
		"Move workspace to " .. name .. " monitor",
		o.workspaces.move_to_monitor(direction)
	)
end

for ws = 1, 5 do
	hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1", default = true })
end

for ws = 6, 10 do
	hl.workspace_rule({ workspace = tostring(ws), monitor = "HDMI-A-1", default = true })
end

-- The app workspaces live on the external display too. No default = true, so
-- they don't compete with 6-10 for being that monitor's starting workspace.
for ws = 11, 13 do
	hl.workspace_rule({ workspace = tostring(ws), monitor = "HDMI-A-1" })
end

-- Send specific apps to their own workspace.
o.window("^(zen)$", { workspace = "11" })
o.window("^(vesktop)$", { workspace = "12" })
o.window("^(chrome-music.youtube.com__-Default)$", { workspace = "13" })
