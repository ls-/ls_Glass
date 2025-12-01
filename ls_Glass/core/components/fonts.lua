local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local next = _G.next
local t_insert = _G.table.insert

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local alphabets = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}

local defaultAlphabet = "roman"
local locale = GetLocale()
if locale == "koKR" then
	defaultAlphabet = "korean"
elseif locale == "zhCN" then
	defaultAlphabet = "simplifiedchinese"
elseif locale == "zhTW" then
	defaultAlphabet = "traditionalchinese"
elseif locale == "ruRU" then
	defaultAlphabet = "russian"
end

local fontData = {}

function E:CreateFonts()
	-- ! don't use font:CopyFontObject(sourceFont)
	local members = {}
	for _, alphabet in next, alphabets do
		local alphabetFont = ChatFontNormal:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			local file, height, flags = alphabetFont:GetFont()
			t_insert(members, {
				alphabet = alphabet,
				file = file,
				height = height,
				flags = flags,
			})

			fontData[alphabet] = {
				file = file,
				height = m_ceil(height),
				isDefault = alphabet == defaultAlphabet,
			}
		end
	end

	-- each alphabet has unique height, preserve it
	local defaultHeight = fontData[defaultAlphabet].height
	for _, data in next, fontData do
		if not data.isDefault then
			data.heightDelta = data.height - defaultHeight
		else
			data.heightDelta = 0
		end
	end

	for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
		local font = CreateFontFamily("LSGlassMessageFont" .. i, members)
		local newSize = C.db.profile.chat[i].font.size
		local newOutline = C.db.profile.chat[i].font.outline and "OUTLINE" or ""
		local newShadow = C.db.profile.chat[i].font.shadow

		for _, alphabet in next, alphabets do
			local alphabetFont = font:GetFontObjectForAlphabet(alphabet)
			if alphabetFont then
				local replaceFont = fontData[alphabet].isDefault or C.db.profile.font.override[alphabet]

				alphabetFont:SetFont(
					replaceFont and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
					newSize + fontData[alphabet].heightDelta,
					newOutline
				)

				alphabetFont:SetShadowColor(0, 0, 0, 1)

				if newShadow then
					alphabetFont:SetShadowOffset(1, -1)
				else
					alphabetFont:SetShadowOffset(0, 0)
				end
			end
		end

		font:SetJustifyH("LEFT")
		font:SetJustifyV("MIDDLE")
	end

	local font = CreateFontFamily("LSGlassEditBoxFont", members)
	local newSize = C.db.profile.edit.font.size
	local newOutline = C.db.profile.edit.font.outline and "OUTLINE" or ""
	local newShadow = C.db.profile.edit.font.shadow

	for _, alphabet in next, alphabets do
		local alphabetFont = font:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			local replaceFont = fontData[alphabet].isDefault or C.db.profile.font.override[alphabet]

			alphabetFont:SetFont(
				replaceFont and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
				newSize + fontData[alphabet].heightDelta,
				newOutline
			)

			alphabetFont:SetShadowColor(0, 0, 0, 1)

			if newShadow then
				alphabetFont:SetShadowOffset(1, -1)
			else
				alphabetFont:SetShadowOffset(0, 0)
			end
		end
	end

	font:SetJustifyH("LEFT")
	font:SetJustifyV("MIDDLE")
end

function E:UpdateMessageFont(id)
	local font = _G["LSGlassMessageFont" .. id]
	local newSize = C.db.profile.chat[id].font.size
	local newOutline = C.db.profile.chat[id].font.outline and "OUTLINE" or ""
	local newShadow = C.db.profile.chat[id].font.shadow

	for _, alphabet in next, alphabets do
		local alphabetFont = font:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			local replaceFont = fontData[alphabet].isDefault or C.db.profile.font.override[alphabet]

			alphabetFont:SetFont(
				replaceFont and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
				newSize + fontData[alphabet].heightDelta,
				newOutline
			)

			if newShadow then
				alphabetFont:SetShadowOffset(1, -1)
			else
				alphabetFont:SetShadowOffset(0, 0)
			end
		end
	end

	font:SetJustifyH("LEFT")
	font:SetJustifyV("MIDDLE")
end

function E:UpdateMessageFonts()
	for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
		self:UpdateMessageFont(i)
	end
end

function E:UpdateEditBoxFont()
	local newSize = C.db.profile.edit.font.size
	local newOutline = C.db.profile.edit.font.outline and "OUTLINE" or ""
	local newShadow = C.db.profile.edit.font.shadow

	for _, alphabet in next, alphabets do
		local alphabetFont = LSGlassEditBoxFont:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			local replaceFont = fontData[alphabet].isDefault or C.db.profile.font.override[alphabet]

			alphabetFont:SetFont(
				replaceFont and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
				newSize + fontData[alphabet].heightDelta,
				newOutline
			)

			if newShadow then
				alphabetFont:SetShadowOffset(1, -1)
			else
				alphabetFont:SetShadowOffset(0, 0)
			end
		end
	end

	LSGlassEditBoxFont:SetJustifyH("LEFT")
	LSGlassEditBoxFont:SetJustifyV("MIDDLE")
end
