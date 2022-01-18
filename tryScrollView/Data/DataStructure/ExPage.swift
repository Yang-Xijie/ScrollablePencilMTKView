import Foundation
import XCLog

/// 一张纸
///
/// 画布的基本构成
///
/// A4 paper with 297x210
struct ExPage {
    // MARK: properties

    var size: ExPageSize

    var style: ExPageStyle

    // MARK: init

    init(size: ExPageSize, style: ExPageStyle) {
        self.size = size
        self.style = style
    }
}

struct ExPageSize {
    var width: Float
    var height: Float

    init(width: Float = 210, height: Float = 297) {
        self.width = width
        self.height = height
    }

    static let A4 = Self(width: 210, height: 297)
}

struct ExPageStyle {
    static let blank = Self()
}
