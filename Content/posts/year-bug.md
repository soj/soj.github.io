---
date: 2026-06-23 14:36
description: A short story about developer's life
tags: разное
---

# One year to fix a bug

This is a story about a bug that took a year to fix.

With this story, I am beginning a series of short stories about a developer's daily work - the challenges we face and how we overcome them. Today's story is about a bug that lasted for a year.

![funny image about 3-rd party code](/images/year-bug-image.jpg)

Once, I was working on a project where users could download videos to their phones for offline viewing. To achieve this, we used a proprietary third-party library provided by the content providers. As a developer, I had access to sample applications and documentation for this library. I implemented everything they asked for in our application.

During testing, I noticed a line in the Xcode console that appeared occasionally, indicating that the application failed to perform some action and would be killed. I soon realized that if I started downloading a video and then put the application to sleep when the download finished, the system would kill my application. Starting the app from the beginning upon tapping the icon again is not the user experience we aimed for.

In this case, I didn't have to search too long for the problem. It quickly became clear that the library started a background process for video downloads. When all the downloads are finished, the system wakes up the application and provides a completion handler to return when the app finishes processing the completed downloads. In our case, the system sent us this handler, but we didn't return it to the system or execute it, so the system warned us that it would kill the app in 30 seconds and then killed it.

You can find more about that here in the [documentation](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background?language=objc).

In short, we should save this completion handler first:

```swift
func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
}
```

and then execute it on the main thread when another event comes

```swift
func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let backgroundCompletionHandler =
            appDelegate.backgroundCompletionHandler else {
                return
        }
        backgroundCompletionHandler()
    }
}
```

With "proper" libraries, the mechanism for handling this is to pass the completion handler to our module responsible for the downloads. For example, I would check something in the app when urlSessionDidFinishEvents arrived, update the UI, and then, if everything was fine, execute the handler. The company did not provide this option in our case, but we wanted to release the app anyway. I didn't want our users to restart the application after every downloaded video constantly. Understandably, I turned to support for help.

An important point when working with any 3rd party library support is that they will only talk to you if you provide them with a working application, preferably their sample app, which will reproduce the error. Simply saying that something isn't working is usually not enough. I created an application that reproduced this error, and I was lucky. A guy from the support team quickly confirmed that the process ID (application) changed after downloading the video. He formalized all the formalities to send this bug to the developers.

But what was I supposed to do? After all, I had to release the application. So I had no choice but to wait 2 seconds and return this handler to the system. Since a 3rd party library is often a black box, I couldn't know how long it would take the library to complete its tasks when all downloads are complete. But there were no visible problems, and we released the application.

Nine months later, I received an email - "the bug you reported will soon be fixed"! And three months after, I received another email announcing a new version of their SDK with the bug you reported fixed.

Here are the conclusions I drew from this experience:
- Always consult the documentation and application samples if you work with 3rd party libraries.
- Support teams often require an application similar to their own to troubleshoot issues faster.