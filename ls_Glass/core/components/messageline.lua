local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert

-- Mine
local message_line_proto = {}

do
	function message_line_proto:GetText()
		return self.Text:GetText() or ""
	end

	function message_line_proto:SetText(text, r, g, b, a)
		self.Text:SetHeight(128)
		self.Text:SetText(text)
		self.Text:SetTextColor(r or 1, g or 1, b or 1, a)

		self:SetHeight(self.Text:GetStringHeight() + C.db.profile.chat.y_padding * 2)
	end

	function message_line_proto:UpdateGradient()
		local width = self:GetWidth()

		self:SetGradientBackgroundSize(E:Round(width * 0.1), E:Round(width * 0.4))
		self:SetGradientBackgroundColor(0, 0, 0, C.db.profile.chat.alpha)
	end
end

local function createMessageLine(parent)
	local width = parent:GetWidth()

	local frame = Mixin(CreateFrame("Frame", nil, parent, "LSGlassHyperlinkPropagator"), message_line_proto)
	frame:SetSize(width, C.db.profile.chat.font.size + C.db.profile.chat.y_padding * 2)
	frame:SetAlpha(0)
	frame:Hide()

	E:CreateGradientBackground(frame, E:Round(width * 0.1), E:Round(width * 0.5), 0, 0, 0, C.db.profile.chat.alpha)

	frame.Text = frame:CreateFontString(nil, "ARTWORK", "LSGlassMessageFont")
	frame.Text:SetPoint("LEFT", C.db.profile.chat.x_padding, 0)
	frame.Text:SetPoint("RIGHT", -C.db.profile.chat.x_padding, 0)

	return frame
end

local function resetMessageLine(messageLine)
	messageLine.Text:SetText("")
	messageLine:ClearAllPoints()
	messageLine:Hide()
	messageLine:UpdateGradient()
	E:StopFading(messageLine, 0)
end

local pools = {}

function E:CreateMessageLinePool(parent)
	local pool = CreateObjectPool(function()
		return createMessageLine(parent)
	end, function(_, messageLine)
		resetMessageLine(messageLine)
	end)

	pool.parent = parent

	t_insert(pools, pool)

	return pool
end

function E:UpdateMessageLinesBackgrounds()
	for _, pool in next, pools do
		for messageLine in pool:EnumerateActive() do
			messageLine:UpdateGradient()
		end

		for _, messageLine in pool:EnumerateInactive() do
			messageLine:UpdateGradient()
		end
	end
end

function E:UpdateMessageLinesHeights()
	for _, pool in next, pools do
		for messageLine in pool:EnumerateActive() do
			messageLine:SetHeight(messageLine.Text:GetStringHeight() + C.db.profile.chat.y_padding * 2)
		end

		for _, messageLine in pool:EnumerateInactive() do
			messageLine:SetHeight(messageLine.Text:GetStringHeight() + C.db.profile.chat.y_padding * 2)
		end
	end
end

function E:UpdateMessageLinesHorizPadding()
	for _, pool in next, pools do
		for messageLine in pool:EnumerateActive() do
			messageLine.Text:SetPoint("LEFT", C.db.profile.chat.x_padding, 0)
			messageLine.Text:SetPoint("RIGHT", -C.db.profile.chat.x_padding, 0)
		end

		for _, messageLine in pool:EnumerateInactive() do
			messageLine.Text:SetPoint("LEFT", C.db.profile.chat.x_padding, 0)
			messageLine.Text:SetPoint("RIGHT", -C.db.profile.chat.x_padding, 0)
		end
	end
end
