import Foundation

/// 一笔
///
/// 独立于Canvas
struct ExStroke {
    // MARK: configure

    init(type: ExStrokeType, color: ExColor, path: [ExPoint]) {
        self.type = type
        self.color = color
        self.path = path
    }

    /// 笔划的类型 决定渲染方式
    var type: ExStrokeType = .common

    /// 一笔的颜色 是唯一的 不能渐变
    var color: ExColor

    // MARK: path

    var path: [ExPoint]
}

enum ExStrokeType {
    case common
}
