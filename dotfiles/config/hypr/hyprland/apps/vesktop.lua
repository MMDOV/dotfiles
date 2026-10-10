hl.window_rule({ match = { class = "vesktop" }, workspace = "5 silent" })
-- Vesktop fades its own background (Quick CSS from `look`, with its
-- `transparent` setting on), same idea as Konsole: blur, no window-wide fade.
hl.window_rule({
	match = { class = "^vesktop$" },
	opacity = "opacity 1.0 override 1.0 override",
	no_blur = false,
})
