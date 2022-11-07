local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
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
		frame.Backdrop = E:CreateBackdrop(frame, 0, 2)

		handledEditBoxes[frame] = true
	end

	for _, texture in next, EDIT_BOX_TEXTURES do
		_G[frame:GetName() .. texture]:SetTexture(0)
	end

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.chatFrame, "BOTTOMLEFT", 0, -2)
	frame:SetPoint("TOPRIGHT", frame.chatFrame, "BOTTOMRIGHT", 0, -2)

	frame:SetFontObject("LSGlassEditBoxFont")
	frame.header:SetFontObject("LSGlassEditBoxFont")
	frame.headerSuffix:SetFontObject("LSGlassEditBoxFont")
	frame.NewcomerHint:SetFontObject("LSGlassEditBoxFont")
	frame.prompt:SetFontObject("LSGlassEditBoxFont")
end
