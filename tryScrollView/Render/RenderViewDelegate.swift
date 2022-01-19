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

    let pipelineState_drawTriangleStripWithSingleColor: MTLRenderPipelineState

    init?(renderView: MTKView, document: ExNoteDocument, scrollView: UIScrollView) {
        self.renderView = renderView

        self.document = document
        self.scrollView = scrollView

        device = renderView.device!
        commandQueue = device.makeCommandQueue()!

        do {
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

        // MARK: - encoder: triangle strips with single color

        var all_shapes = document.pageSeperators
        all_shapes.append(contentsOf: document.shapes)

        for shape in all_shapes {
            renderEncoder.setRenderPipelineState(pipelineState_drawTriangleStripWithSingleColor)
            renderEncoder.setTriangleFillMode(.fill)

            let vertices_triangleStrips = shape.vertices
            var color_triangleStrips = shape.color.array

            let vertexBuffer = device.makeBuffer(bytes: vertices_triangleStrips,
                                                 length: vertices_triangleStrips.count * MemoryLayout<MetalPosition>.stride,
                                                 options: [])!
            renderEncoder.setVertexBuffer(vertexBuffer,
                                          offset: 0,
                                          index: 0)
            renderEncoder.setVertexBytes(&transformConfig,
                                         length: MemoryLayout<TransfromConfig>.stride,
                                         index: 1) // transformConfig is smaller than 4KB
            renderEncoder.setFragmentBytes(&color_triangleStrips,
                                           length: MemoryLayout<MetalRGBA>.stride,
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

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
