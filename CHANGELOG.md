# CHANGELOG

## Version 110105.02

- Fixed an issue where old chat messages would still disappear even though message fading is disabled.

## Version 110105.01

- Added 11.1.5 support.
- Added an option to make the chat input show multiple lines of text. Can be found at / LSG > Edit Box > Multiline,
  disabled by default.
- Fixed an issue where clicking the "[Show Message]" link to reveal a censored message would do nothing.

## Version 110100.01

- Added 11.1.0 support.
- Added an option to position buttons (social, menu, etc) to the left or to the right of the main chat frame. Can be
  found at /LSG > Tabs & Buttons > Position, set to "Right" by default.
- Added an option to disabled quick join toasts. Can be found at /LSG > Tabs & Buttons > Quick Join Toasts, enabled by
  default.
- Added support for "Chat Page Up", "Chat Page Down", and "Chat Bottom" keybinds. 

### Known Issues

- Chat messages may behave a bit weird at times, for instance, they might blink while scrolling. Blizz changed something
  in the backend (not Lua code, so it's not available to addon devs) because the same code works without issues in
  11.0.7. Now I need to figure out how to work around it.

## Version 110000.03

- Fixed an issue where the tabs and buttons wouldn't fade when the main/general tab wasn't selected.

## Version 110000.02

- Improved compatibility with ElvUI. Now the addon will stop loading if it detects that ElvUI chat is enabled, and
  you'll be greeted by the addon incompatibility popup from ElvUI. Just to make things clear, it's safe to use LS: Glass
  with ElvUI, you just want to disable its chat module because both addons will try to modify chat in rather extensive
  ways which nowadays may result in game freezes.
- Fixed an issue where the addon would struggle to scroll through messages that are taller than the chat frame itself.
- Fixed an issue where the "Copy from" menu in the chat settings would fail to fetch the list of other chat windows.
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.

## Version 110000.01

- Added 11.0.0 support.
- Rewrote the addon. Only font-related settings will be carried over.
- Added smooth scrolling through the chat history. Most fading and sliding options are gone because the new system
  relies on rather tight timings.
- Added proper "Social" button handling.
- Replaced the fade in on mouseover option with show on click. It's causing way too many false positives, too much
  headache.
- Most chat options are now tab-specific.

## Version 100206.02

- Fixed an issue where vertical padding wouldn't apply correctly.

## Version 100206.01

- Added 10.2.6 support.
- Fixed an issue where the chat frame would disappear after it's previously hidden.
- Fixed an issue where some messages would appear truncated.
- Fixed an issue where some characters would appear as squares. The addon now properly mimics the default chat's
  behaviour which also includes all the bugs that come with it. For instance, depending on the alphabet those characters
  belong to, those messages will completely ignore various chat settings like font size, outline, etc. It is this way 
  due to limitation on Blizz end.
- Set minimal Y padding to 0. Yes, no more gaps in the TomCats' messages :>

## Version 100105.01

- Added 10.1.5 support.

### Known Issues

I'm still in the process of rewriting the addon, so for the time being I'm not fixing any bugs. It takes time because
real life keeps getting in the way.

## Version 100100.02

- Fixed an issue where due to some other addon interference temporary tabs, for instance, whisper tabs would get broken.

### Known Issues

I'm aware of the fact that sliding in, when set to below 0.05s, got broken in 10.1. However, I'm currently rewriting the
addon to add smooth scrolling, and it includes rewriting the new message sliding part. That's why I won't be fixing
that bug for the time being.

Here's a preview of smooth scrolling. A bit rough since it's WIP.

![Imgur](https://i.imgur.com/vNNBczC.gif)

## Version 100100.01

- Added 10.1.0 support.

## Version 100005.01

- Added 10.0.5 support.
- Added optional buttons for scrolling up and down. It's an accessibility feature meant for users
  who can't use the mouse wheel. Holding the Ctrl key will slow the scrolling rate by two times.
- Added an option to fade in chat messages on mouseover.

## Version 100002.01

- Added 10.0.2 support.
- Increased the max fade out delay to 120s.
- Changed the initial anchor of the edit box. It now can be positioned inside the chat frame.
- Fixed an issue where profession links would open a profession window on mouse over. Thanks
  truckcarr11@GitHub.
- Updated French translation. Translated by Braincell1980@Curse.
- Updated German translation. Translated by OHerendirO@Curse.
- Updated Korean translation. Translated by netaras@Curse.
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.

## Version 100000.05

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

## Version 100000.04

- Added support for the pet battle log.
- Fixed an issue where custom fonts wouldn't apply on load. 
- Added Korean translation. Translated by netaras@Curse.
- Added Portuguese translation. Translated by Azeveco@Curse.
- Added Traditional Chinese translation. Translated by RainbowUI@Curse.
- Updated French translation. Translated by Braincell1980@Curse.
- Updated German translation. Translated by Solence1@Curse.

### Known Issues

- There's a bug where the chat frame sometimes stops updating properly after scrolling down with
  the mouse wheel. It's a tricky one to fix, I'm still investigating it. But to resume the update
  process you need to scroll up until you see the "Jump to Present"/"Unread Messages" button and
  then click it.

## Version 100000.03

- Fixed more issues related to fasting forward. Those pesky line#340 errors.
- Added German translation. Translated by terijaki@GitHub.

## Version 100000.02

- Added horizontal and vertical padding options for messages.
- Fixed an issue where messages' background gradient wouldn't resize properly.
- Fixed an issue where fasting forward would break the message display.
- Reduced the minimal possible chat frame size to 176x64, making it smaller will break stuff.
  The max is uncapped.
- Added French translation. Translated by Braincell1980@Curse.

## Version 100000.01

- The initial release.
