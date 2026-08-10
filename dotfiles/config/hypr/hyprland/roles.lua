-- Monitor roles and workspace placement.
--
-- Workspace rules used to name connectors directly (eDP-1, HDMI-A-1), so all
-- ten of them silently stopped applying on any other machine. Here the roles
-- are resolved from whatever is actually connected, and the rules are
-- generated from those roles.
--
-- Roles are recomputed on hotplug as well as at startup, so docking,
-- undocking and plugging in a TV all land correctly without a reload.

local M = {}

-- Workspaces 1..PRIMARY_COUNT live on the primary display; the rest are spread
-- across the others. With a single display everything collapses onto it.
local PRIMARY_COUNT = 3
local TOTAL = 10
local DEFAULT_WORKSPACE = 3

local function is_internal(name)
	return name:match("^eDP") ~= nil or name:match("^LVDS") ~= nil
end

-- Ranking for external displays: refresh rate first, then pixel area.
local function better(a, b)
	if a.refreshRate ~= b.refreshRate then
		return a.refreshRate > b.refreshRate
	end
	return (a.width * a.height) > (b.width * b.height)
end

-- Returns the primary monitor and a ranked list of the others, or nil when no
-- monitors are reported.
function M.resolve()
	local ok, monitors = pcall(hl.get_monitors)
	if not ok or type(monitors) ~= "table" then
		return nil, {}
	end

	local active = {}
	for _, m in ipairs(monitors) do
		if not m.disabled then
			table.insert(active, m)
		end
	end
	if #active == 0 then
		return nil, {}
	end

	-- The built-in panel wins when present: it is the display guaranteed to
	-- exist on a laptop, so the default workspace stays reachable even with
	-- everything unplugged. Otherwise take the best external.
	local primary
	for _, m in ipairs(active) do
		if is_internal(m.name) then
			primary = m
			break
		end
	end
	if not primary then
		for _, m in ipairs(active) do
			if not primary or better(m, primary) then
				primary = m
			end
		end
	end

	local rest = {}
	for _, m in ipairs(active) do
		if m.name ~= primary.name then
			table.insert(rest, m)
		end
	end
	table.sort(rest, better)

	return primary, rest
end

-- (Re)apply workspace placement for the current set of monitors.
function M.apply()
	local primary, rest = M.resolve()
	if not primary then
		-- Nothing enumerated yet. Not an error: the hotplug hooks below will
		-- call back once outputs appear.
		return false
	end

	for ws = 1, TOTAL do
		local target
		if ws <= PRIMARY_COUNT or #rest == 0 then
			target = primary.name
		else
			-- Round-robin across the secondaries so a third display is used
			-- instead of ignored.
			local idx = ((ws - PRIMARY_COUNT - 1) % #rest) + 1
			target = rest[idx].name
		end

		hl.workspace_rule({
			workspace = tostring(ws),
			monitor = target,
			default = (ws == DEFAULT_WORKSPACE),
		})
	end

	return true
end

M.apply()

-- Whether hl.get_monitors() is populated this early in config evaluation is
-- not guaranteed, so re-resolve whenever the output set changes. This is also
-- what makes hotplug work at all.
hl.on("monitor.added", function()
	M.apply()
end)

hl.on("monitor.removed", function()
	M.apply()
end)

return M
