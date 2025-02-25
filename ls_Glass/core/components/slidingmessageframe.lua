local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_ceil = _G.math.ceil
local m_max = _G.math.max
local m_min = _G.math.min
local next = _G.next
local pcall = _G.pcall
local t_wipe = _G.table.wipe

-- Mine
local CHAT_FADE_OUT_DURATION = 0.6
local DOCK_FADE_IN_DURATION = 0.1
local DOCK_FADE_OUT_DURATION = 0.6
local DOCK_FADE_OUT_DELAY = 4

local DOWN = -1
local UP = 1

local MAX_SCROLL = 8
local MED_SCROLL = 4
local MIN_SCROLL = 1

do
	local map = {}

	function E:GetSlidingFrameForChatFrame(chatFrame)
		return map[chatFrame]
	end

	function E:SetSlidingFrameForChatFrame(chatFrame, slidingFrame)
		map[chatFrame] = slidingFrame
	end
end

--------------
-- SMOOTHER --
--------------

local setSmoothScroll

do
	local SCROLL_DURATION = 0.2
	local POST_SCROLL_DELAY = 0.1
	local THRESHOLD = 1/120

	local activeFrames = {}

	local smoother = CreateFrame("Frame")

	local function clamp(v)
		if v > SCROLL_DURATION then
			return SCROLL_DURATION
		elseif v < 0 then
			return 0
		end

		return v
	end

	-- out cubic
	local function smoothFunc(t, b, c)
		t = t / SCROLL_DURATION - 1
		return c * (t ^ 3 + 1) + b
	end

	local elapsed = 0
	local function onUpdate(_, e)
		elapsed = elapsed + e
		if elapsed >= THRESHOLD then
			for frame, data in next, activeFrames do
				data[2] = data[2] + elapsed
				data[1](smoothFunc(clamp(data[2]), data[3], data[4]))

				if data[2] >= SCROLL_DURATION + POST_SCROLL_DELAY then
					if data[5] then
						data[5]()
					end

					activeFrames[frame] = nil
				end
			end

			if not next(activeFrames) then
				smoother:SetScript("OnUpdate", nil)
			end

			elapsed = 0
		end
	end

	function setSmoothScroll(frame, func, change, callback)
		elapsed = THRESHOLD
		-- func, time, start, change, callback
		activeFrames[frame] = {func, 0, frame:GetVerticalScroll(), change, callback}

		if not smoother:GetScript("OnUpdate") then
			smoother:SetScript("OnUpdate", onUpdate)
		end

		return true
	end
end

------------------
-- GLOBAL HOOKS --
------------------

hooksecurefunc("ChatFrame_ChatPageUp", function()
	local slidingFrame = E:GetSlidingFrameForChatFrame(SELECTED_CHAT_FRAME)
	if slidingFrame then
		slidingFrame:OnMouseWheel(UP, MAX_SCROLL)
	end
end)

hooksecurefunc("ChatFrame_ChatPageDown", function()
	local slidingFrame = E:GetSlidingFrameForChatFrame(SELECTED_CHAT_FRAME)
	if slidingFrame then
		slidingFrame:OnMouseWheel(DOWN, MAX_SCROLL)
	end
end)

hooksecurefunc("ChatFrame_ScrollToBottom", function()
	local slidingFrame = E:GetSlidingFrameForChatFrame(SELECTED_CHAT_FRAME)
	if slidingFrame then
		slidingFrame:FastForward()

		E:FadeOut(slidingFrame.ScrollToBottomButton, 0, 0.1, function()
			slidingFrame.ScrollToBottomButton:SetState(1, true)
			slidingFrame.ScrollToBottomButton:Hide()
		end)
	end
end)

----------------
-- BLIZZ CHAT --
----------------

local function chatFrame_OnSizeChanged(self, width, height)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		width, height = E:Round(width), E:Round(height)

		slidingFrame:SetSize(width, height)
		slidingFrame.ScrollChild:SetSize(width, height)

		slidingFrame.isLayoutDirty = true
		slidingFrame.isDisplayDirty = true

		-- don't use StopMovingOrSizing, OnSizeChanged can fire for a multitude of reasons, but only one ends with
		-- StopMovingOrSizing
		if slidingFrame.refreshTimer then
			slidingFrame.refreshTimer:Cancel()
		end

		slidingFrame.refreshTimer = C_Timer.NewTimer(0.5, slidingFrame.funcCache.refreshDisplay)
	end
end

local function chatFrame_SetShownHook(self, isShown)
	if isShown then
		self.FontStringContainer:Hide()

		local slidingFrame = E:GetSlidingFrameForChatFrame(self)
		if slidingFrame then
			-- FCF indiscriminately calls :SetShown(true) when adding new tabs, I don't need to do anything when that happens
			if not slidingFrame:IsShown() then
				slidingFrame:Show()
			end
		end
	end
