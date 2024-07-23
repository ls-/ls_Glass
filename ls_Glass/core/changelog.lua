local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.0.0 support.
- Rewrote the addon. Only font-related settings will be carried over.
- Added smooth scrolling through the chat history. Most fading and sliding options are gone because the new system relies on rather tight timings.
- Added proper "Social" button handling.
- Replaced the fade in on mouseover option with show on click. It's causing way too many false positives, too much headache.
- Most chat options are now tab-specific.
]]
