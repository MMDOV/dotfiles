-- Picture-in-picture overlays
hl.window_rule({ tag = "+pip", match = { title = "(Picture.?in.?[Pp]icture)" } })
hl.window_rule({
	match = { tag = "pip" },
	float = true,
	pin = true,
	size = { 600, 338 },
	keep_aspect_ratio = true,
	border_size = 0,
	opacity = "1 1",
	move = { "100%-w-40", "4%" },
})