end

local function chatFrame_HideHook(self)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame:Hide()
	end
end

local function chatFrame_RemoveMessagesByPredicateHook(self)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame.isLayoutDirty = true
		slidingFrame.isDisplayDirty = true

		if slidingFrame:IsShown() then
			slidingFrame:OnShow()
		end
	end
end

local function chatFrame_OnHyperlinkEnterHook(self, link, text, fontString)
	if C.db.profile.chat.tooltips then
		local linkType = LinkUtil.SplitLinkData(link)
		if linkType == "battlepet" then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 4, 2)
			BattlePetToolTip_ShowLink(text)
		elseif linkType ~= "trade" then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 4, 2)

			local isOK = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
			if not isOK then
				GameTooltip:Hide()
			else
				GameTooltip:Show()
			end
		end
	end

	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame.mouseOverHyperlinkMessageLine = fontString:GetParent()
	end
end

local function chatFrame_OnHyperlinkLeaveHook(self)
	BattlePetTooltip:Hide()
	GameTooltip:Hide()

	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame and slidingFrame:IsShown() then
		slidingFrame.mouseOverHyperlinkMessageLine = nil
	end
end

local alertingFrames = {}

local function isAnyChatAlerting()
	return not not next(alertingFrames)
end

hooksecurefunc("FCF_StartAlertFlash", function(chatFrame)
	alertingFrames[chatFrame] = true

	E:FadeIn(GeneralDockManager, DOCK_FADE_IN_DURATION)
end)

hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
	alertingFrames[chatFrame] = nil
end)

---------------------------
-- SLIDING MESSAGE FRAME --
---------------------------

local hookedChatFrames = {}

local CHAT_FRAME_TEXTURES = {
	"Background",
	"TopLeftTexture",
	"TopRightTexture",
	"BottomLeftTexture",
	"BottomRightTexture",
	"TopTexture",
	"BottomTexture",
	"LeftTexture",
	"RightTexture",
}

local object_proto = {
	firstActiveMessageIndex = 0,
	isAtBottom = true,
	isAtTop = true,
	isScrolling = false,
	isLayoutDirty = true,
	isDisplayDirty = true,
	canProcessIncoming = true,
	numIncomingMessages = 0,
	numIncomingMessagesWhileScrolling = 0,
	overrideFadeTimestamp = 0,
}

function object_proto:CaptureChatFrame(chatFrame)
	self:ReleaseAllMessageLines()

	self.ChatFrame = chatFrame
	self.ChatTab = _G[chatFrame:GetName() .. "Tab"]
	self.EditBox = _G[chatFrame:GetName() .. "EditBox"]
	self.ButtonFrame = chatFrame.buttonFrame
	self.historyBuffer = chatFrame.historyBuffer
	self:SetParent(chatFrame)

	E:SetSlidingFrameForChatFrame(chatFrame, self)

	-- ! Comment me out!
	-- if not chatFrame.bg1 then
	-- 	chatFrame.bg1 = chatFrame:CreateTexture(nil, "BACKGROUND")
	-- 	chatFrame.bg1:SetColorTexture(0, 0.6, 0.3, 0.3)
	-- 	chatFrame.bg1:SetPoint("TOPLEFT")
	-- 	chatFrame.bg1:SetPoint("BOTTOMLEFT")
	-- 	chatFrame.bg1:SetWidth(25)

	-- 	chatFrame.bg2 = chatFrame:CreateTexture(nil, "BACKGROUND")
	-- 	chatFrame.bg2:SetColorTexture(0, 0.6, 0.3, 0.3)
	-- 	chatFrame.bg2:SetPoint("TOPRIGHT")
	-- 	chatFrame.bg2:SetPoint("BOTTOMRIGHT")
	-- 	chatFrame.bg2:SetWidth(25)
	-- end

	chatFrame:SetClampedToScreen(false)
	chatFrame:SetClampRectInsets(0, 0, 0, 0)
	chatFrame:SetResizeBounds(176, 64)
	chatFrame:EnableMouse(false)
	chatFrame:SetScript("OnUpdate", nil)

	E:ForceHide(chatFrame.ScrollBar)
	E:ForceHide(chatFrame.ScrollToBottomButton)

	for _, texture in next, CHAT_FRAME_TEXTURES do
		local obj = _G[chatFrame:GetName() .. texture]
		if obj then
			obj:SetTexture(0)
		end
	end

	local width, height = chatFrame:GetSize()
	width, height = E:Round(width), E:Round(height)

	self:SetPoint("TOPLEFT", chatFrame)
	self:SetSize(width, height)

	self.ScrollChild:SetSize(width, height)

	-- ! it's safer to hide the string container than the chat frame itself
	chatFrame.FontStringContainer:Hide()

	if not hookedChatFrames[chatFrame] then
		chatFrame:HookScript("OnSizeChanged", chatFrame_OnSizeChanged)

		hooksecurefunc(chatFrame, "SetShown", chatFrame_SetShownHook)
		hooksecurefunc(chatFrame, "Hide", chatFrame_HideHook)

		-- some addon devs tend to hook AddMessage to add filtering, so do it the hard way
		hooksecurefunc(chatFrame.historyBuffer, "PushFront", function()
			local slidingFrame = E:GetSlidingFrameForChatFrame(chatFrame)
			if slidingFrame then
				slidingFrame:NewIncomingMessage()
			end
		end)

		-- redraw the frame if visible
		hooksecurefunc(chatFrame, "RemoveMessagesByPredicate", chatFrame_RemoveMessagesByPredicateHook)

		chatFrame:HookScript("OnHyperlinkEnter", chatFrame_OnHyperlinkEnterHook)
		chatFrame:HookScript("OnHyperlinkLeave", chatFrame_OnHyperlinkLeaveHook)

		hookedChatFrames[chatFrame] = true
	end

	if chatFrame:GetNumMessages() > 0 then
		self:SetFirstVisibleMessageID(1)
	end

	self:SetShown(chatFrame:IsShown())
