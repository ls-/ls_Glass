local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local m_min = _G.math.min

-- Mine
local message_line_proto = {}

do
	function message_line_proto:SetIndentedWordWrap()
		self.Text:SetIndentedWordWrap(C.db.profile.chat.font.indented_word_wrap)
	end

	function message_line_proto:SetText(text, r, g, b, a)
		self.Text:SetHeight(128)
		self.Text:SetText(text)
		self.Text:SetTextColor(r or 1, g or 1, b or 1, a)

		self:SetHeight(self.Text:GetStringHeight() + C.db.profile.chat.padding * 2)
	end

	function message_line_proto:UpdateGradient()
		self:SetGradientBackgroundSize(50, m_min(250, C.db.profile.width - 50))
		self:SetGradientBackgroundColor(0, 0, 0, C.db.profile.chat.alpha) -- TODO: Add me to config!
	end
end

local function createMessageLine(parent)
	local frame = Mixin(CreateFrame("Frame", nil, parent, "LSGlassHyperlinkPropagator"), message_line_proto)
	frame:SetSize(C.db.profile.width, C.db.profile.chat.size + C.db.profile.chat.padding * 2)
	frame:SetAlpha(0)
	frame:Hide()

	E:CreateGradientBackground(frame, 50, m_min(250, C.db.profile.width - 50), 0, 0, 0, C.db.profile.chat.alpha) -- TODO: Add me to config!

	frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- TODO: Fix me!
	-- frame.Text = frame:CreateFontString(nil, "ARTWORK", "GlassMessageFont")
	frame.Text:SetPoint("LEFT", 15, 0)
	frame.Text:SetPoint("RIGHT", -15, 0)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetJustifyV("MIDDLE")
	frame.Text:SetIndentedWordWrap(C.db.profile.chat.font.indented_word_wrap)

	return frame
end

local function resetMessageLine(_, messageLine)
	messageLine.Text:SetText("")
	messageLine:ClearAllPoints()
	messageLine:Hide()
	E:StopFading(messageLine, 0)
end

function E:CreateMessageLinePool(parent)
	return CreateObjectPool(function() return createMessageLine(parent) end, resetMessageLine)
end
