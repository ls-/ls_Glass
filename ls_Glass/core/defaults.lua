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
		tooltips = true,
		smooth = true,
		fade = {
			enabled = true, -- if disabled, messages don't fade out
			click = false,
			out_delay = 60,
		},
		buttons = {
			up_and_down = false,
		},
		[ 1] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 2] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 3] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 4] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 5] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 6] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 7] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 8] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[ 9] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
		[10] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 12,
				shadow = true,
				outline = false,
			},
		},
	},
	dock = { -- tabs & buttons
		alpha = 0.8,
		-- font = {
		-- 	size = 12,
		-- 	shadow = true,
		-- 	outline = false,
		-- },
		buttons = {
			position = "left", -- "right",
		},
		fade = {
			enabled = true,
		},
		toasts = {
			enabled = true,
		},
	},
	edit = {
		alpha = 0.8,
		position = "bottom", -- "top"
		offset = 32,
		font = {
			size = 12,
			shadow = true,
			outline = false,
		},
	},
}