end

function object_proto:ReleaseChatFrame()
	if self.ChatFrame then
		E:SetSlidingFrameForChatFrame(self.ChatFrame, nil)

		self.ChatFrame = nil
		self.ChatTab = nil
		self.EditBox = nil
		self.ButtonFrame = nil
		self.historyBuffer = nil
		t_wipe(self.activeMessages)
		t_wipe(self.backfillMessages)

		self:ReleaseAllMessageLines()
		self:SetParent(UIParent)
		self:Hide()
	end
end

function object_proto:OnShow()
	if not self:CanShowMessages() then return end

	-- happens when additional docked chat frames were resized while hidden OnSizeChanged will fire first followed by
	-- OnShow
	self:ResetFadingTimer()
	self:RefreshIfNecessary()
	self:ResetState()
end

function object_proto:OnHide()
	self.isMouseOver = nil
	self.isLayoutDirty = true
	self.isDisplayDirty = true
	self.numIncomingMessages = 0
	self.mouseOverHyperlinkMessageLine = nil
	-- self.numIncomingMessagesWhileScrolling = 0
end

function object_proto:CanShowMessages()
	return self:GetBottom() and self:IsShown() and self.ScrollChild:GetHeight() ~= 0
end

function object_proto:UpdateLayout()
	self.isLayoutDirty = false

	t_wipe(self.activeMessages)
	t_wipe(self.backfillMessages)

	if self.messageFramePool then
		self.messageFramePool:ReleaseAll()
		self.messageFramePool:UpdateWidth()
		self.messageFramePool:UpdateHeight()
	end
end

function object_proto:UpdateDisplay()
	self.isDisplayDirty = false

	self:RefreshActive(self:GetFirstVisibleMessageID())
end

function object_proto:RefreshIfNecessary()
	if self.isLayoutDirty then
		self:UpdateLayout()
	end

	if self.isDisplayDirty then
		self:UpdateDisplay()
	end
end

function object_proto:GetNumHistoryElements()
	return self.historyBuffer:GetNumElements()
end

function object_proto:GetHistoryEntryAtIndex(index)
	return self.historyBuffer:GetEntryAtIndex(index)
end

function object_proto:SetAtBottom(state)
	self.isAtBottom = state
end

function object_proto:IsAtBottom()
	return self.isAtBottom
end

function object_proto:SetAtTop(state)
	self.isAtTop = state
end

function object_proto:IsAtTop()
	return self.isAtTop
end

-- TODO: Remove
function object_proto:GetNumActiveMessageLines()
	if self.messageFramePool then
		return self.messageFramePool:GetNumActive()
	end

	return 0
end

function object_proto:AcquireMessageLine()
	if not self.messageFramePool then
		self.messageFramePool = E:CreateMessageLinePool(self.ScrollChild, self:GetID())
	end

	return self.messageFramePool:Acquire()
end

-- TODO: Remove
function object_proto:ReleaseMessageLine(messageLine)
	if self.messageFramePool and messageLine then
		self.messageFramePool:Release(messageLine)
	end
end

function object_proto:ReleaseAllMessageLines()
	if self.messageFramePool then
		self.messageFramePool:ReleaseAll()
	end
end

