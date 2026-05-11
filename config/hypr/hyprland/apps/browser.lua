-- Only a subtle opacity change, but not for video sites
hl.window_rule({
	opacity = "1 override 0.97 override",
	tile = true,
	workspace = "2 silent",
	match = { class = "(Vivaldi-stable|chromium|zen|Vivaldi-snapshot)" },
})

-- music is on 6 dont question it
hl.window_rule({ workspace = "6 silent", match = { initial_title = "(YouTube Music)" } })
hl.window_rule({ workspace = "6 silent", match = { initial_title = "^(music.youtube.com_/)(.*)$" } })
hl.window_rule({ workspace = "6 silent", match = { initial_title = "^(desktop.melodify.app)(.*)$" } })
