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
  local listeners = self.listeners[messageType] or {}
  for _, listener in ipairs(listeners) do
    listener(payload)
  end
end
