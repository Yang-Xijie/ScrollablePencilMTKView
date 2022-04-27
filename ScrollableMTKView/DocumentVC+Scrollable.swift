import Foundation
import UIKit

import XCLog

extension DocumentVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.fullDocumentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        XCLog(.trace,
//              """
//              scrollView.frame \(scrollView.frame)
//              renderView.frame \(renderView.frame)
//              renderView.drawableSize \(renderView.drawableSize)
//
//              scrollContentView.frame \(fullDocumentView.frame)
//              scrollView.contentSize \(scrollView.contentSize)
//              scrollView.contentOffset \(scrollView.contentOffset)
//              """)

        setRenderViewToScreen()

//        XCLog(.trace,
//              """
//              scrollView.frame \(scrollView.frame)
//              renderView.frame \(renderView.frame)
//              renderView.drawableSize \(renderView.drawableSize)
//
//              scrollContentView.frame \(scrollContentView.frame)
//              scrollView.contentSize \(scrollView.contentSize)
//              scrollView.contentOffset \(scrollView.contentOffset)
//              """)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setRenderViewToScreen()

//        XCLog(.trace,
//              """
//              scrollView.frame \(scrollView.frame)
//              renderView.frame \(renderView.frame)
//              renderView.drawableSize \(renderView.drawableSize)
//
//              scrollContentView.frame \(scrollContentView.frame)
//              scrollView.contentSize \(scrollView.contentSize)
//              scrollView.contentOffset \(scrollView.contentOffset)
//              """)
    }
}
