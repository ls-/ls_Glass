# CHANGELOG

## Version 100206.01

- Added 10.2.6 support.

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
