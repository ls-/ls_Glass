local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
function E:HandleMinimizeButton(frame)
	-- due to how this button works, I can't reparent it

	frame:SetSize(20, 20)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", _G[frame:GetParent():GetParent():GetName() .. "Tab"], "BOTTOMRIGHT", 1, 0)
	frame:SetNormalTexture(0)
	frame:SetPushedTexture(0)
	frame:SetHighlightTexture(0)

	frame.Backdrop = E:CreateBackdrop(frame)

	local normalTexture = frame:GetNormalTexture()
	normalTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	normalTexture:SetTexCoord(0.25, 0.5, 0, 0.5)
	normalTexture:ClearAllPoints()
	normalTexture:SetPoint("TOPLEFT", 2, -2)
	normalTexture:SetPoint("BOTTOMRIGHT", -2, 2)
	normalTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	local psuhedTexture = frame:GetPushedTexture()
	psuhedTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	psuhedTexture:SetTexCoord(0.25, 0.5, 0, 0.5)
	psuhedTexture:ClearAllPoints()
	psuhedTexture:SetPoint("TOPLEFT", 3, -3)
	psuhedTexture:SetPoint("BOTTOMRIGHT", -1, 1)
	psuhedTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	local highlightLeft = frame:CreateTexture(nil, "HIGHLIGHT")
	highlightLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	highlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightLeft:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightLeft:SetTexCoord(0, 1, 0.5, 1)
	highlightLeft:SetSize(8, 8)

	local highlightRight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlightRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	highlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightRight:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightRight:SetTexCoord(1, 0, 0.5, 1)
	highlightRight:SetSize(8, 8)

	local highlightMiddle = frame:CreateTexture(nil, "HIGHLIGHT")
	highlightMiddle:SetPoint("TOPLEFT", highlightLeft, "TOPRIGHT", 0, 0)
	highlightMiddle:SetPoint("TOPRIGHT", highlightRight, "TOPLEFT", 0, 0)
	highlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightMiddle:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	highlightMiddle:SetSize(8, 8)
end
