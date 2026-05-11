-- MONITOR CONFIG
hl.monitor({
	output = "HDMI-A-1",
	mode = "1440x900@75",
	position = "0x0",
	scale = "1",
})

-- 2. THE RIGHT "MAIN" (Laptop)
-- Position: 1440x0 (Immediately to the right of the external)
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "1440x0",
	scale = "1",
})

-- Variables
local activeBorderColor = { colors = { "rgba(589ED7ee)", "rgba(0DB9D7ee)" }, angle = 45 }
local inactiveBorderColor = "rgba(595959aa)"

hl.config({
	input = {
		kb_layout = "us",
		kb_options = "caps:escape",
		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 35,
		accel_profile = "flat",
		sensitivity = -0.5,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			scroll_factor = 0.5,
		},
		follow_mouse = 1,
	},

	binds = {
		scroll_event_delay = 0,
	},
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
	dwindle = {
		preserve_split = true,
		force_split = 2,
		smart_split = false,
		smart_resizing = false,
	},
	general = {
		gaps_in = 5,
		gaps_out = 10,

		border_size = 2,

		resize_on_border = false,

		allow_tearing = false,

		layout = "dwindle",
		col = {
			active_border = activeBorderColor,
			inactive_border = inactiveBorderColor,
		},
	},
	decoration = {
		rounding = 0,
		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			special = true,
			brightness = 0.60,
			contrast = 0.75,
		},
	},
	group = {
		col = {
			border_active = activeBorderColor,
			border_inactive = inactiveBorderColor,
		},

		groupbar = {
			col = {
				active = "rgba(00000040)",
				inactive = "rgba(00000020)",
			},
			font_size = 12,
			font_family = "monospace",
			font_weight_active = "ultraheavy",
			font_weight_inactive = "normal",
			text_color = "rgb(ffffff)",
			text_color_inactive = "rgba(ffffff90)",

			indicator_height = 0,
			indicator_gap = 5,
			height = 22,
			gaps_in = 5,
			gaps_out = 0,

			gradients = true,
			gradient_rounding = 0,
			gradient_round_only_edges = false,
		},
	},
	animations = {
		enabled = true,
	},
	misc = {
		disable_splash_rendering = true,
		focus_on_activate = false,
		anr_missed_pings = 3,
		vrr = 1,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot | kitty | allacritty | Alacritty | ghostty | Ghostty)",

		disable_hyprland_logo = true,
		force_default_wallpaper = 0,

		allow_session_lock_restore = true,

		initial_workspace_tracking = 0,
	},
	cursor = {
		hide_on_key_press = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })

hl.animation({ leaf = "workspaces", enabled = false, speed = 0, bezier = "ease" })
