import Metal
import simd

final class GradientTextureShader {
    init(library: MTLLibrary) throws {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "gradientTextureVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "gradientTextureFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try library.device.makeRenderPipelineState(descriptor: descriptor)
    }

    func callAsFunction(
        locations: [Float],
        colors: [SIMD4<Float>],
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = destination
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        encoder.setRenderPipelineState(self.pipelineState)

        encoder.setVertexBytes(
            locations,
            length: MemoryLayout<Float>.stride * locations.count,
            index: 0
        )

        encoder.setVertexBytes(
            colors,
            length: MemoryLayout<SIMD4<Float>>.stride * colors.count,
            index: 1
        )

        encoder.drawPrimitives(
            type: .lineStrip,
            vertexStart: 0,
            vertexCount: locations.count
        )

        encoder.endEncoding()
    }

    private let pipelineState: MTLRenderPipelineState
}
