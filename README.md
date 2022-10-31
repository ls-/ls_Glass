# Disclaimer

This fork is largely for my own personal use and experiments. I'm still not sure about taking the addon over because it'll require a pretty substantial rewrite to make it not break anything in the default UI. If someone else takes it over in the meantime, no biggie 😁

## An update from 28/10/2022

Right now it's basically impossible to handle clicking any chat links (player names, item links, etc) via `SetItemRef` in an addon that replaces the default chat output (like this one) and doesn't just customise/reskin it (like Prat). If you call it, you won't be able to close chat tabs while in combat, the default layout editor will go haywire, etc. It's not something I can ignore because it's the most basic and fundamental chat feature. This project is def put on the backburner. 


![Imgur](https://i.imgur.com/D6vpWG6.png)

## An update from 31/10/2022

I found a workaround for the issue mentioned above. There's one handy XML-only attribute called `propagateHyperlinksToParent` that can be chained. As long as a chat message has `ChatFrame#` in its parent hierarchy and all the frames in between use the following template

```xml
<Frame name="YourHyperlinkPropagator" propagateHyperlinksToParent="true" virtual="true"/>
```

hyperlinks from that chat message will reach `ChatFrame#` and it'll handle them via `SetItemRef` without tainting anything.

---

![Glass](https://user-images.githubusercontent.com/3102758/90884068-9549a600-e3e1-11ea-944f-481bd894560e.png)

#### An immersive and minimalistic chat UI for World of Warcraft

[![Demo](https://thumbs.gfycat.com/SkinnyPopularIsabellineshrike-size_restricted.gif)](https://gfycat.com/skinnypopularisabellineshrike)

(Click for slightly higher resolution)

## License

MIT License

Copyright (c) 2022 Val Voronov  
Copyright (c) 2020 Mitchel Cabuloy
