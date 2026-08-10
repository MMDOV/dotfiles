-- Screen brightness.
--
-- Loaded only when the machine actually exposes a backlight device under
-- /sys/class/backlight. That is the real precondition — brightnessctl has
-- nothing to act on without one — and it is narrower than "is this a laptop":
-- a desktop driving a DDC-capable monitor is a different mechanism entirely.

local hyprlandPath = "$HOME/.config/hypr/hyprland/"

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Toggle between minimum and full brightness.
hl.bind("SUPER + R", hl.dsp.exec_cmd(hyprlandPath .. "scripts/switch_backlight.sh"))
