local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added support for the pet battle log.
- Fixed an issue where custom fonts wouldn't apply on load.
- Added Korean translation. Translated by netaras@Curse.
- Added Portuguese translation. Translated by Azeveco@Curse.
- Added Traditional Chinese translation. Translated by RainbowUI@Curse.
- Updated French translation. Translated by Braincell1980@Curse.
- Updated German translation. Translated by Solence1@Curse.

### Known Issues

- There's a bug where the chat frame sometimes stops updating properly after scrolling down with
  the mouse wheel. It's a tricky one to fix, I'm still investigating it. But to resume the update
  process you need to scroll up until you see the "Jump to Present"/"Unread Messages" button and
  then click it.
]]
