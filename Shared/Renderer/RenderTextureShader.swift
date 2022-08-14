import Metal
import MetalKit

final class RenderTextureShader {
    init(library: MTLLibrary) throws {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "renderTextureVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "renderTextureFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try library.device.makeRenderPipelineState(descriptor: descriptor)
    }

    func callAsFunction(
        source: MTLTexture,
        destination: MTKView,
        in commandBuffer: MTLCommandBuffer
    ) {
        guard let descriptor = destination.currentRenderPassDescriptor
        else { return }

        descriptor.colorAttachments[0].storeAction = .store

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

        encoder.setRenderPipelineState(self.pipelineState)
        encoder.setFragmentTexture(source, index: 0)

        encoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4
        )

        encoder.endEncoding()

        if let drawable = destination.currentDrawable {
            commandBuffer.present(drawable)
        }
    }

    private let pipelineState: MTLRenderPipelineState
}
