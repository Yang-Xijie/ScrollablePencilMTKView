# URGENT

- 刚刚打开app使用的内存是60MB 但是一打开Control Center再放回去就变成120MB了
    - control+center+effect+metal+performance
    - loadView里面到底什么东西增多了？引用没释放？RenderView还是用的原来的？感觉像是重新addSubView了
    - 如何让View重新加载
    - [Fix for Control Center lag on iOS 9](https://forums.macrumors.com/threads/fix-for-control-center-lag-on-ios-9-2-1-and-possibly-9-2.1946042/) 
    - https://developer.apple.com/documentation/metal/performance_tuning/using_metal_system_trace_in_instruments_to_profile_your_app

I encountered the same issue when using Metal framework (Xcode 13.3) to render a scrollable view on iPad Pro 11 with M1 chip (iPadOS 15.4).

MTKView works well with 120fps when I open the app and interact with it. However, opening the control center (or the notification center) and then closing it, the frame rate often drops to 80Hz.

the demo project - https://github.com/Yang-Xijie/ScrollablePencilMTKView

Does anyone has some great solutions?

Stoping the MTKView by setting `isPaused` in `SceneDelegate` might be one workaround (Genshin Impact uses this).

```swift
func sceneWillResignActive(_ scene: UIScene) {
    mainVC.documentVC?.renderView.isPaused = true
}

func sceneDidBecomeActive(_ scene: UIScene) {
    mainVC.documentVC?.renderView.isPaused = false
}
```

Or some tricky method that never stops rendering? Notability will still render its pages when user interacts with control center. I do wonder how this is achieved...

