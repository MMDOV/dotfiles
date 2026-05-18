local mainMod = "SUPER"

-- Youtube music
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("playerctl next -p vivaldi"), { locked = true })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause -p vivaldi"), { locked = true })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("playerctl previous -p vivaldi"), { locked = true })

-- Spotify
-- hl.bind(mainMod .. " + N",  hl.dsp.exec_cmd("playerctl next -p spotify"),       { locked = true })
-- hl.bind(mainMod .. " + P",  hl.dsp.exec_cmd("playerctl play-pause -p spotify"), { locked = true })
-- hl.bind(mainMod .. " + B",  hl.dsp.exec_cmd("playerctl previous -p spotify"),   { locked = true })

-- General
hl.bind(
	mainMod .. " + SHIFT + N",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl next -p'"),
	{ locked = true }
)
hl.bind(
	mainMod .. " + SHIFT + P",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl play-pause -p'"),
	{ locked = true }
)
hl.bind(
	mainMod .. " + SHIFT + B",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl previous -p'"),
	{ locked = true }
)
