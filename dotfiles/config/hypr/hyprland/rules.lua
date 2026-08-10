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

hl.window_rule({
	name = "force-tile-special",
	tile = true,
	match = { workspace = "special" },
})

require("hyprland.apps")
