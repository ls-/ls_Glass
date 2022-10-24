local Core, Constants = unpack(select(2, ...))
local News = Core:GetModule("News")

local AceGUI = Core.Libs.AceGUI

local OPEN_NEWS = Constants.EVENTS.OPEN_NEWS

-- luacheck: push ignore 631
local CHANGELOG = {
  {
    name = "1.8.0 (2020-10-14)",
    items = {[[
What's new

- New: Updated for Shadowlands!
    ]]}
  },
  {
    name = "1.7.0 (2020-09-29)",
    items = {[[
What's new

- New: Glass now indents lines that wrap past the first line. Super helpful for visually distinguishing lines that belong to a single message. Note: If you don't like this new behavior, you can turn it off in the settings.
    ]]}
  },
  {
    name = "1.6.0 (2020-09-23)",
    items = {[[
What's new

- New: Glass now supports Prat's History module! As long as it's enabled, Glass now restores your chat message history.

Bug fixes

- Fixed: There was an issue where messages that were received before Glass initialized were lost (e.g. Guild Message of the Day). This has now been fixed.
    ]]}
  },
  {
    name = "1.5.0 (2020-09-14)",
    items = {[[
What's new

- New: You can now stick the edit box to the top of the chat window! Very useful if you like chat flush to a bottom corner.
- New: You no longer need a 16,000 DPI gaming mouse to move Glass to the perfect spot. Now you can use sliders for window positioning.
- New: More control over the font, including leading, line padding, and outline.
- New: New options for controlling animations. Now you can adjust how fast messages fade in, fade out, and slide in. You can even set these to zero to disable animations completely if that's not your cup of tea.
- New: This thing! Glass is getting constant updates with new features and fixes added almost weekly. We thought it would be a good idea to write up changes and new stuff between each release. Watch this space!

Bug fixes

- Fixed: Sometimes messages do not appear. This now happens... even less often!
    ]]}
  },
  {
    name = "1.4.2 (2020-09-09)",
    items = {[[
Bug fixes

- Fixed: Icons in chat messages used to stutter as new messages come in. They now slide smoothly up along with the text. So smooth.
- Fixed: Sometimes messages do not appear. This now happens... less often!
- Fixed: Scrolling used to break just after resizing the chat window. This should no longer happen.
    ]]}
  },
  {
    name = "1.4.1 (2020-09-08)",
    items = {[[
Bug fixes

- Fixed: There was an issue with how Glass saved the window position that was causing AceDB to throw a fit. This issue has been resolved.
    ]]}
  },
  {
    name = "1.4.0 (2020-09-07)",
    items = {[[
What's new

- New: World of Waracraft Classic is now officially supported!
    ]]}
  },
  {
    name = "1.3.0 (2020-09-06)",
    items = {[[
What's new

- New: Glass now supports Prat 3.0 URL links! This will now allow you click URL links in chat as long as you have Prat's UrlCopy module enabled.
- New: Much better scrolling experience. The chat no longer snaps to the bottom when a new message arrives while you're scrolling through history. In addition, we've added a little arrow you can click to go back to your most recent messages. It even tells you when you have unread messages!

Bug fixes

- Fixed: Players have been experiencing issues with the edit box being visible even if it's not focused. This is caused by the chat style setting being set to "IM style". From now on, Glass will automatically set the chat style to "Classic" so that you don't have to do it yourself.
    ]]}
  },
  {
    name = "1.2.1 (2020-09-01)",
    items = {[[
Bug fixes

- Fixed: There was a conflict with the ElvUI mover and Glass. This has been fixed.
    ]]}
  },
  {
    name = "1.2.0 (2020-08-31)",
    items = {[[
What's new

- New: Glass now supports the "New tab" whisper mode! Other "temporary" chat windows are also now supported, including the Pet Battle tab.
- New: Major architecture changes for Glass. You won't see any changes while using the addon, but rest well in knowing that we've given the engine a massive tune up.
    ]]}
  },
  {
    name = "1.1.1 (2020-08-26)",
    items = {[[
Bug fixes:

- Fixed: You will find that animations are now 99% less jittery!
- Fixed: Some players were experiencing issues when using Glass with other addons. These issues have been addressed and should no longer happen.
    ]]}
  },
  {
    name = "1.1.0 (2020-08-24)",
    items = {[[
What's new

- New: Players have been having a hard time figuring out how to move Glass around. So we've added a new "Unlock Window" option when right-clicking the "General" tab. This is how the default chat UI unlocked its windows so hopefully this will be more obvious.
- New: Glass now supports Prat Timestamps! If you're using Prat, you should find that timestamps are now displayed.
    ]]}
  },
  {
    name = "1.0.1 (2020-08-22)",
    items = {[[
Bug fixes

- Fixed: The Battle.net toast used to be out of place. We've given it a nudge and it should now be where it belongs.
- Fixed: Previously, some text icons become "squished". We've removed the Squisher Module so you should now see icons in their full, unsquished glory.
    ]]}
  },
  {
    name = "1.0.0 (2020-08-22)",
    items = {[[
What's new

- New: Glass exists!
    ]]}
  }
}
-- luacheck: pop

-- Module
function News:OnEnable()
  local baseSize = 13

  local frame = AceGUI:Create("Frame")
  frame:SetTitle("Glass: Version history")
  frame:SetWidth(600)
  frame:SetHeight(400)
  frame:SetStatusText("Version: "..Core.Version)
  frame:SetCallback("OnClose", function(widget) frame:Hide() end)
  frame:SetLayout("Fill")
  frame:Hide()

  local scrollFrame = AceGUI:Create("ScrollFrame")
  scrollFrame:SetLayout("List")
  frame:AddChild(scrollFrame)

  for _, release in ipairs(CHANGELOG) do
    local releaseLabel = AceGUI:Create("Label")
    releaseLabel:SetFont('Fonts\\FRIZQT__.TTF', baseSize, '');
    releaseLabel:SetRelativeWidth(1)
    releaseLabel:SetText("|c00DFBA69"..release.name.."|r")
    scrollFrame:AddChild(releaseLabel)

    for i, item in ipairs(release.items) do
      local itemLabel = AceGUI:Create("Label")
      itemLabel:SetFont('Fonts\\FRIZQT__.TTF', baseSize, '');
      itemLabel:SetRelativeWidth(1)
      itemLabel.label:SetSpacing(3.2)
      itemLabel.label:SetAlpha(0.95)

      local prefix, suffix = "", ""

      if i == 1 then
        prefix = "\n"
      end

      if i == #release.items then
        suffix = "\n"
      end

      itemLabel:SetText(prefix..item..suffix)
      scrollFrame:AddChild(itemLabel)
    end
  end

  Core:Subscribe(OPEN_NEWS, function ()
    frame:Show()
  end)
end