function object_proto:GetMaxNumVisibleLines()
	return m_ceil(self:GetHeight() / self:GetMessageLineHeight())
end

function object_proto:GetMessageLineHeight()
	return C.db.profile.chat[self:GetID()].font.size + C.db.profile.chat[self:GetID()].y_padding * 2
end

function object_proto:IsDocked()
	return self.ChatFrame.isDocked
end

function object_proto:IsScrolling()
	return self.isScrolling
end

function object_proto:SetScrolling(state)
	self.isScrolling = state
end

function object_proto:SetSmoothScroll(func, change, callback)
	if C.db.profile.chat.smooth then
		setSmoothScroll(self, func, change, callback)

		self.numIncomingMessagesWhileScrolling = 0
		self:SetScrolling(true)
	else
		func(self:GetVerticalScroll() + change)

		if callback then
			callback()
		end
	end
end

function object_proto:UpdateFirstVisibleMessageInfo()
	for i = 1, #self.backfillMessages do
		local messageLine = self.backfillMessages[i]

		if messageLine:GetID() == 0 then break end
		if messageLine:GetTop() < self:GetBottom() then break end

		-- ideally, it should be messageLine:GetBottom() <= self:GetBottom() in here, but since I'm dealing with floats I can
		-- forget about having equal values, instead subtract 0.01 to account for any rounding bs
		if messageLine:GetBottom() - 0.01 < self:GetBottom() and messageLine:GetTop() > self:GetBottom() then
			self:SetFirstVisibleMessageInfo(messageLine:GetID(), messageLine:GetBottom() - self:GetBottom())

			break
		end
	end

	for i = 1, #self.activeMessages do
		local messageLine = self.activeMessages[i]

		if messageLine:GetID() == 0 then break end

		-- ideally, it should be messageLine:GetBottom() <= self:GetBottom() in here, but since I'm dealing with floats I can
		-- forget about having equal values, instead subtract 0.01 to account for any rounding bs
		if messageLine:GetBottom() - 0.01 < self:GetBottom() and messageLine:GetTop() > self:GetBottom() then
			self:SetFirstVisibleMessageInfo(messageLine:GetID(), messageLine:GetBottom() - self:GetBottom())

			break
		end
	end
end

function object_proto:ResetState(doNotRefresh)
	self:UpdateFirstVisibleMessageInfo()

	local offset = self:GetFirstVisibleMessageOffset()
	if offset < 1 and offset > -1 then
		offset = 0
	end

	self:SetVerticalScroll(offset)

	local id = self:GetFirstVisibleMessageID() + self.numIncomingMessagesWhileScrolling
	self.numIncomingMessagesWhileScrolling = 0

	if id == 0 and self:GetNumHistoryElements() > 0 then
		id = 1
	end

	if not doNotRefresh then
		self:RefreshActive(id)
		self:RefreshBackfill(0)
	end

	self:SetFirstActiveMessageID(id)

	self:SetAtBottom(id == 0 or (id == 1 and offset == 0))
	self:SetAtTop(id == self:GetNumHistoryElements() and self:GetLastActiveMessageOffset() < self:GetMessageLineHeight())

	if not doNotRefresh then
		self:UpdateFading()
	end

	self:SetScrolling(false)
end

function object_proto:EnableIncomingProcessing(state)
	self.canProcessIncoming = state
end

function object_proto:CanProcessIncoming()
	return self.canProcessIncoming
end

function object_proto:ResetStateAfterUserScroll()
	self:ResetState()
	self:EnableIncomingProcessing(self:IsAtBottom())
end

function object_proto:SetFirstVisibleMessageID(id)
	self.firstVisibleMessageID = id
end

function object_proto:SetFirstVisibleMessageInfo(id, offset)
	self.firstVisibleMessageID = id
	self.firstVisibleMessageOffset = offset
end

function object_proto:GetFirstVisibleMessageID()
	return self.firstVisibleMessageID or 0
end

function object_proto:GetFirstVisibleMessageOffset()
	return self.firstVisibleMessageOffset or 0
end

function object_proto:SetLastActiveMessageInfo(id, offset)
	self.lastActiveMessageID = id
	self.lastActiveMessageOffset = m_max(offset, 0)
end

-- TODO: Remove
function object_proto:GetLastActiveMessageID()
	return self.lastActiveMessageID or 0
end

function object_proto:GetLastActiveMessageOffset()
	return self.lastActiveMessageOffset or 0
end

function object_proto:SetLastBackfillMessageInfo(id, offset)
	self.lastBackfillMessageID = id
	self.lastBackfillMessageOffset = offset
end

-- TODO: Remove
function object_proto:GetLastBackfillMessageID()
	return self.lastBackfillMessageID or 0
