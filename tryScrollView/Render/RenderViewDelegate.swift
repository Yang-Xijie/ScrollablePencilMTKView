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
    let pipelineState: MTLRenderPipelineState

    init?(renderView: MTKView, document: ExNoteDocument, scrollView: UIScrollView) {
        self.renderView = renderView

        self.document = document
        self.scrollView = scrollView

        device = renderView.device!
        commandQueue = device.makeCommandQueue()!

        do {
            pipelineState = try Self.buildRenderPipelineWith(device: device, metalKitView: renderView)
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
    }

    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        if let library = device.makeDefaultLibrary() {
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        }

        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    // MARK: - draw

    func draw(in view: MTKView) {
        // MARK: prepare

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1) // white

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)

        // MARK: use shape in document to create vertex data

        var vertices: [Vertex] = []
        var colors: [Color] = []

        for seperatorTriangle in document.pageSeperators {
            for vertex in seperatorTriangle.vertices {
                vertices.append(Vertex(pos: [vertex.x, vertex.y]))
            }
            colors.append(Color(color: seperatorTriangle.color.array))
        }

        for shape in document.shapes {
            for vertex in shape.vertices {
                vertices.append(Vertex(pos: [vertex.x, vertex.y]))
            }
            colors.append(Color(color: shape.color.array))
        }

        // MARK: buffer

        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride,
                                             options: [])!
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let colorBuffer = device.makeBuffer(bytes: colors,
                                            length: colors.count * MemoryLayout<Color>.stride,
                                            options: [])!
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)

        var transformConfig = TransfromConfig(documentSize: [document.size.width, document.size.height],
                                              scrollViewContentSize: [Float(scrollView.contentSize.width), Float(scrollView.contentSize.height)],
                                              scrollViewContentOffset: [Float(scrollView.contentOffset.x), Float(scrollView.contentOffset.y)],
                                              renderViewFrameSize: [Float(renderView.frame.width), Float(renderView.frame.height)],
                                              scrollViewZoomScale: Float(scrollView.zoomScale))

        // transformConfig is smaller than 4KB
        renderEncoder.setVertexBytes(&transformConfig,
                                     length: MemoryLayout.size(ofValue: transformConfig),
                                     index: 2)

        // MARK: commit

        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: vertices.count)
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}
