local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.2.6 support.
- Fixed an issue where the chat frame would disappear after it's previously hidden.
- Fixed an issue where some messages would appear truncated.
- Fixed an issue where some characters would appear as squares. The addon now properly mimics the default chat's
  behaviour which also includes all the bugs that come with it. For instance, depending on the alphabet those characters
  belong to, those messages will completely ignore various chat settings like font size, outline, etc. It is this way 
  due to limitation on Blizz end.
- Set minimal Y padding to 0. Yes, no more gaps in the TomCats' messages :>
]]
