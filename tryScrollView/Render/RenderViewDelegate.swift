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
                fragmentFuncName: "fragmentShader")

            pipelineState_drawTriangleStripWithSingleColor = try buildRenderPipelineWith(
                device: device, metalKitView: renderView,
                vertexFuncName: "vertexShader_drawTriangleStripWithSingleColor",
                fragmentFuncName: "fragmentShader")
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

        // MARK: - generate data

        var transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        // MARK: - render command encoder

        // MARK: triangles with single color

        guard let renderEncoder_triangles = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder_triangles.setRenderPipelineState(pipelineState_drawTrianglesWithSingleColor)
        renderEncoder_triangles.setTriangleFillMode(.fill)

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
        renderEncoder_triangles.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        let colorBuffer = device.makeBuffer(bytes: colors_triangles,
                                            length: colors_triangles.count * MemoryLayout<Color>.stride,
                                            options: [])!
        renderEncoder_triangles.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder_triangles.setVertexBytes(&transformConfig,
                                               length: MemoryLayout.size(ofValue: transformConfig),
                                               index: 2) // transformConfig is smaller than 4KB

        renderEncoder_triangles.drawPrimitives(type: .triangle,
                                               vertexStart: 0,
                                               vertexCount: 3,
                                               instanceCount: colors_triangles.count)
        renderEncoder_triangles.endEncoding()

        // MARK: triangle strips with single color

        for seperatorRectangle in document.pageSeperators {
            let vertices_triangleStrips = seperatorRectangle.vertices
            var color_triangleStrips = seperatorRectangle.color.array

            guard let renderEncoder_triangleStrip = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
            renderEncoder_triangleStrip.setRenderPipelineState(pipelineState_drawTriangleStripWithSingleColor)
            renderEncoder_triangleStrip.setTriangleFillMode(.fill)

            let vertexBuffer = device.makeBuffer(bytes: vertices_triangleStrips,
                                                 length: vertices_triangleStrips.count * MemoryLayout<Vertex>.stride,
                                                 options: [])!
            renderEncoder_triangleStrip.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            let colorBuffer = device.makeBuffer(bytes: &color_triangleStrips,
                                                length: MemoryLayout.size(ofValue: color_triangleStrips),
                                                options: [])!
            renderEncoder_triangleStrip.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            renderEncoder_triangleStrip.setVertexBytes(&transformConfig,
                                                       length: MemoryLayout.size(ofValue: transformConfig),
                                                       index: 2) // transformConfig is smaller than 4KB

            renderEncoder_triangleStrip.drawPrimitives(type: .triangleStrip,
                                                       vertexStart: 0,
                                                       vertexCount: vertices_triangleStrips.count)
            renderEncoder_triangleStrip.endEncoding()
        }

        // MARK: commit

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
