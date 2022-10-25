local Core, Constants = unpack(select(2, ...))

local LockMover = Constants.ACTIONS.LockMover

local LOCK_MOVER = Constants.EVENTS.LOCK_MOVER
local UNLOCK_MOVER = Constants.EVENTS.UNLOCK_MOVER

local MoverDialogMixin = {}

-- luacheck: push ignore 113
local BackdropTemplateMixin = BackdropTemplateMixin
local CreateFrame = CreateFrame
local Mixin = Mixin
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
-- luacheck: pop

function MoverDialogMixin:Init()
  self:SetFrameStrata("DIALOG")
  self:SetToplevel(true)
  self:EnableMouse(false)
  self:SetMovable(false)
  self:SetClampedToScreen(true)
  self:SetWidth(360)
  self:SetHeight(110)
  self:SetBackdrop{
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    insets = {left = 11, right = 12, top = 12, bottom = 11},
    tileSize = 32,
    edgeSize = 32,
  }
  self:SetPoint("TOP", 0, -50)
  self:Hide()

  self:SetScript("OnShow", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPTION) end)
  self:SetScript("OnHide", function() PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT) end)

  self.header = self:CreateTexture(nil, "ARTWORK")
  self.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
  self.header:SetWidth(256)
  self.header:SetHeight(64)
  self.header:SetPoint("TOP", 0, 12)

  self.title = self:CreateFontString("ARTWORK")
  self.title:SetFontObject("GameFontNormal")
  self.title:SetPoint("TOP", self.header, "TOP", 0, -14)
  self.title:SetText("Glass")

  self.desc = self:CreateFontString("ARTWORK")
  self.desc:SetFontObject("GameFontHighlight")
  self.desc:SetJustifyV("TOP")
  self.desc:SetJustifyH("LEFT")
  self.desc:SetPoint("TOPLEFT", 18, -32)
  self.desc:SetPoint("BOTTOMRIGHT", -18, 48)
  self.desc:SetText("Chat frame unlocked. You can now drag the chat frame to reposition it.")

  self.lockButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
  self.lockButton:SetText("Lock")
  self.lockButton:SetScript("OnClick", function()
    Core:Dispatch(LockMover())
  end)
  self.lockButton:SetPoint("BOTTOMRIGHT", -14, 14)

  Core:Subscribe(LOCK_MOVER, function ()
    self:Hide()
  end)

  Core:Subscribe(UNLOCK_MOVER, function ()
    self:Show()
  end)
end

Core.Components.CreateMoverDialog = function (name, parent)
  local frame = CreateFrame(
    "Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil
  )
  local object = Mixin(frame, MoverDialogMixin)
  object:Init()
  return object
end