end

function object_proto:GetLastBackfillMessageOffset()
	return self.lastBackfillMessageOffset or 0
end

function object_proto:RefreshBackfill(startIndex, maxLines, maxPixels, fadeIn)
	if not self:CanShowMessages() then return end

	local checkLines = maxLines ~= false
	maxLines = maxLines or 6
	maxPixels = maxPixels or self:GetBottom()

	self:SetLastBackfillMessageInfo(0, 0)

	local lineIndex = 0
	local messageID, messageInfo, messageLine

	local isFull = false
	while not isFull do
		lineIndex = lineIndex + 1
		messageID = startIndex - lineIndex + 1

		messageInfo = self:GetHistoryEntryAtIndex(messageID)
		if not messageInfo then
			lineIndex = lineIndex - 1

			break
		end

		messageLine = self.backfillMessages[lineIndex]
		if not messageLine then
			messageLine = self:AcquireMessageLine()
			self.backfillMessages[lineIndex] = messageLine

			messageLine:ClearAllPoints()

			if lineIndex == 1 then
				messageLine:SetPoint("TOPLEFT", self.ScrollChild, "BOTTOMLEFT", 0, 0)
			else
				messageLine:SetPoint("TOPLEFT", self.backfillMessages[lineIndex - 1], "BOTTOMLEFT", 0, 0)
			end
		end

		messageLine:SetMessage(messageID, messageInfo.timestamp, messageInfo.message, messageInfo.r, messageInfo.g, messageInfo.b)

		if fadeIn then
			messageLine:SetAlpha(0)
			messageLine:FadeIn()
		else
			messageLine:SetAlpha(1)
		end

		if checkLines then
			isFull = lineIndex == maxLines
		else
			isFull = messageLine:GetBottom() - 1 <= maxPixels
		end
	end

	if lineIndex > 0 then
		-- I want it to be a positive value, so flip it around instead of doing messageLine:GetBottom() - self:GetBottom()
		self:SetLastBackfillMessageInfo(messageID, self:GetBottom() - self.backfillMessages[lineIndex]:GetBottom())
	end

	-- just hide the excess, releasing and removing them here is expensive, they'll be taken care of when the frame gets
	-- hidden
	for i = lineIndex + 1, #self.backfillMessages do
		if self.backfillMessages[i]:GetID() ~= 0 then
			self.backfillMessages[i]:ClearMessage()
		end
	end
end

function object_proto:SetFirstActiveMessageID(id)
	self.firstActiveMessageID = id
end

function object_proto:GetFirstActiveMessageID()
	return self.firstActiveMessageID or 0
end

function object_proto:GetNegativeVerticalOffset()
	return m_max(self:GetBottom() - self.ScrollChild:GetBottom(), self:GetLastBackfillMessageOffset())
end

function object_proto:ResetFadingTimer()
	self.overrideFadeTimestamp = GetTime()
end

function object_proto:CanFade()
	return C.db.profile.chat.fade.enabled and self:IsAtBottom()
end

function object_proto:CalculateAlphaFromTimestampDelta(delta)
	local config = C.db.profile.chat.fade

	if delta <= config.out_delay then
		return 1
	end

	delta = delta - config.out_delay
	if delta >= CHAT_FADE_OUT_DURATION then
		return 0
	end

	return 1 - delta / CHAT_FADE_OUT_DURATION
end

function object_proto:UpdateFading()
	if not self:CanShowMessages() or not self:CanFade() then return end

	local now = GetTime()

	for i = 1, #self.activeMessages do
		local messageLine = self.activeMessages[i]

		if messageLine:GetID() == 0 then return end

		local timeDelta = now - m_max(messageLine:GetTimestamp(), self.overrideFadeTimestamp)
		local alpha = self:CalculateAlphaFromTimestampDelta(timeDelta)

		messageLine:SetAlpha(alpha)

		if alpha < 1 then
			messageLine:FadeOut(0, CHAT_FADE_OUT_DURATION * alpha)
		else
			messageLine:FadeOut(C.db.profile.chat.fade.out_delay - timeDelta, CHAT_FADE_OUT_DURATION)
		end
	end
end

function object_proto:ShouldShowMessage(delta)
	delta = delta - C.db.profile.chat.fade.out_delay
	if delta >= CHAT_FADE_OUT_DURATION then
		return false
	end

	return true
end

