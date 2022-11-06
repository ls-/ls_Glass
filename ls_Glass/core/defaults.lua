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
	width = 448,
	height = 256,
	chat = {
		mouseover = true,
		hold_time = 10,
		opacity = 0.4,
		padding = 2,
		size = 12,
		slide_in_duration = 0.3,
		fade_in_duration = 0.6,
		fade_out_duration = 0.6,
	},
	dock = {
		alpha = 0.8,
	},

	indented_word_wrap = true,
	mouseover_tooltips = true,

	-- OLD
	-- General
	font = "Friz Quadrata TT",
	fontFlags = "",
	frameWidth = 450,
	frameHeight = 230,
	positionAnchor = {
		point = "BOTTOMLEFT",
		xOfs = 20,
		yOfs = 230
	},

	-- Edit box
	editBoxFontSize = 12,
	editBoxBackgroundOpacity = 0.6,
	editBoxAnchor = {
		position = "BELOW",
		yOfs = -5
	},

	-- Messages
	messageFontSize = 12,
	chatBackgroundOpacity = 0.4,
	messageLeading = 3,
	messageLinePadding = 0.25,

	chatHoldTime = 10,
	chatShowOnMouseOver = true,
	chatFadeInDuration = 0.6,
	chatFadeOutDuration = 0.6,
	chatSlideInDuration = 0.3,

	indentWordWrap = true,
	mouseOverTooltips = true,
	iconTextureYOffset = 4,
}
