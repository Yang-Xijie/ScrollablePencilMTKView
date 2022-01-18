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

    // This is the initializer for the Renderer class.
    // We will need access to the mtkView later, so we add it as a parameter here.
    init?(renderView: MTKView, document: ExNoteDocument, scrollView: UIScrollView) {
        self.document = document
        self.scrollView = scrollView

        self.renderView = renderView
        device = renderView.device!
        commandQueue = device.makeCommandQueue()!

        // Create the Render Pipeline
        do {
            pipelineState = try Self.buildRenderPipelineWith(device: device, metalKitView: renderView)
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }

        // MARK: use shape in document to create vertex data

        for shape in document.shapes {
            XCLog(.trace, "\(shape)")
        }
    }

    // MARK: - draw

    func draw(in view: MTKView) {
        // MARK: prepare

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)

        // MARK: set data

        let vertices: [Vertex] =
            [Vertex(pos: [-1.0, 1.0]), Vertex(pos: [-1.0, -1.0]), Vertex(pos: [1.0, 1.0]),
             Vertex(pos: [1.0, -1.0]), Vertex(pos: [-1.0, -1.0]), Vertex(pos: [1.0, 1.0])]

        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride,
                                             options: [])!
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let colors: [Color] = [Color(color: [1.0, 0.0, 0.0, 1.0]),
                               Color(color: [0.0, 1.0, 0.0, 1.0])]
        let colorBuffer = device.makeBuffer(bytes: colors,
                                            length: colors.count * MemoryLayout<Color>.stride,
                                            options: [])!
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)

        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: vertices.count)

        // MARK: commit

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

    // Create our custom rendering pipeline, which loads shaders using `device`, and outputs to the format of `metalKitView`
    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        // Create a new pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        // Setup the shaders in the pipeline
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")

        // Setup the output pixel format to match the pixel format of the metal kit view
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        // Compile the configured pipeline descriptor to a pipeline state object
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
