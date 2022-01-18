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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
}
