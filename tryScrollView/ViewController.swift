// ViewController.swift

import MetalKit
import UIKit
import XCLog

class ViewController: UIViewController {
    var scrollView: UIScrollView!
    var scrollContentView: UIView!
    var renderView: UIView!

    override func loadView() {
        // MARK: - view

        view = {
            let v = UIView()
            v.backgroundColor = .cyan
            return v
        }()

        // MARK: - scrollView

        scrollView = {
            let sv = UIScrollView()

            sv.backgroundColor = .yellow // the blank when scroll to edges

            sv.contentInsetAdjustmentBehavior = .never // let mktView inset the bottom safe area

            sv.isScrollEnabled = true // default is true
            sv.isUserInteractionEnabled = true // default: true

            sv.bounces = false // add default animation

            // MARK: zoom

            sv.delegate = self
            sv.maximumZoomScale = 4.0
            sv.minimumZoomScale = 0.33
            sv.bouncesZoom = false // diable bounce animation

            return sv
        }()

        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
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
            let rv = UIView()
            rv.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
//            rv.autoResizeDrawable = true
            return rv
        }()

        // not `view.addSubView()` because the scrollView should be on the top to recieve user's gesture
        // notice: renderView.frame is relative to scrollContentView
        scrollContentView.addSubview(renderView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        XCLog(.trace,
              """
              view.frame \(view.frame)
              scrollView.frame \(scrollView.frame)
              """)
    }

    override func viewDidLayoutSubviews() {
        scrollView.zoomScale = 1.0 // reset zoomScale

        XCLog(.trace,
              """
              view.frame \(view.frame)
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              """)

        // change when pages.count changes
        scrollContentView.frame.size = .init(width: scrollView.frame.width * 1.0, height: scrollView.frame.height * 2.0)
        scrollView.contentSize = scrollContentView.frame.size

        setRenderViewToScreen()

        XCLog(.trace,
              """
              view.frame \(view.frame)
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              """)
    }

    func setRenderViewToScreen() {
        if scrollView.zoomScale < 1.0 {
            let w = min(scrollView.frame.width * 1.0 / scrollView.zoomScale,
                        scrollContentView.frame.width * 1.0 / scrollView.zoomScale)
            let h = min(scrollView.frame.height * 1.0 / scrollView.zoomScale,
                        scrollContentView.frame.height * 1.0 / scrollView.zoomScale)
            renderView.frame.size = .init(width: w, height: h)
        } else {
            // correct
            let w = scrollView.frame.width * 1.0 / scrollView.zoomScale
            let h = scrollView.frame.height * 1.0 / scrollView.zoomScale
            renderView.frame.size = .init(width: w, height: h)
        }

        let x = scrollView.contentOffset.x / scrollView.zoomScale
        let y = scrollView.contentOffset.y / scrollView.zoomScale
        renderView.frame.origin = .init(x: x, y: y)
    }
}
