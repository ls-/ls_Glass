local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local tonumber = _G.tonumber

-- Mine
E.VER = {}
E.VER.string = C_AddOns.GetAddOnMetadata(addonName, "Version")
E.VER.number = tonumber(E.VER.string:gsub("%D", ""), nil)

local function updateCallback()
	E:UpdateEditBoxFont()
	E:UpdateMessageFonts()
	E:UpdateTabAlpha()
	E:UpdateScrollButtonAlpha()
	E:UpdateButtonAlpha()

	for i = 1, 10 do
		E:ForMessageLinePool(i, "UpdateWidth")
		E:ForMessageLinePool(i, "UpdateHeight")
		E:ForMessageLinePool(i, "UpdateGradientBackgroundAlpha")
		E:ForMessageLinePool(i, "UpdatePadding")

		E:ForChatFrame(i, "ToggleScrollButtons")
		E:ForChatFrame(i, "FadeInChatWidgets")
		E:ForChatFrame(i, "FadeInMessages")
	end
end

local function shutdownCallback()
	C.db.profile.version = E.VER.number
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	-- stop loading if ElvUI with enabled chat is detected
	local elvUI = ElvUI and ElvUI[1]
	if elvUI and elvUI.private.chat.enable then
		elvUI:AddIncompatible("Chat", addonName)

		return
	end

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
				E:HandleQuickJoinToastButton(QuickJoinToastButton)
				E:HandleChannelButton(ChatFrameChannelButton)
				E:HandleMenuButton(ChatFrameMenuButton)
				E:HandleTTSButton(TextToSpeechButton)
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

				self.elapsed = 0
			end
		end)

		-- ? consider moving it elsewhere as well
		E:RegisterEvent("GLOBAL_MOUSE_DOWN", function(button)
			if C.db.profile.chat.fade.enabled then
				if button == "LeftButton" and C.db.profile.chat.fade.click then
					for frame in next, chatFrames do
						if frame:IsShown() and frame:IsMouseOver() and not frame:IsMouseOverHyperlink() then
							if frame:IsScrolling() then
								frame:ResetFadingTimer()
							else
								frame:FadeInMessages()
							end
						end
					end

					for frame in next, tempChatFrames do
						if frame:IsShown() and frame:IsMouseOver() and not frame:IsMouseOverHyperlink() then
							if frame:IsScrolling() then
								frame:ResetFadingTimer()
							else
								frame:FadeInMessages()
							end
						end
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

				if not C.options then
					E:CreateConfig()
				end

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
					if not C.options then
						E:CreateConfig()
					end

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
					if not C.options then
						E:CreateConfig()
					end

					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			end
		end
	end)
end)
