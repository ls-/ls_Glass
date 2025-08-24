local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed an issue with the line spacing. There seems to be a Blizz bug where it just ends up increasing on its own.
- Reworked and brought back the new message fade-in effect. Instead of fading in all new messages, only the last/lowest new messaged will be faded in. It should eliminate any weird emptiness while keeping things smooth. Bozo, welcome back.
]]
