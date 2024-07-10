local addonName, ns = ...
local L = ns.L

-- Lua
local _G = getfenv(0)
local error = _G.error
local ipairs = _G.ipairs
local m_floor = _G.math.floor
local next= _G.next
local pcall = _G.pcall
local s_format = _G.string.format
local t_insert = _G.table.insert
local tonumber = _G.tonumber
local type = _G.type

-- Mine
local E, C, D = {}, {}, {}
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

do
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local dispatcher = CreateFrame("Frame", "LSGEventFrame")
	dispatcher:SetScript("OnEvent", function(_, event, ...)
		for func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end)

	function E:RegisterEvent(event, func)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			dispatcher:RegisterEvent(event)
		end

		registeredEvents[event][func] = true
	end

	function E:UnregisterEvent(event, func)
		local funcs = registeredEvents[event]

		if funcs and funcs[func] then
			funcs[func] = nil

			if not next(funcs) then
				registeredEvents[event] = nil

				dispatcher:UnregisterEvent(event)
			end
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

	local function outCubic(t, b, c, d)
		t = t / d - 1
		return clamp(c * (t ^ 3 + 1) + b)
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

				object:SetAlpha(outCubic(data.fadeTimer, data.initAlpha, data.finalAlpha - data.initAlpha, data.duration))
				-- object:SetAlpha(lerp(data.initAlpha, data.finalAlpha, data.fadeTimer / data.duration))

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

	function E:FadeIn(object, duration, callback, delay)
		if not object then return end

		add(FADE_IN, object, delay or 0, duration * (1 - object:GetAlpha()), callback)
	end

	function E:FadeOut(object, ...)
		if not object then return end

		add(FADE_OUT, object, ...)
	end

	function E:StopFading(object, alpha)
		if not object then return end

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

----------
-- MISC --
----------

do
	local link = ""

	local popup = CreateFrame("Frame", nil, UIParent)
	popup:Hide()
	popup:SetPoint("CENTER", UIParent, "CENTER")
	popup:SetSize(384, 78)
	popup:EnableMouse(true)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFixedFrameStrata(true)
	popup:SetFrameLevel(100)
	popup:SetFixedFrameLevel(true)

	local border = CreateFrame("Frame", nil, popup, "DialogBorderTranslucentTemplate")
	border:SetAllPoints(popup)

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetHeight(32)
	editBox:SetPoint("TOPLEFT", 22, -10)
	editBox:SetPoint("TOPRIGHT", -16, -10)

	editBox:SetScript("OnChar", function(self)
		self:SetText(link)
		self:HighlightText()
	end)

	editBox:SetScript("OnMouseUp", function(self)
		self:HighlightText()
	end)

	editBox:SetScript("OnEscapePressed", function()
		popup:Hide()
	end)

	local button = CreateFrame("Button", nil, popup, "UIPanelButtonNoTooltipTemplate")
	button:SetText(L["OKAY"])
	button:SetSize(90, 22)
	button:SetPoint("BOTTOM", 0, 16)

	button:SetScript("OnClick", function()
		popup:Hide()
	end)

	popup:SetScript("OnHide", function()
		link = ""
		editBox:SetText(link)
	end)

	popup:SetScript("OnShow", function()
		editBox:SetText(link)
		editBox:SetFocus()
		editBox:HighlightText()
	end)

	function E:ShowLinkCopyPopup(text)
		popup:Hide()
		link = text
		popup:Show()
	end
end

------------
-- CONFIG --
------------

