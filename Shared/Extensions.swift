import CoreGraphics
import simd
import SwiftUI

extension CGColor {
    var simd: SIMD4<Float> {
        guard let components = self.components else { return .zero }

        switch components.count {
        case 4:
            return SIMD4(
                Float(components[0]),
                Float(components[1]),
                Float(components[2]),
                Float(components[3])
            )
        case 3:
            return SIMD4(
                Float(components[0]),
                Float(components[1]),
                Float(components[2]),
                1.0
            )
        case 2:
            return SIMD4(
                SIMD3(repeating: Float(components[0])),
                Float(components[1])
            )
        case 1:
            return SIMD4(
                .zero,
                Float(components[0])
            )
        default:
            return .zero
        }
    }
}

extension SIMD4 where Scalar == Float {
    var cg: CGColor {
        CGColor(
            red: CGFloat(self[0]),
            green: CGFloat(self[1]),
            blue: CGFloat(self[2]),
            alpha: CGFloat(self[3])
        )
    }

    static var white: SIMD4<Float> {
        SIMD4(SIMD3(repeating: 1.0), 1.0)
    }

    static var black: SIMD4<Float> {
        SIMD4(SIMD3(repeating: 0.0), 1.0)
    }

    var ui: Color {
        get {
            Color(self.cg)
        }
        set {
            self = newValue.cgColor?.simd ?? .zero
        }
    }
}

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(range.lowerBound, self), range.upperBound)
    }
}
