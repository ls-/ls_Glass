local Core, Constants = unpack(select(2, ...))

local Colors = Constants.COLORS

-- luacheck: push ignore 113
local CreateFrame = CreateFrame
local Mixin = Mixin
-- luacheck: pop

local NewMessageAlertFrameMixin = {}

function NewMessageAlertFrameMixin:Init()
    self:SetHeight(20)
    self:SetPoint("BOTTOMLEFT")
    self:SetPoint("BOTTOMRIGHT")
    self:SetFadeInDuration(0.15)
    self:SetFadeOutDuration(0.15)

    -- New messages text
    if self.text == nil then
      self.text = self:CreateFontString(nil, "ARTWORK", "GlassMessageFont")
    end
    self.text:SetTextColor(Colors.apache.r, Colors.apache.g, Colors.apache.b)
    self.text:SetPoint("BOTTOMLEFT", 30, 10)
    self.text:SetText("Unread messages")

    -- Alert line
    if self.bottomLine == nil then
      local GradientBackgroundMixin = Core.Components.GradientBackgroundMixin

      self.bottomLine = CreateFrame("Frame", nil, self)
      self.bottomLine = Mixin(self.bottomLine, GradientBackgroundMixin)
      GradientBackgroundMixin.Init(self.bottomLine)
      self.bottomLine:SetHeight(1)
      self.bottomLine:SetPoint("BOTTOMLEFT")
      self.bottomLine:SetPoint("BOTTOMRIGHT")
    end
    self.bottomLine:SetGradientBackground(15, 15, Colors.apache, 0.65)
end

local function CreateNewMessageAlertFrame(parent)
  local FadingFrameMixin = Core.Components.FadingFrameMixin

  local frame = CreateFrame("Frame", nil, parent)
  local object = Mixin(frame, FadingFrameMixin, NewMessageAlertFrameMixin)

  FadingFrameMixin.Init(object)
  NewMessageAlertFrameMixin.Init(object)

  return object
end

Core.Components.CreateNewMessageAlertFrame = CreateNewMessageAlertFrame
