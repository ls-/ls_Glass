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

		if slidingFrame:GetNumActiveMessageLines() > 0 then
			slidingFrame:ReleaseAllMessageLines()
		end

		slidingFrame:SetFirstMessageIndex(0)

		slidingFrame.ScrollDownButon:Hide()
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
			slidingFrame:ScrollTo(0, true)

			slidingFrame.ScrollDownButon:Hide()
		end
	end
end

local function chatFrame_HideHook(self)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame:Hide()
	end
end

local function chatFrame_AddMessageHook(self, ...)
	local slidingFrame = E:GetSlidingFrameForChatFrame(self)
	if slidingFrame then
		slidingFrame:AddMessage(self,...)
	end
end

------------------------
-- SCROLL DOWN BUTTON --
------------------------

local scroll_down_button_proto = {}

do
	function scroll_down_button_proto:OnClick()
		local frame = self:GetParent()
		local num = m_min(frame:GetNumHistoryElements(), frame:GetMaxMessages(), frame:GetFirstMessageIndex())

		frame:ScrollTo(num, true)

		if num == frame:GetFirstMessageIndex() then
			num = num + 1
		end

		local messages = {}
		for i = num - 1, 1, -1 do
			local messageInfo = frame:GetHistoryEntryAtIndex(i)
			if messageInfo then
				t_insert(messages, {messageInfo.message, messageInfo.r, messageInfo.g, messageInfo.b})
			end
		end

		frame:SetFirstMessageIndex(0)
		frame:ProcessIncoming(messages, true)

		E:FadeOut(self, 0, 0.1, function()
			self:SetText(L["JUMP_TO_PRESESNT"], true)
			self:Hide()
		end)
	end

	function scroll_down_button_proto:SetText(text, isInstant)
		if text ~= self.textString then
			self.textString = text

			if isInstant then
				self.Text:SetText(text)

				self:SetWidth(self.Text:GetUnboundedStringWidth() + 26)
				self:SetHeight(self.Text:GetStringHeight() + 4)
			else
				E:StopFading(self.Text, 1)
				E:FadeOut(self.Text, 0, 0.1, function()
					self.Text:SetText(text)

					self:SetWidth(self.Text:GetUnboundedStringWidth() + 26)
					self:SetHeight(self.Text:GetStringHeight() + 4)

					E:FadeIn(self.Text, 0.1)
				end)
			end
		end
	end

	function scroll_down_button_proto:SetTextColor(r, g, b)
		self.Text:SetTextColor(r, g, b)
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
	chatFrame:SetResizeBounds(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT)
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
	self:SetShown(chatFrame:IsShown())

	self.ScrollChild:SetSize(width, height)

	-- it's safer to hide the string container than the chat frame itself
	chatFrame.FontStringContainer:Hide()

	if not hookedChatFrames[chatFrame] then
		chatFrame:HookScript("OnSizeChanged", chatFrame_OnSizeChanged)

		hooksecurefunc(chatFrame, "Show", chatFrame_ShowHook)
		hooksecurefunc(chatFrame, "Hide", chatFrame_HideHook)
		hooksecurefunc(chatFrame, "AddMessage", chatFrame_AddMessageHook)

		hookedChatFrames[chatFrame] = true
	end

	-- load any messages already in the chat frame
	for i = 1, chatFrame:GetNumMessages() do
		self:AddMessage(chatFrame, chatFrame:GetMessageInfo(i))
	end
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
		self:ReleaseAllMessageLines()
		self:SetParent(UIParent)
		self:Hide()
	end
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

function object_proto:AcquireMessageLine()
	if not self.messageFramePool then
		self.messageFramePool = E:CreateMessageLinePool(self.ScrollChild)
	end

	return self.messageFramePool:Acquire()
end

function object_proto:ReleaseAllMessageLines()
	if self.messageFramePool then
		self.messageFramePool:ReleaseAll()
	end
end

function object_proto:GetNumActiveMessageLines()
	if self.messageFramePool then
		return self.messageFramePool:GetNumActive()
	end

	return 0
end

function object_proto:ReleaseMessageLine(messageLine)
	if self.messageFramePool and messageLine then
		self.messageFramePool:Release(messageLine)
	end
end

function object_proto:GetMaxMessages()
	return m_ceil(self.ChatFrame:GetHeight() / (C.db.profile.chat.font.size + 4))
