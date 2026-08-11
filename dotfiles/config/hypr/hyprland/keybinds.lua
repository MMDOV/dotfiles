local mainMod = "SUPER"
local hyprlandPath = "$HOME/.config/hypr/hyprland/"
-- Terminal
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("uwsm app -- konsole -e tmux a"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app -- konsole"))

-- App launcher
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("walker"))

-- Screenshot
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(hyprlandPath .. "scripts/screenshot_fullscreen.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(hyprlandPath .. "scripts/screenshot_area.sh"))

-- Clipboard history
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd("uwsm app -- pkill fuzzel || cliphist list | walker -d | cliphist decode | wl-copy")
)

-- Color picker
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("uwsm app -- hyprpicker -a"))

-- Session
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("systemctl --user restart --now waybar.service"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(hyprlandPath .. "scripts/montior_toggle.sh"))

require("hyprland.keybinds.windows")
require("hyprland.keybinds.media")
require("hyprland.keybinds.playback")
require("hyprland.keybinds.apps")

-- Hardware-dependent binds. facts.lua is generated per machine by
-- scripts/utils/facts.sh --write-lua; if it is missing, fall back to loading
-- them, since a missing keybind is a better failure than a missing file
-- silently disabling working hardware.
local ok, facts = pcall(require, "hyprland.facts")
if not ok or facts.has_backlight then
	require("hyprland.keybinds.backlight")
end
