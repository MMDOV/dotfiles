-- Konsole fades its own background (Opacity in the Look color scheme), so the
-- text stays solid. Undo the window-wide fade from rules.lua and let it blur
-- what is behind it instead.
hl.window_rule({
	match = { class = "^org\\.kde\\.konsole$" },
	opacity = "opacity 1.0 override 1.0 override",
	no_blur = false,
})
