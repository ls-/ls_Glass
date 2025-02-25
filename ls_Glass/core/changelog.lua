local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.1.0 support.
- Added an option to position buttons (social, menu, etc) to the left or to the right of the main chat frame. Can be
  found at /LSG > Tabs & Buttons > Position, set to "Right" by default.
- Added an option to disabled quick join toasts. Can be found at /LSG > Tabs & Buttons > Quick Join Toasts, enabled by
  default.
- Added support for "Chat Page Up", "Chat Page Down", and "Chat Bottom" keybinds.

### Known Issues

- Chat messages may behave a bit weird at times, for instance, they might blink while scrolling. Blizz changed something
  in the backend (not Lua code, so it's not available to addon devs) because the same code works without issues in
  11.0.7. Now I need to figure out how to work around it.
]]
