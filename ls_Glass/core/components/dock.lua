local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
function E:HandleDock(frame)
	frame:SetHeight(20)
	frame.scrollFrame:SetHeight(20)
	frame.scrollFrame.child:SetHeight(20)
	frame.overflowButton:SetSize(20, 20)

	frame.overflowButton.Backdrop = E:CreateBackdrop(frame.overflowButton)

	local normalTexture = frame.overflowButton:GetNormalTexture()
	normalTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	normalTexture:SetTexCoord(0, 0.5, 0, 0.5)
	normalTexture:ClearAllPoints()
	normalTexture:SetPoint("TOPLEFT", 2, -2)
	normalTexture:SetPoint("BOTTOMRIGHT", -2, 2)
	normalTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	frame.overflowButton:SetPushedTexture(0)

	local pushedTexture = frame.overflowButton:GetPushedTexture()
	pushedTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	pushedTexture:SetTexCoord(0, 0.5, 0, 0.5)
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", 3, -3)
	pushedTexture:SetPoint("BOTTOMRIGHT", -1, 1)
	pushedTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	frame.overflowButton:SetHighlightTexture(0)

	local highlightLeft = frame.overflowButton:CreateTexture(nil, "HIGHLIGHT")
	highlightLeft:SetPoint("TOPLEFT", frame.overflowButton, "TOPLEFT", 0, -2)
	highlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightLeft:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightLeft:SetTexCoord(0, 1, 0.5, 1)
	highlightLeft:SetSize(8, 8)

	local highlightRight = frame.overflowButton:CreateTexture(nil, "HIGHLIGHT")
	highlightRight:SetPoint("TOPRIGHT", frame.overflowButton, "TOPRIGHT", 0, -2)
	highlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightRight:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightRight:SetTexCoord(1, 0, 0.5, 1)
	highlightRight:SetSize(8, 8)

	local highlightMiddle = frame.overflowButton:CreateTexture(nil, "HIGHLIGHT")
	highlightMiddle:SetPoint("TOPLEFT", highlightLeft, "TOPRIGHT", 0, 0)
	highlightMiddle:SetPoint("TOPRIGHT", highlightRight, "TOPLEFT", 0, 0)
	highlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightMiddle:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	highlightMiddle:SetSize(8, 8)
end
