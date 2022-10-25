local Core, Constants = unpack(select(2, ...))

local MouseEnter = Constants.ACTIONS.MouseEnter
local MouseLeave = Constants.ACTIONS.MouseLeave

local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

-- luacheck: push ignore 113
local CreateFrame = CreateFrame
local Mixin = Mixin
local MouseIsOver = MouseIsOver
-- luacheck: pop

local MainContainerFrameMixin = {}

function MainContainerFrameMixin:Init()
  self.state = {
    mouseOver = false
  }

  self:SetWidth(Core.db.profile.frameWidth)
  self:SetHeight(Core.db.profile.frameHeight)

  --@debug@
  self.bg = self:CreateTexture(nil, "BACKGROUND")
  self.bg:SetColorTexture(1, 0, 0, 0)
  self.bg:SetAllPoints()
  --@end-debug@

  Core:Subscribe(UPDATE_CONFIG, function (key)
    if key == "frameWidth" then
      self:SetWidth(Core.db.profile.frameWidth)
    end

    if key == "frameHeight" then
      self:SetHeight(Core.db.profile.frameHeight)
    end
  end)
end

function MainContainerFrameMixin:OnFrame()
  -- Mouse over tracking
  if self.state.mouseOver ~= MouseIsOver(self) then
    if not self.state.mouseOver then
      Core:Dispatch(MouseEnter())
    else
      Core:Dispatch(MouseLeave())
    end

    self.state.mouseOver = not self.state.mouseOver
  end
end

Core.Components.CreateMainContainerFrame = function (name, parent)
  local frame = CreateFrame("Frame", name, parent)
  local object = Mixin(frame, MainContainerFrameMixin)
  object:Init()
  return object
end
