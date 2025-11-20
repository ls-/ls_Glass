local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local function rgb(r, g, b)
	return E:CreateColor(r, g, b)
end

-- match LSM names to fonts in NumberFont_Shadow_Med
local function getDefaultFont()
	local locale = GetLocale()
	if locale == "koKR" then
		return "기본 글꼴"
	elseif locale == "zhCN" then
		return "聊天"
	elseif locale == "zhTW" then
		-- LSM doesn't include arheiuhk_bd.ttf, use similar looking bHEI01B.ttf instead
		return "聊天"
	else
		return "Arial Narrow"
	end
end

D.global = {
	colors = {
		lanzones = rgb(224, 188, 91)
	},
}

D.profile = {
	font = {
		name = getDefaultFont(),
		override = {
			roman = false,
			russian = false,
			korean = false,
			simplifiedchinese = false,
			traditionalchinese = false,
		},
	},
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
		["*"] = {
			alpha = 0.4,
			-- solid = false,
			x_padding = 8,
			y_padding = 0,
			font = {
				size = 14,
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
		multiline = false,
		alt = true,
		font = {
			size = 14,
			shadow = true,
			outline = false,
		},
	},
}
