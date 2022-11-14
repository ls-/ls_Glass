local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added options to change the edit box's position and offset.
- Improved compatibility with other addons that re-format chat messages. IME, the most compatible
  one is BasicChatMods by funkehdude, it has features my addon currently lacks, like button hiding.
  That said, you definitely should disable overlapping features in other addons.
- Replaced "Jump to Present" and "Unread Messages" with icons because those text strings were
  obnoxiously long in some locales.
- Fixed an issue where the chat frame would sometimes stop updating after scrolling down with the
  mouse wheel.
- Added Spanish translation. Translated by cacahuete_uchi@Curse.
- Updated Korean translation. Translated by netaras@Curse and unrealcrom96@Curse.
]]
