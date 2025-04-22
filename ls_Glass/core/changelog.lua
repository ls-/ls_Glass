local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.1.5 support.
- Added an option to make the chat input show multiple lines of text. Can be found at / LSG > Edit Xox > Multiline,
  disabled by default.
- Fixed an issue where clicking the "[Show Message]" link to reveal a censored message would do nothing.
]]