function object_proto:RefreshActive(startIndex, maxPixels)
	if not self:CanShowMessages() then return end

	maxPixels = maxPixels or self:GetTop()

	self:SetLastActiveMessageInfo(0, 0)

	local now = GetTime()
	local lineIndex = 0
	local messageID, messageInfo, messageLine

	local isFull = false
	while not isFull do
		lineIndex = lineIndex + 1
		messageID = startIndex + lineIndex - 1

		messageInfo = self:GetHistoryEntryAtIndex(messageID)
		if not messageInfo then
			lineIndex = lineIndex - 1

			break
		end

		if not self:ShouldShowMessage(now - m_max(messageInfo.timestamp, self.overrideFadeTimestamp)) then
			lineIndex = lineIndex - 1

			break
		end

		messageLine = self.activeMessages[lineIndex]
		if not messageLine then
			messageLine = self:AcquireMessageLine()
			self.activeMessages[lineIndex] = messageLine

			messageLine:ClearAllPoints()

			if lineIndex == 1 then
				messageLine:SetPoint("BOTTOMLEFT", self.ScrollChild, "BOTTOMLEFT", 0, 0)
			else
				messageLine:SetPoint("BOTTOMLEFT", self.activeMessages[lineIndex - 1], "TOPLEFT", 0, 0)
			end
		end

		messageLine:SetMessage(messageID, messageInfo.timestamp, messageInfo.message, messageInfo.r, messageInfo.g, messageInfo.b)
		messageLine:StopFading(1)

		-- if :GetTop() is nil, then it means that the line is already hidden
		if not messageLine:GetTop() then
			lineIndex = lineIndex - 1

			break
		end

		isFull = messageLine:GetTop() + 1 >= maxPixels
	end

	if lineIndex > 0 then
		-- 2 is kinda arbitrary, I just want to make sure that only the first line of the last message is visible at the top
		self:SetLastActiveMessageInfo(messageID, self.activeMessages[lineIndex]:GetTop() - self:GetBottom() - self:GetMessageLineHeight() + 2)
	end

	-- just hide the excess, releasing and removing them here is expensive, they'll be taken care of when the frame gets
	-- hidden
	for i = lineIndex + 1, #self.activeMessages do
		if self.activeMessages[i]:GetID() ~= 0 then
			self.activeMessages[i]:ClearMessage()
		end
	end
end

function object_proto:FadeInMessages()
	if not self:CanShowMessages() then return end

	self:ResetFadingTimer()
	self:RefreshActive(self:GetFirstActiveMessageID())
	self:UpdateFading()
end

function object_proto:FastForward()
	if not self:CanShowMessages() then return end

	self:ResetFadingTimer()

	if self:GetNumHistoryElements() > 0 then
		self.numIncomingMessages = 0

		local id = m_min(self:GetNumHistoryElements(), self:GetMaxNumVisibleLines(), self:GetFirstActiveMessageID())
		if id >= 1 then
			self:RefreshActive(id)
			self:RefreshBackfill(id - 1, id - 1)
			self:EnableIncomingProcessing(true)
			self:SetSmoothScroll(self.funcCache.baseScroll, self:GetNegativeVerticalOffset(), self.funcCache.baseScrollCallback)
		else
			local offset = self:GetNegativeVerticalOffset()
			if offset > 0 then
				self:EnableIncomingProcessing(true)
				self:SetSmoothScroll(self.funcCache.baseScroll, offset, self.funcCache.baseScrollCallback)
			else
				self:ResetStateAfterUserScroll()
			end
		end
	end
end

function object_proto:ToggleScrollButtons()
	self.ScrollDownButton:SetShown(C.db.profile.chat.buttons.up_and_down)
	self.ScrollUpButton:SetShown(C.db.profile.chat.buttons.up_and_down)
end

function object_proto:OnMouseWheel(delta, scrollOverride)
	if self:GetNumHistoryElements() == 0 then
		return self:SetFirstActiveMessageID(0)
	end

	self:ResetFadingTimer()

	if delta == DOWN and self:IsAtBottom() then
		self:RefreshActive(self:GetFirstActiveMessageID())
		self:UpdateFading()

		return
	end

	if delta == UP and self:IsAtTop() then
		self:RefreshActive(self:GetFirstActiveMessageID())

		return
	end

	self:ResetState(true)

	local numLines = scrollOverride or (IsShiftKeyDown() and MAX_SCROLL or IsControlKeyDown() and MIN_SCROLL or MED_SCROLL)
	local offset = numLines * self:GetMessageLineHeight()

	if delta == DOWN then
		self:RefreshActive(self:GetFirstActiveMessageID())
		self:RefreshBackfill(self:GetFirstActiveMessageID() - 1, false, self:GetBottom() - offset)

		offset = m_min(offset, self:GetNegativeVerticalOffset())
	else
		self:RefreshActive(self:GetFirstActiveMessageID(), self:GetTop() + offset)
		self:RefreshBackfill(0)

		offset = m_min(offset, self:GetLastActiveMessageOffset())
	end

	self:SetSmoothScroll(self.funcCache.baseScroll, -delta * offset, self.funcCache.userScrollCallback)
