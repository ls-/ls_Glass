local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed an issue where old chat messages would still disappear even though message fading is disabled.
]]
