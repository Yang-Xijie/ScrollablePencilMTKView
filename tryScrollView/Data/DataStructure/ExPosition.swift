import Foundation

/// 从左上角开始点的位置
struct ExPosition {
    var x: Float
    var y: Float

    var vector: vector_float2 {
        return [x, y]
    }
}
