local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local handledbuttons = {}

local function handleButton(frame, ...)
	if not handledbuttons[frame] then
		frame.Backdrop = E:CreateBackdrop(frame)
		frame.HighlightLeft = frame:CreateTexture(nil, "HIGHLIGHT")
		frame.HighlightMiddle = frame:CreateTexture(nil, "HIGHLIGHT")
		frame.HighlightRight = frame:CreateTexture(nil, "HIGHLIGHT")

		handledbuttons[frame] = true
	end

	frame:SetSize(20, 20)
	frame:SetNormalTexture(0)
	frame:SetPushedTexture(0)
	frame:SetHighlightTexture(0)

	local normalTexture = frame:GetNormalTexture()
	normalTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	normalTexture:SetTexCoord(...)
	normalTexture:ClearAllPoints()
	normalTexture:SetPoint("TOPLEFT", 2, -2)
	normalTexture:SetPoint("BOTTOMRIGHT", -2, 2)
	normalTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

	local pushedTexture = frame:GetPushedTexture()
	pushedTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\icons")
	pushedTexture:SetTexCoord(...)
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", 3, -3)
	pushedTexture:SetPoint("BOTTOMRIGHT", -1, 1)
	pushedTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())

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

function E:HandleMinimizeButton(frame)
	handleButton(frame, 0.25, 0.5, 0, 0.5)

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", _G[frame:GetParent():GetParent():GetName() .. "Tab"], "BOTTOMRIGHT", 1, 0)
end

function E:HandleMaximizeButton(frame)
	handleButton(frame, 0.5, 0.75, 0, 0.5)

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "BOTTOMRIGHT", 1, 0)
end

function E:HandleChannelButton(frame)
	handleButton(frame, 0, 0.25, 0.5, 1)

	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 2, 0)

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
