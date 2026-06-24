---
date: 2026-06-24 12:11
description: My AVPlayer Video Optimization practice
tags: avplayer, avkit, video
---
# AVPlayer Video Optimization (part 1)

I'm often asked whether it's possible to place an AVPlayer or AVPlayerViewController within a table cell or a collection view cell. The answer is yes, it's doable. And I'm planning to write a few articles on this topic. But today, we'll start in an unusual way - with optimization. I'll introduce you to some properties of AVPlayerItem that will assist us in this endeavor.

Imagine scrolling through Instagram and encountering video posts. On Instagram, they begin playing as soon as they appear on screen. We aim to achieve this same effect, so the user doesn't witness a loading animation. However, Meta, much like YouTube, doesn't use AVPlayer for this; they have their custom players. Considering that we, as developers, cannot always afford to create our own players, let's focus on utilizing the existing functionality of Apple's AVPlayer.

Let's say we have a table cell that contains an AVPlayer. Most likely, we'll pass the video URL to the player in the `cellForRow` method. Even if our player is paused, we can observe that the player begins preloading the video. We want the video to start playing as soon as it appears on screen. However, if there are multiple videos on the screen, we want only one to play, while the others remain paused without downloading anything. To achieve this, we will use two properties of the AVPlayerItem class:

```swift
let playerItem = AVPlayerItem(url: our_Url_Here)
playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false
playerItem.preferredForwardBufferDuration = TimeInterval(1)
let player = AVPlayer(playerItem: playerItem)
```

The preferredForwardBufferDuration property determines how much buffer, in seconds of video, we want to have. I've noticed that on a stable network, 1 second is often enough for the video to start playing immediately upon appearing on the screen and to catch the user's interest. But it all depends on your context, so experiment. If the value is too small, the user may see a loading animation; if it's too large, it could impact your app's resources. Setting it to 0 allows the player to manage the buffer automatically.

Let's run this code in Xcode and open a Debug Navigator (Cmd-7)

```swift
guard let url = URL(string: "https://some-url-here.com») else { return }
let playerItem = AVPlayerItem(url: url)
let player = AVPlayer(playerItem: playerItem)
avPlayerViewController.player = player
```

![after code changes](/images/avplayer-opt-image-1.png)

And let's do it again after we added

```swift
playerItem.preferredForwardBufferDuration = TimeInterval(1)
```

![after code changes](/images/avplayer-opt-image-2.png)

As you can see, we reduced the network load from 37.8 to 0.2Mb just by setting the `preferredForwardBufferDuration` to a 1-second value.

The second property, canUseNetworkResourcesForLiveStreamingWhilePaused, as you might infer from its name, controls the use of network resources when the player is paused. The documentation and name mention live streaming, but I've found that it sometimes works for VOD streams as well. Just test it with your video resources in your app. For more details, you can read here: [AVPlayerItem canUseNetworkResourcesForLiveStreamingWhilePaused](https://developer.apple.com/documentation/avfoundation/avplayeritem/1388752-canusenetworkresourcesforlivestr).

There's another property of AVPlayerItem, preferredPeakBitRate, which I've never used in my projects. You might use it to optimize resource usage in your app. For example, lower the bitrate while the cell is offscreen, and set it to 0 when visible, thereby allowing the player to choose the bitrate itself.

In fact, there are even stricter properties that allow for tighter control over bitrate on "expensive" networks, such as when a user is on cellular data. You can read about this here: [preferredPeakBitRateForExpensiveNetwork](https://developer.apple.com/documentation/avfoundation/avplayeritem/3746589-preferredpeakbitrateforexpensive). However, a search on Google for open projects on GitHub yielded no projects that seem to be using this in the real world.