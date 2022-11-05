local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
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
