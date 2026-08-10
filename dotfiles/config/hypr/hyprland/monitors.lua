-- Monitor declarations.
--
-- Connector names (eDP-1, HDMI-A-1, DP-2) are a property of the machine and
-- the port a cable happens to be in, so they cannot be shared between systems.
-- Displays are therefore matched on their EDID description instead, which
-- follows the physical panel across machines, ports and cable swaps. Get the
-- string for a new display from `hyprctl monitors`.
--
-- Physical arrangement — which panel sits left of which, and rotation — is the
-- one thing no API can infer, so it stays declared here. Keying it on the
-- monitor rather than on a hostname means a docked laptop and a desktop
-- sharing a display both get the right layout with no per-machine branching.
--
-- Workspace placement is NOT here; see roles.lua, which assigns it from
-- whatever is actually connected at the time.

-- Fallback for anything not named below. Declared first so an unknown machine
-- still comes up with a usable desktop rather than a broken session; without
-- it, a display with no matching rule gets no configuration at all.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

-- Laptop internal panel.
hl.monitor({
	output = "desc:BOE 0x0703",
	mode = "1920x1080@60",
	position = "1440x0",
	scale = 1,
	-- Fullscreen-only adaptive sync. Set per-monitor rather than globally via
	-- misc.vrr, because VRR support is a property of the panel: a monitor that
	-- flickers under always-on VRR should not force the setting on the others.
	-- Mode 2 is the documented fullscreen-only value. CachyOS's own dots ship
	-- mode 3, but its semantics are not documented in the wiki and could not be
	-- confirmed, so it is deliberately not used here.
	vrr = 2,
})

-- External ASUS VW199.
hl.monitor({
	output = "desc:Ancor Communications Inc ASUS VW199 C6LMTF021677",
	mode = "preferred",
	position = "0x0",
	scale = 1,
	vrr = 2,
})
