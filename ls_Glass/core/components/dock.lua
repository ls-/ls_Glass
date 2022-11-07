local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
function E:HandleDock(frame)
	frame:SetHeight(20)
	frame.scrollFrame:SetHeight(20)
	frame.scrollFrame.child:SetHeight(20)

	E:HandleOverflowButton(frame.overflowButton)
end
