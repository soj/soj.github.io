---
date: 2026-06-23 14:50
description: Another short story about developer's life
tags: разное
---
# Blessing in disguise

Here's another developer story that shows how, sometimes, luck can play a big part in solving problems. In one of our apps, 95 percent of users didn't experience any crashes. However, we knew that a 3rd party library in the app was causing crashes for the remaining 5 percent. The big problem was that our QA team never saw these crashes and couldn't reproduce them. We had no idea when and under what conditions the app was crashing. This mystery went on for a year, maybe even longer.

But then, something strange happened. My internet provider had some issues right when I was testing our app. Suddenly, the app started to crash over and over. As a developer, this was like striking gold because I could finally see the crashes happening.

![funny image about 3-rd party code](/images/blessing-image-1.png)

Once I learned that lousy internet was likely causing the crashes, the next step was learning how to make it happen again. Luckily, iOS has a tool called Network Link Conditioner (Settings -> Developer) that I could use. I started to try different settings to make the network on my phone worse, hoping to find out what was causing the app to crash. When I set High Latency DNS, the app began to crash 80 percent of the time.

![funny image about 3-rd party code](/images/blessing-image-2.png)

From my other post here, you might remember that it's essential for companies that develop libraries or frameworks to reproduce problems on their sample apps. So, I tried the High Latency DNS setting on their demo app, and just like with our app, everything started crashing.

After that, I quickly contacted their support team. I explained everything and showed them how to reproduce the problem. It took them a while, but they finally confirmed the issue and released an update to fix the error.