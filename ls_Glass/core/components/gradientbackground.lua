local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local Core = unpack(select(2, ...))

local GradientBackgroundMixin = {}

function GradientBackgroundMixin:Init()
end

function GradientBackgroundMixin:SetGradientBackground(leftWidth, rightWidth, color, opacity)
  if self.leftBg == nil then
    self.leftBg = self:CreateTexture(nil, "BACKGROUND")
    self.leftBg:SetPoint("TOPLEFT")
    self.leftBg:SetPoint("BOTTOMLEFT")
    self.leftBg:SetColorTexture(1, 1, 1, 1)
  end
  self.leftBg:SetWidth(leftWidth)
  self.leftBg:SetGradient(
    "HORIZONTAL",
    CreateColor(color.r, color.g, color.b, 0),
    CreateColor(color.r, color.g, color.b, opacity)
  )

  if self.rightBg == nil then
    self.rightBg = self:CreateTexture(nil, "BACKGROUND")
    self.rightBg:SetPoint("TOPRIGHT")
    self.rightBg:SetPoint("BOTTOMRIGHT")
    self.rightBg:SetColorTexture(1, 1, 1, 1)
  end
  self.rightBg:SetWidth(rightWidth)
  self.rightBg:SetGradient(
    "HORIZONTAL",
    CreateColor(color.r, color.g, color.b, opacity),
    CreateColor(color.r, color.g, color.b, 0)
  )

  if self.centerBg == nil then
    self.centerBg = self:CreateTexture(nil, "BACKGROUND")
    self.centerBg:SetPoint("TOPLEFT", self.leftBg, "TOPRIGHT")
    self.centerBg:SetPoint("BOTTOMRIGHT", self.rightBg, "BOTTOMLEFT")
  end
  self.centerBg:SetColorTexture(color.r, color.g, color.b, opacity)
end

Core.Components.GradientBackgroundMixin = GradientBackgroundMixin

local object_proto = {}

function object_proto:SetGradientBackgroundSize(leftWidth, rightWidth)
	self.leftBg:SetWidth(leftWidth)
	self.rightBg:SetWidth(rightWidth)
end

function object_proto:SetGradientBackgroundColor(r, g, b, a)
	self.leftBg:SetGradient("HORIZONTAL", {r = r, g = g, b = b, a = 0}, {r = r, g = g, b = b, a = a})
	self.rightBg:SetGradient("HORIZONTAL", {r = r, g = g, b = b, a = a}, {r = r, g = g, b = b, a = 0})
	self.centerBg:SetColorTexture(r, g, b, a)
end

function E:CreateGradientBackground(object, leftWidth, rightWidth, r, g, b, a)
	Mixin(object, object_proto)

	if not object.leftBg then
		object.leftBg = object:CreateTexture(nil, "BACKGROUND")
		object.leftBg:SetPoint("TOPLEFT")
		object.leftBg:SetPoint("BOTTOMLEFT")
		object.leftBg:SetColorTexture(1, 1, 1, 1)
	end

	object.leftBg:SetWidth(leftWidth)
	object.leftBg:SetGradient("HORIZONTAL", {r = r, g = g, b = b, a = 0}, {r = r, g = g, b = b, a = a})

	if not object.rightBg then
		object.rightBg = object:CreateTexture(nil, "BACKGROUND")
		object.rightBg:SetPoint("TOPRIGHT")
		object.rightBg:SetPoint("BOTTOMRIGHT")
		object.rightBg:SetColorTexture(1, 1, 1, 1)
	end

	object.rightBg:SetWidth(rightWidth)
	object.rightBg:SetGradient("HORIZONTAL", {r = r, g = g, b = b, a = a}, {r = r, g = g, b = b, a = 0})

	if not object.centerBg then
		object.centerBg = object:CreateTexture(nil, "BACKGROUND")
		object.centerBg:SetPoint("TOPLEFT", object.leftBg, "TOPRIGHT")
		object.centerBg:SetPoint("BOTTOMRIGHT", object.rightBg, "BOTTOMLEFT")
	end

	object.centerBg:SetColorTexture(r, g, b, a)
end
