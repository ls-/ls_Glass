local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local pcall = _G.pcall
local tonumber = _G.tonumber

-- Mine
E.VER = {}
E.VER.string = C_AddOns.GetAddOnMetadata(addonName, "Version")
E.VER.number = tonumber(E.VER.string:gsub("%D", ""), nil)

local function updateCallback()
	-- E:UpdateMessageFont()
	-- E:UpdateMessageLinesHeights()
	-- E:UpdateMessageLinesBackgrounds()
	-- E:UpdateBackdrops()
	-- E:UpdateEditBoxFont()
	-- E:UpdateEditBoxes()
	-- E:ResetSlidingFrameDockFading()
	-- E:ResetSlidingFrameChatFading()
end

local function shutdownCallback()
	C.db.profile.version = E.VER.number
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	if LS_GLASS_GLOBAL_CONFIG then
		if LS_GLASS_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_GLASS_GLOBAL_CONFIG.profiles do
				E:Modernize(data, profile, "profile")
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
			-- general = {},
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

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:CreateFonts()
		E:HandleDock(GeneralDockManager)

		local chatFrames = {}
		local tempChatFrames = {}
		local expectedChatFrames = {}

		-- static chat frames
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = E:HandleChatFrame(_G["ChatFrame" .. i], i)
			if frame then
				chatFrames[frame] = true
			end

			E:HandleChatTab(_G["ChatFrame" .. i .. "Tab"])
			E:HandleEditBox(_G["ChatFrame" .. i .. "EditBox"])
			E:HandleMinimizeButton(_G["ChatFrame" .. i .. "ButtonFrameMinimizeButton"], _G["ChatFrame" .. i .. "Tab"])

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

			-- the PET_BATTLE_COMBAT_LOG chatType doesn't have chatTarget
			if chatTarget then
				expectedChatFrames[chatType][chatTarget] = chatFrame
			else
				expectedChatFrames[chatType] = chatFrame
			end
		end)

		hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, chatTarget)
			local chatFrame = chatTarget and (expectedChatFrames[chatType] and expectedChatFrames[chatType][chatTarget]) or expectedChatFrames[chatType]
			if chatFrame then
				local frame = E:HandleChatFrame(chatFrame, 1)
				if frame then
					E:HandleChatTab(_G[chatFrame:GetName() .. "Tab"])
					E:HandleEditBox(_G[chatFrame:GetName() .. "EditBox"])
					E:HandleMinimizeButton(_G[chatFrame:GetName() .. "ButtonFrameMinimizeButton"], _G[chatFrame:GetName() .. "Tab"])

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

		local alertingTabs = {}

		hooksecurefunc("FCFTab_UpdateAlpha", function(chatFrame)
			local tab = _G[chatFrame:GetName() .. "Tab"]
			if tab then
				alertingTabs[tab] = tab.alerting and true or nil

				local isAlerting = false
				for _, v in next, alertingTabs do
					isAlerting = isAlerting or v
				end

				if isAlerting then
					E:FadeIn(GeneralDockManager, 0.1)
				end

				LSGlassUpdater.isAlerting = isAlerting
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
								elseif not self.isAlerting then
									E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration)
								end
							end)
						elseif not self.isAlerting then
							E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration)
						end
					end
				end

				self.elapsed = 0
			end
		end)

		-- ? consider moving it elsewhere as well
		E:RegisterEvent("GLOBAL_MOUSE_DOWN", function(button)
			if button == "LeftButton" and C.db.profile.chat.fade.click then
				for frame in next, chatFrames do
					if frame:IsShown() and frame:IsMouseOver() and not frame:IsMouseOverHyperlink() then
						frame:FadeInMessages()
					end
				end

				for frame in next, tempChatFrames do
					if frame:IsShown() and frame:IsMouseOver() and not frame:IsMouseOverHyperlink() then
						frame:FadeInMessages()
					end
				end
			end
		end)

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

		AddonCompartmentFrame:RegisterAddon({
			text = L["LS_GLASS"],
			icon = "Interface\\AddOns\\ls_Glass\\assets\\logo-32",
			notCheckable = true,
			registerForAnyClick = true,
			func = function()
				if not InCombatLockdown() then
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			end,
		})

		E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
			LibStub("AceConfigDialog-3.0"):Close(addonName)
		end)

		SLASH_LSGLASS1 = "/lsglass"
		SLASH_LSGLASS2 = "/lsg"
		SlashCmdList["LSGLASS"] = function(msg)
			if msg == "" then
				if not InCombatLockdown() then
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			end
		end
	end)
end)
