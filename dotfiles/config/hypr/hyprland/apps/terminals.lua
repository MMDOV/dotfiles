-- Define terminal tag to style them uniformly
hl.window_rule({
	tag = "+terminal",
	match = { class = "(Alacritty|kitty|com.mitchellh.ghostty|foot|com.raggesilver.BlackBox)" },
})
hl.window_rule({ opacity = "1 0.9", match = { tag = "terminal" } })
hl.window_rule({ opacity = "0.97 0.9", match = { class = "com.raggesilver.BlackBox" } })
