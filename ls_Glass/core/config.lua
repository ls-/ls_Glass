local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local tonumber = _G.tonumber

-- Mine
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

						E:ForMessageLinePool(id, "UpdateGradientBackgroundAlpha")
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

						E:ForMessageLinePool(id, "UpdatePadding")
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

						E:ForMessageLinePool(id, "UpdatePadding")
						E:ForMessageLinePool(id, "UpdateHeight")
					end
				end,
			},
			spacer_1 = {
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
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					font = {
						order = 10,
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

							-- some fonts are weird
							for i = 1, 10 do
								E:ForMessageLinePool(i, "UpdateHeight")
							end
						end
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
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
					spacer_3 = {
						order = 29,
						type = "description",
						name = " ",
					},
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

										-- E:UpdateBackdrops()
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
							spacer_1 = {
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
					spacer_4 = {
						order = 39,
						type = "description",
						name = " ",
					},
					chat = {
						order = 40,
						type = "group",
						-- inline = true,
						childGroups = "tab",
						name = L["CHAT"],
						get = function(info)
							return C.db.profile.chat[info[#info]]
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

									-- E:ToggleScrollButtons()
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
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
												end

												-- E:ResetSlidingFrameDockFading()
											end
										end,
									},
									click = {
										order = 2,
										type = "toggle",
										name = L["FADE_IN_ON_CLICK"],
										disabled = function()
											return not C.db.profile.chat.fade.enabled
										end,
										set = function(_, value)
											if C.db.profile.chat.fade.click ~= value then
												C.db.profile.chat.fade.click = value

												-- E:ResetSlidingFrameDockFading()
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
									},
								},
							},
							spacer_2 = {
								order = 19,
								type = "description",
								name = " ",
							},
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
