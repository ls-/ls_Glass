local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.2.0 support.
- Added an option not to use the Alt key for cursor movement inside the edit box.
- Fixed an issue where the pet battle chat tab would stay nameless. It's a Blizz bug, but it's possible to add a
  workaround on my end.
- Made scrolling/sliding animations smoother.
- Removed the fade-in effect on new messages. It looked cool on oneliners, but on anything else it's pretty jarring. Whenever multiple new messages were sliding in, at first you'd see a large empty space, and then the text would appear. It's particularly bad, if the messages were also long. Sorry, but I couldn't stand it anymore. RIP Bozo.
]]
