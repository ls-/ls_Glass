local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

function E:CreateFonts()
	local messageFont = CreateFont("LSGlassMessageFont")
	messageFont:SetFont(
		LSM:Fetch("font", C.db.profile.font),
		C.db.profile.chat.font.size,
		C.db.profile.chat.font.outline and "OUTLINE" or ""
	)

	messageFont:SetShadowColor(0, 0, 0, 1)

	if C.db.profile.chat.font.shadow then
		messageFont:SetShadowOffset(1, -1)
	else
		messageFont:SetShadowOffset(0, 0)
	end

	messageFont:SetJustifyH("LEFT")
	messageFont:SetJustifyV("MIDDLE")
	messageFont:SetIndentedWordWrap(true)

	local editBoxFont = CreateFont("LSGlassEditBoxFont")
	editBoxFont:SetFont(
		LSM:Fetch("font", C.db.profile.font), -- ? Add eparate font?
		C.db.profile.dock.font.size,
		C.db.profile.dock.font.outline and "OUTLINE" or ""
	)

	editBoxFont:SetShadowColor(0, 0, 0, 1)

	if C.db.profile.dock.font.shadow then
		editBoxFont:SetShadowOffset(1, -1)
	else
		editBoxFont:SetShadowOffset(0, 0)
	end

	editBoxFont:SetJustifyH("LEFT")
	editBoxFont:SetJustifyV("MIDDLE")
end

function E:UpdateFonts()
	LSGlassMessageFont:SetFont(
		LSM:Fetch("font", C.db.profile.font),
		C.db.profile.chat.font.size,
		C.db.profile.chat.font.outline and "OUTLINE" or ""
	)

	if C.db.profile.chat.font.shadow then
		LSGlassMessageFont:SetShadowOffset(1, -1)
	else
		LSGlassMessageFont:SetShadowOffset(0, 0)
	end

	LSGlassEditBoxFont:SetFont(
		LSM:Fetch("font", C.db.profile.font),
		C.db.profile.dock.font.size,
		C.db.profile.dock.font.outline and "OUTLINE" or ""
	)

	if C.db.profile.dock.font.shadow then
		LSGlassEditBoxFont:SetShadowOffset(1, -1)
	else
		LSGlassEditBoxFont:SetShadowOffset(0, 0)
	end
end
