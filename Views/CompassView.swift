import SwiftUI

struct CompassView: View {
    let windDirection: Double
    let windSpeed: Double
    /// Device heading in degrees clockwise from true north.
    /// The whole compass face rotates by `-heading` so N always points true north.
    var heading: Double = 0

    // Cumulative angles used to ensure rotation always takes the shortest path
    // (SwiftUI's rotationEffect animation otherwise sweeps the long way around
    // when crossing the 0°/360° boundary).
    @State private var displayedHeading: Double = 0
    @State private var displayedWindDirection: Double = 0
    @State private var hasInitializedHeading = false
    @State private var hasInitializedWind = false

    var body: some View {
        ZStack {
            // Rotating compass face (ticks + cardinal labels + arrow spin together)
            ZStack {
                // Outer thin ring
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 300, height: 300)

                // Inner ring
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 230, height: 230)

                // Degree tick marks (every 15 degrees)
                ForEach(Array(stride(from: 0, to: 360, by: 15)), id: \.self) { degree in
                    Rectangle()
                        .fill(Color.white.opacity(degree % 90 == 0 ? 0.9 : (degree % 45 == 0 ? 0.5 : 0.25)))
                        .frame(
                            width: degree % 90 == 0 ? 2 : 1,
                            height: degree % 90 == 0 ? 14 : (degree % 45 == 0 ? 10 : 6)
                        )
                        .offset(y: -143)
                        .rotationEffect(.degrees(Double(degree)))
                }

                // Cardinal direction labels
                ForEach(["N", "E", "S", "W"], id: \.self) { direction in
                    Text(direction)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(direction == "N" ? .white : .white.opacity(0.6))
                        .position(cardinalPosition(for: direction))
                }

                // Wind direction indicator (arrow) — rotates with the face
                WindArrow(angle: displayedWindDirection + 180)
                    .frame(width: 200, height: 200)
            }
            .frame(width: 300, height: 300)
            .rotationEffect(.degrees(-displayedHeading))
            .animation(.linear(duration: 0.2), value: displayedHeading)
            .animation(.easeInOut(duration: 0.6), value: displayedWindDirection)

            // Fixed center dot (does not rotate with the face)
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)

            // Fixed top-of-screen marker showing "where the phone is pointed"
            CompassHeadingMarker()
                .fill(Color.white.opacity(0.9))
                .frame(width: 10, height: 8)
                .offset(y: -162)
        }
        .frame(width: 340, height: 340)
        .onAppear {
            displayedHeading = heading
            displayedWindDirection = windDirection
        }
        .onChange(of: heading) { newValue in
            // Snap (no animation) on the first real reading to avoid a jarring
            // sweep from 0° to the user's actual heading.
            if !hasInitializedHeading {
                hasInitializedHeading = true
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) {
                    displayedHeading = newValue
                }
                return
            }
            displayedHeading = shortestPathAngle(from: displayedHeading, to: newValue)
        }
        .onChange(of: windDirection) { newValue in
            if !hasInitializedWind {
                hasInitializedWind = true
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) {
                    displayedWindDirection = newValue
                }
                return
            }
            displayedWindDirection = shortestPathAngle(from: displayedWindDirection, to: newValue)
        }
    }

    private func cardinalPosition(for direction: String) -> CGPoint {
        let radius: CGFloat = 128
        let center = CGPoint(x: 150, y: 150)

        let angle: Double
        switch direction {
        case "N": angle = 0
        case "E": angle = 90
        case "S": angle = 180
        case "W": angle = 270
        default: angle = 0
        }

        let radians = (angle - 90) * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(cos(radians)),
            y: center.y + radius * CGFloat(sin(radians))
        )
    }

    /// Returns a new cumulative angle near `current` that is equivalent (mod 360)
    /// to `target` but reached via the shortest angular delta. This keeps
    /// `.animation` from taking the long way around 0°/360°.
    private func shortestPathAngle(from current: Double, to target: Double) -> Double {
        let delta = ((target - current).truncatingRemainder(dividingBy: 360) + 540)
            .truncatingRemainder(dividingBy: 360) - 180
        return current + delta
    }
}

struct WindArrow: View {
    /// Rotation in degrees where 0 = arrow pointing up (toward N on the compass face).
    let angle: Double

    var body: some View {
        ArrowShape()
            .fill(
                LinearGradient(
                    colors: [Color.cyan, Color.blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 18, height: 110)
            .rotationEffect(.degrees(angle))
    }
}

/// A slim, tapered arrow pointing up by default.
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Tip
        path.move(to: CGPoint(x: w / 2, y: 0))
        // Right shoulder
        path.addLine(to: CGPoint(x: w, y: h * 0.35))
        // Right notch
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.35))
        // Right tail
        path.addLine(to: CGPoint(x: w * 0.62, y: h))
        // Left tail
        path.addLine(to: CGPoint(x: w * 0.38, y: h))
        // Left notch
        path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.35))
        // Left shoulder
        path.addLine(to: CGPoint(x: 0, y: h * 0.35))
        path.closeSubpath()
        return path
    }
}

/// Small downward-pointing triangle used as the fixed "you are here" marker
/// at the top of the compass.
struct CompassHeadingMarker: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CompassView(windDirection: 45, windSpeed: 10, heading: 0)
    }
}
