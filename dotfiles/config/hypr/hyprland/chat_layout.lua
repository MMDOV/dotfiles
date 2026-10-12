-- TeamSpeak gets a slim column and Vesktop the rest of workspace 5.
-- Vesktop maps a splash window first and swaps it for the real one when it
-- finishes loading (or never does), so the split is re-applied on every
-- open/title change instead of once at startup.
local WORKSPACE = 5
local TS_SHARE = 0.35

local function is_ts(w)
	return w.class == "teamspeak-client" or w.class == "TeamSpeak 3"
end

local function component(v, i, key)
	return v[key] or v[i]
end

local swaps = 0

local balance
function balance()
	local ts, vk
	for _, w in ipairs(hl.get_workspace_windows(WORKSPACE)) do
		if w.mapped and not w.floating then
			if is_ts(w) then
				ts = w
			elseif w.class == "vesktop" then
				vk = w
			end
		end
	end
	if not (ts and vk) then
		return
	end

	-- TeamSpeak lives on the left; whichever app opened last lands on the right.
	if component(ts.at, 1, "x") > component(vk.at, 1, "x") and swaps < 2 then
		swaps = swaps + 1
		hl.dispatch(hl.dsp.window.swap({ target = "address:" .. vk.address, window = "address:" .. ts.address }))
		balance()
		return
	end

	swaps = 0

	local tw, vw = component(ts.size, 1, "x"), component(vk.size, 1, "x")
	local gap = component(vk.at, 1, "x") - (component(ts.at, 1, "x") + tw)
	local total = tw + vw + gap
	if math.abs(tw / total - TS_SHARE) < 0.02 then
		return
	end
	hl.dispatch(hl.dsp.window.resize({
		x = math.floor(total * TS_SHARE + 0.5),
		y = component(ts.size, 2, "y"),
		exact = true,
		window = "address:" .. ts.address,
	}))
end

local function watch(w)
	if w and (is_ts(w) or w.class == "vesktop") then
		balance()
	end
end

hl.on("window.open", watch)
hl.on("window.title", watch)
