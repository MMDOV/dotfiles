hl.window_rule({
	match = {
		class = "([Oo]verwatch|(net.)?[Ll]utris(.[Ll]utris)?|[Bb]attle.net(.exe)?|[Hh]earthstone(.exe)?|[Bb]alatro(.exe)?|[Tt]he [Bb]azaar|(com.usebottles.)?[Bb]ottles)",
	},
	workspace = "1 silent",
	opacity = "1",
	tile = true,
})

hl.window_rule({
	name = "hdt_overlay",
	match = {
		title = "^(Hearthstone Deck Tracker.*)$",
	},
	float = true,
	pin = false,
	no_focus = false,
	no_blur = true,
	border_size = 0,
})
hl.window_rule({ match = { class = "ArenaTracker" }, float = true })
hl.window_rule({ match = { class = "[Bb]attle.net(.exe)?" }, float = true })
hl.window_rule({ match = { title = "[Bb]attle.net(.exe)?" }, float = true })