do
	local isInit = false

	local function getChatFrameName(info)
		local id = tonumber(info[#info])
		return GetChatWindowInfo(id)
	end

	local function isChatFrameHidden(info)
		local id = tonumber(info[#info])
		local _, _, _, _, _, _, isShown, _, isDocked = GetChatWindowInfo(id)

		return not (isShown or (not isShown and isDocked))
	end

	local function createChatFrameConfig(id, order)
		return {
			order = order,
			type = "group",
			name = getChatFrameName,
			hidden = isChatFrameHidden,
			get = function(info)
				return C.db.profile.chat[id][info[#info]]
			end,
			args = {
				alpha = {
					order = 1,
					type = "range",
					name = L["BACKGROUND_ALPHA"],
					hidden = false,
					min = 0, max = 1, step = 0.01, bigStep = 0.1,
					set = function(_, value)
						if C.db.profile.chat[id].alpha ~= value then
							C.db.profile.chat[id].alpha = value

							-- E:UpdateBackdrops()
						end
					end,
				},
				-- solid = {},
				x_padding = {
					order = 3,
					type = "range",
					name = L["X_PADDING"],
					hidden = false,
					min = 1, max = 20, step = 1,
					set = function(_, value)
						if C.db.profile.chat[id].x_padding ~= value then
							C.db.profile.chat[id].x_padding = value

							-- E:UpdateMessageLinesPadding()
						end
					end,
				},
				y_padding = {
					order = 4,
					type = "range",
					name = L["Y_PADDING"],
					hidden = false,
					min = 0, max = 10, step = 1,
					set = function(_, value)
						if C.db.profile.chat[id].y_padding ~= value then
							C.db.profile.chat[id].y_padding = value

							-- E:UpdateMessageLinesHeights()
							-- E:UpdateMessageLinesPadding()
						end
					end,
				},
				spacer1 = {
					order = 9,
					type = "description",
					name = " ",
					hidden = false,
				},
				font = {
					order = 10,
					type = "group",
					inline = true,
					name = L["FONT"],
					hidden = false,
					get = function(info)
						return C.db.profile.chat[id].font[info[#info]]
					end,
					set = function(info, value)
						if C.db.profile.chat[id].font[info[#info]] ~= value then
							C.db.profile.chat[id].font[info[#info]] = value

							E:UpdateMessageFont(id)
						end
					end,
					args = {
						size = {
							order = 1,
							type = "range",
							name = L["SIZE"],
							min = 10, max = 20, step = 1,
						},
						outline = {
							order = 2,
							type = "toggle",
							name = L["OUTLINE"],
						},
						shadow = {
							order = 3,
							type = "toggle",
							name = L["SHADOW"],
						},
					},
				},
			},
		}
	end

	function E:CreateConfig()
		if isInit then return end

		C.options = {
			type = "group",
			name = "|cffffffff" .. L["LS_GLASS"] .. "|r",
			args = {
				general = {
					order = 10,
					type = "group",
					name = L["GENERAL"],
					childGroups = "tab",
					args = {
						font = {
							order = 1,
							type = "select",
							name = L["FONT"],
							dialogControl = "LSM30_Font",
							values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
							get = function()
								return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font) and C.db.profile.font or LibStub("LibSharedMedia-3.0"):GetDefault("font")
							end,
							set = function(_, value)
								C.db.profile.font = value

								E:UpdateEditBoxFont()
								E:UpdateMessageFonts()
								-- E:UpdateMessageLinesHeights()
								-- E:UpdateMessageLinesPadding()
							end
						},
						spacer1 = {
							order = 9,
							type = "description",
							name = " ",
						},
						dock = {
							order = 10,
							type = "group",
							inline = true,
							name = "WIP Dock",
							args = {
								alpha = {
									order = 1,
									type = "range",
									name = L["BACKGROUND_ALPHA"],
									min = 0, max = 1, step = 0.01, bigStep = 0.1,
									get = function()
										return C.db.profile.dock.alpha
									end,
									set = function(_, value)
										if C.db.profile.dock.alpha ~= value then
											C.db.profile.dock.alpha = value

											E:UpdateBackdrops()
										end
									end,
								},
								fade = {
									order = 2,
									type = "toggle",
									name = L["FADING"],
									get = function()
										return C.db.profile.dock.fade.enabled
									end,
									set = function(_, value)
										if C.db.profile.dock.fade.enabled ~= value then
											C.db.profile.dock.fade.enabled = value

											-- E:ResetSlidingFrameDockFading()
										end
									end,
								},
							},
						},
						spacer2 = {
							order = 19,
							type = "description",
							name = " ",
						},
						edit = {
							order = 20,
							type = "group",
							inline = true,
							name = "WIP Editbox",
							get = function(info)
								return C.db.profile.edit[info[#info]]
							end,
							args = {
								alpha = {
									order = 1,
									type = "range",
									name = L["BACKGROUND_ALPHA"],
									min = 0, max = 1, step = 0.01, bigStep = 0.1,
									set = function(_, value)
										if C.db.profile.edit.alpha ~= value then
											C.db.profile.edit.alpha = value

											-- E:UpdateBackdrops()
										end
									end,
								},
								position = {
									order = 2,
									type = "select",
									name = "WIP Position",
									-- name = L["EDITBOX_POSITION"],
									values = {
										["bottom"] = L["BOTTOM"],
										["top"] = L["TOP"],
									},
									set = function(_, value)
										if C.db.profile.edit.position ~= value then
											C.db.profile.edit.position = value

											-- E:UpdateEditBoxes()
										end
									end,
								},
								offset = {
									order = 3,
									type = "range",
									name = L["OFFSET"],
									min = 0, max = 64, step = 1,
									set = function(_, value)
										if C.db.profile.dock.offset ~= value then
											C.db.profile.dock.offset = value

											-- E:UpdateEditBoxes()
										end
									end,
								},
								spacer1 = {
									order = 9,
									type = "description",
									name = " ",
								},
								font = {
									order = 10,
									type = "group",
									inline = true,
									name = L["FONT"],
									get = function(info)
										return C.db.profile.edit.font[info[#info]]
									end,
									set = function(info, value)
										if C.db.profile.edit.font[info[#info]] ~= value then
											C.db.profile.edit.font[info[#info]] = value

											-- E:UpdateEditBoxFont()
										end
									end,
									args = {
										size = {
											order = 1,
											type = "range",
											name = L["SIZE"],
											min = 10, max = 20, step = 1,
										},
										outline = {
											order = 2,
											type = "toggle",
											name = L["OUTLINE"],
										},
										shadow = {
											order = 3,
											type = "toggle",
											name = L["SHADOW"],
										},
									},
								},
							},
						},
						spacer3 = {
							order = 29,
							type = "description",
							name = " ",
						},
						[ "1"] = createChatFrameConfig(1, 30), -- general
						-- [ "2"] = createChatFrameConfig(2, 31), -- combat log
						[ "3"] = createChatFrameConfig(3, 32), -- voice
						[ "4"] = createChatFrameConfig(4, 33),
						[ "5"] = createChatFrameConfig(5, 34),
						[ "6"] = createChatFrameConfig(6, 35),
						[ "7"] = createChatFrameConfig(7, 36),
						[ "8"] = createChatFrameConfig(8, 37),
						[ "9"] = createChatFrameConfig(9, 38),
						["10"] = createChatFrameConfig(10, 39),
					},
				},
				about = {
					order = 110,
					type = "group",
					name = L["INFO"],
					args = {
						desc = {
							order = 1,
							type = "description",
							name = L["LS_GLASS"] .. " |cffffd200v|r" .. E.VER.string,
							width = "full",
							fontSize = "medium",
						},
						spacer_1 = {
							order = 2,
							type = "description",
							name = " ",
							width = "full",
						},
						support = {
							order = 3,
							type = "group",
							name = L["SUPPORT"],
							inline = true,
							args = {
								discord = {
									order = 1,
									type = "execute",
									name = L["DISCORD"],
									func = function()
										E:ShowLinkCopyPopup("https://discord.gg/7QcJgQkDYD")
									end,
								},
								github = {
									order = 2,
									type = "execute",
									name = L["GITHUB"],
									func = function()
										E:ShowLinkCopyPopup("https://github.com/ls-/ls_Glass/issues")
									end,
								},
							},
						},
						spacer_2 = {
							order = 4,
							type = "description",
							name = " ",
							width = "full",
						},
						downloads = {
							order = 5,
							type = "group",
							name = L["DOWNLOADS"],
							inline = true,
							args = {
								cf = {
									order = 1,
									type = "execute",
									name = L["CURSEFORGE"],
									func = function()
										E:ShowLinkCopyPopup("https://www.curseforge.com/wow/addons/ls-glass")
									end,
								},
								wago = {
									order = 2,
									type = "execute",
									name = L["WAGO"],
									func = function()
										E:ShowLinkCopyPopup("https://addons.wago.io/addons/ls-glass")
									end,
								},
							},
						},
						spacer_3 = {
							order = 6,
							type = "description",
							name = " ",
							width = "full",
						},
						CHANGELOG = {
							order = 7,
							type = "group",
							name = L["CHANGELOG"],
							inline = true,
							args = {
								latest = {
									order = 1,
									type = "description",
									name = E.CHANGELOG,
									width = "full",
									fontSize = "medium",
								},
								spacer_1 = {
									order = 2,
									type = "description",
									name = " ",
									width = "full",
								},
								cf = {
									order = 3,
									type = "execute",
									name = L["CHANGELOG_FULL"],
									func = function()
										E:ShowLinkCopyPopup("https://github.com/ls-/ls_Glass/blob/master/CHANGELOG.md")
									end,
								},
							},
						},
					},
				},
			},
		}

		LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)
		LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 1024, 768)

		C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
		C.options.args.profiles.order = 100
		C.options.args.profiles.desc = nil
	end
end
