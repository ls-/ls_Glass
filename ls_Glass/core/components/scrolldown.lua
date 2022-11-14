local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local button_proto = {}

do
	local ICONS = {
		{0 / 128, 52 / 128, 0 / 64, 52 / 64}, -- 1, "down"
		{52 / 128, 104 / 128, 0 / 64, 52 / 64}, -- 2, "new"
	}

	function button_proto:OnClick()
		local frame = self:GetParent()
		if frame then
			frame:FastForward()

			E:FadeOut(self, 0, 0.1, function()
				self:SetState(1, true)
				self:Hide()
			end)
		end
	end

	function button_proto:SetState(state, isInstant)
		if state ~= self.state then
			self.state = state

			if isInstant then
				self.NormalTexture:SetTexCoord(unpack(ICONS[state]))
				self.PushedTexture:SetTexCoord(unpack(ICONS[state]))
			else
				E:StopFading(self.NormalTexture, 1)
				E:FadeOut(self.NormalTexture, 0, 0.1, function()
					self.NormalTexture:SetTexCoord(unpack(ICONS[state]))
					self.PushedTexture:SetTexCoord(unpack(ICONS[state]))

					E:FadeIn(self.NormalTexture, 0.1)
				end)
			end
		end
	end
end

function E:CreateScrollDownButton(parent)
	local button = Mixin(CreateFrame("Button", nil, parent), button_proto)
	button:SetSize(24, 24)
	button:SetPoint("BOTTOMRIGHT", -4, 4)
	button:SetScript("OnClick", button.OnClick)
	button:SetAlpha(0)
	button:Hide()

	button.Backdrop = E:CreateBackdrop(button)

	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetHighlightTexture(0)

	local normalTexture = button:GetNormalTexture()
	normalTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\scrolldown")
	normalTexture:ClearAllPoints()
	normalTexture:SetPoint("TOPLEFT", 3, -3)
	normalTexture:SetPoint("BOTTOMRIGHT", -3, 3)
	normalTexture:SetAlpha(0.8)
	normalTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())
	button.NormalTexture = normalTexture

	local pushedTexture = button:GetPushedTexture()
	pushedTexture:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\scrolldown")
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", 4, -4)
	pushedTexture:SetPoint("BOTTOMRIGHT", -2, 2)
	pushedTexture:SetAlpha(0.8)
	pushedTexture:SetVertexColor(C.db.global.colors.lanzones:GetRGB())
	button.PushedTexture = pushedTexture

	local highlightLeft = button:CreateTexture(nil, "HIGHLIGHT")
	highlightLeft:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -2)
	highlightLeft:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightLeft:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightLeft:SetTexCoord(0, 1, 0.5, 1)
	highlightLeft:SetSize(8, 8)

	local highlightRight = button:CreateTexture(nil, "HIGHLIGHT")
	highlightRight:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -2)
	highlightRight:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightRight:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightRight:SetTexCoord(1, 0, 0.5, 1)
	highlightRight:SetSize(8, 8)

	local highlightMiddle = button:CreateTexture(nil, "HIGHLIGHT")
	highlightMiddle:SetPoint("TOPLEFT", highlightLeft, "TOPRIGHT", 0, 0)
	highlightMiddle:SetPoint("TOPRIGHT", highlightRight, "TOPLEFT", 0, 0)
	highlightMiddle:SetTexture("Interface\\AddOns\\ls_Glass\\assets\\border-highlight")
	highlightMiddle:SetVertexColor(DEFAULT_TAB_SELECTED_COLOR_TABLE.r, DEFAULT_TAB_SELECTED_COLOR_TABLE.g, DEFAULT_TAB_SELECTED_COLOR_TABLE.b)
	highlightMiddle:SetTexCoord(0, 1, 0, 0.5)
	highlightMiddle:SetSize(8, 8)

	button:SetState(1)

	return button
end
