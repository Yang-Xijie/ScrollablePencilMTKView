import Foundation
import UIKit

import XCLog

extension DocumentVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullDocumentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        setRenderViewToScreen()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setRenderViewToScreen()
    }
}
