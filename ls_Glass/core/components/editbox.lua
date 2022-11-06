local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
hooksecurefunc("ChatEdit_DeactivateChat", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame and not frame.isMouseOver then
		frame.isMouseOver = nil
	end
end)

hooksecurefunc("ChatEdit_ActivateChat", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame and not frame.isMouseOver then
		frame.isMouseOver = nil
	end
end)

hooksecurefunc("ChatEdit_OnChar", function(self)
	local frame = self.chatFrame.SlidingMessageFrame
	if frame and not frame.isMouseOver then
		frame.isMouseOver = nil
	end
end)

local function chatEdit_Show(self)
	self.Fader:Show()
end

local handledEditBoxes = {}

local EDIT_BOX_TEXTURES = {
	"Left",
	"Mid",
	"Right",

	"FocusLeft",
	"FocusMid",
	"FocusRight",
}

function E:HandleEditBox(frame)
	if not handledEditBoxes[frame] then
		-- Blizz change the edit box's alpha so frequently that trying to adjust it
		-- directly only produces jank
		local fader = CreateFrame("Frame", nil, UIParent)
		frame.Fader = fader

		frame.Backdrop = E:CreateBackdrop(frame, 0, 2)

		hooksecurefunc(frame, "Show", chatEdit_Show)

		handledEditBoxes[frame] = true
	end

	for _, texture in next, EDIT_BOX_TEXTURES do
		_G[frame:GetName() .. texture]:SetTexture(0)
	end

	frame:SetParent(frame.Fader)

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.chatFrame, "BOTTOMLEFT", 0, -2)
	frame:SetPoint("TOPRIGHT", frame.chatFrame, "BOTTOMRIGHT", 0, -2)
end
