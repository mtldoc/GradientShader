import Combine
import Metal
import MetalKit

typealias RenderCommands = ((MTKView) -> Void)

final class Renderer {
    init() throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary(),
              let commandQueue = device.makeCommandQueue()
        else { throw Error.metalInitializationFailed }

        self.device = device
        self.commandQueue = commandQueue
        self.gradientTextureShader = try GradientTextureShader(library: library)
        self.gradientShader = try GradientShader(library: library)
        self.renderTextureShader = try RenderTextureShader(library: library)

        let descriptor = MTLTextureDescriptor()
        descriptor.width = 1024
        descriptor.height = 1
        descriptor.depth = 1
        descriptor.pixelFormat = .bgra8Unorm
        descriptor.storageMode = .private
        descriptor.textureType = .type2D
        descriptor.usage = [.shaderRead, .renderTarget]

        self.gradient1DTexture = try Self.texture(descriptor: descriptor, device: device)
        descriptor.height = 1024
        self.gradient2DTexture = try Self.texture(descriptor: descriptor, device: device)
    }

    enum Error: Swift.Error {
        case metalInitializationFailed
        case textureCreationFailed
    }

    let device: MTLDevice

    var renderPublisher: AnyPublisher<RenderCommands, Never> {
        self.renderSubject.eraseToAnyPublisher()
    }

    func render(gradient: Gradient) {
        var stops = gradient.stops.sorted { $0.location < $1.location }

        if let first = stops.first, first.location != 0 {
            stops.insert(Gradient.GradientStop(location: 0, color: first.color), at: 0)
        }

        if let last = stops.last, last.location != 1 {
            stops.insert(Gradient.GradientStop(location: 1, color: last.color), at: stops.count)
        }

        self.renderSubject.send { [weak self] view in
            guard let self = self,
                  let commandBuffer = self.commandQueue.makeCommandBuffer()
            else { return }

            commandBuffer.enqueue()

            self.gradientTextureShader(
                locations: stops.map(\.location),
                colors: stops.map(\.color),
                destination: self.gradient1DTexture,
                in: commandBuffer
            )

            self.gradientShader(
                gradientTexture: self.gradient1DTexture,
                destination: self.gradient2DTexture,
                rotationTransform: gradient.rotationMatrix,
                gradientType: gradient.type.rawValue,
                in: commandBuffer
            )

            self.renderTextureShader(
                source: self.gradient2DTexture,
                destination: view,
                in: commandBuffer
            )

            commandBuffer.commit()
        }
    }

    private let commandQueue: MTLCommandQueue

    private let gradientTextureShader: GradientTextureShader
    private let gradientShader: GradientShader
    private let renderTextureShader: RenderTextureShader

    private let gradient1DTexture: MTLTexture
    private let gradient2DTexture: MTLTexture

    private let renderSubject: PassthroughSubject<RenderCommands, Never> = .init()

    private static func texture(descriptor: MTLTextureDescriptor, device: MTLDevice) throws -> MTLTexture {
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw Error.textureCreationFailed
        }

        return texture
    }
}
