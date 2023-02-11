local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_ceil = _G.math.ceil
local m_min = _G.math.min
local next = _G.next
local t_insert = _G.table.insert
local t_removemulti = _G.table.removemulti
local t_wipe = _G.table.wipe

-- Mine
local LibEasing = LibStub("LibEasing-1.0")

do
	local map = {}

	function E:GetSlidingFrameForChatFrame(chatFrame)
		return map[chatFrame]
	end

	function E:SetSlidingFrameForChatFrame(chatFrame, slidingFrame)
		map[chatFrame] = slidingFrame
	end
end

----------------
-- BLIZZ CHAT --
----------------

local function chatFrame_OnSizeChanged(self, width, height)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		width, height = E:Round(width), E:Round(height)

		slidingFrame:SetSize(width, height)
		slidingFrame.ScrollChild:SetSize(width, height)

		t_wipe(slidingFrame.visibleLines)

		-- TODO: Refactor it later...
		if slidingFrame.messageFramePool then
			if slidingFrame:GetNumActiveMessageLines() > 0 then
				slidingFrame:ReleaseAllMessageLines()
			end

			for _, messageLine in slidingFrame.messageFramePool:EnumerateInactive() do
				messageLine:SetWidth(width)
				messageLine:SetGradientBackgroundSize(E:Round(width * 0.1), E:Round(width * 0.4))
			end
		end

		slidingFrame:SetFirstMessageIndex(0)

		slidingFrame.ScrollToBottomButton:Hide()
	end
end

local function chatFrame_ShowHook(self)
	self.FontStringContainer:Hide()

	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		-- FCF indiscriminately calls :Show() when adding new tabs, I don't need to do
		-- anything when that happens
		if not slidingFrame:IsShown() then
			slidingFrame:Show()
		end
	end
end

local function chatFrame_HideHook(self)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame:Hide()
	end
end

local function chatFrame_AddMessageHook(self)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		-- pull the data from history to account for any text processing done by other
		-- addons
		local data = slidingFrame:GetHistoryEntryAtIndex(1)
		slidingFrame:AddMessage(self, data.message, data.r, data.g, data.b)
	end
end

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

	"ButtonFrameBackground",
	"ButtonFrameTopLeftTexture",
	"ButtonFrameTopRightTexture",
	"ButtonFrameBottomLeftTexture",
	"ButtonFrameBottomRightTexture",
	"ButtonFrameTopTexture",
	"ButtonFrameBottomTexture",
	"ButtonFrameLeftTexture",
	"ButtonFrameRightTexture",
}

