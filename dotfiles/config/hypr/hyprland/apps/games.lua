hl.window_rule({
	match = {
		class = "([Oo]verwatch|(net.)?[Ll]utris(.[Ll]utris)?|[Bb]alatro(.exe)?|[Tt]he [Bb]azaar|(com.usebottles.)?[Bb]ottles)",
	},
	workspace = "1 silent",
	opacity = "1",
	tile = true,
})

hl.window_rule({
	match = { initial_class = "(hearthstone.exe)" },
	workspace = "1 silent",
	tile = true,
})

hl.window_rule({
	match = { initial_class = "(battle.net.exe)" },
	workspace = "1 silent",
	float = true,
})
hl.window_rule({
	match = { initial_class = "(battle.net.exe)", initial_title = "(Battle.net Login)" },
	workspace = "1 silent",
	float = true,
})

hl.window_rule({
	match = { initial_class = "(battle.net.exe)", initial_title = "(Battle.net)" },
	center = true,
	size = { 1100, 700 },
})

hl.window_rule({
	match = {
		initial_class = "(hearthstonedecktracker.exe)",
		initial_title = "(HearthstoneOverlay)",
	},
	workspace = "1 silent",
	float = true,
	no_focus = true,
	no_blur = true,
	border_size = 0,
})

hl.window_rule({
	match = {
		initial_class = "(hearthstonedecktracker.exe)",
		initial_title = "([Hh]earthstone [Dd]eck [Tt]racker)",
	},
	workspace = "8 silent",
	float = true,
	center = true,
	size = { 1100, 700 },
})

hl.window_rule({
	match = {
		initial_class = "(hearthstonedecktracker.exe)",
		initial_title = "(SplashScreenWindow)",
	},
	workspace = "8 silent",
	float = true,
})

hl.window_rule({ match = { class = "ArenaTracker" }, float = true })
hl.window_rule({ match = { class = "explorer.exe" }, float = true, size = { 162, 25 }, move = "10 40" })
