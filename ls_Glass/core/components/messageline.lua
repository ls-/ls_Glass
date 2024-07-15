local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local pairs = _G.pairs

-- Mine
local FADE_IN_DURATION = 0.2
local FADE_IN_DELAY = 0.075

local message_line_proto = {}
do
	function message_line_proto:GetText()
		return self.Text:GetText() or ""
	end

	function message_line_proto:SetText(text, r, g, b, a)
		self.Text:SetText(text)
		self.Text:SetTextColor(r or 1, g or 1, b or 1, a)

		self:AdjustHeight()
	end

	function message_line_proto:SetTimestamp(...)
		self.timestamp = ...
	end

	function message_line_proto:GetTimestamp()
		return self.timestamp or 0
	end

	function message_line_proto:SetMessage(id, timestamp, ...)
		self:SetID(id)
		self:SetTimestamp(timestamp)
		self:SetText(...)
		self:Show()
	end

	function message_line_proto:ClearMessage()
		if self:IsShown() then
			self:Hide()
			self:SetID(0)
			self:SetTimestamp(nil)
			self:SetText("")
		end
	end

	function message_line_proto:FadeIn()
		E:FadeIn(self, FADE_IN_DURATION, nil, FADE_IN_DELAY)
	end

	function message_line_proto:FadeOut(delay, duration)
		E:FadeOut(self, delay, duration, self.funcCache.fadeOutCallback)
	end

	function message_line_proto:StopFading(finalAlpha)
		E:StopFading(self, finalAlpha)
	end

	function message_line_proto:SetPadding(width, xPadding, yPadding)
		self.Text:SetPoint("TOPLEFT", xPadding, -yPadding)
		self.Text:SetWidth(width - xPadding * 2)
	end

	-- SetHeight is taken, duh
	function message_line_proto:AdjustHeight()
		-- realistically, it should be height == 0, but given how this API works, it could be 0.00000001 for all I know
		-- it happens when nil or "" messages are being rendered
		local height = self.Text:GetStringHeight()
		if height < 1 then
			height = self.Text:GetLineHeight()
		end

		self:SetHeight(height + C.db.profile.chat[self:GetPoolID()].y_padding * 2)
	end

	-- ditto
	function message_line_proto:AdjustWidth(width, xPadding)
		self:SetWidth(width)
		self:SetGradientBackgroundSize(width)

		self.Text:SetWidth(width - xPadding * 2)
	end
end

local counters = {}
local poolIDGetters = {}

local function createMessageLine(pool, parent, id)
	local width = E:Round(parent:GetWidth())
	local config = C.db.profile.chat[id]

	counters[pool] = counters[pool] + 1

	local frame = Mixin(CreateFrame("Frame", "$parentMessageLine" .. counters[pool], parent, "LSGlassHyperlinkPropagator"), message_line_proto)
	frame:SetSize(width, config.font.size + config.y_padding * 2)
	frame:SetID(0)
	frame:Hide()

	E:CreateGradientBackground(frame, width, config.alpha)

	frame.Text = frame:CreateFontString(nil, "ARTWORK", "LSGlassMessageFont" .. id)
	frame.Text:SetPoint("TOPLEFT", config.x_padding, -config.y_padding)
	frame.Text:SetWidth(width - config.x_padding * 2)
	frame.Text:SetIndentedWordWrap(true)
	frame.Text:SetNonSpaceWrap(true)

	if not poolIDGetters[id] then
		poolIDGetters[id] = function()
			return id
		end
	end

	frame.GetPoolID = poolIDGetters[id]

	-- these functions are always the same, so just cache them
	frame.funcCache = {
		fadeOutCallback = function()
			frame:ClearMessage()
		end,
	}

	return frame
end

local function resetMessageLine(messageLine)
	messageLine:ClearMessage()
	messageLine:ClearAllPoints()
	messageLine:StopFading(1)
end

local message_pool_proto = {}
do
	function message_pool_proto:UpdateWidth()
		local width = E:Round(self:GetParent():GetWidth())
		local xPadding = C.db.profile.chat[self:GetID()].x_padding

		for messageLine in self:EnumerateActive() do
			messageLine:AdjustWidth(width, xPadding)
		end

		for _, messageLine in self:EnumerateInactive() do
			messageLine:AdjustWidth(width, xPadding)
		end
	end

	function message_pool_proto:UpdateHeight()
		for messageLine in self:EnumerateActive() do
			messageLine:AdjustHeight()
		end

		for _, messageLine in self:EnumerateInactive() do
			messageLine:AdjustHeight()
		end
	end

	function message_pool_proto:UpdateGradientBackgroundAlpha()
		local alpha = C.db.profile.chat[self:GetID()].alpha

		for messageLine in self:EnumerateActive() do
			messageLine:SetGradientBackgroundAlpha(alpha)
		end

		for _, messageLine in self:EnumerateInactive() do
			messageLine:SetGradientBackgroundAlpha(alpha)
		end
	end

	function message_pool_proto:UpdatePadding()
		local width = E:Round(self:GetParent():GetWidth())
		local xPadding = C.db.profile.chat[self:GetID()].x_padding
		local yPadding = C.db.profile.chat[self:GetID()].y_padding

		for messageLine in self:EnumerateActive() do
			messageLine:SetPadding(width, xPadding, yPadding)
		end

		for _, messageLine in self:EnumerateInactive() do
			messageLine:SetPadding(width, xPadding, yPadding)
		end
	end

	-- ! remove, if Blizz add it back
	function message_pool_proto:EnumerateInactive()
		return pairs(self.inactiveObjects)
	end
end

local pools = {}

function E:CreateMessageLinePool(parent, id)
	local pool = Mixin(CreateUnsecuredObjectPool(
			function(pool)
				return createMessageLine(pool, parent, id)
			end,
			function(_, messageLine)
				resetMessageLine(messageLine)
			end
		),
		message_pool_proto
	)

	function pool:GetParent()
		return parent
	end

	function pool:GetID()
		return id
	end

	pools[id] = pool

	counters[pool] = 0

	return pool
end

function E:ForMessageLinePool(id, method, ...)
	local pool = pools[id]
	if pool and pool[method] then
		pool[method](pool, ...)
	end
end
