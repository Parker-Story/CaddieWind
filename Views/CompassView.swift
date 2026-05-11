import SwiftUI

struct CompassView: View {
    let windDirection: Double
    let windSpeed: Double

    var body: some View {
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

            // Wind direction indicator (arrow)
            WindArrow(direction: windDirection)
                .frame(width: 200, height: 200)

            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        .frame(width: 300, height: 300)
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
}

struct WindArrow: View {
    let direction: Double

    var body: some View {
        // Slim arrow pointing in the direction the wind is blowing TOWARD
        // (wind `direction` is the bearing the wind comes FROM, so rotate +180)
        ArrowShape()
            .fill(
                LinearGradient(
                    colors: [Color.cyan, Color.blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 18, height: 110)
            .rotationEffect(.degrees(direction + 180))
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

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CompassView(windDirection: 45, windSpeed: 10)
    }
}
