# ExNotes

## Target

Make an iPadOS app which has the similar experience as using Notability.

**Core Functions**:
* Write Chinese characters by Apple Pencil.
* Use Metal framework to render with low latency.
* Continuous vertical scrolling.
* PDF export.
* PDF import and make annotations.

## References

### Metal tutorials

* <https://donaldpinckney.com/metal/2018/07/05/metal-intro-1.html#what-is-metal-and-why-use-it>
    * This blog clearly teach you to use Metal to draw a triangle on you screen step by step. really recommended
* <https://www.raywenderlich.com/7475-metal-tutorial-getting-started>
    * simple but enough

* WWDC
    * [WWDC14 | Working with Metal: Overview](https://developer.apple.com/wwdc14/603)
    * [WWDC14 | Working with Metal: Fundamentals](https://developer.apple.com/wwdc14/604)
    * [WWDC14 | Working with Metal: Advanced](https://developer.apple.com/wwdc14/605)

### How Apple Pencil works?

* <https://stackoverflow.com/questions/42889699/smooth-drawing-with-apple-pencil>
    * use vector
* [WWDC19 | Introducing PencilKit](https://developer.apple.com/wwdc19/221)
    * The first xx minutes shows that you should using Metal and series of techs to lower the latency. It tells you how to exert full ability of Apple Pencil.
* <https://developer.apple.com/documentation/uikit/pencil_interactions>
    * Get data collected from sensors in Apple Pencil.
    
### Vector

* https://stackoverflow.com/a/42891040/14298786
    * use vectors
    * [Wiki | Ramer–Douglas–Peucker algorithm](https://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm)
    * <http://blog.ivank.net/interpolation-with-cubic-splines.html>
* [Adobe | What is vector art](https://www.adobe.com/creativecloud/illustration/discover/vector-art.html)
* https://developer.apple.com/documentation/uikit/uibezierpath
* https://en.wikipedia.org/wiki/Bézier_curve
* how computers draw cubic Bézier curves https://www.dev-metal.com/bezier-curves-hood-4min-video/
* GitHub <https://github.com/OwenCalvin/hand-drawing-swift-metal>
    * check <https://github.com/eldade/ios_metal_bezier_renderer>
* Rasterization in Metal https://www.reddit.com/r/GraphicsProgramming/comments/l412jf/rasterization_in_metal/ 
* UIBezierPath https://developer.apple.com/documentation/uikit/uibezierpath
* to render a model or make something smooth: https://www.reddit.com/r/GraphicsProgramming/comments/l412jf/rasterization_in_metal/
    * just split the shape into several triangles

**Raymarch**
Maybe you could raymarch a surface in a pixel shader. You could render a bounding geometry using triangles just to limit the number of pixels running the shader. That's done somewhat often for 2D curves, but I've not seen it done for 3D curved surfaces besides https://blog.demofox.org/2016/12/16/analyticsurfacesvolumesgpu/

SDF
https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
https://www.labri.fr/perso/nrougier/python-opengl/#distance-based-anti-aliasing


### GitHub

Search for `pencil metal`:
* <https://github.com/rydermackay/MetalPaint>
