local addonName, ns = ...
local C, L = ns.C, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
local E = {}
ns.E = E

-- TODO: Remove Me!
local AceAddon = _G.LibStub("AceAddon-3.0")

local Core = AceAddon:NewAddon(addonName)
_G[addonName] = Core

-- Core
Core.Libs = {
	AceConfig = _G.LibStub("AceConfig-3.0"),
	AceConfigDialog = _G.LibStub("AceConfigDialog-3.0"),
	AceDB = _G.LibStub("AceDB-3.0"),
	AceDBOptions = _G.LibStub("AceDBOptions-3.0"),
	AceGUI = _G.LibStub("AceGUI-3.0"),
	AceHook = _G.LibStub("AceHook-3.0"),
	LSM = _G.LibStub("LibSharedMedia-3.0"),
	LibEasing = _G.LibStub("LibEasing-1.0"),
	lodash = _G.LibStub("lodash.wow")
}

local Constants = {}
ns[1] = Core
ns[2] = Constants

Core.Components = {}
Core.Version = tonumber(GetAddOnMetadata(addonName, "Version"):gsub("%D", ""), nil)

-- Modules
Core:NewModule("Config", "AceConsole-3.0")
Core:NewModule("Fonts")
Core:NewModule("Hyperlinks")
Core:NewModule("News")
Core:NewModule("TextProcessing")
Core:NewModule("UIManager", "AceHook-3.0")

-- TODO: Remove Me!
-- Utility functions
function E.super(obj)
	return getmetatable(obj).__index
end

-- TODO: Remove Me!
-- Prints Glass' notification messages
function E.notify(message)
	print("|c00DFBA69Glass|r: ", message)
end
