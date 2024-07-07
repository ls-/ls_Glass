local _, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
function E:HandleDock(frame)
	frame:SetHeight(20)
	frame.scrollFrame:SetHeight(20)
	frame.scrollFrame.child:SetHeight(20)

	frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	hooksecurefunc(frame.scrollFrame, "SetPoint", function(self, p, anchor, rP, x, _, shouldIgnore)
		if shouldIgnore then return end

		if p == "BOTTOMRIGHT" and anchor == frame then
			self:SetPoint(p, anchor, rP, x, 0, true)
		end
	end)

	E:HandleOverflowButton(frame.overflowButton)
end
