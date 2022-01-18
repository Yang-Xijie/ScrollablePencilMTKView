import Foundation

let test_strokepoints: [ExPoint] = [
    ExPoint(position: ExPosition(x: 0, y: 0), force: 1),
    ExPoint(position: ExPosition(x: 100, y: 100), force: 1),
    ExPoint(position: ExPosition(x: 105, y: 110), force: 1),
    ExPoint(position: ExPosition(x: 110, y: 130), force: 1),
    ExPoint(position: ExPosition(x: 200, y: 200), force: 1),
]

let test_stroke = ExStroke(type: .common,
                           color: ExColor(red: 0xee / 256, green: 0x74 / 256, blue: 0x34 / 256, alpha: 1),
                           path: test_strokepoints)

/// 一个占满第一页的黑色三角形
let test_trianglePoints = [
    ExPosition(x: ExPageSize.A4.width / 2.0, y: 0.0),
    ExPosition(x: 0.0, y: ExPageSize.A4.height),
    ExPosition(x: ExPageSize.A4.width, y: ExPageSize.A4.height)
]

let test_triangle = ExShape(type: .triangle,
                            color: .black,
                            vertices: test_trianglePoints)

let testExNote = ExNoteDocument(title: "test document",
                                numberOfPages: 2, pageSize: .A4, pageStyle: .blank,
                                strokes: [test_stroke],
                                shapes: [test_triangle])
