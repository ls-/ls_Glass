local Core, Constants = unpack(select(2, ...))

local SaveFramePosition = Constants.ACTIONS.SaveFramePosition

local LOCK_MOVER = Constants.EVENTS.LOCK_MOVER
local UNLOCK_MOVER = Constants.EVENTS.UNLOCK_MOVER
local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

local MoverFrameMixin = {}

-- luacheck: push ignore 113
local CreateFrame = CreateFrame
local Mixin = Mixin
-- luacheck: pop

function MoverFrameMixin:Init()
  local editBoxMargin = 35
  self:ClearAllPoints()
  self:SetPoint(
    Core.db.profile.positionAnchor.point,
    Core.db.profile.positionAnchor.xOfs,
    Core.db.profile.positionAnchor.yOfs
  )
  self:SetWidth(Core.db.profile.frameWidth)
  self:SetHeight(Core.db.profile.frameHeight + editBoxMargin)

  self.bg = self:CreateTexture(nil, "BACKGROUND")
  self.bg:SetColorTexture(0, 1, 0, 0.5)
  self.bg:SetAllPoints()

  self:Hide()

  self:RegisterForDrag("LeftButton")
  self:SetScript("OnDragStart", self.StartMoving)
  self:SetScript("OnDragStop", self.StopMovingOrSizing)

  if self.subscriptions == nil then
    self.subscriptions = {
      Core:Subscribe(LOCK_MOVER, function ()
        self:Hide()
        self:EnableMouse(false)
        self:SetMovable(false)

        local point, _, _, xOfs, yOfs = self:GetPoint(1)
        local position = {
          point = point,
          xOfs = xOfs,
          yOfs = yOfs
        }

        Core:Dispatch(SaveFramePosition(position))
      end),
      Core:Subscribe(UNLOCK_MOVER, function ()
        self:Show()
        self:EnableMouse(true)
        self:SetMovable(true)
      end),
      Core:Subscribe(UPDATE_CONFIG, function (key)
        if (key == "frameWidth") then
          self:SetWidth(Core.db.profile.frameWidth)
        end

        if (key == "frameHeight") then
          self:SetHeight(Core.db.profile.frameHeight + editBoxMargin)
        end

        if key == "framePosition" then
          self:ClearAllPoints()
          self:SetPoint(
            Core.db.profile.positionAnchor.point,
            Core.db.profile.positionAnchor.xOfs,
            Core.db.profile.positionAnchor.yOfs
          )
        end
      end),
    }
  end
end

Core.Components.CreateMoverFrame = function (name, parent)
  local frame = CreateFrame("Frame", name, parent)
  local object = Mixin(frame, MoverFrameMixin)
  object:Init()
  return object
end
