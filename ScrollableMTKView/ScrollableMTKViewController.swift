import MetalKit
import UIKit
import XCLog

class ScrollableMTKViewController: UIViewController {
    var scrollView: UIScrollView!
    var scrollContentView: UIView!

    var renderView: MTKView!
    var renderViewDelegate: RenderViewDelegate!

    var document: ExNoteDocument!

    override func loadView() {
        document = testExNote

        // MARK: - view

        view = {
            let v = UIView()
            v.backgroundColor = .white
            return v
        }()

        // MARK: - scrollView

        scrollView = {
            let sv = UIScrollView()

            sv.backgroundColor = .yellow // the blank when scroll to edges

            sv.contentInsetAdjustmentBehavior = .never // let mktView inset the bottom safe area

            sv.isScrollEnabled = true // default: true
            sv.isUserInteractionEnabled = true // default: true

            sv.bounces = false // add default animation

            // MARK: zoom

            sv.delegate = self
            sv.maximumZoomScale = 5.0
            sv.minimumZoomScale = 1.0 // no support for `zoomScale` smaller than 1.0
            sv.bouncesZoom = false // bounce animation

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

        scrollContentView = {
            let scv = UIView()
            scv.backgroundColor = .orange
            return scv
        }()

        scrollView.addSubview(scrollContentView)

        // MARK: - renderView

        renderView = {
            let rv = MTKView()

            // MARK: device

            guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
                XCLog(.fatal, "Metal is not supported on this device")
                fatalError()
            }
            rv.device = defaultDevice

            // MARK: render method
            
            // No need for `rv.preferredFramesPerSecond = 120`. It will be automatically decided by device.
            rv.isPaused = true
            rv.enableSetNeedsDisplay = false // when Apple Pencil or finger strokes, render

            rv.autoResizeDrawable = false // set renderView size and drawableSize by ourselves

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
        scrollContentView.addSubview(renderView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        let doc_hwratio: Float = document.size.height / document.size.width

        scrollView.zoomScale = 1.0 // reset zoomScale

        // change when pages.count changes
        scrollContentView.frame.size = .init(width: scrollView.frame.width,
                                             height: scrollView.frame.width * CGFloat(doc_hwratio))
        scrollView.contentSize = scrollContentView.frame.size

        XCLog(.trace,
              """
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              renderView.drawableSize \(renderView.drawableSize)
              scrollView.contentOffset \(scrollView.contentOffset)
              """)

        setRenderViewToScreen()

        XCLog(.trace,
              """
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              renderView.drawableSize \(renderView.drawableSize)
              scrollView.contentOffset \(scrollView.contentOffset)
              """)
    }

    func setRenderViewToScreen() {
        let w = scrollView.frame.width * 1.0 / scrollView.zoomScale
        let h = scrollView.frame.height * 1.0 / scrollView.zoomScale
        renderView.frame.size = .init(width: w, height: h)

        renderView.drawableSize = .init(width: scrollView.frame.width * UIScreen.main.nativeScale,
                                        height: scrollView.frame.height * UIScreen.main.nativeScale)

        let x = scrollView.contentOffset.x / scrollView.zoomScale
        let y = scrollView.contentOffset.y / scrollView.zoomScale
        renderView.frame.origin = .init(x: x, y: y)

        renderView.draw() // render the frame
    }
}