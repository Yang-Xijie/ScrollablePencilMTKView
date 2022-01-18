// ViewController.swift

import UIKit
import XCLog

class ViewController: UIViewController {
    var scrollView: UIScrollView!

    override func loadView() {
        view = {
            let v = UIView()
            v.backgroundColor = .cyan
            return v
        }()

        scrollView = {
            let sv = UIScrollView()

            sv.backgroundColor = .orange // the blank when scroll to edges

            sv.contentInsetAdjustmentBehavior = .never // let mktView inset the bottom safe area

            sv.isScrollEnabled = true // default is true
            sv.isUserInteractionEnabled = true // default: true

            sv.bounces = true // add default animation

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
        XCLog(.trace,
              """
              view.frame \(view.frame)
              scrollView.frame \(scrollView.frame)
              """)
    }
}
