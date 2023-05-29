local _, ns = ...
local E = ns.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
## Version 100100.02

- Fixed an issue where due to some other addon interference temporary tabs, for instance, whisper tabs would get broken.

### Known Issues

I'm aware of the fact that sliding in, when set to below 0.05s, got broken in 10.1. However, I'm currently rewriting the
addon to add smooth scrolling, and it includes rewriting the new message sliding part. That's why I won't be fixing
that bug for the time being.
]]
