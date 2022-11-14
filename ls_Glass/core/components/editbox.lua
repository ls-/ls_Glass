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

	if C.db.profile.dock.edit.position == "top" then
		frame:SetPoint("BOTTOMLEFT", frame.chatFrame, "TOPLEFT", 0, C.db.profile.dock.edit.offset)
		frame:SetPoint("BOTTOMRIGHT", frame.chatFrame, "TOPRIGHT", 0, C.db.profile.dock.edit.offset)
	else
		frame:SetPoint("TOPLEFT", frame.chatFrame, "BOTTOMLEFT", 0, -C.db.profile.dock.edit.offset)
		frame:SetPoint("TOPRIGHT", frame.chatFrame, "BOTTOMRIGHT", 0, -C.db.profile.dock.edit.offset)
	end

	frame:SetFontObject("LSGlassEditBoxFont")
	frame.header:SetFontObject("LSGlassEditBoxFont")
	frame.headerSuffix:SetFontObject("LSGlassEditBoxFont")
	frame.NewcomerHint:SetFontObject("LSGlassEditBoxFont")
	frame.prompt:SetFontObject("LSGlassEditBoxFont")
end

function E:UpdateEditBoxes()
	for editBox in next, handledEditBoxes do
		editBox:ClearAllPoints()

		if C.db.profile.dock.edit.position == "top" then
			editBox:SetPoint("BOTTOMLEFT", editBox.chatFrame, "TOPLEFT", 0, C.db.profile.dock.edit.offset)
			editBox:SetPoint("BOTTOMRIGHT", editBox.chatFrame, "TOPRIGHT", 0, C.db.profile.dock.edit.offset)
		else
			editBox:SetPoint("TOPLEFT", editBox.chatFrame, "BOTTOMLEFT", 0, -C.db.profile.dock.edit.offset)
			editBox:SetPoint("TOPRIGHT", editBox.chatFrame, "BOTTOMRIGHT", 0, -C.db.profile.dock.edit.offset)
		end
	end
end
