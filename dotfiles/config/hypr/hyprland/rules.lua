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
-- Konsole fades its own background (Opacity in the Look color scheme), so the
-- text stays solid. Undo the window-wide fade above and let it blur what is
-- behind it instead.
hl.window_rule({
	match = { class = "^org\\.kde\\.konsole$" },
	opacity = "opacity 1.0 override 1.0 override",
	no_blur = false,
})
-- Vesktop fades its own background (Quick CSS from `look`, with its
-- `transparent` setting on), same idea as Konsole: blur, no window-wide fade.
hl.window_rule({
	match = { class = "^vesktop$" },
	opacity = "opacity 1.0 override 1.0 override",
	no_blur = false,
})
-- Notification cards and history (quickshell/notifd): blur what is behind them.
hl.layer_rule({ match = { namespace = "^notifd(-history)?$" }, blur = true, ignore_alpha = 0.2 })
-- Dolphin fades its own background through the translucent Kvantum `Look` theme
-- (same idea as Konsole); here it only needs blur and no window-wide fade.
hl.window_rule({
	match = { class = "^org\\.kde\\.dolphin$" },
	opacity = "opacity 1.0 override 1.0 override",
	no_blur = false,
})
-- rofi (launcher and dialogs) is translucent and blurs what is behind it.
hl.layer_rule({ match = { namespace = "^rofi$" }, blur = true, ignore_alpha = 0.1 })
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
