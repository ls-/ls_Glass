local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
hooksecurefunc("ChatEdit_DeactivateChat", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame then
		if not frame.isMouseOver then
			frame.isMouseOver = nil
		end
	end
end)

hooksecurefunc("ChatEdit_ActivateChat", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame then
		if not frame.isMouseOver then
			frame.isMouseOver = nil
		end
	end
end)

hooksecurefunc("ChatEdit_OnChar", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame then
		if not frame.isMouseOver then
			frame.isMouseOver = nil
		end
	end
end)

local function chatEdit_Show(self)
	self.Fader:Show()
end

local hookedEditBoxes = {}

local CHAT_EDIT_BOX_TEXTURES = {
	"Left",
	"Mid",
	"Right",

	"FocusLeft",
	"FocusMid",
	"FocusRight",
}

function E:HandleEditBox(frame)
	for _, texture in ipairs(CHAT_EDIT_BOX_TEXTURES) do
		_G[frame:GetName() .. texture]:SetTexture(0)
	end

	-- Blizz change the edit box's alpha so frequently that trying to adjust it
	-- directly only produces jank
	local fader = CreateFrame("Frame", nil, UIParent)
	frame.Fader = fader

	frame:SetParent(fader)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.chatFrame, "BOTTOMLEFT", 0, -2)
	frame:SetPoint("TOPRIGHT", frame.chatFrame, "BOTTOMRIGHT", 0, -2)

	frame.Backdrop = E:CreateBackdrop(frame, 0, 2)

	if not hookedEditBoxes[frame] then
		hooksecurefunc(frame, "Show", chatEdit_Show)

		hookedEditBoxes[frame] = true
	end
end
