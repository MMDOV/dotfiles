-- Only a subtle opacity change, but not for video sites.
-- The global rule turns blur off; browsers get it back, so Zen's transparent
-- page and sidebar blur the wallpaper. Zen (zen-browser/desktop#7663) starts with
-- an unblurred sidebar unless the active opacity is just under 1.
hl.window_rule({
	opacity = "0.99999 override 0.9 override",
	no_blur = false,
	tile = true,
	workspace = "2 silent",
	match = { class = "(chromium|zen|([Vv]ivaldi)(.*))" },
})

-- music is on 6 dont question it
hl.window_rule({ workspace = "6 silent", match = { initial_title = "(YouTube Music)" } })
hl.window_rule({ workspace = "6 silent", match = { initial_title = "^(music.youtube.com_/)(.*)$" } })
hl.window_rule({ workspace = "6 silent", match = { initial_title = "^(desktop.melodify.app)(.*)$" } })
