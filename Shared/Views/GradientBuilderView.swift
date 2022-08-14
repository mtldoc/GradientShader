import SwiftUI

struct GradientBuilderView: View {
    init(gradient: Binding<Gradient>) {
        self._gradient = gradient
    }

    var body: some View {
        VStack {
            Picker(selection: self.$gradient.type) {
                ForEach(Gradient.GradientType.allCases) { type in
                    Text(type.title)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)

            GeometryReader { proxy in
                GradientView(stops: self.$gradient.stops)
                    .frame(width: proxy.size.width, height: 32)

                StopsView(
                    width: proxy.size.width,
                    stops: self.$gradient.stops,
                    selectedStopID: self.$selectedStopID
                )
                .frame(width: proxy.size.width, height: 24)
                .offset(y: 16)
            }
            .frame(height: 32)

            SelectedStopView(
                stops: self.$gradient.stops,
                stopID: self.$selectedStopID
            )

            Slider(value: self.$gradient.rotationAngle, in: 0 ... 360)
        }
    }

    private struct GradientView: View {
        init(stops: Binding<[Gradient.GradientStop]>) {
            self._stops = stops
        }

        var body: some View {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: self.stops.map(\.ui),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white.opacity(0.7))
                )
                .frame(height: 32)
                .onTapGesture {
                    let stops = self.stops.suffix(2)
                    let location = stops.reduce(0) { $0 + $1.location } / 2.0
                    let color = stops.reduce(.zero) { $0 + $1.color } / 2.0

                    self.stops.insert(
                        Gradient.GradientStop(
                            location: location,
                            color: color
                        ),
                        at: self.stops.count - 1
                    )
                }
        }

        @Binding private var stops: [Gradient.GradientStop]
    }

    private struct StopsView: View {
        init(
            width: CGFloat,
            stops: Binding<[Gradient.GradientStop]>,
            selectedStopID: Binding<UUID?>
        ) {
            self.width = width
            self._stops = stops
            self._selectedStopID = selectedStopID
        }

        var body: some View {
            ForEach(self.$stops) { stop in
                StopView(
                    stops: self.$stops,
                    stop: stop,
                    selectedStopID: self.$selectedStopID,
                    width: self.width
                )
            }
        }

        private let width: CGFloat
        @Binding private var stops: [Gradient.GradientStop]
        @Binding private var selectedStopID: UUID?
    }

    private struct StopView: View {
        init(
            stops: Binding<[Gradient.GradientStop]>,
            stop: Binding<Gradient.GradientStop>,
            selectedStopID: Binding<UUID?>,
            width: CGFloat
        ) {
            self._stops = stops
            self._stop = stop
            self._selectedStopID = selectedStopID
            self.width = width
        }

        var body: some View {
            Circle()
                .foregroundColor(Color(self.stop.color.cg))
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(self.selectedStopID == self.stop.id ? .accentColor : .white.opacity(0.7))
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                .position(x: self.width * CGFloat(self.stop.location))
                .gesture(self.dragGesture)
                .contextMenu {
                    if self.stops.count > 2 {
                        Button("Delete") {
                            self.stops.removeAll { $0.id == self.stop.id }
                        }
                    } else {
                        EmptyView()
                    }
                }
                .onTapGesture {
                    self.selectedStopID = self.stop.id
                }
        }

        private let width: CGFloat

        @Binding private var stops: [Gradient.GradientStop]
        @Binding private var stop: Gradient.GradientStop
        @Binding private var selectedStopID: UUID?
        @GestureState private var initialLocation: Float?

        private var dragGesture: some Gesture {
            DragGesture()
                .updating(self.$initialLocation) { _, state, _ in
                    guard state == nil else { return }
                    state = self.stop.location
                }
                .onChanged { value in
                    let location = (self.initialLocation ?? 0) + Float(value.translation.width / self.width)
                    self.stop.location = location.clamped(to: 0 ... 1)
                    self.stops.sort { $0.location < $1.location }
                }
        }
    }

    private struct SelectedStopView: View {
        init(
            stops: Binding<[Gradient.GradientStop]>,
            stopID: Binding<UUID?>
        ) {
            self._stops = stops
            self._stopID = stopID
        }

        var body: some View {
            HStack {
                ForEach(self.channels, id: \.title) { channel in
                    Text("\(channel.title): \(channel.value)")
                }

                ColorPicker(
                    selection: self.color,
                    label: EmptyView.init
                )
                .disabled(self.stopID == nil)
            }
            .font(.system(size: 12))
            .foregroundColor(self.stopID == nil ? .gray : .black)
        }

        @State private var placeholder: Color = .clear
        @Binding private var stops: [Gradient.GradientStop]
        @Binding private var stopID: UUID?

        private var stop: Binding<Gradient.GradientStop>? {
            self.$stops.first { $0.id == self.stopID }
        }

        private var color: Binding<Color> {
            if let stop = self.stop {
                return stop.color.ui
            } else {
                return self.$placeholder
            }
        }

        private var channels: [(title: String, value: String)] {
            func channelValue(_ value: Float?) -> String {
                value.map { String(describing: Int($0 * 255)) } ?? "-"
            }

            let color = self.stop?.wrappedValue.color

            return [
                ("R", channelValue(color?[0])),
                ("G", channelValue(color?[1])),
                ("B", channelValue(color?[2])),
                ("A", channelValue(color?[3])),
            ]
        }
    }

    @State private var selectedStopID: UUID?
    @Binding private var gradient: Gradient
}
