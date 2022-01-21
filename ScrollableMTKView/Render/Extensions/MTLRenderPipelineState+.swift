import Foundation
import Metal
import MetalKit

func buildRenderPipelineWith(device: MTLDevice,
                             metalKitView: MTKView,
                             vertexFuncName: String,
                             fragmentFuncName: String)
    throws -> MTLRenderPipelineState {
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    if let library = device.makeDefaultLibrary() {
        pipelineDescriptor.vertexFunction = library.makeFunction(name: vertexFuncName)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fragmentFuncName)
    }
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
    return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
}
