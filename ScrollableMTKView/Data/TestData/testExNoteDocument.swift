import Foundation

let test_strokepoints: [ExPoint] = [
    ExPoint(position: ExPosition(x: 0, y: 0), force: 1),
    ExPoint(position: ExPosition(x: 100, y: 100), force: 1),
    ExPoint(position: ExPosition(x: 105, y: 110), force: 1),
    ExPoint(position: ExPosition(x: 110, y: 130), force: 1),
    ExPoint(position: ExPosition(x: 200, y: 200), force: 1),
]

let test_stroke = ExStroke(type: .common,
                           color: ExColor(red: 0xEE, green: 0x74, blue: 0x34, alpha: 1),
                           path: test_strokepoints)

/// Page 1, half top
let test_trianglePoints1 = [
    ExPosition(x: ExPageSize.A4.width / 2.0, y: 0.0),
    ExPosition(x: 0.0, y: ExPageSize.A4.height / 2.0),
    ExPosition(x: ExPageSize.A4.width, y: ExPageSize.A4.height / 2.0),
]

let test_triangle1 = ExShape(type: .triangle,
                             color: .black,
                             vertices: test_trianglePoints1)

/// Page 1, left top corner
let test_trianglePoints2 = [
    ExPosition(x: 0.0, y: 0.0),
    ExPosition(x: 0.0, y: ExPageSize.A4.height / 4.0),
    ExPosition(x: ExPageSize.A4.width / 4.0, y: 0.0),
]

let test_triangle2 = ExShape(type: .triangle,
                             color: .red,
                             vertices: test_trianglePoints2)

let test_document = ExNoteDocument(title: "test document",
                                numberOfPages: 2, pageSize: .A4, pageStyle: .blank,
                                strokes: [test_stroke],
                                shapes: [test_triangle1, test_triangle2])
