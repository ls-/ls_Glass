local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local next = _G.next
local tonumber = _G.tonumber
local type = _G.type

-- Mine
local showLinkCopyPopup
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

	function showLinkCopyPopup(text)
		popup:Hide()
		link = text
		popup:Show()
	end
end

local function configReset(info)
	local option = C.options
	for i = 1, #info - 1 do
		option = option.args[info[i]]
	end

	local name = option.name
	if type(option.name) == "function" then
		name = option.name({info[#info - 1]})
	end

	return L["CONFIRM_RESET"]:format(name)
end

local function copyOptions(src, dest, ignoredKeys)
	for k, v in next, dest do
		if not (ignoredKeys and ignoredKeys[k]) then
			if src[k] ~= nil then
				if type(v) == "table" then
					if next(v) and type(src[k]) == "table" then
						copyOptions(src[k], v, ignoredKeys)
					end
				else
					if type(v) == type(src[k]) then
						dest[k] = src[k]
					end
				end
			end
		end
	end
end

local function createSpacer(order)
	return {
		order = order,
		type = "description",
		name = " ",
		hidden = false,
	}
end

local function getChatFrameName(info)
	local id = tonumber(info[#info])
	return GetChatWindowInfo(id)
end

local function isChatFrameShown(id)
	local _, _, _, _, _, _, isShown, _, isDocked = GetChatWindowInfo(id)
	return isShown or (not isShown and isDocked)
end

local function isChatFrameHidden(info)
	local id = tonumber(info[#info])
	return not isChatFrameShown(id)
end

local function getChatOptionsForCopy(id)
	local tabs = {}

	for i = 1, 10 do
		if i ~= id and i ~= 2 then
			if isChatFrameShown(i) then
				tabs[i] = GetChatWindowInfo(i)
			end
		end
	end

	return tabs
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
			reset = {
				type = "execute",
				order = 1,
				name = L["RESET_TO_DEFAULT"],
				confirm = configReset,
				hidden = false,
				func = function()
					copyOptions(D.profile.chat[id], C.db.profile.chat[id])

					E:UpdateMessageFont(id)
					E:ForMessageLinePool(id, "UpdatePadding")
					E:ForMessageLinePool(id, "UpdateHeight")
					E:ForMessageLinePool(id, "UpdateGradientBackgroundAlpha")
				end,
			},
			copy = {
				order = 2,
				type = "select",
				name = L["COPY_FROM"],
				hidden = false,
				values = function()
					return getChatOptionsForCopy(id)
				end,
				disabled = function()
					return not next(getChatOptionsForCopy(id))
				end,
				get = function() end,
				set = function(_, value)
					copyOptions(C.db.profile.chat[value], C.db.profile.chat[id])

					E:UpdateMessageFont(id)
					E:ForMessageLinePool(id, "UpdatePadding")
					E:ForMessageLinePool(id, "UpdateHeight")
					E:ForMessageLinePool(id, "UpdateGradientBackgroundAlpha")
				end,
			},
			spacer_1 = createSpacer(9),
			alpha = {
				order = 10,
				type = "range",
				name = L["BACKGROUND_ALPHA"],
				hidden = false,
				min = 0, max = 1, step = 0.01, bigStep = 0.1,
				set = function(_, value)
					if C.db.profile.chat[id].alpha ~= value then
						C.db.profile.chat[id].alpha = value

						E:ForMessageLinePool(id, "UpdateGradientBackgroundAlpha")
					end
				end,
			},
			-- solid = {},
			x_padding = {
				order = 13,
				type = "range",
				name = L["X_PADDING"],
				hidden = false,
				min = 1, max = 20, step = 1,
				set = function(_, value)
					if C.db.profile.chat[id].x_padding ~= value then
						C.db.profile.chat[id].x_padding = value

						E:ForMessageLinePool(id, "UpdatePadding")
					end
				end,
			},
			y_padding = {
				order = 14,
				type = "range",
				name = L["Y_PADDING"],
				hidden = false,
				min = 0, max = 10, step = 1,
				set = function(_, value)
					if C.db.profile.chat[id].y_padding ~= value then
						C.db.profile.chat[id].y_padding = value

						E:ForMessageLinePool(id, "UpdatePadding")
						E:ForMessageLinePool(id, "UpdateHeight")
					end
				end,
			},
			spacer_2 = createSpacer(19),
			font = {
				order = 20,
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
						E:ForMessageLinePool(id, "UpdateHeight")
					end
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 32, step = 1,
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

local isInit = false

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
				args = {
					warning = {
						order = 1,
						type = "description",
						name = L["CONFIG_WARNING"],
						fontSize = "medium",
						image = "Interface\\OPTIONSFRAME\\UI-OptionsFrame-NewFeatureIcon",
						imageWidth = 16,
						imageHeight = 16,
					},
					spacer_1 = createSpacer(9),
					font = {
						order = 10,
						type = "select",
						name = L["FONT"],
						width = 1.25,
						dialogControl = "LSM30_Font",
						values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
						get = function()
							return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font) and C.db.profile.font or LibStub("LibSharedMedia-3.0"):GetDefault("font")
						end,
						set = function(_, value)
							C.db.profile.font = value

							E:UpdateEditBoxFont()
							E:UpdateMessageFonts()

							-- some fonts are weird
							for i = 1, 10 do
								E:ForMessageLinePool(i, "UpdateHeight")
							end
						end
					},
					spacer_2 = createSpacer(19),
					dock = {
						order = 20,
						type = "group",
						inline = true,
						name = L["DOCK"],
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

										E:UpdateTabAlpha()
										E:UpdateScrollButtonAlpha()
										E:UpdateButtonAlpha()
									end
								end,
							},
							position = {
								order = 2,
								type = "select",
								name = L["POSITION"],
								values = {
									["left"] = L["LEFT"],
									["right"] = L["RIGHT"],
								},
								get = function()
									return C.db.profile.dock.buttons.position
								end,
								set = function(_, value)
									if C.db.profile.dock.buttons.position ~= value then
										C.db.profile.dock.buttons.position = value

										E:UpdateButtonFramePosition()
									end
								end,
							},
							fade = {
								order = 3,
								type = "toggle",
								name = L["FADING"],
								get = function()
									return C.db.profile.dock.fade.enabled
								end,
								set = function(_, value)
									if C.db.profile.dock.fade.enabled ~= value then
										C.db.profile.dock.fade.enabled = value

										for i = 1, 10 do
											E:ForChatFrame(i, "FadeInChatWidgets")
										end
									end
								end,
							},
							toasts = {
								order = 4,
								type = "toggle",
								name = L["QUICK_JOING_TOASTS"],
								get = function()
									return C.db.profile.dock.toasts.enabled
								end,
								set = function(_, value)
									if C.db.profile.dock.toasts.enabled ~= value then
										C.db.profile.dock.toasts.enabled = value

										if value then
											QuickJoinToastButton:SetScript("OnEvent", QuickJoinToastButton.OnEvent)
										else
											QuickJoinToastButton.displayedToast = nil
											QuickJoinToastButton:SetScript("OnEvent", nil)
										end
									end
								end,
							},
						},
					},
					spacer_3 = createSpacer(29),
					edit = {
						order = 30,
						type = "group",
						inline = true,
						name = L["EDITBOX"],
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

										E:UpdateEditBoxAlpha()
									end
								end,
							},
							position = {
								order = 2,
								type = "select",
								name = L["POSITION"],
								values = {
									["bottom"] = L["BOTTOM"],
									["top"] = L["TOP"],
								},
								set = function(_, value)
									if C.db.profile.edit.position ~= value then
										C.db.profile.edit.position = value

										E:UpdateEditBoxPosition()
									end
								end,
							},
							offset = {
								order = 3,
								type = "range",
								name = L["OFFSET"],
								min = 0, max = 64, step = 1,
								set = function(_, value)
									if C.db.profile.edit.offset ~= value then
										C.db.profile.edit.offset = value

										E:UpdateEditBoxPosition()
									end
								end,
							},
							spacer_1 = createSpacer(9),
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

										E:UpdateEditBoxFont()
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
					spacer_4 = createSpacer(39),
					chat = {
						order = 40,
						type = "group",
						-- inline = true,
						childGroups = "tab",
						name = L["CHAT"],
						get = function(info)
							return C.db.profile.chat[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.chat[info[#info]] ~= value then
								C.db.profile.chat[info[#info]] = value
							end
						end,
						args = {
							tooltips = {
								order = 1,
								type = "toggle",
								name = L["MOUSEOVER_TOOLTIPS"],
							},
							smooth = {
								order = 2,
								type = "toggle",
								name = L["SMOOTH_SCROLLING"],
							},
							up_and_down = {
								order = 3,
								type = "toggle",
								name = L["SCROLL_BUTTONS"],
								get = function()
									return C.db.profile.chat.buttons.up_and_down
								end,
								set = function(_, value)
									C.db.profile.chat.buttons.up_and_down = value

									for i = 1, 10 do
										E:ForChatFrame(i, "ToggleScrollButtons")
									end
								end,
							},
							spacer_1 = createSpacer(9),
							fade = {
								order = 10,
								type = "group",
								name = L["FADING"],
								inline = true,
								get = function(info)
									return C.db.profile.chat.fade[info[#info]]
								end,
								args = {
									enabled = {
										order = 1,
										type = "toggle",
										name = L["ENABLE"],
										set = function(_, value)
											if C.db.profile.chat.fade.enabled ~= value then
												C.db.profile.chat.fade.enabled = value

												if value then
													C.db.profile.chat.fade.click = false

													for i = 1, 10 do
														E:ForChatFrame(i, "ResetFadingTimer")
														E:ForChatFrame(i, "UpdateFading")
													end
												else
													for i = 1, 10 do
														E:ForChatFrame(i, "FadeInMessages")
													end
												end
											end
										end,
									},
									click = {
										order = 2,
										type = "toggle",
										name = L["SHOW_ON_CLICK"],
										disabled = function()
											return not C.db.profile.chat.fade.enabled
										end,
										set = function(_, value)
											if C.db.profile.chat.fade.click ~= value then
												C.db.profile.chat.fade.click = value
											end
										end,
									},
									out_delay = {
										order = 3,
										type = "range",
										name = L["FADE_OUT_DELAY"],
										min = 10, max = 240, step = 1, bigStep = 10,
										disabled = function()
											return not C.db.profile.chat.fade.enabled
										end,
										set = function(_, value)
											if C.db.profile.chat.fade.out_delay ~= value then
												C.db.profile.chat.fade.out_delay = value

												for i = 1, 10 do
													E:ForChatFrame(i, "ResetFadingTimer")
													E:ForChatFrame(i, "UpdateFading")
												end
											end
										end,
									},
								},
							},
							spacer_2 = createSpacer(19),
							[ "1"] = createChatFrameConfig(1, 20), -- general
							-- [ "2"] = createChatFrameConfig(2, 21), -- combat log
							[ "3"] = createChatFrameConfig(3, 22), -- voice
							[ "4"] = createChatFrameConfig(4, 23),
							[ "5"] = createChatFrameConfig(5, 24),
							[ "6"] = createChatFrameConfig(6, 25),
							[ "7"] = createChatFrameConfig(7, 26),
							[ "8"] = createChatFrameConfig(8, 27),
							[ "9"] = createChatFrameConfig(9, 28),
							["10"] = createChatFrameConfig(10, 29),
						},
					},
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
					spacer_1 = createSpacer(2),
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
									showLinkCopyPopup("https://discord.gg/7QcJgQkDYD")
								end,
							},
							github = {
								order = 2,
								type = "execute",
								name = L["GITHUB"],
								func = function()
									showLinkCopyPopup("https://github.com/ls-/ls_Glass/issues")
								end,
							},
						},
					},
					spacer_2 = createSpacer(4),
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
									showLinkCopyPopup("https://www.curseforge.com/wow/addons/ls-glass")
								end,
							},
							wago = {
								order = 2,
								type = "execute",
								name = L["WAGO"],
								func = function()
									showLinkCopyPopup("https://addons.wago.io/addons/ls-glass")
								end,
							},
						},
					},
					spacer_3 = createSpacer(6),
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
							spacer_1 = createSpacer(2),
							cf = {
								order = 3,
								type = "execute",
								name = L["CHANGELOG_FULL"],
								func = function()
									showLinkCopyPopup("https://github.com/ls-/ls_Glass/blob/master/CHANGELOG.md")
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
