#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

import Combine
import MetalKit

final class MetalView: MTKView, MTKViewDelegate {
    init(
        device: MTLDevice,
        renderPublisher: AnyPublisher<RenderCommands, Never>
    ) {
        super.init(frame: .zero, device: device)

        self.colorPixelFormat = .bgra8Unorm
        self.enableSetNeedsDisplay = true
        self.delegate = self

        renderPublisher.sink { commands in
            self.renderCommands = commands
            self.setNeedsDisplay(self.bounds)
        }
        .store(in: &self.subscriptions)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Init from coder is not supported")
    }

    func draw(in view: MTKView) {
        self.renderCommands?(self)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    private var subscriptions: Set<AnyCancellable> = []
    private var renderCommands: RenderCommands?
}