end

function object_proto:ScrollTo(index, refreshFading, tryToFadeIn)
	local numVisibleLines = 0

	local maxMessages = self:GetMaxMessages()
	for i = 1, maxMessages do
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
			messageLine:SetText(E:ProcessText(messageInfo.message), messageInfo.r, messageInfo.g, messageInfo.b)
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
		E:StopFading(self.visibleLines[i], 0)
		self.visibleLines[i]:Hide()
	end

	self:SetFirstMessageIndex(index)
end

function object_proto:Refresh(delta, refreshFading, tryToFadeIn)
	delta = delta or 0

	self:ScrollTo(Clamp(self:GetFirstMessageIndex() + delta, 0, self:GetNumHistoryElements() - 1), refreshFading, tryToFadeIn)

	if delta == 0 then
		self:SetFirstMessageIndex(0)
	end
end

function object_proto:OnMouseWheel(delta)
	local scrollingHandler = self:GetScrollingHandler()
	if scrollingHandler then
		LibEasing:StopEasing(scrollingHandler)

		self:SetVerticalScroll(0)
	end

	self:Refresh(delta, true, true)

	if self:GetFirstMessageIndex() ~= 0 then
		self.ScrollDownButon:Show()
		E:FadeIn(self.ScrollDownButon, 0.1)
	else
		E:FadeOut(self.ScrollDownButon, 0, 0.1, function()
			self.ScrollDownButon:Hide()
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
			-- it means we're scrolling up, just show "Unread Messages"
			self.ScrollDownButon:SetText(L["UNREAD_MESSAGES"])

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
	end
end

function object_proto:OnFrame()
	if not self:IsShown() or self:GetScrollingHandler() then return end

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
				self.ScrollDownButon:Show()
				E:FadeIn(self.ScrollDownButon, C.db.profile.chat.fade.in_duration, function()
					if self.isMouseOver then
						E:StopFading(self.ScrollDownButon, 1)
					elseif not C.db.profile.chat.fade.persistent then
						E:FadeOut(self.ScrollDownButon, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
							self.ScrollDownButon:Hide()
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

				E:FadeOut(self.ScrollDownButon, C.db.profile.chat.fade.out_delay, C.db.profile.chat.fade.out_duration, function()
					self.ScrollDownButon:Hide()
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

		messageLine:SetText(E:ProcessText(incoming[i][1]), incoming[i][2], incoming[i][3], incoming[i][4])
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
			self:Refresh(0, doNotFade)
			self:SetScrollingHandler()
		end
	))
end

function object_proto:Release()
	self.pool:Release(self)
end

do
	local index = 0
	local slidingMessageFramePool = CreateObjectPool(
		function(pool)
			index = index + 1
			local frame = Mixin(CreateFrame("ScrollFrame", "LSGlassFrame" .. index, UIParent, "LSGlassHyperlinkPropagator"), object_proto)
			frame:EnableMouse(false)
			frame:SetClipsChildren(true)

			frame.visibleLines = {}
			frame.incomingMessages = {}
			frame.pool = pool

			local scrollChild = CreateFrame("Frame", nil, frame, "LSGlassHyperlinkPropagator")
			frame:SetScrollChild(scrollChild)
			frame.ScrollChild = scrollChild

			frame:SetScript("OnMouseWheel", frame.OnMouseWheel)

			local scrollDownButon = Mixin(CreateFrame("Button", nil, frame), scroll_down_button_proto)
			scrollDownButon:SetPoint("BOTTOMRIGHT", -2, 4)
			scrollDownButon:SetScript("OnClick", scrollDownButon.OnClick)
			scrollDownButon:SetAlpha(0)
			scrollDownButon:Hide()
			frame.ScrollDownButon = scrollDownButon

			local text = scrollDownButon:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- TODO: Fix me!
			-- local text = scrollDownButon:CreateFontString(nil, "ARTWORK", "GlassMessageFont")
			text:SetPoint("TOPLEFT", 2, 0)
			text:SetPoint("BOTTOMRIGHT", -2, 0)
			text:SetJustifyH("RIGHT")
			text:SetJustifyV("MIDDLE")
			scrollDownButon.Text = text

			scrollDownButon:SetText(L["JUMP_TO_PRESESNT"])
			scrollDownButon:SetTextColor(C.db.global.colors.lanzones:GetRGB())

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
end