end

function object_proto:HasIncomingMessages()
	return self.numIncomingMessages ~= 0
end

function object_proto:NewIncomingMessage()
	if self:IsShown() then
		if self:IsScrolling() or not self:CanProcessIncoming() then
			self.numIncomingMessagesWhileScrolling = self.numIncomingMessagesWhileScrolling + 1
			-- TODO: auto-scroll to the bottom if we reached reached the end of the historyBuffer
		end

		if self:CanProcessIncoming() then
			self.numIncomingMessages = self.numIncomingMessages + 1
		end

		if not self:IsAtBottom() then
			self.ScrollToBottomButton:SetState(2)
		end
	else
		if not self:IsAtBottom() then
			self:SetFirstVisibleMessageID(self:GetFirstVisibleMessageID() + 1)
		end
	end
end

function object_proto:IsMouseOverHyperlink()
	return self.mouseOverHyperlinkMessageLine and self.mouseOverHyperlinkMessageLine:IsShown()
end

function object_proto:OnFrame()
	if not self:CanShowMessages() or self:IsScrolling() then return end

	if self:HasIncomingMessages() and self:CanProcessIncoming() then
		self:ProcessIncoming(self.numIncomingMessages)
		self.numIncomingMessages = 0
	end

	self:UpdateChatWidgetFading()
end

function object_proto:FadeInChatWidgets()
	if not self:CanShowMessages() then return end

	self.isMouseOver = nil

	E:StopFading(self.ChatTab, 1)
	E:StopFading(self.ButtonFrame, 1)
	E:StopFading(self.ScrollDownButton, 1)
	E:StopFading(self.ScrollUpButton, 1)

	-- there's only one visible docked frame at a time
	if self:IsDocked() then
		E:StopFading(GeneralDockManager, 1)
	end

	self:UpdateChatWidgetFading()
end

