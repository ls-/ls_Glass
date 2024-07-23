local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local t_remove = _G.table.remove
local tonumber = _G.tonumber

-- Mine
local handledbuttons = {}

local function handleButton(frame, ...)
	if not handledbuttons[frame] then
		frame.Backdrop = E:CreateBackdrop(frame, C.db.profile.dock.alpha)
		frame.HighlightLeft = frame:CreateTexture(nil, "HIGHLIGHT")
		frame.HighlightMiddle = frame:CreateTexture(nil, "HIGHLIGHT")
		frame.HighlightRight = frame:CreateTexture(nil, "HIGHLIGHT")

		handledbuttons[frame] = true
	end

	frame:SetFlattensRenderLayers(true)
	frame:SetSize(20, 20)
	frame:SetNormalTexture(0)
	frame:SetPushedTexture(0)
	frame:SetHighlightTexture(0)

	local normalTexture = frame:GetNormalTexture()
	normalTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	normalTexture:SetTexCoord(...)
	normalTexture:ClearAllPoints()
	normalTexture:SetPoint("TOPLEFT", 1, -1)
	normalTexture:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", 19, -19)
	normalTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	local pushedTexture = frame:GetPushedTexture()
	pushedTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	pushedTexture:SetTexCoord(...)
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", 2, -2)
	pushedTexture:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", 20, -20)
	pushedTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	-- PropertyButtonMixin resets this stuff, so nil it
	frame:ClearHighlightTexture()
	frame.highlightAtlas = nil

	local highlightLeft = frame.HighlightLeft
	highlightLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	highlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightLeft:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightLeft:SetTexCoord(0, 1, 0.5, 1)
	highlightLeft:SetSize(8, 8)

	local highlightRight = frame.HighlightRight
	highlightRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	highlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightRight:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightRight:SetTexCoord(1, 0, 0.5, 1)
	highlightRight:SetSize(8, 8)

	local highlightMiddle = frame.HighlightMiddle
	highlightMiddle:SetPoint("TOPLEFT", highlightLeft, "TOPRIGHT", 0, 0)
	highlightMiddle:SetPoint("TOPRIGHT", highlightRight, "TOPLEFT", 0, 0)
	highlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightMiddle:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	highlightMiddle:SetSize(8, 8)
end

function E:HandleMinimizeButton(frame, tab)
	handleButton(frame, 0.25, 0.5, 0, 0.5)

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", tab, "BOTTOMRIGHT", 1, 0)
end

function E:HandleMaximizeButton(frame)
	handleButton(frame, 0.5, 0.75, 0, 0.5)

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "BOTTOMRIGHT", 1, 0)
end

function E:HandleQuickJoinToastButton(frame)
	for i = #ChatAlertFrame.alertFrameSubSystems, 1, -1 do
		if ChatAlertFrame.alertFrameSubSystems[i].anchorFrame == frame then
			t_remove(ChatAlertFrame.alertFrameSubSystems, i)
		end
	end

	handleButton(frame, 0.5, 0.75, 0.5, 1)

	frame:SetParent(ChatFrame1.buttonFrame)
	frame:SetSize(20, 30)
	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", ChatFrame1.buttonFrame, "TOPRIGHT", 2, 0)

	frame.FriendCount:ClearAllPoints()
	frame.FriendCount:SetPoint("BOTTOMLEFT", -1.5, 4)
	frame.FriendCount:SetPoint("BOTTOMRIGHT", 2.5, 4)
	frame.FriendCount:SetTextColor(C.db.global.colors.lanzones:GetRGB())

	hooksecurefunc(frame, "UpdateDisplayedFriendCount", function(self)
		local value = tonumber(self.FriendCount:GetText())
		if not value or value > 99 then
			self.FriendCount:SetText("++")
		end
	end)

	frame.FriendsButton:SetTexture(0)
	frame.FriendsButton:Hide()

	frame.QueueCount:SetTextColor(C.db.global.colors.lanzones:GetRGB())

	frame.QueueButton:SetTexture(0)
	frame.QueueButton:Hide()

	frame.FlashingLayer:SetTexture(0)
	frame.FlashingLayer:Hide()

	frame.FriendToToastAnim:HookScript("OnPlay", function()
		frame.FriendCount:SetAlpha(0)
	end)

	frame.ToastToFriendAnim:HookScript("OnFinished", function()
		frame.FriendCount:SetAlpha(1)
	end)

	local function resetToastPoint(self, _, anchor, _, _, _, shouldIgnore)
		if shouldIgnore then return end

		if anchor == QuickJoinToastButton then
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", ChatAlertFrame, "BOTTOMRIGHT", 2, 0, true)
		end
	end

	frame.Toast:ClearAllPoints()
	frame.Toast:SetPoint("TOPLEFT", ChatAlertFrame, "BOTTOMLEFT", 0, -2)
	hooksecurefunc(frame.Toast, "SetPoint", resetToastPoint)

	frame.Toast2:ClearAllPoints()
	frame.Toast2:SetPoint("TOPLEFT", ChatAlertFrame, "BOTTOMLEFT", 0, -2)
	hooksecurefunc(frame.Toast2, "SetPoint", resetToastPoint)

	-- ? mb move it elsewhere
	ChatAlertFrame:ClearAllPoints()
	ChatAlertFrame:SetPoint("BOTTOMLEFT", ChatFrame1.buttonFrame, "TOPRIGHT", -18, 56)
end

function E:HandleChannelButton(frame)
	handleButton(frame, 0, 0.25, 0.5, 1)

	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", QuickJoinToastButton, "BOTTOMRIGHT", 0, -1)

	frame.Icon:SetTexture(0)

	local flash = frame.Flash
	flash:ClearAllPoints()
	flash:SetPoint("TOPLEFT", -3, 3)
	flash:SetPoint("BOTTOMRIGHT", 3, -3)
end

function E:HandleMenuButton(frame)
	handleButton(frame, 0.75, 1, 0, 0.5)

	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", ChatFrameChannelButton, "BOTTOMRIGHT", 0, -1)
end

function E:HandleOverflowButton(frame)
	handleButton(frame, 0, 0.25, 0, 0.5)
end

function E:HandleTTSButton(frame)
	local parent = frame:GetParent()

	for i = #ChatAlertFrame.alertFrameSubSystems, 1, -1 do
		if ChatAlertFrame.alertFrameSubSystems[i].anchorFrame == parent then
			t_remove(ChatAlertFrame.alertFrameSubSystems, i)
		end
	end

	handleButton(frame, 0.25, 0.5, 0.5, 1)

	frame.Icon:SetTexture(0)
	frame.Icon:Hide()

	frame.Background:SetTexture(0)

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

	parent:SetSize(20, 20)
	parent:SetParent(ChatFrame1.buttonFrame)
	parent:ClearAllPoints()
	parent:SetPoint("TOPRIGHT", ChatFrameMenuButton, "BOTTOMRIGHT", 0, -1)
end

function E:UpdateButtonAlpha()
	local alpha = C.db.profile.dock.alpha

	for button in next, handledbuttons do
		button.Backdrop:UpdateAlpha(alpha)
	end
end
