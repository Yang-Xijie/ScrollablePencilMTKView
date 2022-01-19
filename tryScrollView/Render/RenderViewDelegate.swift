// RenderViewDelegate.swift

import Foundation
import Metal
import MetalKit
import XCLog

class RenderViewDelegate: NSObject, MTKViewDelegate {
    let renderView: MTKView!

    let document: ExNoteDocument!
    let scrollView: UIScrollView!

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let pipelineState_drawTrianglesWithSingleColor: MTLRenderPipelineState
    let pipelineState_drawTriangleStripWithSingleColor: MTLRenderPipelineState

    init?(renderView: MTKView, document: ExNoteDocument, scrollView: UIScrollView) {
        self.renderView = renderView

        self.document = document
        self.scrollView = scrollView

        device = renderView.device!
        commandQueue = device.makeCommandQueue()!

        do {
            pipelineState_drawTrianglesWithSingleColor = try buildRenderPipelineWith(
                device: device, metalKitView: renderView,
                vertexFuncName: "vertexShader_drawTrianglesWithSingleColor",
                fragmentFuncName: "fragmentShader_drawTrianglesWithSingleColor")

            pipelineState_drawTriangleStripWithSingleColor = try buildRenderPipelineWith(
                device: device, metalKitView: renderView,
                vertexFuncName: "vertexShader_drawTriangleStripWithSingleColor",
                fragmentFuncName: "fragmentShader_drawTriangleStripWithSingleColor")
        } catch {
            XCLog(.fatal, "Unable to compile render pipeline state: \(error)")
            return nil
        }
    }

    // MARK: - draw

    func draw(in view: MTKView) {
        // MARK: - prepare

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1) // white background
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        // transform from documentCoordinate to metalNormCoordinate
        var transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        // MARK: - encoder: triangles with single color

        renderEncoder.setRenderPipelineState(pipelineState_drawTrianglesWithSingleColor)
        renderEncoder.setTriangleFillMode(.fill)

        var vertices_triangles: [Vertex] = []
        var colors_triangles: [Color] = []

        for shape in document.shapes {
            for vertex in shape.vertices {
                vertices_triangles.append(Vertex(pos: [vertex.x, vertex.y]))
            }
            colors_triangles.append(Color(color: shape.color.array))
        }

        let vertexBuffer = device.makeBuffer(bytes: vertices_triangles,
                                             length: vertices_triangles.count * MemoryLayout<Vertex>.stride,
                                             options: [])!
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        let colorBuffer = device.makeBuffer(bytes: colors_triangles,
                                            length: colors_triangles.count * MemoryLayout<Color>.stride,
                                            options: [])!
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBytes(&transformConfig,
                                     length: MemoryLayout.size(ofValue: transformConfig),
                                     index: 2) // transformConfig is smaller than 4KB

        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 3,
                                     instanceCount: colors_triangles.count)

        // MARK: encoder - triangle strips with single color

        for seperatorRectangle in document.pageSeperators {
            renderEncoder.setRenderPipelineState(pipelineState_drawTriangleStripWithSingleColor)
            renderEncoder.setTriangleFillMode(.fill)

            let vertices_triangleStrips = seperatorRectangle.vertices
            var color_triangleStrips = seperatorRectangle.color.array

            let vertexBuffer = device.makeBuffer(bytes: vertices_triangleStrips,
                                                 length: vertices_triangleStrips.count * MemoryLayout<Vertex>.stride,
                                                 options: [])!
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//            let colorBuffer = device.makeBuffer(bytes: ,
//                                                length: ),
//                                                options: [])!
//            renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            renderEncoder.setVertexBytes(&transformConfig,
                                         length: MemoryLayout.size(ofValue: transformConfig),
                                         index: 1) // transformConfig is smaller than 4KB
            renderEncoder.setFragmentBytes(&color_triangleStrips,
                                           length: MemoryLayout.size(ofValue: color_triangleStrips),
                                           index: 0)

            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: vertices_triangleStrips.count)
        }

        // MARK: commit

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
