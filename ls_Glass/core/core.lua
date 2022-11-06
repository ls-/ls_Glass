local addonName, ns = ...
local L = ns.L

-- Lua
local _G = getfenv(0)
local ipairs = _G.ipairs
local m_floor = _G.math.floor
local next= _G.next
local pcall = _G.pcall
local s_format = _G.string.format
local t_insert = _G.table.insert

-- Mine
local E, C, D = LibStub("AceAddon-3.0"):NewAddon(addonName), {}, {}
ns.E, ns.C, ns.D = E, C, D

_G[addonName] = {
	[1] = E,
	[2] = C,
	[3] = L,
}

--------------------
-- TEXT PROCESSOR --
--------------------

do
	local TEXT_PROCESSORS = {
		-- function(text)
		-- 	return text
		-- end,
	}

	function E:ProcessText(text)
		for _, processor in ipairs(TEXT_PROCESSORS) do
			local isOK, val = pcall(processor, text)
			if isOK then
				text = val
			end
		end

		return text
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
	local hidden = CreateFrame("Frame", nil, UIParent)
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
			pcall(object.SetDontSavePosition, object, true)
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
			if data.fadeTimer > 0 then
				data.initAlpha = data.initAlpha or object:GetAlpha()

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
	end

	function add(mode, object, delay, duration, callback)
		local initAlpha = object:GetAlpha()
		local finalAlpha = mode == FADE_IN and 1 or 0

		if delay == 0 and (duration == 0 or initAlpha == finalAlpha) then
			return callback and callback(object)
		end

		objects[object] = {
			mode = mode,
			fadeTimer = -delay,
			-- initAlpha = initAlpha,
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

	function E:IsFading(object)
		local data = objects[object]
		if data then
			return data.mode
		end
	end
end

-------------
-- COLOURS --
-------------

do
	local color_proto = {}

	function color_proto:GetHex()
		return self.hex
	end

	-- override ColorMixin:GetRGBA
	function color_proto:GetRGBA(a)
		return self.r, self.g, self.b, a or self.a
	end

	-- override ColorMixin:SetRGBA
	function color_proto:SetRGBA(r, g, b, a)
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		self.r = r
		self.g = g
		self.b = b
		self.a = a
		self.hex = s_format('ff%02x%02x%02x', self:GetRGBAsBytes())
	end

	-- override ColorMixin:WrapTextInColorCode
	function color_proto:WrapTextInColorCode(text)
		return "|c" .. self.hex .. text .. "|r"
	end

	function E:CreateColor(r, g, b, a)
		local color = Mixin({}, ColorMixin, color_proto)
		color:SetRGBA(r, g, b, a)

		return color
	end
end

-----------
-- MATHS --
-----------

function E:Round(v)
	return m_floor(v + 0.5)
end
