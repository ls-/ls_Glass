local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

function E:CreateFonts()
	for i = 1, 10 do
		local messageFont = CreateFont("LSGlassMessageFont" .. i)
		messageFont:CopyFontObject(ChatFontNormal)
		messageFont:SetFont(
			LSM:Fetch("font", C.db.profile.font),
			C.db.profile.chat[i].font.size,
			C.db.profile.chat[i].font.outline and "OUTLINE" or ""
		)

		local mFont = messageFont:GetFont()
		if not mFont then
			-- a corrupt, missing, or misplaced font was supplied, reset it
			messageFont:SetFont(
				LSM:Fetch("font"),
				C.db.profile.chat.font[i].size,
				C.db.profile.chat.font[i].outline and "OUTLINE" or ""
			)
		end

		messageFont:SetShadowColor(0, 0, 0, 1)

		if C.db.profile.chat[i].font.shadow then
			messageFont:SetShadowOffset(1, -1)
		else
			messageFont:SetShadowOffset(0, 0)
		end

		messageFont:SetJustifyH("LEFT")
		messageFont:SetJustifyV("MIDDLE")
	end

	local editBoxFont = CreateFont("LSGlassEditBoxFont")
	editBoxFont:CopyFontObject(GameFontNormalSmall)
	editBoxFont:SetFont(
		LSM:Fetch("font", C.db.profile.font), -- ? Add a separate font?
		C.db.profile.edit.font.size,
		C.db.profile.edit.font.outline and "OUTLINE" or ""
	)

	local ebFont = editBoxFont:GetFont()
	if not ebFont then
		editBoxFont:SetFont(
			LSM:Fetch("font"),
			C.db.profile.edit.font.size,
			C.db.profile.edit.font.outline and "OUTLINE" or ""
		)
	end

	editBoxFont:SetShadowColor(0, 0, 0, 1)

	if C.db.profile.edit.font.shadow then
		editBoxFont:SetShadowOffset(1, -1)
	else
		editBoxFont:SetShadowOffset(0, 0)
	end

	editBoxFont:SetJustifyH("LEFT")
	editBoxFont:SetJustifyV("MIDDLE")
end

-- function E:UpdateMessageFont()
-- 	LSGlassMessaLSGlassMessageFontgeFont:SetFont(
-- 		LSM:Fetch("font", C.db.profile.font),
-- 		C.db.profile.chat.font.size,
-- 		C.db.profile.chat.font.outline and "OUTLINE" or ""
-- 	)

-- 	local font = LSGlassMessageFont:GetFont()
-- 	if not font then
-- 		:SetFont(
-- 			LSM:Fetch("font"),
-- 			C.db.profile.chat.font.size,
-- 			C.db.profile.chat.font.outline and "OUTLINE" or ""
-- 		)
-- 	end

-- 	if C.db.profile.chat.font.shadow then
-- 		LSGlassMessageFont:SetShadowOffset(1, -1)
-- 	else
-- 		LSGlassMessageFont:SetShadowOffset(0, 0)
-- 	end
-- end

-- function E:UpdateEditBoxFont()
-- 	LSGlassEditBoxFont:SetFont(
-- 		LSM:Fetch("font", C.db.profile.font),
-- 		C.db.profile.edit.font.size,
-- 		C.db.profile.edit.font.outline and "OUTLINE" or ""
-- 	)

-- 	local font = LSGlassEditBoxFont:GetFont()
-- 	if not font then
-- 		LSGlassEditBoxFont:SetFont(
-- 			LSM:Fetch("font"),
-- 			C.db.profile.edit.font.size,
-- 			C.db.profile.edit.font.outline and "OUTLINE" or ""
-- 		)
-- 	end

-- 	if C.db.profile.edit.font.shadow then
-- 		LSGlassEditBoxFont:SetShadowOffset(1, -1)
-- 	else
-- 		LSGlassEditBoxFont:SetShadowOffset(0, 0)
-- 	end
-- end
