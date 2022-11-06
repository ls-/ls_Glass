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

local function chatTab_OnDragStart(self)
	self.isDragging = true
end

local function chatTab_OnDragStop(self)
	self.isDragging = false

	local frame = _G["ChatFrame" .. self:GetID()]
	if frame and frame.SlidingMessageFrame and not frame.SlidingMessageFrame.isMouseOver then
		frame.SlidingMessageFrame.isMouseOver = nil
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

local handledTabs = {}

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
	if not handledTabs[frame] then
		frame.Backdrop = E:CreateBackdrop(frame)

		hooksecurefunc(frame, "SetPoint", chatTab_SetPoint)
		frame:HookScript("OnDragStart", chatTab_OnDragStart)
		hooksecurefunc("FCFTab_OnDragStop", chatTab_OnDragStop)

		hooksecurefunc(frame.Text, "SetPoint", chatTabText_SetPoint)
		hooksecurefunc(frame.Text, "SetTextColor", chatTabText_SetTextColor)

		handledTabs[frame] = true
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
	frame.HighlightLeft:SetTexCoord(0, 1, 0.5, 1)
	frame.HighlightLeft:SetSize(8, 8)

	frame.HighlightRight:ClearAllPoints()
	frame.HighlightRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	frame.HighlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightRight:SetTexCoord(1, 0, 0.5, 1)
	frame.HighlightRight:SetSize(8, 8)

	frame.HighlightMiddle:ClearAllPoints()
	frame.HighlightMiddle:SetPoint("TOPLEFT", frame.HighlightLeft, "TOPRIGHT", 0, 0)
	frame.HighlightMiddle:SetPoint("TOPRIGHT", frame.HighlightRight, "TOPLEFT", 0, 0)
	frame.HighlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	frame.HighlightMiddle:SetSize(8, 8)

	-- frame:SetNormalFontObject("GameFontNormal") -- TODO: Fix me!
	-- frame.Text:SetJustifyH("LEFT")
	-- frame.Text:SetJustifyV("MIDDLE")
	-- frame.Text:SetPoint("TOPLEFT", 2, -2)
	-- frame.Text:SetPoint("BOTTOMRIGHT", -2, 2)

	-- reset the tab
	frame:SetPoint(frame:GetPoint(1))

	if not frame.selectedColorTable then
		frame.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end

	-- It can be "CENTER" or "LEFT", so just use the index
	frame.Text:SetPoint(frame.Text:GetPoint(1))
end

local handledMiniTabs = {}

local MINI_TAB_TEXTURES = {
	"Left",
	"Middle",
	"Right",

	-- "ActiveLeft",
	-- "ActiveMiddle",
	-- "ActiveRight",

	-- "HighlightLeft",
	-- "HighlightMiddle",
	-- "HighlightRight",
}

function E:HandleMinimizedTab(frame)
	if not frame then return end

	if not handledMiniTabs[frame] then
		frame.Backdrop = E:CreateBackdrop(frame)

		handledMiniTabs[frame] = true
	end

	for _, texture in next, MINI_TAB_TEXTURES do
		frame[texture]:SetTexture(0)
	end

	frame:SetHeight(20)

	frame.glow:ClearAllPoints()
	frame.glow:SetPoint("BOTTOMLEFT", 8, 2)
	frame.glow:SetPoint("BOTTOMRIGHT", -24, 2)

	frame.HighlightLeft:ClearAllPoints()
	frame.HighlightLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	frame.HighlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightLeft:SetTexCoord(0, 1, 0.5, 1)
	frame.HighlightLeft:SetSize(8, 8)

	frame.HighlightRight:ClearAllPoints()
	frame.HighlightRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	frame.HighlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightRight:SetTexCoord(1, 0, 0.5, 1)
	frame.HighlightRight:SetSize(8, 8)

	frame.HighlightMiddle:ClearAllPoints()
	frame.HighlightMiddle:SetPoint("TOPLEFT", frame.HighlightLeft, "TOPRIGHT", 0, 0)
	frame.HighlightMiddle:SetPoint("TOPRIGHT", frame.HighlightRight, "TOPLEFT", 0, 0)
	frame.HighlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	frame.HighlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	frame.HighlightMiddle:SetSize(8, 8)

	local maximizeButton = _G[frame:GetName() .. "MaximizeButton"]
	maximizeButton:SetNormalTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	maximizeButton:GetNormalTexture():SetTexCoord(0.5, 1, 0, 0.5)
	maximizeButton:GetNormalTexture():ClearAllPoints()
	maximizeButton:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
	maximizeButton:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
	maximizeButton:GetNormalTexture():SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	maximizeButton:SetPushedTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	maximizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
	maximizeButton:GetPushedTexture():ClearAllPoints()
	maximizeButton:GetPushedTexture():SetPoint("TOPLEFT", 3, -3)
	maximizeButton:GetPushedTexture():SetPoint("BOTTOMRIGHT", -1, 1)
	maximizeButton:GetPushedTexture():SetVertexColor(C.db.global.colors.lanzones:GetRGB())
end
