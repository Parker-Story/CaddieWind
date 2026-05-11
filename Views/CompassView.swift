import SwiftUI

struct CompassView: View {
    let windDirection: Double
    let windSpeed: Double

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            // Compass ring with cardinal directions
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 280, height: 280)

            // Cardinal direction labels
            ForEach(["N", "E", "S", "W"], id: \.self) { direction in
                Text(direction)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .position(cardinalPosition(for: direction))
            }

            // Degree markers (every 30 degrees)
            ForEach(Array(stride(from: 0, to: 360, by: 30)), id: \.self) { degree in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2, height: degree % 90 == 0 ? 15 : 8)
                    .offset(y: -130)
                    .rotationEffect(.degrees(Double(degree)))
            }

            // Wind direction indicator (arrow)
            WindArrow(direction: windDirection)
                .frame(width: 200, height: 200)

            // Center circle
            Circle()
                .fill(Color.green)
                .frame(width: 20, height: 20)
                .shadow(radius: 3)
        }
        .rotationEffect(.degrees(-windDirection))
    }

    private func cardinalPosition(for direction: String) -> CGPoint {
        let radius: CGFloat = 115
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
        ZStack {
            // Arrow pointing in wind direction
            Image(systemName: "location.north.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .rotationEffect(.degrees(180)) // Point opposite of where wind comes from
                .frame(width: 60, height: 60)

            // Wind "blowing from" indicator
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                .frame(width: 250, height: 250)
        }
    }
}

#Preview {
    CompassView(windDirection: 45, windSpeed: 10)
}