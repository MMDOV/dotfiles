hl.window_rule({
	match = {
		class = "([Oo]verwatch|[Ll]utris|[Bb]attle.net(.exe)?|[Hh]earthstone(.exe)?|[Bb]alatro(.exe)?|[Tt]he [Bb]azaar)",
	},
	workspace = "1 silent",
	opacity = "1",
	tile = true,
})
hl.window_rule({ match = { class = "hearthstone deck tracker.exe" }, float = true, no_blur = true })
hl.window_rule({ match = { class = "ArenaTracker" }, float = true })
