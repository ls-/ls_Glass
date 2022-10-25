local _, ns = ...

-- Mine
local C, D = {}, {}
ns.C, ns.D = C, D

-- Lua
local _G = getfenv(0)

D.profile = {
	width = 448,
	height = 256,


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
