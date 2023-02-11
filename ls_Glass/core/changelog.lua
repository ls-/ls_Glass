local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.0.5 support.
- Added optional buttons for scrolling up and down. It's an accessibility feature meant for users
  who can't use the mouse wheel. Holding the Ctrl key will slow the scrolling rate by two times.
- Added an option to fade in chat messages on mouseover.
]]
