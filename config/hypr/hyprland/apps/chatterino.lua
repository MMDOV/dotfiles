local chat_w = 335
local chat_h = 500

hl.window_rule({
	{ match = { class = "com.chatterino.chatterino" } },
	monitor = "eDP-1",
	float = true,
	center = true,
	size = { chat_w, chat_h },
	opacity = "1.0 override 1.0 override",
	move = { "(monitor_w-335-15)", "200" },
})
