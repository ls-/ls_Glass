local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local Core, Constants = unpack(select(2, ...))
local UIManager = Core:GetModule("UIManager")

-- local CreateChatDock = Core.Components.CreateChatDock
-- local CreateChatTab = Core.Components.CreateChatTab
-- local CreateEditBox = Core.Components.CreateEditBox
-- local CreateMoverDialog = Core.Components.CreateMoverDialog
-- local CreateMoverFrame = Core.Components.CreateMoverFrame
-- local CreateSlidingMessageFramePool = Core.Components.CreateSlidingMessageFramePool


-- UIManager Module
function UIManager:OnInitialize()
	self.state = {
		frames = {},
		tabs = {},
		temporaryFrames = {},
		temporaryTabs = {}
	}
end

local chatFrames = {}
local tempChatFrames = {}
local expectedChatFrames = {}

function UIManager:OnEnable()
	-- GeneralDockManager:SetHeight(C.db.profile.tab.size + 4)
	-- GeneralDockManager.scrollFrame:SetHeight(C.db.profile.tab.size + 4)
	-- GeneralDockManager.scrollFrame.child:SetHeight(C.db.profile.tab.size + 4)

	ChatFrame1:HookScript("OnHyperlinkEnter", function(chatFrame, link)
		if C.db.profile.mouseover_tooltips then
			GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)
			GameTooltip:SetHyperlink(link)
		end
	end)

	ChatFrame1:HookScript("OnHyperlinkLeave", function()
		GameTooltip:Hide()
	end)

	-- permanent chat frames
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = E:HandleChatFrame(_G["ChatFrame" .. i])
		if frame then
			chatFrames[frame] = true
		end

		E:HandleChatTab(_G["ChatFrame" .. i .. "Tab"])
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
				tempChatFrames[frame] = true
			end

			E:HandleChatTab(_G[chatFrame:GetName() .. "Tab"])
		end
	end)

	hooksecurefunc("FCF_Close", function(chatFrame)
		local frame = chatFrame.SlidingMessageFrame
		if tempChatFrames[frame] then
			frame:Release()

			tempChatFrames[frame] = nil
		end
	end)

	-- -- Edit box
	-- self.editBox = CreateEditBox(self.container)

	-- -- Fix Battle.net Toast frame position
	-- BNToastFrame:ClearAllPoints()
	-- BNToastFrame:SetPoint("BOTTOMLEFT", ChatAlertFrame, "BOTTOMLEFT", 0, 0)

	-- ChatAlertFrame:ClearAllPoints()
	-- ChatAlertFrame:SetPoint("BOTTOMLEFT", self.container, "TOPLEFT", 15, 10)

	-- -- Hide other chat elements
	-- if Constants.ENV == "retail" then
	--   QuickJoinToastButton:Hide()
	-- end

	-- ChatFrameChannelButton:Hide()
	-- ChatFrameMenuButton:Hide()

	-- Start rendering
	-- TODO: Consider moving it elsewhere
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

			self.elapsed = 0
		end
	end)
end
