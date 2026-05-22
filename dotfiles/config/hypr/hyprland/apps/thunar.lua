local width = 500
local height = 100
-- gap = 20

hl.window_rule({
	{ match = { title = "^(File Operation Progress)$" } },
	float = true,
	center = true,
	size = { width, height },
	pin = true,
	move = { "(monitor_w-500-20)", "(monitor_h-100-20)" },
})
hl.window_rule({
	{ match = { title = "^(Confirm to replace files)$" } },
	center = true,
})
