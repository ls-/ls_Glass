local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.2.5 support.
- Added a workaround for an issue where item, achievement, etc links in chat couldn't be clicked because the chat window was set to non-interactive.
]]
