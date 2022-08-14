import Combine
import Metal
import MetalKit
import SwiftUI

#if canImport(UIKit)
typealias ViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
typealias ViewRepresentable = NSViewRepresentable
#endif

struct MetalViewContainer: View, ViewRepresentable {
    init(
        device: MTLDevice,
        renderPublisher: AnyPublisher<RenderCommands, Never>
    ) {
        self.device = device
        self.publisher = renderPublisher
    }

    #if canImport(AppKit)
    func makeNSView(context: Context) -> MetalView {
        MetalView(
            device: self.device,
            renderPublisher: self.publisher
        )
    }

    func updateNSView(_ nsView: MetalView, context: Context) {}
    #endif

    #if canImport(UIKit)
    func makeUIView(context: Context) -> MetalView {
        MetalView(
            device: self.device,
            renderPublisher: self.publisher
        )
    }

    func updateUIView(_ uiView: MetalView, context: Context) {}
    #endif

    private let device: MTLDevice
    private let publisher: AnyPublisher<RenderCommands, Never>
}
