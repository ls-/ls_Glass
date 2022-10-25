local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local _, Constants = unpack(select(2, ...))

local MOUSE_ENTER = Constants.EVENTS.MOUSE_ENTER
local MOUSE_LEAVE = Constants.EVENTS.MOUSE_LEAVE
local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

local HEIGHT = 20

local dock_proto = {
	state = {
		mouseOver = false
	},
}

function E:CreateTabHeader(parent)
	local frame = Mixin(GeneralDockManager, dock_proto)
	frame:SetWidth(C.db.profile.width)
	frame:SetHeight(HEIGHT)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT")

	-- ? Do I want it here or do I want every frame header to have its own bg?
	E:CreateGradientBackground(frame, 50, 250, 0, 0, 0, 0.4) -- TODO: Add me to config!
	-- frame:SetFadeInDuration(0.6) -- ! FadingFrameMixin
	-- frame:SetFadeOutDuration(0.6) -- ! FadingFrameMixin

	-- TODO: Comment me out!
	-- frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	-- frame.bg:SetColorTexture(0, 0.6, 0.3, 0.3)
	-- frame.bg:SetAllPoints()

	-- TODO: what do?
	-- frame.scrollFrame:SetHeight(HEIGHT)
	-- self.scrollFrame:SetPoint("TOPLEFT", _G.ChatFrame2Tab, "TOPRIGHT")
	-- frame.scrollFrame.child:SetHeight(HEIGHT)

	-- ! This taints the default UI, never do this
	-- hooksecurefunc("FCF_StopDragging", function(chatFrame)
	-- 	local mouseX, mouseY = GetCursorPosition()
	-- 	mouseX, mouseY = mouseX / UIParent:GetScale(), mouseY / UIParent:GetScale()
	-- 	FCF_DockFrame(chatFrame, FCFDock_GetInsertIndex(frame, chatFrame, mouseX, mouseY), true)
	-- 	FCF_SavePositionAndDimensions(chatFrame)
	-- end)

	-- self:QuickHide() -- ! FadingFrameMixin

	E:Subscribe(MOUSE_ENTER, function()
		-- Don't hide tabs when mouse is over
		frame.state.mouseOver = true
		frame:Show()
	end)

	E:Subscribe(MOUSE_LEAVE, function()
		-- Hide chat tab when mouse leaves
		frame.state.mouseOver = false

		if C.db.profile.chat.mouseover then
			-- When chatShowOnMouseOver is on, synchronize the chat tab's fade out with
			-- the chat
			frame:Hide()
			-- frame:HideDelay(C.db.profile.chat.hold_time) -- ! FadingFrameMixin
		else
			-- Otherwise hide it immediately on mouse leave
			frame:Hide()
		end
	end)

	E:Subscribe(UPDATE_CONFIG, function(key)
		if key == "frameWidth" then
			frame:SetWidth(C.db.profile.width)
			frame:SetGradientBackgroundSize(50, C.db.profile.width - 150) -- 150 = 450 - 250
		end
	end)

	return frame
end
