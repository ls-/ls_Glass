local addonName, ns = ...
local C, L = ns.C, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local E = {}
ns.E = E

-- TODO: Remove Me!
local AceAddon = _G.LibStub("AceAddon-3.0")

local Core = AceAddon:NewAddon(addonName)
_G[addonName] = Core

-- Core
Core.Libs = {
	AceConfig = _G.LibStub("AceConfig-3.0"),
	AceConfigDialog = _G.LibStub("AceConfigDialog-3.0"),
	AceDB = _G.LibStub("AceDB-3.0"),
	AceDBOptions = _G.LibStub("AceDBOptions-3.0"),
	AceGUI = _G.LibStub("AceGUI-3.0"),
	AceHook = _G.LibStub("AceHook-3.0"),
	LSM = _G.LibStub("LibSharedMedia-3.0"),
	LibEasing = _G.LibStub("LibEasing-1.0"),
	lodash = _G.LibStub("lodash.wow")
}

local Constants = {}
ns[1] = Core
ns[2] = Constants

Core.Components = {}
Core.Version = tonumber(GetAddOnMetadata(addonName, "Version"):gsub("%D", ""), nil)

-- Modules
Core:NewModule("Config", "AceConsole-3.0")
Core:NewModule("Fonts")
Core:NewModule("Hyperlinks")
Core:NewModule("News")
Core:NewModule("UIManager", "AceHook-3.0")

-- TODO: Remove Me!
-- Utility functions
function E.super(obj)
	return getmetatable(obj).__index
end

-- TODO: Remove Me!
-- Prints Glass' notification messages
function E.notify(message)
	print("|c00DFBA69Glass|r: ", message)
end


--------------------
-- TEXT PROCESSOR --
--------------------

do
	local s_join = _G.string.join
	local s_split = _G.string.split

	--Takes a texture escape string and adjusts its yOffset
	local function adjustTextureYOffset(texture)
		-- Texture has 14 parts
		-- path, height, width, offsetX, offsetY,
		-- texWidth, texHeight
		-- leftTex, topTex, rightTex, bottomText,
		-- rColor, gColor, bColor

		-- Strip escape characters
		-- Split into parts
		local parts = {s_split(':', strsub(texture, 3, -3))}
		local yOffset = Core.db.profile.iconTextureYOffset

		if #parts < 5 then
			-- Pad out ommitted attributes
			for i=1, 5 do
			if parts[i] == nil then
				if i == 3 then
				-- If width is not specified, the width should equal the height
				parts[i] = parts[2]
				else
				parts[i] = '0'
				end
			end
			end
		end

		-- Adjust yOffset by configured amount
		parts[5] = tostring(tonumber(parts[5]) - yOffset)

		-- Rejoin string and readd escape codes
		return '|T'..s_join(':', unpack(parts))..'|t'
	end


	---
	-- Gets all inline textures found in the string and adjusts their yOffset
	local function textureProcessor(text)
		local cursor = 1
		local origLen = strlen(text)

		local parts = {}

		while cursor <= origLen do
			local mStart, mEnd = strfind(text, '%|T.-%|t', cursor)

			if mStart then
			table.insert(parts, strsub(text, cursor, mStart - 1))
			table.insert(parts, adjustTextureYOffset(strsub(text, mStart, mEnd)))
			cursor = mEnd + 1
			else
			-- No more matches
			table.insert(parts, strsub(text, cursor, origLen))
			cursor = origLen + 1
			end
		end

		return s_join("", unpack(parts))
	end

	-- Adds Prat Timestamps if configured
	local function pratTimestampProcessor(text)
		return _G.Prat.Addon:GetModule("Timestamps"):InsertTimeStamp(text)
	end


	-- Text processing pipeline
	local TEXT_PROCESSORS = {
		textureProcessor,
		pratTimestampProcessor
	}

	function E:ProcessText(text)
		local result = text

		for _, processor in ipairs(TEXT_PROCESSORS) do
			-- Prevent failing processors from bringing down the whole pipeline
			local isOk, val = pcall(processor, result)
			if isOk then
				result = val
			end
		end

		return result
	end
end
