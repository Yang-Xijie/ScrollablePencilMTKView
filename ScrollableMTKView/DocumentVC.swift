import MetalKit
import UIKit
import XCLog

class DocumentVC: UIViewController {
    /// the opened document
    var document: ExNoteDocument!

    /// scrollView is the front layer to receive user's actions
    var scrollView: UIScrollView!
    /// fullDocumentView is the contentView of the scrollView, which show the document thumbnail page by page
    ///
    /// The height of MTKView should be no more than 2^14. So use MTKView to show the full document is not a feasible choice.
    var fullDocumentView: UIView!

    /// renderView renders the on-screen document
    ///
    /// the drawableSize is the `UIScreen.main.nativeScale * renderView.on-screen-size`
    var renderView: MTKView!
    /// draw on-screen triangleStrips in renderView
    var renderViewDelegate: RenderViewDelegate!

    override func loadView() {
        // FIXME: 看看是不是添加了多次subView？？
        XCLog(.trace)

        // MARK: document

        document = test_document

        // MARK: view

        view = {
            let v = UIView()
            v.backgroundColor = .white
            return v
        }()

        // MARK: scrollView

        scrollView = {
            let sv = UIScrollView()

            sv.backgroundColor = .systemYellow // the blank when scroll to edges; cannot see it if `scrollView.zoomScale > 1`

            sv.contentInsetAdjustmentBehavior = .never // QUESTION: let mktView inset the bottom safe area

            sv.isScrollEnabled = true // default: true
            sv.isUserInteractionEnabled = true // default: true

            sv.bounces = false // turn off bounce animation (margins)

            sv.maximumZoomScale = 5.0
            sv.minimumZoomScale = 1.0 // no support for `zoomScale` smaller than 1.0
            sv.bouncesZoom = false // turn off bounce animation (zoom)

            sv.delegate = self // zoom and scroll
            return sv
        }()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])

        // MARK: - scrollContentView

        fullDocumentView = { // TODO: 添加缩略图？
            let scv = UIView()
            scv.backgroundColor = .orange
            return scv
        }()
        scrollView.addSubview(fullDocumentView)

        // MARK: - renderView

        prepareRenderData()

        renderView = {
            let rv = MTKView()

            // MARK: device

            guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
                XCLog(.fatal, "Metal is not supported on this device")
                fatalError()
            }
            rv.device = defaultDevice

            // MARK: render method

            rv.preferredFramesPerSecond = 120
            rv.isPaused = false // No need for `rv.preferredFramesPerSecond = 120`. It will be automatically decided by device.
            rv.enableSetNeedsDisplay = false // when Apple Pencil or finger strokes, call `draw()` to render a drawable
            rv.autoResizeDrawable = false // set `renderView.drawableSize` by ourselves
            rv.presentsWithTransaction = false

            // MARK: delegate

            guard let tempRenderer = RenderViewDelegate(renderView: rv,
                                                        document: document,
                                                        scrollView: scrollView) else {
                XCLog(.fatal, "Renderer failed to initialize")
                fatalError()
            }
            renderViewDelegate = tempRenderer // neccessary
            rv.delegate = renderViewDelegate

            return rv
        }()
        // not `view.addSubView()` because the scrollView should be on the top to recieve user's gesture
        // notice: renderView.frame is relative to scrollContentView
        fullDocumentView.addSubview(renderView)
    }

    override func viewDidLayoutSubviews() {
        renderView.isPaused = true
        XCLog(.trace)
//        printDebugInfo()
        let doc_hwratio: Float = document.size.height / document.size.width

        scrollView.zoomScale = 1.0 // reset zoomScale

        // TODO: should change if pages.count changes
        fullDocumentView.frame.size = .init(width: scrollView.frame.width,
                                            height: scrollView.frame.width * CGFloat(doc_hwratio))
        scrollView.contentSize = fullDocumentView.frame.size
        setRenderViewToScreen()
        renderView.isPaused = false
    }

    func setRenderViewToScreen() {
//        XCLog(.trace)
        let w = scrollView.frame.width * 1.0 / scrollView.zoomScale
        let h = scrollView.frame.height * 1.0 / scrollView.zoomScale
        renderView.frame.size = .init(width: w, height: h)

        renderView.drawableSize = .init(width: scrollView.frame.width * UIScreen.main.nativeScale,
                                        height: scrollView.frame.height * UIScreen.main.nativeScale)

        let x = scrollView.contentOffset.x / scrollView.zoomScale
        let y = scrollView.contentOffset.y / scrollView.zoomScale
        renderView.frame.origin = .init(x: x, y: y)
    }
    

    private func prepareRenderData() { // TODO: 为某一文件准备渲染的数据
        XCLog(.trace)
        RenderData.shared.all_shapes = []
        RenderData.shared.all_shapes.append(contentsOf: document.pageSeperators)
        RenderData.shared.all_shapes.append(contentsOf: document.shapes)

        for shape in RenderData.shared.all_shapes {
            RenderData.shared.vertices_triangleStrips.append(contentsOf: shape.vertices.map {
                VertexIn(position: $0.position2,
                         alpha: shape.color.alpha,
                         r: shape.color.red,
                         g: shape.color.green,
                         b: shape.color.blue)
            })
            RenderData.shared.shapeNumer += 1

            RenderData.shared.indexBytes.append(contentsOf: RenderData.shared.instanceIndexStart ..< (RenderData.shared.instanceIndexStart + UInt32(shape.vertices.count)))
            RenderData.shared.instanceIndexStart += UInt32(shape.vertices.count)
            RenderData.shared.indexBytes.append(UInt32.max) // end an instance
        }
    }

    func printDebugInfo() {
        XCLog(.trace,
              """
              scrollView.frame \(scrollView.frame)
              fullDocumentView.frame \(fullDocumentView.frame)
              renderView.frame \(renderView.frame)
              renderView.drawableSize \(renderView.drawableSize)
              """)
    }
}
