import Foundation

/// 从左上角开始点的位置
struct ExPosition {
    var x: Float
    var y: Float

    // MARK: render in Metal

    var position2: MetalPosition2 {
        return [x, y]
    }
}
