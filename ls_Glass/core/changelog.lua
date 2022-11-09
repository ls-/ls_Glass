local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed more issues related to fasting forward. Those pesky line#340 errors.
- Limited x/y padding to >= 1. Vertical padding set to 0 was breaking stuff.
- Added German translation. Translated by terijaki@GitHub.
]]
