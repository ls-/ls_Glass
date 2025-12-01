local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.2.7 support.
- Reworked how fonts are handled. Added a way to override individual alphabets, it should be useful for fonts that support multiple alphabets like CJK and whatnot.

NOTE: Unfortunately, the addon will be retired come Midnight. The addon simply can't function in M+, during raid encounters, etc because chat messages now contain secrets, and when that happens I can't get messages' dimensions which makes maths and thus smooth scrolling impossible.
]]
