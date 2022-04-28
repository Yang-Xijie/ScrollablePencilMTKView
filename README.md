# ScrollableMTKView

The goal of this project is to integrate `MTKView` with `UIScrollView`.

* On the top the screen is a `UIScrollView` to receive user's gestures.
* Inside the `UIScrollView` is a `UIView` acting as the `contentView` of `UIScrollView`.  
* Then comes an `MTKView` to render on-screen contents. The `size` is just the size of the screen, and the `drawableSize` is always at the device fitting resolution.

## Background

I want to make a note taking app just like `Notability`, who uses `Metal` framework to render things on the screen.

However, it's not as easy as I thought. Metal is a framework at extremely low level to talk with GPU, in order to achieve the best rednering performance.

## References

[GitHub | codelynx/Metal2DScrollable: Demonstrate how to zoom and scroll MTKView using UIScrollView](https://github.com/codelynx/Metal2DScrollable)
