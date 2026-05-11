-- Float Steam
hl.window_rule({
	match = { class = "steam" },
	float = true,
	opacity = "1 1",
	workspace = "1",
	idle_inhibit = "fullscreen",
})
hl.window_rule({ match = { class = "steam", title = "Steam" }, center = true, size = { 1100, 700 } })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })

hl.window_rule({ match = { class = "^(steam_app_[0-9]+)$" }, workspace = "1 silent" })
hl.window_rule({ match = { class = "ArenaTracker" }, workspace = "1 silent" })
