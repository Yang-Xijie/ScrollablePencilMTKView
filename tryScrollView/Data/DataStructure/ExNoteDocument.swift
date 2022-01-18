// 这个文件只描述数据的存储 与实际渲染无关

import Foundation

/// Note文档
///
/// 比如可以有两张A4纸
struct ExNoteDocument {
    /// 新建一个文档
    init(title: String,
         numberOfPages: Int = 2, pageSize: ExPageSize = .A4, pageStyle: ExPageStyle = .blank,
         strokes: [ExStroke] = [],
         shapes: [ExShape] = []) {
        self.title = title
        self.pages = [ExPage](repeating: ExPage(size: pageSize, style: pageStyle), count: numberOfPages)
        self.strokes = strokes
        self.shapes = shapes
    }

    // MARK: - properties

    /// 文档的标题
    var title: String

    /// 文档的不同页 不同页可能是不同的类型
    var pages: [ExPage]

    /// 文档的所有笔划
    var strokes: [ExStroke]

    /// 文档的所有矢量形状
    var shapes: [ExShape]

    // MARK: - calculated var

    /// document.size
    var size: ExSize {
        return ExSize(width: pages.first!.size.width, height: pages.first!.size.height * Float(pages.count))
    }

    var pageSize: ExSize {
        return ExSize(width: pages.first!.size.width, height: pages.first!.size.height)
    }

    /// esay to render seperator
    ///
    /// seperator appear at the end of each page
    var pageSeperators: [ExShape] {
        guard pages.count >= 1 else {
            return []
        }

        let seperatorWidth: Float = 0.5

        var seperators: [ExShape] = []
        for i in 1 ... pages.count {
            let y_center = pageSize.height * Float(i)
            seperators.append(ExShape(type: .triangle,
                                      color: .seperator,
                                      vertices: [.init(x: 0.0, y: y_center - seperatorWidth),
                                                 .init(x: pageSize.width, y: y_center - seperatorWidth),
                                                 .init(x: 0.0, y: y_center)]))
            seperators.append(ExShape(type: .triangle,
                                      color: .seperator,
                                      vertices: [.init(x: pageSize.width, y: y_center - seperatorWidth),
                                                 .init(x: 0.0, y: y_center),
                                                 .init(x: pageSize.width, y: y_center)]))
        }
        return seperators
    }
}
