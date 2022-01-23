import Foundation

/// 0.0 - 1.0
struct ExColor {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: Float

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var red: ExColor {
        return .init(red: 0xFF, green: 0, blue: 0, alpha: 1)
    }

    static var black: ExColor {
        return .init(red: 0, green: 0, blue: 0, alpha: 1)
    }

    static var seperator: ExColor {
        return .init(red: 0, green: 0, blue: 0xFF, alpha: 1)
    }

}
