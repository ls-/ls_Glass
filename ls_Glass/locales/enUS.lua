-- Contributors:

local _, ns = ...

-- Lua
local _G = getfenv(0)

-- Mine
local L = {}
ns.L = L

L["LS_GLASS"] = "LS: |cffe0bc5bGlass|r"
L["CURSEFORGE"] = "CurseForge"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["WAGO"] = "Wago"
L["WOWINTERFACE"] = "WoWInterface"

L["CHAT"] = _G.CHAT_LABEL
L["ENABLE"] = _G.ENABLE
L["GENERAL"] = _G.GENERAL_LABEL
L["INFO"] = "|cffe0bc5b" .. _G.INFO .. "|r"
L["OKAY"] = _G.OKAY
L["RESET_TO_DEFAULT"] = _G.RESET_TO_DEFAULT

-- Require translation
L["BACKGROUND_ALPHA"] = "Background Opacity"
L["BOTTOM"] = "Bottom"
L["CHANGELOG"] = "Changelog"
L["CHANGELOG_FULL"] = "Full"
L["CONFIG_WARNING"] = "I strongly recommend to |cffffd200/reload|r the UI after you're done setting up the addon or even opening this panel to avoid any errors during combat."
L["CONFIRM_RESET"] = "Do you wish to reset \"%s\"?"
L["COPY_FROM"] = "Copy from"
L["DOCK"] = "Tabs & Buttons"
L["DOWNLOADS"] = "Downloads"
L["EDITBOX"] = "Edit Box"
L["FADE_OUT_DELAY"] = "Fade Out Delay"
L["FADING"] = "Fading"
L["FONT"] = "Font"
L["MOUSEOVER_TOOLTIPS"] = "Mouseover Tooltips"
L["OFFSET"] = "Offset"
L["OPEN_CONFIG"] = "Open Config"
L["OUTLINE"] = "Outline"
L["POSITION"] = "Position"
L["SCROLL_BUTTONS"] = "Scroll Buttons"
L["SHADOW"] = "Shadow"
L["SHOW_ON_CLICK"] = "Show On Click"
L["SIZE"] = "Size"
L["SMOOTH_SCROLLING"] = "Smooth Scrolling"
L["SUPPORT"] = "Support"
L["TOP"] = "Top"
L["X_PADDING"] = "Horizontal Padding"
L["Y_PADDING"] = "Vertical Padding"
