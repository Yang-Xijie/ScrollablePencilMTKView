import Foundation

struct ExPoint {
    /// 点在Document中的位置
    var position: ExPosition

    /** 压感原始数据

     垂直方向的压感 0.0 - 4.167，1.0表示适中的压感

     <https://developer.apple.com/documentation/uikit/pencil_interactions/handling_input_from_apple_pencil/computing_the_perpendicular_force_of_apple_pencil>

     ```swift
     extension UITouch {
         var perpendicularForce: CGFloat {
             if type == .pencil {
                 return force / sin(altitudeAngle)
             } else {
                 return force
             }
         }
     }
     ```
     */
    var force: Float = 1.0
}
