# ScrollableMTKView with poor performance

The goal of this project is to integrate `MTKView` with `UIScrollView`.

* On the top the screen is a `UIScrollView` to receive user's gestures.
* Inside the `UIScrollView` is a `UIView` acting as the `contentView` of `UIScrollView`.  
* Then comes an `MTKView` to render on-screen contents. The `size` is just the size of the screen, and the `drawableSize` is always at the device fitting resolution.

However, this project is in poor performance, tested by only 4 triangleStrips.

Now, I set the render mode to: call `draw()` and then render. It could not reach 120 fps on iPad Pro 11, 3rd generation with M1 chip. I also tried using the rendering mode: constant time refresh, which also lagged when you pinch/zoom the scrollView and change the orientation of device.

The main problem happens on CPU: to achieve 120 fps, time per render cycle on CPU should be set less than 8.3s, which is not met in this project.

Probable problems are as follows:
* User's gestures are sampled at a higher rate. If we continously call `draw()`, CPU may calculate extra frames, which is useless. 
* Didn't use double buffer. `Your application created a MTLBuffer object during GPU work.` This is a warning in Xcode Metal capture tool.
* ...

## Background

I want to make a note taking app just like `Notability`, who uses `Metal` framework to render things on the screen.

However, it's not as easy as I thought. Metal is a framework at extremely low level to talk with GPU, in order to achieve the best rednering performance.

I will try `Core Graphics` instead.
