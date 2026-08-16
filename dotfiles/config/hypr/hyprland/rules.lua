-- ######## Default workspace ########
-- Workspace placement is resolved from the monitors actually connected.
-- See roles.lua; it also re-applies these on hotplug.
require("hyprland.roles")

-- ######## Window rules ########
hl.window_rule({
	match = { class = "^(.*)$" },
	opaque = false,
	no_blur = true,
	opacity = "opacity 0.97 override 0.9 override",
})
hl.window_rule({ match = { title = "^(Open File)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(Choose wallpaper)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(Library)(.*)$" }, center = true, float = true })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, center = true, float = true })

-- Keep tiling invisible; a restrained titlebar marks the floating layer and
-- gives it a familiar drag target without turning the desktop into a DE.
-- These are dynamic matches, so the bar appears/disappears when SUPER+W
-- changes a window's floating state.
-- The third rule looks redundant but is not: leaving fullscreen wipes the
-- plugin effect and only re-runs rules whose match touches `fullscreen`, so
-- without it a tiled window keeps the bar after tile -> fullscreen -> tile.
hl.window_rule({ match = { float = false }, ["hyprbars:no_bar"] = true })
hl.window_rule({ match = { fullscreen = true }, ["hyprbars:no_bar"] = true })
hl.window_rule({ match = { float = false, fullscreen = false }, ["hyprbars:no_bar"] = true })

hl.window_rule({
	name = "force-tile-special",
	tile = true,
	match = { workspace = "special" },
})

require("hyprland.apps")
