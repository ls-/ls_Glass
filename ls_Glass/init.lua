local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local pcall = _G.pcall
local tonumber = _G.tonumber

-- Mine
function E:OnInitialize()
	self.VER = {}
	self.VER.string = GetAddOnMetadata(addonName, "Version")
	self.VER.number = tonumber(self.VER.string:gsub("%D", ""), nil)

	C.db = LibStub("AceDB-3.0"):New("LS_GLASS_GLOBAL_CONFIG", D, true)

	E:CreateFonts()
end

local chatFrames = {}
local tempChatFrames = {}
local expectedChatFrames = {}

function E:OnEnable()
	E:HandleDock(GeneralDockManager)

	-- TODO: Move these somewhere better
	ChatFrame1:HookScript("OnHyperlinkEnter", function(chatFrame, link, text)
		if C.db.profile.chat.tooltips then
			local linkType = LinkUtil.SplitLinkData(link)
			if linkType == "battlepet" then
				GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)
				BattlePetToolTip_ShowLink(text)
			else
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

		expectedChatFrames[chatType][chatTarget] = chatFrame
	end)

	hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, chatTarget)
		local chatFrame = expectedChatFrames[chatType] and expectedChatFrames[chatType][chatTarget]
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
	updater:SetScript("OnUpdate", function (_, elapsed)
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
				local isMouseOver = ChatFrame1:IsMouseOver(26, -36, 0, 0)
				if self.isMouseOver ~= isMouseOver then
					self.isMouseOver = isMouseOver

					if isMouseOver then
						GeneralDockManager:Show()
						E:FadeIn(GeneralDockManager, 0.1, function()
							if self.isMouseOver then
								E:StopFading(GeneralDockManager, 1)
							else
								E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration, function()
									GeneralDockManager:Hide()
								end)
							end
						end)
					else
						E:FadeOut(GeneralDockManager, 4, C.db.profile.dock.fade.out_duration, function()
							GeneralDockManager:Hide()
						end)
					end
				end
			end

			self.elapsed = 0
		end
	end)
end