function object_proto:UpdateChatWidgetFading()
	if not self:CanShowMessages() then return end
	if not C.db.profile.dock.fade.enabled then return end

	local isMouseOver = self:IsMouseOver(26, -36, -36, 36)
	if isMouseOver ~= self.isMouseOver then
		self.isMouseOver = isMouseOver

		-- ! DO NOT SHOW/HIDE tabs or gdm, it'll taint EVERYTHING, just adjust its alpha
		if isMouseOver then
			if self:IsDocked() then
				E:FadeIn(GeneralDockManager, DOCK_FADE_IN_DURATION, function()
					if self.isMouseOver then
						E:StopFading(GeneralDockManager, 1)
					elseif not isAnyChatAlerting() then
						E:FadeOut(GeneralDockManager, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
					end
				end)
			else
				E:FadeIn(self.ChatTab, DOCK_FADE_IN_DURATION, function()
					if self.isMouseOver then
						E:StopFading(self.ChatTab, 1)
					else
						E:FadeOut(self.ChatTab, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
					end
				end)
			end

			E:FadeIn(self.ButtonFrame, DOCK_FADE_IN_DURATION, function()
				if self.isMouseOver then
					E:StopFading(self.ButtonFrame, 1)
				else
					E:FadeOut(self.ButtonFrame, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
				end
			end)

			if C.db.profile.chat.buttons.up_and_down then
				E:FadeIn(self.ScrollDownButton, DOCK_FADE_IN_DURATION, function()
					if self.isMouseOver then
						E:StopFading(self.ScrollDownButton, 1)
					else
						E:FadeOut(self.ScrollDownButton, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
					end
				end)

				E:FadeIn(self.ScrollUpButton, DOCK_FADE_IN_DURATION, function()
					if self.isMouseOver then
						E:StopFading(self.ScrollUpButton, 1)
					else
						E:FadeOut(self.ScrollUpButton, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
					end
				end)
			end
		else
			if self:IsDocked() then
				if not isAnyChatAlerting() then
					E:FadeOut(GeneralDockManager, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
				end
			else
				if not self.isDragging then
					E:FadeOut(self.ChatTab, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
				else
					E:StopFading(self.ChatTab, 1)
				end
			end

			E:FadeOut(self.ButtonFrame, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)

			if C.db.profile.chat.buttons.up_and_down then
				E:FadeOut(self.ScrollDownButton, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
				E:FadeOut(self.ScrollUpButton, DOCK_FADE_OUT_DELAY, DOCK_FADE_OUT_DURATION)
			end
		end
	end
end

function object_proto:ProcessIncoming(num)
	self:RefreshBackfill(num, num, nil, true)
	self:SetSmoothScroll(self.funcCache.baseScroll, self:GetLastBackfillMessageOffset(), self.funcCache.baseScrollCallback)
end

function object_proto:Release()
	self.pool:Release(self)
end

do
	local frames = {}
	local curID = nil

	local slidingMessageFramePool = CreateUnsecuredObjectPool(
		function(pool)
			local frame = Mixin(CreateFrame("ScrollFrame", "LSGlassFrame" .. curID, UIParent, "LSGlassHyperlinkPropagator"), object_proto)
			frame:EnableMouse(false)
			frame:Hide()

			-- local dbg = frame:CreateTexture("ARTWORK")
			-- dbg:SetAllPoints()
			-- dbg:SetColorTexture(0.1, 0.1, 0.1, 0.4)

			frame.activeMessages = {}
			frame.backfillMessages = {}
			frame.pool = pool

			local scrollChild = CreateFrame("Frame", nil, frame, "LSGlassHyperlinkPropagator")
			frame:SetFrameLevel(frame:GetFrameLevel() + 1)
			frame:SetScrollChild(scrollChild)
			frame.ScrollChild = scrollChild

			-- local dbg = scrollChild:CreateTexture("ARTWORK")
			-- dbg:SetAllPoints()
			-- dbg:SetColorTexture(0, 0.4, 0, 0.4)

			frame:SetScript("OnHide", frame.OnHide)
			frame:SetScript("OnShow", frame.OnShow)
			frame:SetScript("OnMouseWheel", frame.OnMouseWheel)

			local scrollToBottomButton = E:CreateScrollToBottomButton(frame)
			scrollToBottomButton:SetPoint("BOTTOMRIGHT", -4, 4)
			scrollToBottomButton:SetFrameLevel(frame:GetFrameLevel() + 2)
			frame.ScrollToBottomButton = scrollToBottomButton

			local scrollDownButton = E:CreateScrollButton(frame, 3)
			scrollDownButton:SetPoint("BOTTOMRIGHT", scrollToBottomButton, "TOPRIGHT", 0, 2)
			scrollDownButton:SetShown(C.db.profile.chat.buttons.up_and_down)
			scrollDownButton:SetFrameLevel(frame:GetFrameLevel() + 2)
			frame.ScrollDownButton = scrollDownButton

			local scrollUpButton = E:CreateScrollButton(frame, 4)
			scrollUpButton:SetPoint("BOTTOMRIGHT", scrollDownButton, "TOPRIGHT", 0, 2)
			scrollUpButton:SetShown(C.db.profile.chat.buttons.up_and_down)
			scrollUpButton:SetFrameLevel(frame:GetFrameLevel() + 2)
			frame.ScrollUpButton = scrollUpButton

			-- these functions are always the same, so just cache them
			frame.funcCache = {
				baseScroll = function(n)
					frame:SetVerticalScroll(n)
				end,
				baseScrollCallback = function()
					frame:ResetState()
				end,
				userScrollCallback = function()
					frame:ResetStateAfterUserScroll()

					if not frame:IsAtBottom() then
						frame.ScrollToBottomButton:Show()

						if frame:HasIncomingMessages() then
							frame.ScrollToBottomButton:SetState(2, true)
						else
							frame.ScrollToBottomButton:SetState(1, true)
						end

						E:FadeIn(frame.ScrollToBottomButton, 0.1)
					else
						E:FadeOut(frame.ScrollToBottomButton, 0, 0.1, function()
							frame.ScrollToBottomButton:SetState(1, true)
							frame.ScrollToBottomButton:Hide()
						end)
					end
				end,
				refreshDisplay = function()
					frame:RefreshIfNecessary()

					frame.refreshTimer = nil
				end,
			}

			-- local backdrop = E:CreateBackdrop(frame, 0, -4)
			-- frame.Backdrop = backdrop

			-- backdrop:SetBackdropColor(0, 0, 0, 0.4)
			-- backdrop:SetBackdropBorderColor(0, 0, 0, 0.4)

			frames[curID] = frame

			return frame
		end,
		function(_, frame, isNew)
			if isNew then return end

			frame:ReleaseChatFrame()
		end
	)

	function E:HandleChatFrame(chatFrame, id)
		if chatFrame == ChatFrame2 then
			-- Combat Log, I might want to skin it, but without sliding
		else
			-- for the sake of matching names, otherwise it breaks my brain
			curID = chatFrame:GetID()

			local frame = slidingMessageFramePool:Acquire()
			frame:SetID(id)
			frame:CaptureChatFrame(chatFrame)

			return frame
		end
	end

	function E:ForChatFrame(id, method, ...)
		local frame = frames[id]
		if frame and frame[method] then
			frame[method](frame, ...)
		end
	end
end
