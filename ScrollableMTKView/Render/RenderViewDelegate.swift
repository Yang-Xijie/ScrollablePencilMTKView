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

        for _ in 0 ..< MaxFramesInFlight {
            vertexBuffer.append(device.makeBuffer(bytes: RenderData.shared.vertices_triangleStrips,
                                                  length: RenderData.shared.vertices_triangleStrips.count * MemoryLayout<VertexIn>.stride,
                                                  options: [])!)
            indexBuffer.append(device.makeBuffer(bytes: RenderData.shared.indexBytes,
                                                 length: RenderData.shared.indexBytes.count * MemoryLayout<UInt32>.stride,
                                                 options: [])!)
            transformConfigBuffer.append(TransfromConfig(documentSize: .zero, scrollViewContentSize: .zero, scrollViewContentOffset: .zero, renderViewFrameSize: .zero, scrollViewZoomScale: 1.0))
        }
    }

    // flight
    let MaxFramesInFlight = 3
    var _currentBuffer = 0
    var vertexBuffer: [MTLBuffer] = []
    var indexBuffer: [MTLBuffer] = []
    var transformConfigBuffer: [TransfromConfig] = []

    // MARK: draw

    func draw(in view: MTKView) {
        _currentBuffer = (_currentBuffer + 1) % MaxFramesInFlight

        // MARK: preparation

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1) // white background
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        // MARK: create data

        // MARK: create buffer and set draw primitive

        renderEncoder.setRenderPipelineState(pipelineState_drawTriangleStripWithSingleColor)
        renderEncoder.setTriangleFillMode(.fill)

        let currentVertexBufferAddr = vertexBuffer[_currentBuffer].contents()
        let currentVertexBufferData = RenderData.shared.vertices_triangleStrips
        currentVertexBufferAddr.initializeMemory(as: VertexIn.self, from: currentVertexBufferData, count: RenderData.shared.vertices_triangleStrips.count)

        let currentIndexBufferAddr = indexBuffer[_currentBuffer].contents()
        let currentIndexBufferData = RenderData.shared.indexBytes
        currentIndexBufferAddr.initializeMemory(as: UInt32.self, from: currentIndexBufferData, count: RenderData.shared.indexBytes.count)

        // transform from documentCoordinate to metalNormCoordinate
        // FIXME: sceneDidBecomeActive变卡可能是有些东西没算出来 获取不到 然后就丢了几帧 然后一直卡
        let transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        transformConfigBuffer[_currentBuffer] = transformConfig

        renderEncoder.setVertexBuffer(vertexBuffer[_currentBuffer],
                                      offset: 0,
                                      index: 0)
        renderEncoder.setVertexBytes(&transformConfigBuffer[_currentBuffer],
                                     length: MemoryLayout<TransfromConfig>.stride,
                                     index: 1) // transformConfig is smaller than 4KB

        renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                            indexCount: RenderData.shared.indexBytes.count,
                                            indexType: .uint32,
                                            indexBuffer: indexBuffer[_currentBuffer],
                                            indexBufferOffset: 0,
                                            instanceCount: 1) // only one instance

        // MARK: commit

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
