local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Improved compatibility with ElvUI. Now the addon will stop loading if it detects that ElvUI chat is enabled, and you'll be greeted by the addon incompatibility popup from ElvUI. Just to make things clear, it's safe to use LS: Glass with ElvUI, you just want to disable its chat module because both addons will try to modify chat in rather extensive ways which nowadays may result in game freezes.
- Fixed an issue where the addon would struggle to scroll through messages that are taller than the chat frame itself.
- Fixed an issue where the "Copy from" menu in the chat settings would fail to fetch the list of other chat windows.
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.
]]
