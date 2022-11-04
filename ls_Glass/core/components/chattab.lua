local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local _, Constants = unpack(select(2, ...))
local Colors = Constants.COLORS

local function chatTabText_SetTextColor(self, r, g, b)
	if r == NORMAL_FONT_COLOR.r and g == NORMAL_FONT_COLOR.g and b == NORMAL_FONT_COLOR.b then
		self:SetTextColor(Colors.apache.r, Colors.apache.g, Colors.apache.b) -- TODO: Move to config!
	end
end

local hookedChatTabs = {}

local CHAT_TAB_TEXTURES = {
	"Left",
	"Middle",
	"Right",

	"ActiveLeft",
	"ActiveMiddle",
	"ActiveRight",

	"HighlightLeft",
	"HighlightMiddle",
	"HighlightRight",
}

function E:HandleChatTab(frame)
	for _, texture in ipairs(CHAT_TAB_TEXTURES) do
		frame[texture]:SetTexture(0)
	end

	-- frame:SetHeight(C.db.profile.tab.size + 4)

	-- frame:SetNormalFontObject("GameFontNormal") -- TODO: Fix me!
	-- frame.Text:SetJustifyH("LEFT")
	-- frame.Text:SetJustifyV("MIDDLE")
	-- frame.Text:SetPoint("TOPLEFT", 2, -2)
	-- frame.Text:SetPoint("BOTTOMRIGHT", -2, 2)

	if not hookedChatTabs[frame] then
		hooksecurefunc(frame.Text, "SetTextColor", chatTabText_SetTextColor)

		hookedChatTabs[frame] = true
	end

	-- reset the tab
	if not frame.selectedColorTable then
		frame.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
end
