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
		frame.Backdrop = E:CreateBackdrop(frame, C.db.profile.edit.alpha, 0, 2)

		handledEditBoxes[frame] = true
	end

	for _, texture in next, EDIT_BOX_TEXTURES do
		_G[frame:GetName() .. texture]:SetTexture(0)
	end

	frame:ClearAllPoints()

	if C.db.profile.edit.position == "top" then
		frame:SetPoint("TOPLEFT", frame.chatFrame, "TOPLEFT", 0, C.db.profile.edit.offset)
		frame:SetPoint("TOPRIGHT", frame.chatFrame, "TOPRIGHT", 0, C.db.profile.edit.offset)
	else
		frame:SetPoint("BOTTOMLEFT", frame.chatFrame, "BOTTOMLEFT", 0, -C.db.profile.edit.offset)
		frame:SetPoint("BOTTOMRIGHT", frame.chatFrame, "BOTTOMRIGHT", 0, -C.db.profile.edit.offset)
	end

	frame:SetFontObject("LSGlassEditBoxFont")
	frame.header:SetFontObject("LSGlassEditBoxFont")
	frame.headerSuffix:SetFontObject("LSGlassEditBoxFont")
	frame.NewcomerHint:SetFontObject("LSGlassEditBoxFont")
	frame.prompt:SetFontObject("LSGlassEditBoxFont")
end

function E:UpdateEditBoxPosition()
	local isOnTop = C.db.profile.edit.position == "top"
	local offset = C.db.profile.edit.offset

	for editBox in next, handledEditBoxes do
		editBox:ClearAllPoints()

		if isOnTop then
			editBox:SetPoint("TOPLEFT", editBox.chatFrame, "TOPLEFT", 0, offset)
			editBox:SetPoint("TOPRIGHT", editBox.chatFrame, "TOPRIGHT", 0, offset)
		else
			editBox:SetPoint("BOTTOMLEFT", editBox.chatFrame, "BOTTOMLEFT", 0, -offset)
			editBox:SetPoint("BOTTOMRIGHT", editBox.chatFrame, "BOTTOMRIGHT", 0, -offset)
		end
	end
end

function E:UpdateEditBoxAlpha()
	local alpha = C.db.profile.edit.alpha

	for editBox in next, handledEditBoxes do
		editBox.Backdrop:UpdateAlpha(alpha)
	end
end
