local Core, Constants, Utils = unpack(select(2, ...))

local Colors = Constants.COLORS

local CreateNewMessageAlertFrame = Core.Components.CreateNewMessageAlertFrame

local super = Utils.super

-- luacheck: push ignore 113
local CreateFrame = CreateFrame
local Mixin = Mixin
-- luacheck: pop

local ScrollOverlayFrame = {}

function ScrollOverlayFrame:Init()
    local overlayOpacity = 0.65
    local topOffset = Core.db.profile.frameHeight - (Constants.DOCK_HEIGHT + 5 + 62)

    self:SetHeight(64)
    self:SetPoint("TOPLEFT", 0, -topOffset)
    self:SetPoint("TOPRIGHT", 0, -topOffset)
    self:SetFadeInDuration(0.3)
    self:SetFadeOutDuration(0.15)

    if self.mask == nil then
      self.mask = self:CreateMaskTexture()
    end
    self.mask:SetTexture("Interface\\Addons\\Glass\\Assets\\overlayMask", "CLAMP", "CLAMPTOBLACKADDITIVE")
    self.mask:SetSize(16, 64)
    self.mask:SetPoint("CENTER", 0, -32)

    self:SetGradientBackground(15, 15, Colors.codGray, overlayOpacity)

    self.leftBg:AddMaskTexture(self.mask)
    self.centerBg:AddMaskTexture(self.mask)
    self.rightBg:AddMaskTexture(self.mask)

    -- Down arrow icon
    if self.icon == nil then
      self.icon = self:CreateTexture(nil, "ARTWORK")
    end
    self.icon:SetTexture("Interface\\Addons\\Glass\\Glass\\Assets\\snapToBottomIcon")
    self.icon:SetSize(16, 16)
    self.icon:SetPoint("BOTTOMLEFT", 15, 5)

    -- See new messages click area
    if self.snapToBottomFrame == nil then
      self.snapToBottomFrame = CreateFrame("Frame", nil, self)
    end
    self.snapToBottomFrame:SetHeight(20)
    self.snapToBottomFrame:SetPoint("BOTTOMLEFT")
    self.snapToBottomFrame:SetPoint("BOTTOMRIGHT")

    if self.newMessageAlertFrame == nil then
      self.newMessageAlertFrame = CreateNewMessageAlertFrame(self)
    end

    self.newMessageAlertFrame:QuickHide()
end

function ScrollOverlayFrame:SetScript(name, callback)
  if name == "OnClickSnapFrame" then
    self.snapToBottomFrame:SetScript("OnMouseDown", callback)
    return
  end

  super(self).SetScript(self, name, callback)
end

function ScrollOverlayFrame:ShowNewMessageAlert()
  self.newMessageAlertFrame:Show()
end

function ScrollOverlayFrame:HideNewMessageAlert()
  self.newMessageAlertFrame:Hide()
end

local function CreateScrollOverlayFrame(parent)
  local FadingFrameMixin = Core.Components.FadingFrameMixin
  local GradientBackgroundMixin = Core.Components.GradientBackgroundMixin

  local frame = CreateFrame("Frame", nil, parent)
  local object = Mixin(frame, FadingFrameMixin, GradientBackgroundMixin, ScrollOverlayFrame)

  FadingFrameMixin.Init(object)
  GradientBackgroundMixin.Init(object)
  ScrollOverlayFrame.Init(object)

  return object
end

Core.Components.CreateScrollOverlayFrame = CreateScrollOverlayFrame
