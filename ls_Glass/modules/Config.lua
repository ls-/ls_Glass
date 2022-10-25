local Core, Constants = unpack(select(2, ...))
local C = Core:GetModule("Config")

local AceConfig = Core.Libs.AceConfig
local AceConfigDialog = Core.Libs.AceConfigDialog
local AceDBOptions = Core.Libs.AceDBOptions
local LSM = Core.Libs.LSM

local OpenNews = Constants.ACTIONS.OpenNews
local RefreshConfig = Constants.ACTIONS.RefreshConfig
local UnlockMover = Constants.ACTIONS.UnlockMover
local UpdateConfig = Constants.ACTIONS.UpdateConfig

local SAVE_FRAME_POSITION = Constants.EVENTS.SAVE_FRAME_POSITION

local ANCHORS = {
  ["TOPLEFT"] = "Top left",
  ["TOPRIGHT"] = "Top right",
  ["BOTTOMLEFT"] = "Bottom left",
  ["BOTTOMRIGHT"] = "Bottom right"
}
local FLAGS = { [""] = "None", ["OUTLINE"] = "Outline", ["OUTLINE, MONOCHROME"] = "Outline Monochrome" }

function C:OnEnable()
  local options = {
      name = "Glass",
      handler = C,
      type = "group",
      args = {
        general = {
          name = "General",
          type = "group",
          order = 1,
          args = {
            section1 = {
              name = "Info",
              type = "group",
              inline = true,
              order = 2,
              args = {
                version = {
                  name = " |cffffd100Version:|r  "..Core.Version,
                  type = "description",
                  width = "double",
                  fontSize = "medium",
                  order = 2.1,
                },
                whatsNew = {
                  name = "What’s new",
                  type = "execute",
                  func = function()
                    Core:Dispatch(OpenNews())
                  end,
                  order = 2.2,
                },
                slashCmd = {
                  name = "|c00DFBA69/glass|r  |cff808080...............|r  Open config window\n"..
                         "|c00DFBA69/glass lock|r  |cff808080.......|r  Unlock Glass frame\n",
                  type = "description",
                  width = "double",
                  order = 2.3,
                },
                unlockFrame = {
                  name = "Unlock frame",
                  type = "execute",
                  func = function()
                    Core:Dispatch(UnlockMover())
                  end,
                  order = 2.4,
                },
              }
            },
            section2 = {
              name = "Appearance",
              type = "group",
              inline = true,
              order = 3,
              args = {
                font = {
                  name = "Font",
                  desc = "Font to use throughout Glass",
                  type = "select",
                  order = 3.1,
                  dialogControl = "LSM30_Font",
                  values = LSM:HashTable("font"),
                  get = function()
                    return Core.db.profile.font
                  end,
                  set = function(info, input)
                    Core.db.profile.font = input
                    Core:Dispatch(UpdateConfig("font"))
                  end,
                },
                fontFlags = {
                  name = "Font flag",
                  type = "select",
                  order = 3.2,
                  values = FLAGS,
                  get = function ()
                    return Core.db.profile.fontFlags
                  end,
                  set = function (_, input)
                    Core.db.profile.fontFlags = input
                    Core:Dispatch(UpdateConfig("font"))
                  end
                }
              },
            },
            section3 = {
              name = "Frame",
              type = "group",
              inline = true,
              order = 4,
              args = {
                frameWidth = {
                  name = "Width",
                  desc = "Default: "..Core.defaults.profile.frameWidth..
                    "\nMin: 100",
                  type = "range",
                  order = 4.1,
                  min = 100,
                  max = 9999,
                  softMin = 300,
                  softMax = 800,
                  step = 1,
                  get = function ()
                    return Core.db.profile.frameWidth
                  end,
                  set = function (info, input)
                    Core.db.profile.frameWidth = input
                    Core:Dispatch(UpdateConfig("frameWidth"))
                  end
                },
                frameHeight = {
                  name = "Height",
                  desc = "Default: "..Core.defaults.profile.frameHeight,
                  type = "range",
                  order = 4.2,
                  min = 1,
                  max = 9999,
                  softMin = 200,
                  softMax = 800,
                  step = 1,
                  get = function ()
                    return Core.db.profile.frameHeight
                  end,
                  set = function (info, input)
                    Core.db.profile.frameHeight = input
                    Core:Dispatch(UpdateConfig("frameHeight"))
                  end
                },
                frameXOfs = {
                  name = "X offset",
                  desc = "Default: "..Core.defaults.profile.positionAnchor.xOfs,
                  type = "range",
                  order = 4.3,
                  min = -9999,
                  max = 9999,
                  softMin = -2000,
                  softMax = 2000,
                  step = 1,
                  get = function ()
                    return Core.db.profile.positionAnchor.xOfs
                  end,
                  set = function (_, input)
                    Core.db.profile.positionAnchor.xOfs = input
                    Core:Dispatch(UpdateConfig("framePosition"))
                  end
                },
                frameYOfs = {
                  name = "Y offset",
                  desc = "Default: "..Core.defaults.profile.positionAnchor.yOfs,
                  type = "range",
                  order = 4.4,
                  min = -9999,
                  max = 9999,
                  softMin = -2000,
                  softMax = 2000,
                  step = 1,
                  get = function ()
                    return Core.db.profile.positionAnchor.yOfs
                  end,
                  set = function (_, input)
                    Core.db.profile.positionAnchor.yOfs = input
                    Core:Dispatch(UpdateConfig("framePosition"))
                  end
                },
                frameAnchor = {
                  name = "Anchor",
                  desc = "Default: "..Core.db.profile.positionAnchor.point,
                  type = "select",
                  order = 4.5,
                  values = ANCHORS,
                  get = function ()
                    return Core.db.profile.positionAnchor.point
                  end,
                  set = function (_, input)
                    Core.db.profile.positionAnchor.point = input
                    Core:Dispatch(UpdateConfig("framePosition"))
                  end
                },
              }
            }
          }
        },
        editBox = {
          name = "Edit box",
          type = "group",
          order = 2,
          args = {
            section1 = {
              name = "Appearance",
              type = "group",
              inline = true,
              order = 1,
              args = {
                editBoxFontSize = {
                  name = "Font size",
                  desc = "Default: "..Core.defaults.profile.editBoxFontSize.."\nMin: 1\nMax: 100",
                  type = "range",
                  min = 1,
                  max = 100,
                  softMin = 6,
                  softMax = 24,
                  step = 1,
                  get = function ()
                    return Core.db.profile.editBoxFontSize
                  end,
                  set = function (info, input)
                    Core.db.profile.editBoxFontSize = input
                    Core:Dispatch(UpdateConfig("editBoxFontSize"))
                  end,
                  order = 1.1,
                },
                editBoxBackgroundOpacity = {
                  name = "Background opacity",
                  desc = "Default: "..Core.defaults.profile.editBoxBackgroundOpacity,
                  type = "range",
                  order = 1.3,
                  min = 0,
                  max = 1,
                  softMin = 0,
                  softMax = 1,
                  step = 0.01,
                  get = function ()
                    return Core.db.profile.editBoxBackgroundOpacity
                  end,
                  set = function (info, input)
                    Core.db.profile.editBoxBackgroundOpacity = input
                    Core:Dispatch(UpdateConfig("editBoxBackgroundOpacity"))
                  end,
                },
              }
            },
            section2 = {
              name = "Position",
              type = "group",
              inline = true,
              order = 2,
              args = {
                editBoxAnchorPosition = {
                  name = "Position",
                  desc = "Default: "..Core.defaults.profile.editBoxAnchor.position,
                  type = "select",
                  order = 2.1,
                  values = {
                    ABOVE = "Above",
                    BELOW = "Below",
                  },
                  get = function ()
                    return Core.db.profile.editBoxAnchor.position
                  end,
                  set = function (_, input)
                    Core.db.profile.editBoxAnchor.position = input
                    if input == "ABOVE" then
                      Core.db.profile.editBoxAnchor.yOfs = 5
                    else
                      Core.db.profile.editBoxAnchor.yOfs = -5
                    end
                    Core:Dispatch(UpdateConfig("editBoxAnchor"))
                  end
                },
                editBoxAnchorYOfs = {
                  name = "Vertical offset",
                  desc = "Default: 5 or -5",
                  type = "range",
                  order = 2.2,
                  min = -9999,
                  max = 9999,
                  softMin = -10,
                  softMax = 10,
                  step = 1,
                  get = function ()
                    return Core.db.profile.editBoxAnchor.yOfs
                  end,
                  set = function (info, input)
                    Core.db.profile.editBoxAnchor.yOfs = input
                    Core:Dispatch(UpdateConfig("editBoxAnchor"))
                  end
                }
              },
            }
          },
        },
        messages = {
          name = "Messages",
          type = "group",
          order = 3,
          args = {
            section1 = {
              name = "Appearance",
              type = "group",
              inline = true,
              order = 1,
              args = {
                messageFontSize = {
                  name = "Font size",
                  desc = "Default: "..Core.defaults.profile.messageFontSize.."\nMin: 1\nMax: 100",
                  type = "range",
                  min = 1,
                  max = 100,
                  softMin = 6,
                  softMax = 24,
                  step = 1,
                  get = function ()
                    return Core.db.profile.messageFontSize
                  end,
                  set = function (info, input)
                    Core.db.profile.messageFontSize = input
                    Core:Dispatch(UpdateConfig("messageFontSize"))
                  end,
                  order = 1.2,
                },
                chatBackgroundOpacity = {
                  name = "Background opacity",
                  desc = "Default: "..Core.defaults.profile.chatBackgroundOpacity,
                  type = "range",
                  order = 1.3,
                  min = 0,
                  max = 1,
                  softMin = 0,
                  softMax = 1,
                  step = 0.01,
                  get = function ()
                    return Core.db.profile.chatBackgroundOpacity
                  end,
                  set = function (info, input)
                    Core.db.profile.chatBackgroundOpacity = input
                    Core:Dispatch(UpdateConfig("chatBackgroundOpacity"))
                  end,
                },
                messageLeading = {
                  name = "Leading",
                  desc = "Default: "..Core.defaults.profile.messageLeading.."\nMin: 0\nMax: 10",
                  type = "range",
                  min = 0,
                  max = 10,
                  softMin = 0,
                  softMax = 5,
                  step = 1,
                  get = function ()
                    return Core.db.profile.messageLeading
                  end,
                  set = function (info, input)
                    Core.db.profile.messageLeading = input
                    Core:Dispatch(UpdateConfig("messageLeading"))
                  end,
                  order = 1.4,
                },
                messageLinePadding = {
                  name = "Line padding",
                  desc = "Default: "..Core.defaults.profile.messageLinePadding.."\nMin: 0\nMax: 5",
                  type = "range",
                  min = 0,
                  max = 5,
                  softMin = 0,
                  softMax = 1,
                  step = 0.05,
                  get = function ()
                    return Core.db.profile.messageLinePadding
                  end,
                  set = function (info, input)
                    Core.db.profile.messageLinePadding = input
                    Core:Dispatch(UpdateConfig("messageLinePadding"))
                  end,
                  order = 1.5,
                },
              },
            },
            section2 = {
              name = "Animations",
              type = "group",
              inline = true,
              order = 2,
              args = {
                chatHoldTime = {
                  name = "Fade out delay",
                  desc = "Default: "..Core.defaults.profile.chatHoldTime..
                    "\nMin: 1\nMax: 180",
                  type = "range",
                  order = 2.1,
                  min = 1,
                  max = 180,
                  softMin = 1,
                  softMax = 20,
                  step = 1,
                  get = function ()
                    return Core.db.profile.chatHoldTime
                  end,
                  set = function (info, input)
                    Core.db.profile.chatHoldTime = input
                  end,
                },
                chatShowOnMouseOver = {
                  name = "Show on mouse over",
                  desc = "Default: "..tostring(Core.defaults.profile.chatShowOnMouseOver),
                  type = "toggle",
                  order = 2.2,
                  get = function ()
                    return Core.db.profile.chatShowOnMouseOver
                  end,
                  set = function (info, input)
                    Core.db.profile.chatShowOnMouseOver = input
                  end,
                },
                fadeInDuration = {
                  name = "Fade in duration",
                  desc = "Default: "..Core.defaults.profile.chatFadeInDuration..
                    "\nMin: 0\nMax:30",
                  type = "range",
                  order = 2.3,
                  min = 0,
                  max = 30,
                  softMin = 0,
                  softMax = 10,
                  step = 0.05,
                  get = function ()
                    return Core.db.profile.chatFadeInDuration
                  end,
                  set = function (_, input)
                    Core.db.profile.chatFadeInDuration = input
                    Core:Dispatch(UpdateConfig("chatFadeInDuration"))
                  end
                },
                fadeOutDuration = {
                  name = "Fade out duration",
                  desc = "Default: "..Core.defaults.profile.chatFadeOutDuration..
                    "\nMin: 0\nMax:30",
                  type = "range",
                  order = 2.3,
                  min = 0,
                  max = 30,
                  softMin = 0,
                  softMax = 10,
                  step = 0.05,
                  get = function ()
                    return Core.db.profile.chatFadeOutDuration
                  end,
                  set = function (_, input)
                    Core.db.profile.chatFadeOutDuration = input
                    Core:Dispatch(UpdateConfig("chatFadeOutDuration"))
                  end
                },
                slideInDuration = {
                  name = "Slide in duration",
                  desc = "Default: "..Core.defaults.profile.chatSlideInDuration,
                  type = "range",
                  order = 2.4,
                  min = 0,
                  max = 30,
                  softMin = 0,
                  softMax = 5,
                  step = 0.05,
                  get = function ()
                    return Core.db.profile.chatSlideInDuration
                  end,
                  set = function (_, input)
                    Core.db.profile.chatSlideInDuration = input
                  end
                }
              }
            },
            section3 = {
              name = "Misc",
              type = "group",
              inline = true,
              order = 3,
              args = {
                indentWordWrap = {
                  name = "Indent on line wrap",
                  desc = "Adds an indent when a message wraps beyond a single line.",
                  type = "toggle",
                  order = 3.1,
                  get = function ()
                    return Core.db.profile.indentWordWrap
                  end,
                  set = function (info, input)
                    Core.db.profile.indentWordWrap = input
                    Core:Dispatch(UpdateConfig("indentWordWrap"))
                  end,
                },
                mouseOverTooltips = {
                  name = "Mouse over tooltips",
                  desc = "Should tooltips appear when hovering over chat links.",
                  type = "toggle",
                  order = 3.2,
                  get = function ()
                    return Core.db.profile.mouseOverTooltips
                  end,
                  set = function (info, input)
                    Core.db.profile.mouseOverTooltips = input
                  end,
                },
                iconTextureYOffset = {
                  type = "range",
                  name = "Text icons Y offset",
                  desc = "Default: "..Core.defaults.profile.iconTextureYOffset..
                    "\nAdjust this if text icons aren't centered.",
                  order = 3.3,
                  min = 0,
                  max = 12,
                  softMin = 0,
                  softMax = 12,
                  step = 3.1,
                  get = function ()
                    return Core.db.profile.iconTextureYOffset
                  end,
                  set = function (info, input)
                    -- TODO: Update messages dynamically
                    Core.db.profile.iconTextureYOffset = input
                  end,
                },
              }
            },
          },
        },
        profile = AceDBOptions:GetOptionsTable(Core.db)
      }
  }

  AceConfig:RegisterOptionsTable("Glass", options)
  AceConfigDialog:SetDefaultSize("Glass", 780, 500)

  self:RegisterChatCommand("glass", "OnSlashCommand")

  Core.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  Core.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  Core.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  Core:Subscribe(SAVE_FRAME_POSITION, function (position)
    Core.db.profile.positionAnchor = position
  end)
end

function C:OnSlashCommand(input)
  if input == "lock" then
    Core:Dispatch(UnlockMover())
  else
    AceConfigDialog:Open("Glass")
  end
end

function C:RefreshConfig()
  -- General
  Core:Dispatch(UpdateConfig("font"))
  Core:Dispatch(UpdateConfig("frameHeight"))
  Core:Dispatch(UpdateConfig("frameWidth"))
  Core:Dispatch(UpdateConfig("framePosition"))

  -- Edit box
  Core:Dispatch(UpdateConfig("editBoxFontSize"))
  Core:Dispatch(UpdateConfig("editBoxBackgroundOpacity"))
  Core:Dispatch(UpdateConfig("editBoxAnchor"))

  -- Messages
  Core:Dispatch(UpdateConfig("messageFontSize"))
  Core:Dispatch(UpdateConfig("chatBackgroundOpacity"))
  Core:Dispatch(UpdateConfig("chatFadeInDuration"))
  Core:Dispatch(UpdateConfig("chatFadeOutDuration"))

  -- For things that don't update using the config frame e.g. frame position
  Core:Dispatch(RefreshConfig())
end
