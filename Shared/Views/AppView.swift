import SwiftUI

struct AppView: View {
    init(renderer: Renderer) {
        self.renderer = renderer
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            MetalViewContainer(
                device: self.renderer.device,
                renderPublisher: self.renderer.renderPublisher
            )
            .aspectRatio(1, contentMode: .fit)

            Spacer()

            GradientBuilderView(gradient: self.$gradient)
                .padding()
        }
        .background(Color.accentColor.opacity(0.25))
        .onAppear {
            self.renderer.render(gradient: self.gradient)
        }
        .onChange(of: self.gradient) { gradient in
            self.renderer.render(gradient: gradient)
        }
    }

    private let renderer: Renderer
    @State private var gradient: Gradient = .default
}
