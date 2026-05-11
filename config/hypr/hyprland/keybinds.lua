local mainMod = "SUPER"
-- Terminal
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("uwsm app -- foot"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app -- foot"))

-- App launcher
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("walker"))

-- Brighntess keybind
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("$HOME/personal/scripts/switch_backlight.sh"))

-- Screenshot
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("$HOME/.config/hypr/hyprland/scripts/screenshot_fullscreen.sh"))
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd("uwsm app -- $HOME/.config/hypr/hyprland/scripts/screenshot_area.sh")
)

-- Clipboard history
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd("uwsm app -- pkill fuzzel || cliphist list | walker -d | cliphist decode | wl-copy")
)

-- Color picker
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("uwsm app -- hyprpicker -a"))

-- Session
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill waybar ; waybar &"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("$HOME/personal/scripts/montior_toggle.sh"))

require("hyprland.keybinds.windows")
require("hyprland.keybinds.laptop")
require("hyprland.keybinds.playback")
require("hyprland.keybinds.apps")
