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
        // MARK: prepare

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1) // white background

        // transform data
        var transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        // MARK: - render command encoder

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState_drawTrianglesWithSingleColor)
        renderEncoder.setTriangleFillMode(.fill)

        // MARK: triangles with single color

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

        // transformConfig is smaller than 4KB
        renderEncoder.setVertexBytes(&transformConfig,
                                     length: MemoryLayout.size(ofValue: transformConfig),
                                     index: 2)

        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 3,
                                     instanceCount: colors_triangles.count)
        renderEncoder.endEncoding()

//        // triangle strips
//
//        for seperatorTriangle in document.pageSeperators {
//            for vertex in seperatorTriangle.vertices {
//                vertices_triangles.append(Vertex(pos: [vertex.x, vertex.y]))
//            }
//            colors_triangles.append(Color(color: seperatorTriangle.color.array))
//        }

        // MARK: commit

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
