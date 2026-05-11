local width = 524
local height = 246
-- gap = 20

hl.window_rule({
	{ match = { class = "zenity" } },
	center = true,
	size = { width, height },
	pin = true,
	move = { "(monitor_w-524-20)", "(monitor_h-246-20)" },
})
