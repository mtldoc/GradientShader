import Foundation
import simd
import SwiftUI

struct Gradient: Equatable {
    enum GradientType: UInt8, CaseIterable, Identifiable {
        case linear
        case radial
        case angular

        var id: Self { self }

        var title: String {
            switch self {
            case .linear:
                return "Linear"
            case .radial:
                return "Radial"
            case .angular:
                return "Angular"
            }
        }
    }

    struct GradientStop: Identifiable, Equatable {
        let id: UUID
        var location: Float
        var color: SIMD4<Float>

        init(location: Float, color: SIMD4<Float>) {
            self.id = UUID()
            self.location = location
            self.color = color
        }

        var ui: SwiftUI.Gradient.Stop {
            get {
                SwiftUI.Gradient.Stop(
                    color: Color(self.color.cg),
                    location: CGFloat(self.location)
                )
            }
            set {
                self.location = Float(newValue.location)
                self.color = newValue.color.cgColor?.simd ?? .zero
            }
        }

        static func == (lhs: GradientStop, rhs: GradientStop) -> Bool {
            lhs.location == rhs.location && lhs.color == rhs.color
        }
    }

    var type: GradientType
    var stops: [GradientStop]
    var rotationAngle: Float

    var rotationMatrix: simd_float2x2 {
        let radians = self.rotationAngle * .pi / 180.0
        var sin: Float = 0
        var cos: Float = 0
        __sincosf(radians, &sin, &cos)

        return simd_float2x2(
            columns: (
                SIMD2(cos, sin),
                SIMD2(-sin, cos)
            )
        )
    }

    static let `default` = Gradient(
        type: .linear,
        stops: [
            Gradient.GradientStop(location: 0, color: .white),
            Gradient.GradientStop(location: 1, color: .black),
        ],
        rotationAngle: 0
    )

    static func == (lhs: Gradient, rhs: Gradient) -> Bool {
        lhs.type == rhs.type && lhs.stops == rhs.stops && lhs.rotationAngle == rhs.rotationAngle
    }
}
