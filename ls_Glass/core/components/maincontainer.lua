local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local Core, Constants = unpack(select(2, ...))

local MouseEnter = Constants.ACTIONS.MouseEnter
local MouseLeave = Constants.ACTIONS.MouseLeave

local UPDATE_CONFIG = Constants.EVENTS.UPDATE_CONFIG

local container_proto = {
	state = {
		mouseOver = false
	},
}

-- TODO: Keep an on these, might need to rework them later
function container_proto:OnFrame()
	if self.state.mouseOver ~= MouseIsOver(self) then
		if not self.state.mouseOver then
			Core:Dispatch(MouseEnter())
		else
			Core:Dispatch(MouseLeave())
		end

		self.state.mouseOver = not self.state.mouseOver
	end
end

function E:CreateMainContainer(name, parent)
	local frame = Mixin(CreateFrame("Frame", name, parent), container_proto)
	frame:SetWidth(C.db.profile.width)
	frame:SetHeight(C.db.profile.height)

	-- TODO: Comment me out!
	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetColorTexture(0, 0.6, 0.3, 0.3)
	frame.bg:SetAllPoints()

	Core:Subscribe(UPDATE_CONFIG, function (key)
		if key == "frameWidth" then -- TODO
			frame:SetWidth(C.db.profile.width)
		end

		if key == "frameHeight" then -- TODO
			frame:SetHeight(C.db.profile.height)
		end
	end)

	return frame
end
