local Core, Constants = unpack(select(2, ...))

local AceHook = Core.Libs.AceHook

local Colors = Constants.COLORS

local MOUSE_ENTER = Constants.EVENTS.MOUSE_ENTER
local MOUSE_LEAVE = Constants.EVENTS.MOUSE_LEAVE
local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

-- luacheck: push ignore 113
local Mixin = Mixin
local FCFDock_GetInsertIndex = FCFDock_GetInsertIndex
local FCFDock_HideInsertHighlight = FCFDock_HideInsertHighlight
local FCF_DockFrame = FCF_DockFrame
local GENERAL_CHAT_DOCK = GENERAL_CHAT_DOCK
local GeneralDockManager = GeneralDockManager
local GetCursorPosition = GetCursorPosition
local UIParent = UIParent
-- luacheck: pop

local ChatDockMixin = {}

function ChatDockMixin:Init(parent)
  self.state = {
    mouseOver = false
  }

  self:SetWidth(Core.db.profile.frameWidth)
  self:SetHeight(Constants.DOCK_HEIGHT)
  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", parent, "TOPLEFT")
  self:SetFadeInDuration(0.6)
  self:SetFadeOutDuration(0.6)

  self.scrollFrame:SetHeight(Constants.DOCK_HEIGHT)
  self.scrollFrame:SetPoint("TOPLEFT", _G.ChatFrame2Tab, "TOPRIGHT")
  self.scrollFrame.child:SetHeight(Constants.DOCK_HEIGHT)

  -- Gradient background
  local opacity = 0.4
  self:SetGradientBackground(50, 250, Colors.black, opacity)

  -- Override drag behaviour
  -- Disable undocking frames
  self:RawHook("FCF_StopDragging", function (chatFrame)
    chatFrame:StopMovingOrSizing();
    _G[chatFrame:GetName().."Tab"]:UnlockHighlight();

    FCFDock_HideInsertHighlight(GENERAL_CHAT_DOCK);

    local mouseX, mouseY = GetCursorPosition();
    mouseX, mouseY = mouseX / UIParent:GetScale(), mouseY / UIParent:GetScale();
    FCF_DockFrame(chatFrame, FCFDock_GetInsertIndex(GENERAL_CHAT_DOCK, chatFrame, mouseX, mouseY), true);
  end, true)

  self:QuickHide()

  if self.subscriptions == nil then
    self.subscriptions = {
      Core:Subscribe(MOUSE_ENTER, function ()
        -- Don't hide tabs when mouse is over
        self.state.mouseOver = true
        self:Show()
      end),
      Core:Subscribe(MOUSE_LEAVE, function ()
        -- Hide chat tab when mouse leaves
        self.state.mouseOver = false

        if Core.db.profile.chatShowOnMouseOver then
          -- When chatShowOnMouseOver is on, synchronize the chat tab's fade out with
          -- the chat
          self:HideDelay(Core.db.profile.chatHoldTime)
        else
          -- Otherwise hide it immediately on mouse leave
          self:Hide()
        end
      end),
      Core:Subscribe(UPDATE_CONFIG, function (key)
        if key == "frameWidth" then
          self:SetWidth(Core.db.profile.frameWidth)

          self:SetGradientBackground(50, 250, Colors.black, opacity)
        end
      end)
    }
  end
end

local isCreated = false

Core.Components.CreateChatDock = function (parent)
  if isCreated then
    error("ChatDock already exists. Only one ChatDock can exist at a time.")
  end

  local FadingFrameMixin = Core.Components.FadingFrameMixin
  local GradientBackgroundMixin = Core.Components.GradientBackgroundMixin

  isCreated = true
  local object = Mixin(GeneralDockManager, FadingFrameMixin, GradientBackgroundMixin, ChatDockMixin)
  AceHook:Embed(object)
  FadingFrameMixin.Init(object)
  GradientBackgroundMixin.Init(object)
  ChatDockMixin.Init(object, parent)
  return object
end
