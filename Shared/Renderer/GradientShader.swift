import Metal
import simd

final class GradientShader {
    init(library: MTLLibrary) throws {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "gradientVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "gradientFragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try library.device.makeRenderPipelineState(descriptor: descriptor)
    }

    func callAsFunction(
        gradientTexture: MTLTexture,
        destination: MTLTexture,
        rotationTransform: simd_float2x2,
        gradientType: UInt8,
        in commandBuffer: MTLCommandBuffer
    ) {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = destination
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        encoder.setRenderPipelineState(self.pipelineState)

        withUnsafePointer(to: rotationTransform) {
            encoder.setVertexBytes(
                $0,
                length: MemoryLayout<simd_float2x2>.stride,
                index: 0
            )
        }

        encoder.setFragmentTexture(gradientTexture, index: 0)

        withUnsafePointer(to: gradientType) {
            encoder.setFragmentBytes(
                $0,
                length: MemoryLayout<UInt8>.stride,
                index: 0
            )
        }

        encoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4
        )

        encoder.endEncoding()
    }

    private let pipelineState: MTLRenderPipelineState
}
