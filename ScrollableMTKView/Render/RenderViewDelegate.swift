import Foundation
import Metal
import MetalKit
import XCLog

class RenderData {
    static let shared = RenderData()

    var all_shapes: [ExShape] = []

    var vertices_triangleStrips: [VertexIn] = []

    var indexBytes: [UInt32] = []

    var instanceIndexStart: UInt32 = 0
    var shapeNumer = 0
}

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
                fragmentFuncName: "fragmentShader_drawTriangleStripWithSingleColor"
            )
        } catch {
            XCLog(.fatal, "Unable to compile render pipeline state: \(error)")
            return nil
        }
    }

    // MARK: draw

    func draw(in view: MTKView) {
        // MARK: preparation

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1) // white background
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        // MARK: create data

        // transform from documentCoordinate to metalNormCoordinate
        var transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        // MARK: create buffer and set draw primitive

        renderEncoder.setRenderPipelineState(pipelineState_drawTriangleStripWithSingleColor)
        renderEncoder.setTriangleFillMode(.fill)
        let vertexBuffer = device.makeBuffer(bytes: RenderData.shared.vertices_triangleStrips,
                                             length: RenderData.shared.vertices_triangleStrips.count * MemoryLayout<VertexIn>.stride,
                                             options: [])!
        let indexBuffer = device.makeBuffer(bytes: RenderData.shared.indexBytes,
                                            length: RenderData.shared.indexBytes.count * MemoryLayout<UInt32>.stride,
                                            options: [])!

        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        renderEncoder.setVertexBytes(&transformConfig,
                                     length: MemoryLayout<TransfromConfig>.stride,
                                     index: 1) // transformConfig is smaller than 4KB

        renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                            indexCount: RenderData.shared.indexBytes.count,
                                            indexType: .uint32,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0,
                                            instanceCount: 1) // only one instance

        // MARK: commit

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
