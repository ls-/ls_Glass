local _G = _G

local AceAddon = _G.LibStub("AceAddon-3.0")

local AddonName, AddonVars = ...
local Core = AceAddon:NewAddon(AddonName)
local Constants = {}
local Utils = {}
AddonVars[1] = Core
AddonVars[2] = Constants
AddonVars[3] = Utils
_G[AddonName] = Core

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
Core.Components = {}
Core.Version = "@project-version@"
--@debug@--
Core.Version = "DEBUG"
--@end-debug@--

-- Modules
Core:NewModule("Config", "AceConsole-3.0")
Core:NewModule("Fonts")
Core:NewModule("Hyperlinks")
Core:NewModule("News")
Core:NewModule("TextProcessing")
Core:NewModule("UIManager", "AceHook-3.0")

-- Default settings
Core.defaults = {
  profile = {
    -- General
    font = "Friz Quadrata TT",
    fontFlags = "",
    frameWidth = 450,
    frameHeight = 230,
    positionAnchor = {
      point = "BOTTOMLEFT",
      xOfs = 20,
      yOfs = 230
    },

    -- Edit box
    editBoxFontSize = 12,
    editBoxBackgroundOpacity = 0.6,
    editBoxAnchor = {
      position = "BELOW",
      yOfs = -5
    },

    -- Messages
    messageFontSize = 12,
    chatBackgroundOpacity = 0.4,
    messageLeading = 3,
    messageLinePadding = 0.25,

    chatHoldTime = 10,
    chatShowOnMouseOver = true,
    chatFadeInDuration = 0.6,
    chatFadeOutDuration = 0.6,
    chatSlideInDuration = 0.3,

    indentWordWrap = true,
    mouseOverTooltips = true,
    iconTextureYOffset = 4,
  }
}

function Core:OnInitialize()
  self.listeners = {}

  self.db = self.Libs.AceDB:New("GlassDB", self.defaults, true)
  self.printBuffer = {}
end

function Core:OnEnable()
  -- Buffer print messages until ViragDevTool loads
  for _, item in ipairs(self.printBuffer) do
    Utils.print(unpack(item))
  end
  self.printBuffer = {}
end

function Core:Subscribe(messageType, listener)
  if self.listeners[messageType] == nil then
    self.listeners[messageType] = {}
  end

  local listeners = self.listeners[messageType]
  local index = #listeners + 1
  listeners[index] = listener

  return function ()
    self.Libs.lodash.remove(listeners, function (val) return val == listener end)
  end
end

function Core:Dispatch(messageType, payload)
  --@debug@--
  Utils.print('E: '..messageType, payload)
  --@end-debug@--

  local listeners = self.listeners[messageType] or {}
  for _, listener in ipairs(listeners) do
    listener(payload)
  end
end