local object_proto = {
	firstMessageIndex = 0,
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

	-- it's safer to hide the string container than the chat frame itself
	chatFrame.FontStringContainer:Hide()

	if not hookedChatFrames[chatFrame] then
		chatFrame:HookScript("OnSizeChanged", chatFrame_OnSizeChanged)

		hooksecurefunc(chatFrame, "Show", chatFrame_ShowHook)
		hooksecurefunc(chatFrame, "Hide", chatFrame_HideHook)

		-- it's more convenient than hooking chatFrame.historyBuffer:PushFront()
		hooksecurefunc(chatFrame, "AddMessage", chatFrame_AddMessageHook)

		hookedChatFrames[chatFrame] = true
	end

	-- load any messages already in the chat frame
	for i = 1, chatFrame:GetNumMessages() do
		self:AddMessage(chatFrame, chatFrame:GetMessageInfo(i))
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
		t_wipe(self.visibleLines)
		t_wipe(self.incomingMessages)

		LibEasing:StopEasing(self:GetScrollingHandler())
		self:SetScrollingHandler(nil)

		self:ReleaseAllMessageLines()
		self:SetParent(UIParent)
		self:Hide()
	end
end

function object_proto:OnShow()
	LibEasing:StopEasing(self:GetScrollingHandler())
	self:SetScrollingHandler(nil)
	self:FastForward()

	self.ScrollToBottomButton:Hide()
end

function object_proto:OnHide()
	LibEasing:StopEasing(self:GetScrollingHandler())
	self:SetScrollingHandler(nil)

	t_wipe(self.visibleLines)
	self:ReleaseAllMessageLines()
end

function object_proto:GetNumHistoryElements()
	return self.historyBuffer:GetNumElements()
end

function object_proto:GetHistoryEntryAtIndex(index)
	return self.historyBuffer:GetEntryAtIndex(index)
end

function object_proto:SetFirstMessageIndex(index)
	self.firstMessageIndex = index
end

function object_proto:GetFirstMessageIndex()
	return self.firstMessageIndex
end

function object_proto:GetNumActiveMessageLines()
	if self.messageFramePool then
		return self.messageFramePool:GetNumActive()
	end

	return 0
end

function object_proto:AcquireMessageLine()
	if not self.messageFramePool then
		self.messageFramePool = E:CreateMessageLinePool(self.ScrollChild)
	end

	return self.messageFramePool:Acquire()
end

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
	return m_ceil(self:GetHeight() / (C.db.profile.chat.font.size + C.db.profile.chat.y_padding * 2))
end

function object_proto:ScrollTo(index, refreshFading, tryToFadeIn)
	if not self:IsShown() or self.ScrollChild:GetHeight() == 0 then return end

	local maxNumVisibleLines = self:GetMaxNumVisibleLines()
	local numVisibleLines = 0

	for i = 1, maxNumVisibleLines do
		local messageLine = self.visibleLines[i]
		if not messageLine then
			messageLine = self:AcquireMessageLine()
			self.visibleLines[i] = messageLine
		end

		messageLine:ClearAllPoints()

		if i == 1 then
			messageLine:SetPoint("BOTTOMLEFT", self.ScrollChild, "BOTTOMLEFT", 0, 0)
		else
			messageLine:SetPoint("BOTTOMLEFT", self.visibleLines[i - 1], "TOPLEFT", 0,0)
		end

		-- bail out if we're beyond the frame capacity
		if messageLine:GetBottom() > self:GetTop() then break end

		local messageInfo = self:GetHistoryEntryAtIndex(index + i)
		if messageInfo then
			messageLine:SetText(messageInfo.message, messageInfo.r, messageInfo.g, messageInfo.b)
			messageLine:Show()

			if refreshFading then
				if tryToFadeIn then
					E:FadeIn(messageLine, C.db.profile.chat.fade.in_duration, function()
						if not self.isMouseOver and not C.db.profile.chat.fade.persistent then
							E:FadeOut(messageLine, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
								messageLine:Hide()
							end)
						end
					end)
				else
					messageLine:SetAlpha(1)

					if not self.isMouseOver and not C.db.profile.chat.fade.persistent then
						E:FadeOut(messageLine, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
							messageLine:Hide()
						end)
					end
				end
			else
				if messageLine:GetAlpha() == 0 then
					messageLine:Hide()
				end
			end
		else
			messageLine:SetText("", 1, 1, 1)
			messageLine:Hide()
		end

		numVisibleLines = numVisibleLines + 1
	end

	for i = numVisibleLines + 1, #self.visibleLines do
		if i > maxNumVisibleLines then
			self:ReleaseMessageLine(self.visibleLines[i])
			self.visibleLines[i] = nil
		else
			E:StopFading(self.visibleLines[i], 0)
			self.visibleLines[i]:Hide()
		end
	end

	self:SetFirstMessageIndex(index)
end

function object_proto:FastForward()
	if not self:IsShown() or self.ScrollChild:GetHeight() == 0 then return end

	if self:GetNumHistoryElements() > 0 then
		t_wipe(self.incomingMessages)

		local num = m_min(self:GetNumHistoryElements(), self:GetMaxNumVisibleLines(), self:GetFirstMessageIndex())

		self:SetVerticalScroll(0)
		self:ScrollTo(num, true)

		if num == 0 then return end
		if num == self:GetFirstMessageIndex() then
			num = num + 1
		end

		local messages = {}
		for i = num - 1, 1, -1 do
			local messageInfo = self:GetHistoryEntryAtIndex(i)
			if messageInfo then
				t_insert(messages, {messageInfo.message, messageInfo.r, messageInfo.g, messageInfo.b})
			end
		end

		self:ProcessIncoming(messages, true)
		self:SetFirstMessageIndex(0)
	end
end

function object_proto:OnMouseWheel(delta)
	if self:GetNumHistoryElements() == 0 then
		return self:SetFirstMessageIndex(0)
	end

	local scrollingHandler = self:GetScrollingHandler()
	if scrollingHandler then
		LibEasing:StopEasing(scrollingHandler)
		self:SetScrollingHandler(nil)
		self:SetVerticalScroll(0)
	end

	self:ScrollTo(Clamp(self:GetFirstMessageIndex() + delta, 0, self:GetNumHistoryElements() - 1), true, true)

	if self:GetFirstMessageIndex() ~= 0 then
		self.ScrollToBottomButton:Show()
		E:FadeIn(self.ScrollToBottomButton, 0.1)
	else
		E:FadeOut(self.ScrollToBottomButton, 0, 0.1, function()
			self.ScrollToBottomButton:Hide()
		end)
	end
end

function object_proto:GetScrollingHandler()
	return self.scrollingHandle
end

function object_proto:SetScrollingHandler(handler)
	self.scrollingHandle = handler
end

function object_proto:AddMessage(_, ...)
	if self:IsShown() then
		if not self:GetScrollingHandler() and self:GetFirstMessageIndex() > 0 then
			-- it means we're scrolling up, just show the message icon
			self.ScrollToBottomButton:SetState(2)

			self:SetFirstMessageIndex(self:GetFirstMessageIndex() + 1)
		else
			-- I'm pulling message data from .historyBuffer, so by the time our
			-- frame is done scrolling, there might be messages that are already
			-- there, but they weren't animated yet
			if self:GetScrollingHandler() then
				self:SetFirstMessageIndex(self:GetFirstMessageIndex() + 1)
			end

			t_insert(self.incomingMessages, {...})
		end
	else
		-- the frame might be hidden due to a bunch of factors, just bump the index of
		-- the first message, OnShow will take care of the rest
		self:SetFirstMessageIndex(self:GetFirstMessageIndex() + 1)
	end
end

function object_proto:OnFrame()
	if not self:IsShown() or self.ScrollChild:GetHeight() == 0 or self:GetScrollingHandler() then return end

	if #self.incomingMessages > 0 then
		self:ProcessIncoming({t_removemulti(self.incomingMessages, 1, #self.incomingMessages)}, false)
	end

	local isMouseOver = self:IsMouseOver(26, -36, 0, 0)
	if isMouseOver ~= self.isMouseOver then
		self.isMouseOver = isMouseOver

		if isMouseOver then
			for _, visibleLine in next, self.visibleLines do
				if visibleLine:IsShown() and visibleLine:GetAlpha() ~= 0 then
					E:FadeIn(visibleLine, C.db.profile.chat.fade.in_duration, function()
						if self.isMouseOver then
							E:StopFading(visibleLine, 1)
						elseif not C.db.profile.chat.fade.persistent then
							E:FadeOut(visibleLine, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
								visibleLine:Hide()
							end)
						end
					end)
				end
			end

			if self:GetFirstMessageIndex() ~= 0 then
				self.ScrollToBottomButton:Show()
				E:FadeIn(self.ScrollToBottomButton, C.db.profile.chat.fade.in_duration, function()
					if self.isMouseOver then
						E:StopFading(self.ScrollToBottomButton, 1)
					elseif not C.db.profile.chat.fade.persistent then
						E:FadeOut(self.ScrollToBottomButton, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
							self.ScrollToBottomButton:Hide()
						end)
					end
				end)
			end

			if C.db.profile.dock.fade.enabled then
				-- these use custom values for fading in/out because Blizz fade chat as well
				-- so I'm trying not to interfere with that
				-- ! DO NOT SHOW/HIDE the tab, it'll taint EVERYTHING, just adjust its alpha
				if not self.ChatFrame.isDocked then
					E:FadeIn(self.ChatTab, 0.1, function()
						if self.isMouseOver then
							E:StopFading(self.ChatTab, 1)
						else
							E:FadeOut(self.ChatTab, 4, C.db.profile.dock.fade.out_duration)
						end
					end)
				end

				E:FadeIn(self.ButtonFrame, 0.1, function()
					if self.isMouseOver then
						E:StopFading(self.ButtonFrame, 1)
					else
						E:FadeOut(self.ButtonFrame, 4, C.db.profile.dock.fade.out_duration)
					end
				end)

				if C.db.profile.chat.buttons.up_and_down then
					E:FadeIn(self.ScrollDownButton, 0.1, function()
						if self.isMouseOver then
							E:StopFading(self.ScrollDownButton, 1)
						else
							E:FadeOut(self.ScrollDownButton, 4, C.db.profile.dock.fade.out_duration)
						end
					end)

					E:FadeIn(self.ScrollUpButton, 0.1, function()
						if self.isMouseOver then
							E:StopFading(self.ScrollUpButton, 1)
						else
							E:FadeOut(self.ScrollUpButton, 4, C.db.profile.dock.fade.out_duration)
						end
					end)
				end
			end
		else
			if not C.db.profile.chat.fade.persistent then
				for _, visibleLine in next, self.visibleLines do
					if visibleLine:IsShown() and not E:IsFading(visibleLine) then
						E:FadeOut(visibleLine, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
							visibleLine:Hide()
						end)
					end
				end

				E:FadeOut(self.ScrollToBottomButton, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
					self.ScrollToBottomButton:Hide()
				end)
			end

			if C.db.profile.dock.fade.enabled then
				-- these use custom values for fading in/out because Blizz fade chat as well
				-- so I'm trying not to interfere with that
				-- ! DO NOT SHOW/HIDE the tab, it'll taint EVERYTHING, just adjust its alpha
				if not self.ChatFrame.isDocked then
					if not self.isDragging then
						E:FadeOut(self.ChatTab, 4, C.db.profile.dock.fade.out_duration)
					else
						E:StopFading(self.ChatTab, 1)
					end
				end

				E:FadeOut(self.ButtonFrame, 4, C.db.profile.dock.fade.out_duration)

				if C.db.profile.chat.buttons.up_and_down then
					E:FadeOut(self.ScrollDownButton, 4, C.db.profile.dock.fade.out_duration)
					E:FadeOut(self.ScrollUpButton, 4, C.db.profile.dock.fade.out_duration)
				end
			end
		end
	end
end

function object_proto:ProcessIncoming(incoming, doNotFade)
	local totalHeight = 0
	local prevIncomingMessage

	for i = 1, #incoming do
		local messageLine = self:AcquireMessageLine()

		t_insert(self.visibleLines, 1, messageLine)

		if prevIncomingMessage then
			messageLine:SetPoint("TOPLEFT", prevIncomingMessage, "BOTTOMLEFT", 0, 0)
		else
			messageLine:SetPoint("TOPLEFT", self.ScrollChild, "BOTTOMLEFT", 0, 0)
		end

		messageLine:SetText(incoming[i][1], incoming[i][2], incoming[i][3], incoming[i][4])
		messageLine:Show()

		if not doNotFade then
			messageLine:SetAlpha(0)
			E:FadeIn(messageLine, C.db.profile.chat.fade.in_duration, function()
				if not self.isMouseOver and not C.db.profile.chat.fade.persistent then
					E:FadeOut(messageLine, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
						messageLine:Hide()
					end)
				end
			end)
		else
			messageLine:SetAlpha(1)
		end

		totalHeight = totalHeight + messageLine:GetHeight()
		prevIncomingMessage = messageLine
	end

	local startOffset = self:GetVerticalScroll()
	local endOffset = totalHeight - startOffset

	LibEasing:StopEasing(self:GetScrollingHandler())

	self:SetScrollingHandler(LibEasing:Ease(
		function (n)
			self:SetVerticalScroll(n)
		end,
		startOffset,
		endOffset,
		C.db.profile.chat.slide_in_duration,
		LibEasing.OutCubic,
		function()
			self:SetVerticalScroll(0)
			self:ScrollTo(self:GetFirstMessageIndex(), doNotFade)
			self:SetFirstMessageIndex(0)
			self:SetScrollingHandler(nil)
		end
	))
end

function object_proto:Release()
	self.pool:Release(self)
end

do
	local frames = {}

	local slidingMessageFramePool = CreateObjectPool(
		function(pool)
			local frame = Mixin(CreateFrame("ScrollFrame", "LSGlassFrame" .. (#frames + 1), UIParent, "LSGlassHyperlinkPropagator"), object_proto)
			frame:EnableMouse(false)
			frame:SetClipsChildren(true)
			frame:Hide()

			frame.visibleLines = {}
			frame.incomingMessages = {}
			frame.pool = pool

			local scrollChild = CreateFrame("Frame", nil, frame, "LSGlassHyperlinkPropagator")
			frame:SetScrollChild(scrollChild)
			frame.ScrollChild = scrollChild

			frame:SetScript("OnHide", frame.OnHide)
			frame:SetScript("OnShow", frame.OnShow)
			frame:SetScript("OnMouseWheel", frame.OnMouseWheel)

			local scrollToBottomButton = E:CreateScrollToBottomButton(frame)
			scrollToBottomButton:SetPoint("BOTTOMRIGHT", -4, 4)
			frame.ScrollToBottomButton = scrollToBottomButton

			local scrollDownButton = E:CreateScrollButton(frame, 3)
			scrollDownButton:SetPoint("BOTTOMRIGHT", scrollToBottomButton, "TOPRIGHT", 0, 2)
			scrollDownButton:SetShown(C.db.profile.chat.buttons.up_and_down)
			frame.ScrollDownButton = scrollDownButton

			local scrollUpButton = E:CreateScrollButton(frame, 4)
			scrollUpButton:SetPoint("BOTTOMRIGHT", scrollDownButton, "TOPRIGHT", 0, 2)
			scrollUpButton:SetShown(C.db.profile.chat.buttons.up_and_down)
			frame.ScrollUpButton = scrollUpButton

			t_insert(frames, frame)

			return frame
		end,
		function(_, frame)
			frame:ReleaseChatFrame()
		end
	)

	slidingMessageFramePool:SetResetDisallowedIfNew(true)

	function E:HandleChatFrame(chatFrame)
		if chatFrame == ChatFrame2 then
			-- Combat Log, I might want to skin it, but without sliding
		else
			local frame = slidingMessageFramePool:Acquire()
			frame:CaptureChatFrame(chatFrame)

			return frame
		end
	end

	function E:ResetSlidingFrameDockFading()
		for _, frame in next, frames do
			if frame:IsShown() then
				frame.isMouseOver = nil

				E:StopFading(frame.ChatTab, 1)
				E:StopFading(frame.ButtonFrame, 1)
			end
		end

		-- ? I don't like this... Should I attach to the first frame?
		LSGlassUpdater.isMouseOver = nil

		E:StopFading(GeneralDockManager, 1)
	end

	function E:ResetSlidingFrameChatFading()
		for _, frame in next, frames do
			if frame:IsShown() then
				frame.isMouseOver = nil

				for _, visibleLine in next, frame.visibleLines do
					if visibleLine:IsShown() then
						E:StopFading(visibleLine, 1)
					end
				end

				if frame:GetFirstMessageIndex() ~= 0 then
					frame.ScrollToBottomButton:Show()
					E:StopFading(frame.ScrollToBottomButton, 1)
				end
			end
		end
	end

	function E:ToggleScrollButtons()
		for _, frame in next, frames do
			frame.ScrollDownButton:SetShown(C.db.profile.chat.buttons.up_and_down)
			frame.ScrollUpButton:SetShown(C.db.profile.chat.buttons.up_and_down)
		end
	end
end
