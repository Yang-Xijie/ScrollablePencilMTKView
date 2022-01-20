import Foundation

struct ExShape {
    // MARK: configure

    init(type: ExShapeType, color: ExColor, vertices: [ExPosition]) {
        self.type = type
        self.color = color
        self.vertices = vertices
    }

    /// 形状的类型
    var type: ExShapeType

    /// 一笔的颜色 是唯一的 不能渐变
    var color: ExColor

    // MARK: path

    var vertices: [ExPosition]
}

enum ExShapeType {
    case line
    case triangle
    case rectangle
}
