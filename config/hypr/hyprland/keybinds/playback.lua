local mainMod = "SUPER"

-- Youtube music
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("playerctl next -p chromium"), { locked = true })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause -p chromium"), { locked = true })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("playerctl previous -p chromium"), { locked = true })

-- Spotify
-- hl.bind(mainMod .. " + N",  hl.dsp.exec_cmd("playerctl next -p spotify"),       { locked = true })
-- hl.bind(mainMod .. " + P",  hl.dsp.exec_cmd("playerctl play-pause -p spotify"), { locked = true })
-- hl.bind(mainMod .. " + B",  hl.dsp.exec_cmd("playerctl previous -p spotify"),   { locked = true })

-- General
hl.bind(
	mainMod .. " + N",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl next -p'"),
	{ locked = true }
)
hl.bind(
	mainMod .. " + P",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl play-pause -p'"),
	{ locked = true }
)
hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'pkill fuzzel || playerctl -l | walker -d | xargs -r playerctl previous -p'"),
	{ locked = true }
)
