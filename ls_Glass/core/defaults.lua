local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local function rgb(r, g, b)
	return E:CreateColor(r, g, b)
end

D.global = {
	colors = {
		lanzones = rgb(224, 188, 91)
	},
}

D.profile = {
	font = LibStub("LibSharedMedia-3.0"):GetDefault("font"), -- "Friz Quadrata TT"
	chat = {
		alpha = 0.4,
		tooltips = true,
		slide_in_duration = 0.3,
		font = {
			size = 12,
			shadow = true,
			outline = false,
		},
		fade = {
			-- enabled = true, -- * hardcoded
			persistent = false, -- messages can fade in, but don't fade out
			in_duration = 0.6,
			out_delay = 10,
			out_duration = 0.6,
		},
	},
	dock = { -- and edit boxes
		alpha = 0.8,
		font = {
			size = 12,
			shadow = true,
			outline = false,
		},
		fade = {
			enabled = true,
			-- in_duration = 0.1, -- * hardcoded
			-- out_delay = 4, -- * hardcoded
			out_duration = 0.6,
		},
	},
}
