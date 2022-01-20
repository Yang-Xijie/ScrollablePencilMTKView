import Foundation

/// 0.0 - 1.0
struct ExColor {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float

    init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var red: ExColor {
        return .init(red: 1, green: 0, blue: 0, alpha: 1)
    }

    static var black: ExColor {
        return .init(red: 0, green: 0, blue: 0, alpha: 1)
    }

    static var seperator: ExColor {
        return .init(red: 0, green: 0, blue: 1, alpha: 1)
    }

    // MARK: render in Metal

    var rgba: MetalRGBA {
        return [red, green, blue, alpha]
    }
}
