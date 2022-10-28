local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local _, Constants = unpack(select(2, ...))

local HyperlinkClick = Constants.ACTIONS.HyperlinkClick
local HyperlinkEnter = Constants.ACTIONS.HyperlinkEnter
local HyperlinkLeave = Constants.ACTIONS.HyperlinkLeave

local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

local message_line_proto = {}

do
	function message_line_proto:SetIndentedWordWrap()
		self.Text:SetIndentedWordWrap(C.db.profile.indented_word_wrap)
	end

	function message_line_proto:SetText(text, r, g, b, a)
		self.Text:SetHeight(128)
		self.Text:SetText(text)
		self.Text:SetTextColor(r or 1, g or 1, b or 1, a)

		self:SetHeight(self.Text:GetStringHeight() + C.db.profile.chat.padding * 2)
	end

	function message_line_proto:UpdateGradient()
		self:SetGradientBackgroundSize(50, math.min(250, C.db.profile.width - 50))
		self:SetGradientBackgroundColor(0, 0, 0, C.db.profile.chat.opacity) -- TODO: Add me to config!
	end

	function message_line_proto:OnHyperlinkClick(link, text, button)
		E:Dispatch(HyperlinkClick({link, text, button}))
	end

	function message_line_proto:OnHyperlinkEnter(link, text)
		if C.db.profile.mouseover_tooltips then
			E:Dispatch(HyperlinkEnter({link, text}))
		end
	end

	function message_line_proto:OnHyperlinkLeave(link)
		E:Dispatch(HyperlinkLeave(link))
	end
end

local function createMessageLine(parent)
	local frame = Mixin(CreateFrame("Frame", nil, parent), message_line_proto)
	frame:SetSize(C.db.profile.width, C.db.profile.chat.size + C.db.profile.chat.padding * 2)
	frame:SetHyperlinksEnabled(true)
	frame:SetScript("OnHyperlinkClick", frame.OnHyperlinkClick)
	frame:SetScript("OnHyperlinkEnter", frame.OnHyperlinkEnter)
	frame:SetScript("OnHyperlinkLeave", frame.OnHyperlinkLeave)
	frame:Hide()

	-- frame:SetFadeInDuration(Core.db.profile.chatFadeInDuration) -- ! FadingFrameMixin
	-- frame:SetFadeOutDuration(Core.db.profile.chatFadeOutDuration) -- ! FadingFrameMixin

	E:CreateGradientBackground(frame, 50, math.min(250, C.db.profile.width - 50), 0, 0, 0, C.db.profile.chat.opacity) -- TODO: Add me to config!

	frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	-- frame.Text = frame:CreateFontString(nil, "ARTWORK", "GlassMessageFont")
	frame.Text:SetPoint("LEFT", Constants.TEXT_XPADDING, 0)
	frame.Text:SetPoint("RIGHT", -Constants.TEXT_XPADDING, 0)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetJustifyV("MIDDLE")
	frame.Text:SetIndentedWordWrap(C.db.profile.indented_word_wrap)

	E:Subscribe(UPDATE_CONFIG, function (key)
		if key == "chatFadeInDuration" then
			-- frame:SetFadeInDuration(Core.db.profile.chatFadeInDuration) -- ! FadingFrameMixin
		end

		if key == "chatFadeOutDuration" then
			-- frame:SetFadeOutDuration(Core.db.profile.chatFadeOutDuration) -- ! FadingFrameMixin
		end
	end)

	return frame
end

local function resetMessageLine(_, messageLine)
	messageLine.Text:SetText("")
	messageLine:ClearAllPoints()
	messageLine:Hide()
end

function E:CreateMessageLinePool(parent)
	return CreateObjectPool(function() return createMessageLine(parent) end, resetMessageLine)
end
