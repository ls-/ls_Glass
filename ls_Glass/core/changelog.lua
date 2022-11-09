local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added horizontal and vertical padding options for messages.
- Fixed an issue where messages' background gradient wouldn't resize properly.
- Fixed an issue where fast forwarding would break the message display.
- Reduced the minimal possible chat frame size to 176x64, making it smaller will break stuff.
  The max is uncapped.
- Added French translation. Translated by Braincell1980@Curse.
]]
