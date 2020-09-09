local Core, Constants = unpack(select(2, ...))
local TP = Core:GetModule("TextProcessing")

local AceHook = Core.Libs.AceHook

local LibEasing = Core.Libs.LibEasing
local lodash = Core.Libs.lodash
local drop, reduce, take = lodash.drop, lodash.reduce, lodash.take

local CreateFadingFrame = Core.Components.CreateFadingFrame
local CreateMessageLinePool = Core.Components.CreateMessageLinePool

local Colors = Constants.COLORS

local MOUSE_ENTER = Constants.EVENTS.MOUSE_ENTER
local MOUSE_LEAVE = Constants.EVENTS.MOUSE_LEAVE
local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

-- luacheck: push ignore 113
local CreateFrame = CreateFrame
local CreateObjectPool = CreateObjectPool
local Mixin = Mixin
-- luacheck: pop

----
-- SlidingMessageFrameMixin
--
-- Custom frame for displaying pretty sliding messages
local SlidingMessageFrameMixin = {}

function SlidingMessageFrameMixin:Init(chatFrame)
  self.config = {
    height = Core.db.profile.frameHeight - Constants.DOCK_HEIGHT - 5,
    width = Core.db.profile.frameWidth,
    overflowHeight = 60,
  }
  self.state = {
    mouseOver = false,
    showingTooltip = false,
    prevLine = nil,
    prevEasingHandle = nil,
    incomingMessages = {},
    messages = {},
    isCombatLog = false,
    scrollAtBottom = true,
    unreadMessages = false,
  }
  self.chatFrame = chatFrame

  -- Override Blizzard UI
  _G[chatFrame:GetName().."ButtonFrame"]:Hide()

  chatFrame:SetClampRectInsets(0,0,0,0)
  chatFrame:SetClampedToScreen(false)
  chatFrame:SetResizable(false)
  chatFrame:SetParent(self:GetParent())
  chatFrame:ClearAllPoints()

  -- Skip combat log
  if chatFrame == _G.ChatFrame2 then
    self.state.isCombatLog = true
    self:RawHook(chatFrame, "SetPoint", function ()
      self.hooks[chatFrame].SetPoint(chatFrame, "TOPLEFT", self:GetParent(), "TOPLEFT", 0, -45)
      self.hooks[chatFrame].SetPoint(chatFrame, "BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0)
    end, true)
    return
  end

  self:RawHook(chatFrame, "SetPoint", function ()
    self.hooks[chatFrame].SetPoint(chatFrame, "TOPLEFT", self:GetParent(), "TOPLEFT", 0, -45)
  end, true)

  -- Chat scroll frame
  self:SetHeight(self.config.height + self.config.overflowHeight)
  self:SetWidth(self.config.width)
  self:SetPoint("TOPLEFT", 0, (Constants.DOCK_HEIGHT + 5) * -1)

  -- Set initial scroll position
  self:SetVerticalScroll(self.config.overflowHeight)

  -- Overlay
  if self.overlay == nil then
    local overlayOpacity = 0.65

    self.overlay = CreateFadingFrame("Frame", nil, self)
    self.overlay:SetHeight(64)
    self.overlay:SetPoint("TOPLEFT", 0, (self.config.height - 62) * -1)
    self.overlay:SetPoint("TOPRIGHT", 0, (self.config.height - 62) * -1)
    self.overlay:SetFadeInDuration(0.3)
    self.overlay:SetFadeOutDuration(0.15)
    self.overlay:QuickHide()

    self.overlay.mask = self.overlay:CreateMaskTexture()
    self.overlay.mask:SetTexture("Interface\\Addons\\Glass\\Assets\\overlayMask", "CLAMP", "CLAMPTOBLACKADDITIVE")
    self.overlay.mask:SetSize(16, 64)
    self.overlay.mask:SetPoint("CENTER", 0, -32)

    self.overlay.leftBg = self.overlay:CreateTexture(nil, "BACKGROUND")
    self.overlay.leftBg:SetPoint("TOPLEFT")
    self.overlay.leftBg:SetPoint("BOTTOMLEFT")
    self.overlay.leftBg:SetWidth(15)
    self.overlay.leftBg:SetColorTexture(1, 1, 1, 1)
    self.overlay.leftBg:SetGradientAlpha(
      "HORIZONTAL",
      Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, 0,
      Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, overlayOpacity
    )
    self.overlay.leftBg:AddMaskTexture(self.overlay.mask)

    self.overlay.centerBg = self.overlay:CreateTexture(nil, "BACKGROUND")
    self.overlay.centerBg:SetPoint("TOPLEFT", 15, 0)
    self.overlay.centerBg:SetPoint("BOTTOMRIGHT", -15, 0)
    self.overlay.centerBg:SetColorTexture(
      Colors.codGray.r,
      Colors.codGray.g,
      Colors.codGray.b,
      overlayOpacity
    )
    self.overlay.centerBg:AddMaskTexture(self.overlay.mask)

    self.overlay.rightBg = self.overlay:CreateTexture(nil, "BACKGROUND")
    self.overlay.rightBg:SetPoint("TOPRIGHT")
    self.overlay.rightBg:SetPoint("BOTTOMRIGHT")
    self.overlay.rightBg:SetWidth(15)
    self.overlay.rightBg:SetColorTexture(1, 1, 1, 1)
    self.overlay.rightBg:SetGradientAlpha(
      "HORIZONTAL",
      Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, overlayOpacity,
      Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, 0
    )
    self.overlay.rightBg:AddMaskTexture(self.overlay.mask)

    -- Down arrow icon
    self.overlay.icon = self.overlay:CreateTexture(nil, "ARTWORK")
    self.overlay.icon:SetTexture("Interface\\Addons\\Glass\\Glass\\Assets\\snapToBottomIcon")
    self.overlay.icon:SetSize(16, 16)
    self.overlay.icon:SetPoint("BOTTOMLEFT", 15, 5)

    -- See new messages click area
    self.overlay.snapToBottomFrame = CreateFrame("Frame", nil, self.overlay)
    self.overlay.snapToBottomFrame:SetHeight(20)
    self.overlay.snapToBottomFrame:SetPoint("BOTTOMLEFT")
    self.overlay.snapToBottomFrame:SetPoint("BOTTOMRIGHT")

    -- Snap to bottom on click
    self.overlay.snapToBottomFrame:SetScript("OnMouseDown", function ()
      self.state.scrollAtBottom = true
      self.state.unreadMessages = false
      self.overlay:Hide()
      self.overlay.newMessageHighlightFrame:Hide()

      local startOffset = math.max(
        self:GetVerticalScrollRange() - self.config.height * 2,
        self:GetVerticalScroll()
      )
      local endOffset = self:GetVerticalScrollRange()

      LibEasing:Ease(
        function (offset) self:SetVerticalScroll(offset) end,
        startOffset,
        endOffset,
        0.3,
        LibEasing.OutCubic,
        function ()
          self:SetHeight(self.config.height + self.config.overflowHeight)
        end
      )
    end)

    -- See new messages frame
    self.overlay.newMessageHighlightFrame = CreateFadingFrame("Frame", nil, self.overlay)
    self.overlay.newMessageHighlightFrame:SetHeight(20)
    self.overlay.newMessageHighlightFrame:SetPoint("BOTTOMLEFT")
    self.overlay.newMessageHighlightFrame:SetPoint("BOTTOMRIGHT")
    self.overlay.newMessageHighlightFrame:SetFadeInDuration(0.15)
    self.overlay.newMessageHighlightFrame:SetFadeOutDuration(0.15)

    -- New messages text
    self.overlay.newMessageHighlightFrame.text = self.overlay.newMessageHighlightFrame:CreateFontString(
      nil, "ARTWORK", "GlassMessageFont"
    )
    self.overlay.newMessageHighlightFrame.text:SetTextColor(Colors.apache.r, Colors.apache.g, Colors.apache.b)
    self.overlay.newMessageHighlightFrame.text:SetPoint("BOTTOMLEFT", 30, 10)
    self.overlay.newMessageHighlightFrame.text:SetText("Unread messages")

    -- Highlight line
    self.overlay.newMessageHighlightFrame.leftBg = self.overlay.newMessageHighlightFrame:CreateTexture(
      nil, "BACKGROUND"
    )
    self.overlay.newMessageHighlightFrame.leftBg:SetPoint("BOTTOMLEFT")
    self.overlay.newMessageHighlightFrame.leftBg:SetHeight(1)
    self.overlay.newMessageHighlightFrame.leftBg:SetWidth(15)
    self.overlay.newMessageHighlightFrame.leftBg:SetColorTexture(1, 1, 1, 1)
    self.overlay.newMessageHighlightFrame.leftBg:SetGradientAlpha(
      "HORIZONTAL",
      Colors.apache.r, Colors.apache.g, Colors.apache.b, 0,
      Colors.apache.r, Colors.apache.g, Colors.apache.b, overlayOpacity
    )

    self.overlay.newMessageHighlightFrame.centerBg = self.overlay.newMessageHighlightFrame:CreateTexture(
      nil, "BACKGROUND"
    )
    self.overlay.newMessageHighlightFrame.centerBg:SetHeight(1)
    self.overlay.newMessageHighlightFrame.centerBg:SetPoint("BOTTOMLEFT", 15, 0)
    self.overlay.newMessageHighlightFrame.centerBg:SetPoint("BOTTOMRIGHT", -15, 0)
    self.overlay.newMessageHighlightFrame.centerBg:SetColorTexture(
      Colors.apache.r,
      Colors.apache.g,
      Colors.apache.b,
      overlayOpacity
    )

    self.overlay.newMessageHighlightFrame.rightBg = self.overlay.newMessageHighlightFrame:CreateTexture(
      nil, "BACKGROUND"
    )
    self.overlay.newMessageHighlightFrame.rightBg:SetPoint("BOTTOMRIGHT")
    self.overlay.newMessageHighlightFrame.rightBg:SetHeight(1)
    self.overlay.newMessageHighlightFrame.rightBg:SetWidth(15)
    self.overlay.newMessageHighlightFrame.rightBg:SetColorTexture(1, 1, 1, 1)
    self.overlay.newMessageHighlightFrame.rightBg:SetGradientAlpha(
      "HORIZONTAL",
      Colors.apache.r, Colors.apache.g, Colors.apache.b, overlayOpacity,
      Colors.apache.r, Colors.apache.g, Colors.apache.b, 0
    )
    self.overlay.newMessageHighlightFrame:QuickHide()
  end

  self.timeElapsed = 0
  self:SetScript("OnUpdate", function (frame, elapsed)
    self:OnUpdate(elapsed)
  end)

  -- Scrolling
  self:SetScript("OnMouseWheel", function (frame, delta)
    local maxScroll = (
      self.state.scrollAtBottom and
      self:GetVerticalScrollRange() + self.config.overflowHeight
      or self:GetVerticalScrollRange()
    )
    local minScroll = self.config.height + self.config.overflowHeight
    local scrollValue

    if delta < 0 then
      -- Scroll down
      scrollValue = math.min(self:GetVerticalScroll() + 20, maxScroll)
    else
      -- Scroll up
      scrollValue = math.max(self:GetVerticalScroll() - 20, math.min(minScroll, maxScroll))
    end

    self:UpdateScrollChildRect()
    self:SetVerticalScroll(scrollValue)

    self.state.scrollAtBottom = scrollValue == maxScroll

    -- Adjust height of scroll frame when scrolling
    if self.state.scrollAtBottom then
      -- If scrolled to the bottom, the height of the scroll frame should
      -- include overflow to account for slide up animations
      self:SetHeight(self.config.height + self.config.overflowHeight)
      self.overlay:Hide()
      self.overlay.newMessageHighlightFrame:Hide()
      self.state.unreadMessages = false
    else
      -- If not, the height should fit the frame exactly so messages don't spill
      -- under the edit box area
      self:SetHeight(self.config.height)
      self.overlay:Show()
    end

    -- Show hidden messages
    for _, message in ipairs(self.state.messages) do
      message:Show()
    end
  end)

  -- Mouse clickthrough
  self:EnableMouse(false)

  -- ScrollChild
  if self.slider == nil then
    self.slider = CreateFrame("Frame", nil, self)
  end
  self.slider:SetHeight(self.config.height + self.config.overflowHeight)
  self.slider:SetWidth(self.config.width)
  self:SetScrollChild(self.slider)

  if self.slider.bg == nil then
    self.slider.bg = self.slider:CreateTexture(nil, "BACKGROUND")
  end
  self.slider.bg:SetAllPoints()
  self.slider.bg:SetColorTexture(0, 0, 1, 0)

  -- Pool for the message frames
  if self.messageFramePool == nil then
    self.messageFramePool = CreateMessageLinePool(self.slider)
  end

  self:Hook(chatFrame, "AddMessage", function (...)
    self:AddMessage(...)
  end, true)

  -- Hide the default chat frame and show the sliding message frame instead
  self:RawHook(chatFrame, "Show", function ()
    self:Show()
  end, true)

  self:RawHook(chatFrame, "Hide", function (f)
    self.hooks[chatFrame].Hide(f)
    self:Hide()
  end, true)

  chatFrame:Hide()

  -- Listeners
  Core:Subscribe(MOUSE_ENTER, function ()
    -- Don't hide chats when mouse is over
    self.state.mouseOver = true

    if not self.state.scrollAtBottom then
      self.overlay:Show()
    end

    for _, message in ipairs(self.state.messages) do
      if Core.db.profile.chatShowOnMouseOver then
        message:Show()
      end
    end
  end)

  Core:Subscribe(MOUSE_LEAVE, function ()
    -- Hide chats when mouse leaves
    self.state.mouseOver = false

    self.overlay:HideDelay(Core.db.profile.chatHoldTime)

    for _, message in ipairs(self.state.messages) do
      message:HideDelay(Core.db.profile.chatHoldTime)
    end
  end)

  Core:Subscribe(UPDATE_CONFIG, function (key)
    if self.state.isCombatLog == false then
      if key == "font" or key == "messageFontSize" or key == "frameWidth" or key == "frameHeight" then
        for _, message in ipairs(self.state.messages) do
            message:UpdateFrame()
        end
      end

      if key == "frameWidth" or key == "frameHeight" then
        self.config.height = Core.db.profile.frameHeight - Constants.DOCK_HEIGHT - 5
        self.config.width = Core.db.profile.frameWidth

        self:SetHeight(self.config.height + self.config.overflowHeight)
        self:SetWidth(self.config.width)

        local contentHeight = reduce(self.state.messages, function (acc, message)
          return acc + message:GetHeight()
        end, 0)
        self.slider:SetHeight(self.config.height + self.config.overflowHeight + contentHeight)
        self.slider:SetWidth(self.config.width)

        self.state.scrollAtBottom = true
        self.state.unreadMessages = false
        self:UpdateScrollChildRect()
        self:SetVerticalScroll(self:GetVerticalScrollRange() + self.config.overflowHeight)
        self.overlay:Hide()
        self.overlay.newMessageHighlightFrame:Hide()
      end

      if key == "chatBackgroundOpacity" then
        for _, message in ipairs(self.state.messages) do
          message:UpdateTextures()
        end
      end
    end
  end)
end

function SlidingMessageFrameMixin:CreateMessageFrame(frame, text, red, green, blue, messageId, holdTime)
  red = red or 1
  green = green or 1
  blue = blue or 1

  local message = self.messageFramePool:Acquire()
  message:SetPoint("BOTTOMLEFT")

  -- Attach previous message to this one
  if self.state.prevLine then
    self.state.prevLine:ClearAllPoints()
    self.state.prevLine:SetPoint("BOTTOMLEFT", message, "TOPLEFT")
  end

  self.state.prevLine = message

  message.text:SetTextColor(red, green, blue, 1)
  message.text:SetText(TP:ProcessText(text))

  -- Adjust height to contain text
  message:UpdateFrame()

  return message
end

function SlidingMessageFrameMixin:AddMessage(...)
  -- Enqueue messages to be displayed
  local args = {...}
  table.insert(self.state.incomingMessages, args)
end

function SlidingMessageFrameMixin:OnUpdate(elapsed)
  self.timeElapsed = self.timeElapsed + elapsed
  while (self.timeElapsed > 0.1) do
    self.timeElapsed = self.timeElapsed - 0.1
    self:Update()
  end
end

function SlidingMessageFrameMixin:Update()
  -- Make sure previous iteration is complete before running again
  if #self.state.incomingMessages > 0 then
    -- Create new message frame for each message
    local newMessages = {}

    for _, message in ipairs(self.state.incomingMessages) do
      table.insert(newMessages, self:CreateMessageFrame(unpack(message)))
    end

    -- Update slider offsets animation
    local offset = reduce(newMessages, function (acc, message)
      return acc + message:GetHeight()
    end, 0)

    local newHeight = self.slider:GetHeight() + offset
    self.slider:SetHeight(newHeight)

    -- Display and run everything
    if self.state.scrollAtBottom then
      -- Only play slide up if not scrolling
      if self.state.prevEasingHandle ~= nil then
        LibEasing:StopEasing(self.state.prevEasingHandle)
      end

      local startOffset = self:GetVerticalScroll()
      local endOffset = newHeight - self:GetHeight() + self.config.overflowHeight

      self.state.prevEasingHandle = LibEasing:Ease(
        function (n) self:SetVerticalScroll(n) end,
        startOffset,
        endOffset,
        0.3,
        LibEasing.OutCubic
      )
    else
      -- Otherwise show "Unread messages" notification
      self.state.unreadMessages = true
      self.overlay:Show()
      self.overlay.newMessageHighlightFrame:Show()
      if not self.state.mouseOver then
        self.overlay:HideDelay(Core.db.profile.chatHoldTime)
      end
    end

    for _, message in ipairs(newMessages) do
      message:Show()
      if not self.state.mouseOver then
        message:HideDelay(Core.db.profile.chatHoldTime)
      end
      table.insert(self.state.messages, message)
    end

    -- Release old messages
    local historyLimit = 128
    if #self.state.messages > historyLimit then
      local overflow = #self.state.messages - historyLimit
      local oldMessages = take(self.state.messages, overflow)
      self.state.messages = drop(self.state.messages, overflow)

      for _, message in ipairs(oldMessages) do
        self.messageFramePool:Release(message)
      end
    end

    -- Reset
    self.state.incomingMessages = {}
  end
end

local function CreateSlidingMessageFrame(name, parent, chatFrame)
  local frame = CreateFrame("ScrollFrame", name, parent)
  local object = Mixin(frame, SlidingMessageFrameMixin)
  AceHook:Embed(object)

  if chatFrame then
    object:Init(chatFrame)
  end
  object:Hide()
  return object
end

local function CreateSlidingMessageFramePool(parent)
  return CreateObjectPool(
    function () return CreateSlidingMessageFrame(nil, parent) end,
    function (_, smf)
      smf:Hide()

      if smf.chatFrame then
        smf:Unhook(smf.chatFrame, "SetPoint")
        smf:Unhook(smf.chatFrame, "AddMessage")
        smf:Unhook(smf.chatFrame, "Show")
        smf:Unhook(smf.chatFrame, "Hide")
      end

      if smf.state ~= nil then
        smf.state.prevLine = nil
        smf.state.messages = {}
        smf.state.incomingMessages = {}
      end

      if smf.messageFramePool ~= nil then
        smf.messageFramePool:ReleaseAll()
      end
    end
  )
end

Core.Components.CreateSlidingMessageFrame = CreateSlidingMessageFrame
Core.Components.CreateSlidingMessageFramePool = CreateSlidingMessageFramePool
