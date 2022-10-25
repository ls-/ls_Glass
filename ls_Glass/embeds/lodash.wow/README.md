# README #

## lodash.wow
lodash inspired library for World of Warcraft Lua

Forked from: https://github.com/danielmgmi/lodash.lua

### Summary ###

A functional programming library for lua in respect to the javascript library lodash.

### How to use the library? ###

Add this library to your .pkgmeta file:

```lua
-- .pkgmeta
externals:
  libs/lodash.wow:
    url: git://github.com/mixxorz/lodash.wow
```

Load it in via `LibStub`:

```lua
local lodash = LibStub("lodash.wow")
local print, map = lodash.print, lodash.map
```

Then use it:

```lua

print(map({1, 2, 3, 4, 5}, function(n)
  return n * 2
end))
```

- Follow the [API documentation](https://moghimi.org/lodash.lua/) for the complete list.
