local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
local function chatTab_SetPoint(self, _, anchor, _, _, _, shouldIgnore)
	if anchor == GeneralDockManager.scrollFrame.child and not shouldIgnore then
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0, true)
	end
end

local function chatTabText_SetPoint(self, p, anchor, rP, x, _, shouldIgnore)
	if not shouldIgnore then
		self:SetPoint(p, anchor, rP, x, p == "CENTER" and 0 or -6, true)
	end
end

local function chatTabText_SetTextColor(self, r, g, b)
	if r == NORMAL_FONT_COLOR.r and g == NORMAL_FONT_COLOR.g and b == NORMAL_FONT_COLOR.b then
		self:SetTextColor(C.db.global.colors.lanzones:GetRGB())
	end
end

local handledChatTabs = {}

local TAB_TEXTURES = {
	"Left",
	"Middle",
	"Right",

	"ActiveLeft",
	"ActiveMiddle",
	"ActiveRight",

	-- "HighlightLeft",
	-- "HighlightMiddle",
	-- "HighlightRight",
}

function E:HandleChatTab(frame)
	if not handledChatTabs[frame] then
		frame.Backdrop = E:CreateBackdrop(frame)

		hooksecurefunc(frame, "SetPoint", chatTab_SetPoint)
		hooksecurefunc(frame.Text, "SetPoint", chatTabText_SetPoint)
		hooksecurefunc(frame.Text, "SetTextColor", chatTabText_SetTextColor)

		handledChatTabs[frame] = true
	end

	for _, texture in next, TAB_TEXTURES do
		frame[texture]:SetTexture(0)
	end

	frame:SetHeight(20)

	frame.glow:ClearAllPoints()
	frame.glow:SetPoint("BOTTOMLEFT", 8, 2)
	frame.glow:SetPoint("BOTTOMRIGHT", -8, 2)

	frame.HighlightLeft:ClearAllPoints()
	frame.HighlightLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	frame.HighlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightLeft:SetTexCoord(0 / 16, 16 / 16, 16 / 32, 32 / 32)
	frame.HighlightLeft:SetSize(16 / 2, 16 / 2)

	frame.HighlightRight:ClearAllPoints()
	frame.HighlightRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	frame.HighlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightRight:SetTexCoord(16 / 16, 0 / 16, 16 / 32, 32 / 32)
	frame.HighlightRight:SetSize(16 / 2, 16 / 2)

	frame.HighlightMiddle:ClearAllPoints()
	frame.HighlightMiddle:SetPoint("TOPLEFT", frame.HighlightLeft, "TOPRIGHT", 0, 0)
	frame.HighlightMiddle:SetPoint("TOPRIGHT", frame.HighlightRight, "TOPLEFT", 0, 0)
	frame.HighlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightMiddle:SetTexCoord(0 / 16, 16 / 16, 0 / 32, 16 / 32)
	frame.HighlightMiddle:SetSize(16 / 2, 16 / 2)

	-- frame:SetNormalFontObject("GameFontNormal") -- TODO: Fix me!
	-- frame.Text:SetJustifyH("LEFT")
	-- frame.Text:SetJustifyV("MIDDLE")
	-- frame.Text:SetPoint("TOPLEFT", 2, -2)
	-- frame.Text:SetPoint("BOTTOMRIGHT", -2, 2)

	-- reset the tab
	if not frame.selectedColorTable then
		frame.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end

	-- It can be "CENTER" or "LEFT", so just use the index
	frame.Text:SetPoint(frame.Text:GetPoint(1))
end
