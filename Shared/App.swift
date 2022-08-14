import SwiftUI

@main
struct GradientShaderApp: App {
    init() {
        self.renderer = try! Renderer()
    }

    var body: some Scene {
        WindowGroup {
            AppView(renderer: self.renderer)
        }
    }

    private let renderer: Renderer
}
