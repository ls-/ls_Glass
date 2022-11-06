local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
function E:CreateBackdrop(parent, xOffset, yOffset)
	local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	backdrop:SetPoint("TOPLEFT", xOffset or 0, -(yOffset or 0))
	backdrop:SetPoint("BOTTOMRIGHT", -(xOffset or 0), yOffset or 0)
	backdrop:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\AddOns\\ls_Glass\\assets\\border",
		tile = true,
		tileEdge = true,
		tileSize = 8,
		edgeSize = 8,
		-- insets = {left = 4, right = 4, top = 4, bottom = 4},
	})

	-- the way Blizz position it creates really weird gaps, so fix it
	backdrop.Center:ClearAllPoints()
	backdrop.Center:SetPoint("TOPLEFT", backdrop.TopLeftCorner, "BOTTOMRIGHT", 0, 0)
	backdrop.Center:SetPoint("BOTTOMRIGHT", backdrop.BottomRightCorner, "TOPLEFT", 0, 0)

	backdrop:SetBackdropColor(0, 0, 0, C.db.profile.dock.alpha)
	backdrop:SetBackdropBorderColor(0, 0, 0, C.db.profile.dock.alpha)

	-- TODO: Add listeners to change opacity
end
