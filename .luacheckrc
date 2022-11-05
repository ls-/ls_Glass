std = "none"
max_line_length = false
max_comment_line_length = 80
self = false

exclude_files = {
	".luacheckrc",
	"ls_Glass/embeds/",
}

ignore = {
	"111/LS.*", -- Setting an undefined global variable starting with SLASH_
	"111/SLASH_.*", -- Setting an undefined global variable starting with SLASH_
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"122", -- Setting a read-only field of a global variable
	"211/_G", -- Unused local variable _G
	"211/C", -- Unused local variable C
	"211/D", -- Unused local variable D
	"211/E", -- Unused local variable E
	"211/L", -- Unused local variable L
	"432", -- Shadowing an upvalue argument
}

globals = {
	-- Lua
	"getfenv",
	"print",
}

read_globals = {
	-- AddOns
	"LibStub",

	-- FrameXML
	"BattlePetTooltip",
	"BattlePetToolTip_ShowLink",
	"ChatFrame1",
	"ChatFrame1EditBox",
	"ChatFrame2",
	"Clamp",
	"ColorMixin",
	"CreateObjectPool",
	"GameTooltip",
	"GeneralDockManager",
	"Mixin",
	"NORMAL_FONT_COLOR",
	"NUM_CHAT_WINDOWS",
	"UIParent",

	-- Namespace
	"LinkUtil",

	-- API
	"CreateFrame",
	"GetAddOnMetadata",
	"GetCVar",
}
