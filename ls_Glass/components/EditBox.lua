local Core, Constants = unpack(select(2, ...))

local AceHook = Core.Libs.AceHook

local Colors = Constants.COLORS

local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

-- luacheck: push ignore 113
local Mixin = Mixin
-- luacheck: pop

local EditBoxMixin = {}

function EditBoxMixin:Init(parent)
  -- Hide default styling
  _G[self:GetName().."Left"]:Hide()
  _G[self:GetName().."Mid"]:Hide()
  _G[self:GetName().."Right"]:Hide()

  self:RawHook(_G[self:GetName().."Left"], "Show", function () end, true)
  self:RawHook(_G[self:GetName().."Mid"], "Show", function () end, true)
  self:RawHook(_G[self:GetName().."Right"], "Show", function () end, true)

  if Constants.ENV == "retail" then
    _G[self:GetName().."FocusLeft"]:Hide()
    _G[self:GetName().."FocusMid"]:Hide()
    _G[self:GetName().."FocusRight"]:Hide()
    self:RawHook(_G[self:GetName().."FocusLeft"], "Show", function () end, true)
    self:RawHook(_G[self:GetName().."FocusMid"], "Show", function () end, true)
    self:RawHook(_G[self:GetName().."FocusRight"], "Show", function () end, true)
  end

  -- New styling
  self:ClearAllPoints()

  self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 8, Core.db.profile.editBoxAnchor.yOfs)

  if Core.db.profile.editBoxAnchor.position == "ABOVE" then
    self:ClearAllPoints()
    self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 8, Core.db.profile.editBoxAnchor.yOfs)
  end

  self:SetFontObject("GlassEditBoxFont")
  self:SetWidth(Core.db.profile.frameWidth - 8 * 2)
  self.header:SetFontObject("GlassEditBoxFont")
  self.header:SetPoint("LEFT", 8, 0)

  local bg = self:CreateTexture(nil, "BACKGROUND")
  bg:SetColorTexture(
    Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, Core.db.profile.editBoxBackgroundOpacity
  )
  bg:SetAllPoints()

  local Ypadding = self.header:GetLineHeight() * 0.66
  self:SetHeight(self.header:GetLineHeight() + Ypadding * 2)

  self:RawHook(self, "SetTextInsets", function ()
    Ypadding = self.header:GetLineHeight() * 0.66
    self.hooks[self].SetTextInsets(
      self,
      self.header:GetStringWidth() + 8,
      8, Ypadding, Ypadding
    )
  end, true)

  self:SetTextInsets()

  -- Animations
  -- Intro animations
  local introAg = self:CreateAnimationGroup()
  local fadeIn = introAg:CreateAnimation("Alpha")
  fadeIn:SetFromAlpha(0)
  fadeIn:SetToAlpha(1)
  fadeIn:SetDuration(0.2)
  fadeIn:SetSmoothing("OUT")

  -- Outro animations
  local outroAg = self:CreateAnimationGroup()
  local fadeOut = outroAg:CreateAnimation("Alpha")
  fadeOut:SetFromAlpha(1)
  fadeOut:SetToAlpha(0)
  fadeOut:SetDuration(0.05)

  -- Workaround for editbox being open on login
  self.glassInitialized = false

  self:SetScript("OnShow", function ()
    if self.glassInitialized then
      introAg:Play()
    else
      self.glassInitialized = true
    end
  end)

  outroAg:SetScript("OnFinished", function ()
    if not introAg:IsPlaying() then
      self.hooks[self].Hide(self)
    end
  end)

  self:RawHook(self, "Hide", function ()
    outroAg:Play()
  end, true)

  Core:Subscribe(UPDATE_CONFIG, function (key)
    if key == "font" or key == "editBoxFontSize" then
      Ypadding = self.header:GetLineHeight() * 0.66
      self:SetHeight(self.header:GetLineHeight() + Ypadding * 2)
      self:SetTextInsets()
    end

    if key == "frameWidth" then
      self:SetWidth(Core.db.profile.frameWidth - 8 * 2)
    end

    if key == "editBoxBackgroundOpacity" then
      bg:SetColorTexture(
        Colors.codGray.r, Colors.codGray.g, Colors.codGray.b, Core.db.profile.editBoxBackgroundOpacity
      )
    end

    if key == "editBoxAnchor" then
      if Core.db.profile.editBoxAnchor.position == "ABOVE" then
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 8, Core.db.profile.editBoxAnchor.yOfs)
      else
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 8, Core.db.profile.editBoxAnchor.yOfs)
      end
    end
  end)
end

Core.Components.CreateEditBox = function (parent)
  local object = Mixin(_G.ChatFrame1EditBox, EditBoxMixin)
  AceHook:Embed(object)
  object:Init(parent)
  return object
end
