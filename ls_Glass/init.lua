local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local pcall = _G.pcall
local tonumber = _G.tonumber

-- Mine
local function updateCallback()
	E:UpdateMessageFont()
	E:UpdateMessageLinesHeights()
	E:UpdateMessageLinesBackgrounds()
	E:UpdateBackdrops()
	E:UpdateEditBoxFont()
	E:UpdateEditBoxes()
	E:ResetSlidingFrameDockFading()
	E:ResetSlidingFrameChatFading()
end

local function shutdownCallback()
	C.db.profile.version = E.VER.number
end

function E:OnInitialize()
	self.VER = {}
	self.VER.string = GetAddOnMetadata(addonName, "Version")
	self.VER.number = tonumber(self.VER.string:gsub("%D", ""), nil)

	if LS_GLASS_GLOBAL_CONFIG then
		if LS_GLASS_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_GLASS_GLOBAL_CONFIG.profiles do
				self:Modernize(data, profile, "profile")
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_GLASS_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileChanged", updateCallback)
	C.db:RegisterCallback("OnProfileCopied", updateCallback)
	C.db:RegisterCallback("OnProfileReset", updateCallback)
	C.db:RegisterCallback("OnProfileShutdown", shutdownCallback)
	C.db:RegisterCallback("OnDatabaseShutdown", shutdownCallback)

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
					spacer1 = {
						order = 2,
						type = "description",
						name = " ",
					},
					font = {
						order = 3,
						type = "select",
						name = L["FONT"],
						dialogControl = "LSM30_Font",
						values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
						get = function()
							return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font) and C.db.profile.font or LibStub("LibSharedMedia-3.0"):GetDefault("font")
						end,
						set = function(_, value)
							C.db.profile.font = value

							E:UpdateMessageFont()
							E:UpdateEditBoxFont()
						end
					},
					spacer2 = {
						order = 9,
						type = "description",
						name = " ",
					},
					chat = {
						order = 10,
						type = "group",
						guiInline = true,
						name = L["MESSAGES"],
						get = function(info)
							return C.db.profile.chat[info[#info]]
						end,
						set = function(info, value)
							C.db.profile.chat[info[#info]] = value
						end,
						args = {
							alpha = {
								order = 1,
								type = "range",
								name = L["BACKGROUND_ALPHA"],
								min = 0, max = 1, step = 0.01, bigStep = 0.1,
								set = function(_, value)
									if C.db.profile.chat.alpha ~= value then
										C.db.profile.chat.alpha = value

										E:UpdateMessageLinesBackgrounds()
									end
								end,
							},
							x_padding = {
								order = 2,
								type = "range",
								name = L["X_PADDING"],
								min = 1, max = 20, step = 1,
								set = function(_, value)
									if C.db.profile.chat.x_padding ~= value then
										C.db.profile.chat.x_padding = value

										E:UpdateMessageLinesHorizPadding()
									end
								end,
							},
							y_padding = {
								order = 3,
								type = "range",
								name = L["Y_PADDING"],
								min = 1, max = 10, step = 1,
								set = function(_, value)
									if C.db.profile.chat.y_padding ~= value then
										C.db.profile.chat.y_padding = value

										E:UpdateMessageLinesHeights()
									end
								end,
							},
							slide_in_duration = {
								order = 4,
								type = "range",
								name = L["SLIDE_IN_DURATION"],
								min = 0, max = 1, step = 0.05,
							},
							tooltips = {
								order = 5,
								type = "toggle",
								name = L["MOUSEOVER_TOOLTIPS"],
							},
							spacer1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							font = {
								order = 10,
								type = "group",
								guiInline = true,
								name = L["FONT"],
								get = function(info)
									return C.db.profile.chat.font[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.chat.font[info[#info]]~= value then
										C.db.profile.chat.font[info[#info]]= value

										E:UpdateMessageFont()
									end
								end,
								args = {
									size = {
										order = 1,
										type = "range",
										name = L["SIZE"],
										min = 10, max = 20, step = 1,
										set = function(_, value)
											if C.db.profile.chat.font.size ~= value then
												C.db.profile.chat.font.size = value

												E:UpdateMessageFont()
												E:UpdateMessageLinesHeights()
											end
										end,
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
							spacer2 = {
								order = 19,
								type = "description",
								name = " ",
							},
							fade = {
								order = 20,
								type = "group",
								guiInline = true,
								name = L["FADING"],
								get = function(info)
									return C.db.profile.chat.fade[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.chat.fade[info[#info]]~= value then
										C.db.profile.chat.fade[info[#info]]= value

										E:ResetSlidingFrameChatFading()
									end
								end,
								args = {
									persistent = {
										order = 1,
										type = "toggle",
										name = L["PERSISTENT"],
									},
									in_duration = {
										order = 10,
										type = "range",
										name = L["FADE_IN_DURATION"],
										min = 0, max = 1, step = 0.05,
									},
									out_delay = {
										order = 11,
										type = "range",
										name = L["FADE_OUT_DELAY"],
										disabled = function()
											return C.db.profile.chat.fade.persistent
										end,
										min = 0, max = 120, step = 1,
									},
									out_duration = {
										order = 12,
										type = "range",
										name = L["FADE_OUT_DURATION"],
										disabled = function()
											return C.db.profile.chat.fade.persistent
										end,
										min = 0.1, max = 1, step = 0.05,
									},
								},
							},
						},
					},
					spacer3 = {
						order = 19,
						type = "description",
						name = " ",
					},
					dock = {
						order = 20,
						type = "group",
						guiInline = true,
						name = L["DOCK_AND_EDITBOX"],
						get = function(info)
							return C.db.profile.dock[info[#info]]
						end,
						args = {
							alpha = {
								order = 1,
								type = "range",
								name = L["BACKGROUND_ALPHA"],
								min = 0, max = 1, step = 0.01, bigStep = 0.1,
								set = function(_, value)
									if C.db.profile.dock.alpha ~= value then
										C.db.profile.dock.alpha = value

										E:UpdateBackdrops()
									end
								end,
							},
							edit_position = {
								order = 2,
								type = "select",
								name = L["EDITBOX_POSITION"],
								values = {
									["bottom"] = L["BOTTOM"],
									["top"] = L["TOP"],
								},
								get = function()
									return C.db.profile.dock.edit.position
								end,
								set = function(_, value)
									if C.db.profile.dock.edit.position ~= value then
										C.db.profile.dock.edit.position = value

										E:UpdateEditBoxes()
									end
								end,
							},
							edit_offset = {
								order = 3,
								type = "range",
								name = L["OFFSET"],
								min = 0, max = 64, step = 1,
								get = function()
									return C.db.profile.dock.edit.offset
								end,
								set = function(_, value)
									if C.db.profile.dock.edit.offset ~= value then
										C.db.profile.dock.edit.offset = value

										E:UpdateEditBoxes()
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
								guiInline = true,
								name = L["FONT_EDITBOX"],
								get = function(info)
									return C.db.profile.dock.font[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.dock.font[info[#info]]~= value then
										C.db.profile.dock.font[info[#info]]= value

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
							spacer2 = {
								order = 19,
								type = "description",
								name = " ",
							},
							fade = {
								order = 20,
								type = "group",
								guiInline = true,
								name = L["FADING"],
								get = function(info)
									return C.db.profile.dock.fade[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.dock.fade[info[#info]]~= value then
										C.db.profile.dock.fade[info[#info]]= value

										E:ResetSlidingFrameDockFading()
									end
								end,
								args = {
									enabled = {
										order = 1,
										type = "toggle",
										name = L["ENABLE"],
									},
									out_duration = {
										order = 12,
										type = "range",
										name = L["FADE_OUT_DURATION"],
										disabled = function()
											return not C.db.profile.dock.fade.enabled
										end,
										min = 0.1, max = 1, step = 0.05,
									},
								},
							},
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

	C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
	C.options.args.profiles.order = 100
	C.options.args.profiles.desc = nil

	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 1024, 768)

	local panel = CreateFrame("Frame", "LSGConfigPanel")
	panel:Hide()

	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetText(L["OPEN_CONFIG"])
	button:SetWidth(button:GetTextWidth() + 18)
	button:SetPoint("TOPLEFT", 16, -16)
	button:SetScript("OnClick", function()
		if not InCombatLockdown() then
			HideUIPanel(SettingsPanel)

			LibStub("AceConfigDialog-3.0"):Open(addonName)
		end
	end)

	Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, L["LS_GLASS"]))

	SLASH_LSGLASS1 = "/lsglass"
	SLASH_LSGLASS2 = "/lsg"
	SlashCmdList["LSGLASS"] = function(msg)
		if msg == "" then
			if not InCombatLockdown() then
				LibStub("AceConfigDialog-3.0"):Open(addonName)
			end
		end
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		LibStub("AceConfigDialog-3.0"):Close(addonName)
	end)
end

local chatFrames = {}
local tempChatFrames = {}
local expectedChatFrames = {}

function E:OnEnable()
	E:CreateFonts()

	E:HandleDock(GeneralDockManager)

	-- TODO: Move these somewhere better
	ChatFrame1:HookScript("OnHyperlinkEnter", function(chatFrame, link, text)
		if C.db.profile.chat.tooltips then
			local linkType = LinkUtil.SplitLinkData(link)
			if linkType == "battlepet" then
				GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)
				BattlePetToolTip_ShowLink(text)
			elseif linkType ~= "trade" then
				GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)

				local isOK = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
				if not isOK then
					GameTooltip:Hide()
				else
					GameTooltip:Show()
				end
			end
		end
	end)

	ChatFrame1:HookScript("OnHyperlinkLeave", function()
		BattlePetTooltip:Hide()
		GameTooltip:Hide()
	end)

	-- static chat frames
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = E:HandleChatFrame(_G["ChatFrame" .. i])
		if frame then
			chatFrames[frame] = true
		end

		E:HandleChatTab(_G["ChatFrame" .. i .. "Tab"])
		E:HandleEditBox(_G["ChatFrame" .. i .. "EditBox"])
		E:HandleMinimizeButton(_G["ChatFrame" .. i .. "ButtonFrameMinimizeButton"])

		if i == 1 then
			E:HandleChannelButton(ChatFrameChannelButton)
			E:HandleMenuButton(ChatFrameMenuButton)
		end
	end

	-- temporary chat frames
	hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame, chatType, chatTarget)
		if not expectedChatFrames[chatType] then
			expectedChatFrames[chatType] = {}
		end

		if chatTarget then
			expectedChatFrames[chatType][chatTarget] = chatFrame
		else
			expectedChatFrames[chatType] = chatFrame
		end
	end)

	hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, chatTarget)
		local chatFrame = chatTarget and (expectedChatFrames[chatType] and expectedChatFrames[chatType][chatTarget]) or expectedChatFrames[chatType]
		if chatFrame then
			local frame = E:HandleChatFrame(chatFrame)
			if frame then
				E:HandleChatTab(_G[chatFrame:GetName() .. "Tab"])
				E:HandleEditBox(_G[chatFrame:GetName() .. "EditBox"])
				E:HandleMinimizeButton(_G[chatFrame:GetName() .. "ButtonFrameMinimizeButton"])

				tempChatFrames[frame] = true
			end
		end
	end)

	hooksecurefunc("FCF_Close", function(chatFrame)
		local frame = E:GetSlidingFrameForChatFrame(chatFrame)
		if tempChatFrames[frame] then
			frame:Release()

			tempChatFrames[frame] = nil
		end
	end)

	hooksecurefunc("FCF_MinimizeFrame", function(chatFrame)
		if chatFrame.minFrame then
			E:HandleMinimizedTab(chatFrame.minFrame)
		end
	end)

	-- ? consider moving it elsewhere
	local updater = CreateFrame("Frame", "LSGlassUpdater", UIParent)
	updater:SetScript("OnUpdate", function (self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.01 then
			for frame in next, chatFrames do
				frame:OnFrame()
			end

			for frame in next, tempChatFrames do
				frame:OnFrame()
			end

			if C.db.profile.dock.fade.enabled then
				-- these use custom values for fading in/out because Blizz fade chat as well
				-- so I'm trying not to interfere with that
				-- ! DO NOT SHOW/HIDE gdm, it'll taint EVERYTHING, just adjust its alpha
				local isMouseOver = ChatFrame1:IsMouseOver(26, -36, 0, 0)
				if self.isMouseOver ~= isMouseOver then
					self.isMouseOver = isMouseOver

					if isMouseOver then
						E:FadeIn(GeneralDockManager, 0.1, function()
							if self.isMouseOver then
								E:StopFading(GeneralDockManager, 1)
							else
								E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration)
							end
						end)
					else
						E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration)
					end
				end
			end

			self.elapsed = 0
		end
	end)
end
