local width = 453
local height = 268
-- gap = 20

hl.window_rule({
	{ match = { title = "^(.*)([Cc]opying|[Mm]oving|[Cc]reating)(.*)$", class = "org.kde.dolphin" } },
	float = true,
	center = true,
	size = { width, height },
	pin = true,
	move = { "(monitor_w-453-20)", "(monitor_h-268-20)" },
})
