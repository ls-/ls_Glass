local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local Core, Constants = unpack(select(2, ...))
local UIManager = Core:GetModule("UIManager")

local CreateChatDock = Core.Components.CreateChatDock
local CreateChatTab = Core.Components.CreateChatTab
local CreateEditBox = Core.Components.CreateEditBox
local CreateMoverDialog = Core.Components.CreateMoverDialog
local CreateMoverFrame = Core.Components.CreateMoverFrame
local CreateSlidingMessageFramePool = Core.Components.CreateSlidingMessageFramePool

----
-- UIManager Module
function UIManager:OnInitialize()
	self.state = {
		frames = {},
		tabs = {},
		temporaryFrames = {},
		temporaryTabs = {}
	}
end

function UIManager:OnEnable()

	-- Chat dock
	-- self.dock = E:CreateTabHeader(self.container)

	-- SlidingMessageFrames
	-- self.slidingMessageFramePool = CreateSlidingMessageFramePool(self.container)

	-- for i=1, NUM_CHAT_WINDOWS do
	-- 	local chatFrame = _G["ChatFrame"..i]
	-- 	local smf = self.slidingMessageFramePool:Acquire()
	-- 	smf:Init(chatFrame)

	-- 	self.state.frames[i] = smf
	-- 	self.state.tabs[i] = CreateChatTab(smf)
	-- end

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

	-- -- Force classic chat style
	-- if GetCVar("chatStyle") ~= "classic" then
	--   SetCVar("chatStyle", "classic")
	--   E.notify('Chat Style set to "Classic Style"')

	--   -- Resets the background that IM style causes
	--   self.editBox:SetFocus()
	--   self.editBox:ClearFocus()
	-- end

	-- -- Handle temporary chat frames (whisper popout, pet battle)
	-- self:RawHook("FCF_OpenTemporaryWindow", function (...)
	--   local chatFrame = self.hooks["FCF_OpenTemporaryWindow"](...)
	--   local smf = self.slidingMessageFramePool:Acquire()
	--   smf:Init(chatFrame)

	--   self.state.temporaryFrames[chatFrame:GetName()] = smf
	--   self.state.temporaryTabs[chatFrame:GetName()] = CreateChatTab(smf)
	--   return chatFrame
	-- end, true)

	-- -- Close window
	-- self:RawHook("FCF_Close", function (chatFrame)
	--   self.hooks["FCF_Close"](chatFrame)

	--   self.slidingMessageFramePool:Release(self.state.temporaryFrames[chatFrame:GetName()])
	--   self.state.temporaryFrames[chatFrame:GetName()] = nil
	--   self.state.temporaryTabs[chatFrame:GetName()] = nil
	-- end, true)

	-- Start rendering
	-- TODO: Consider moving it elsewhere
	-- self.tickerFrame = CreateFrame("Frame", "GlassUpdaterFrame", UIParent)

	-- self.timeElapsed = 0
	-- self.tickerFrame:SetScript("OnUpdate", function (_, elapsed)
	-- 	self.timeElapsed = self.timeElapsed + elapsed

	-- 	while (self.timeElapsed > 0.01) do
	-- 		self.timeElapsed = self.timeElapsed - 0.01

	-- 		self.container:OnFrame()

	-- 		for _, smf in ipairs(self.state.frames) do
	-- 			smf:OnFrame()
	-- 		end

	-- 		for _, smf in pairs(self.state.temporaryFrames) do
	-- 			smf:OnFrame()
	-- 		end
	-- 	end
	-- end)
end
