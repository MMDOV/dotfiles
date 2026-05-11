-- Define terminal tag to style them uniformly
hl.window_rule({ tag = "+terminal", match = { class = "(Alacritty|kitty|com.mitchellh.ghostty|foot)" } })
hl.window_rule({ opacity = "1 0.9", match = { tag = "terminal" } })
