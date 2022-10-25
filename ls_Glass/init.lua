local addonName, ns = ...
local E, C, D, L = ns.E, ns.C, ns.D, ns.L

local _G = _G

local Core = _G[addonName]

function Core:OnInitialize()
  self.listeners = {}

  self.db = self.Libs.AceDB:New("LS_GLASS_GLOBAL_CONFIG", D, true)
  C.db = self.db


end

function Core:OnEnable()
end
