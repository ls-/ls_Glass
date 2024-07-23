local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local object_proto = {}

function object_proto:SetGradientBackgroundSize(width)
	self.leftBg:SetWidth(E:Round(width * 0.15))
	self.rightBg:SetWidth(E:Round(width * 0.45))
end

function object_proto:SetGradientBackgroundAlpha(a)
	self.leftBg.toColor.a = a
	self.leftBg:SetGradient("HORIZONTAL", self.leftBg.fromColor, self.leftBg.toColor)

	self.rightBg.fromColor.a = a
	self.rightBg:SetGradient("HORIZONTAL", self.rightBg.fromColor, self.rightBg.toColor)

	self.centerBg:SetAlpha(a)
end

function object_proto:SetGradientBackgroundShown(state)
	self.leftBg:SetShown(state)
	self.rightBg:SetShown(state)
	self.centerBg:SetShown(state)
end

function E:CreateGradientBackground(object, width, a)
	Mixin(object, object_proto)

	if not object.leftBg then
		object.leftBg = object:CreateTexture(nil, "BACKGROUND")
		object.leftBg:SetPoint("TOPLEFT")
		object.leftBg:SetPoint("BOTTOMLEFT")
		object.leftBg:SetSnapToPixelGrid(false)
		object.leftBg:SetTexelSnappingBias(0)
		object.leftBg:SetColorTexture(1, 1, 1, 1)

		object.leftBg.fromColor = {r = 0, g = 0, b = 0, a = 0}
		object.leftBg.toColor = {r = 0, g = 0, b = 0, a = a}
	end

	object.leftBg:SetWidth(E:Round(width * 0.15))
	object.leftBg:SetGradient("HORIZONTAL", object.leftBg.fromColor, object.leftBg.toColor)

	if not object.rightBg then
		object.rightBg = object:CreateTexture(nil, "BACKGROUND")
		object.rightBg:SetPoint("TOPRIGHT")
		object.rightBg:SetPoint("BOTTOMRIGHT")
		object.rightBg:SetSnapToPixelGrid(false)
		object.rightBg:SetTexelSnappingBias(0)
		object.rightBg:SetColorTexture(1, 1, 1, 1)

		object.rightBg.fromColor = {r = 0, g = 0, b = 0, a = a}
		object.rightBg.toColor = {r = 0, g = 0, b = 0, a = 0}
	end

	object.rightBg:SetWidth(E:Round(width * 0.45))
	object.rightBg:SetGradient("HORIZONTAL", object.rightBg.fromColor, object.rightBg.toColor)

	if not object.centerBg then
		object.centerBg = object:CreateTexture(nil, "BACKGROUND")
		object.centerBg:SetPoint("TOPLEFT", object.leftBg, "TOPRIGHT")
		object.centerBg:SetPoint("BOTTOMRIGHT", object.rightBg, "BOTTOMLEFT")
		object.centerBg:SetSnapToPixelGrid(false)
		object.centerBg:SetTexelSnappingBias(0)
		object.centerBg:SetColorTexture(0, 0, 0, 1)
	end

	object.centerBg:SetAlpha(a)
end
