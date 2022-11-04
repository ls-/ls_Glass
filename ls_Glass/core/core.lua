local addonName, ns = ...
local C, L = ns.C, ns.L

-- Lua
local _G = getfenv(0)
local t_insert = _G.table.insert

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

------------
-- EVENTS --
------------

do
	local listeners = {}

	function E:Subscribe(messageType, listener)
		if not listeners[messageType] then
			listeners[messageType] = {}
		end

		t_insert(listeners[messageType], listener)
	end

	function E:Dispatch(messageType, payload)
		if not listeners[messageType] then return end

		for _, listener in ipairs(listeners[messageType]) do
			listener(payload)
		end
	end
end


-----------
-- UTILS --
-----------

do
	local hidden = _G.CreateFrame("Frame", nil, UIParent)
	hidden:Hide()

	function E:ForceHide(object, skipEvents)
		if not object then return end

		object:Hide(true)
		object:SetParent(hidden)

		if object.EnableMouse then
			object:EnableMouse(false)
		end

		if object.UnregisterAllEvents then
			if not skipEvents then
				object:UnregisterAllEvents()
			end

			if object:GetName() then
				object.ignoreFramePositionManager = true
				object:SetAttribute("ignoreFramePositionManager", true)
			end

			object:SetAttribute("statehidden", true)
		end

		if object.SetUserPlaced then
			pcall(object.SetUserPlaced, object, true)
		end
	end
end

-----------
-- FADER --
-----------

do
	local function clamp(v)
		if v > 1 then
			return 1
		elseif v < 0 then
			return 0
		end

		return v
	end

	local function lerp(v1, v2, perc)
		return clamp(v1 + (v2 - v1) * perc)
	end

	local FADE_IN = 1
	local FADE_OUT = -1

	local objects = {}
	local add, remove

	local updater = CreateFrame("Frame", "LSGlassFader")

	local function updater_OnUpdate(_, elapsed)
		for object, data in next, objects do
			data.fadeTimer = data.fadeTimer + elapsed
			data.isFading = true

			object:SetAlpha(lerp(data.initAlpha, data.finalAlpha, data.fadeTimer / data.duration))

			if data.fadeTimer >= data.duration then
				remove(object)

				if data.callback then
					data.callback(object)
					data.callback = nil
				end

				object:SetAlpha(data.finalAlpha)
			end
		end
	end

	function add(mode, object, delay, duration, callback)
		local initAlpha = object:GetAlpha()
		local finalAlpha = mode == FADE_IN and 1 or 0

		if delay == 0 and (duration == 0 or initAlpha == finalAlpha) then
			return callback and callback(object)
		end

		objects[object] = {
			fadeTimer = -delay,
			initAlpha = initAlpha,
			finalAlpha = finalAlpha,
			duration = duration,
			callback = callback
		}

		if not updater:GetScript("OnUpdate") then
			updater:SetScript("OnUpdate", updater_OnUpdate)
		end
	end

	function remove(object)
		objects[object] = nil

		if not next(objects) then
			updater:SetScript("OnUpdate", nil)
		end
	end

	function E:FadeIn(object, duration, callback)
		add(FADE_IN, object, 0, duration * (1 - object:GetAlpha()), callback)
	end

	function E:FadeOut(...)
		add(FADE_OUT, ...)
	end

	function E:StopFading(object, alpha)
		remove(object)

		object:SetAlpha(alpha or object:GetAlpha())
	end
end
