// VC+ScrollDelegate.swift

import Foundation
import UIKit

import XCLog

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollContentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        XCLog(.trace,
              """
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              """)

        setRenderViewToScreen()

        XCLog(.trace,
              """
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              renderView.frame \(renderView.frame)
              """)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setRenderViewToScreen()

        XCLog(.trace,
              """
              view.frame \(view!.frame)
              scrollView.frame \(scrollView.frame)
              scrollContentView.frame \(scrollContentView.frame)
              scrollView.contentOffset \(scrollView.contentOffset)
              renderView.frame \(renderView.frame)
              """)
    }
}
