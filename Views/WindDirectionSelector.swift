import SwiftUI

struct WindDirectionSelector: View {
    @Binding var selectedAngle: Double
    @Binding var isManual: Bool
    let compassAngle: Double

    private let positions: [(angle: Double, label: String)] = [
        (0, "Into"),
        (45, "Q-Head L"),
        (90, "Cross L"),
        (135, "Q-Tail L"),
        (180, "Down"),
        (225, "Q-Tail R"),
        (270, "Cross R"),
        (315, "Q-Head R")
    ]

    private let radius: CGFloat = 60

    var body: some View {
        let displayAngle = snapToAnchor(isManual ? selectedAngle : compassAngle)

        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: radius * 2 + 28, height: radius * 2 + 28)

            // Position buttons arranged around the ring
            ForEach(0..<positions.count, id: \.self) { i in
                let pos = positions[i]
                let rad = CGFloat((pos.angle - 90) * .pi / 180)
                let selected = isSelected(pos.angle, displayAngle: displayAngle)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedAngle = pos.angle
                        isManual = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(selected ? Color.cyan : Color.white.opacity(0.25))
                            .frame(width: selected ? 12 : 8, height: selected ? 12 : 8)

                        Text(pos.label)
                            .font(.system(size: 9, weight: selected ? .semibold : .medium, design: .rounded))
                            .foregroundColor(selected ? .white : .white.opacity(0.55))
                            .lineLimit(1)
                    }
                    .frame(width: 36, height: 22)
                }
                .offset(x: cos(rad) * radius, y: sin(rad) * radius)
                .contentShape(Rectangle())
            }

            // Center label + reset
            VStack(spacing: 3) {
                Text(angleLabel(displayAngle))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if isManual {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isManual = false
                        }
                    } label: {
                        Text("↻ Compass")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.cyan)
                    }
                }
            }
        }
        .frame(width: 160, height: 160)
    }

    // MARK: - Helpers

    private func isSelected(_ angle: Double, displayAngle: Double) -> Bool {
        let diff = angularDistance(angle, displayAngle)
        return diff < 22.5
    }

    private func snapToAnchor(_ angle: Double) -> Double {
        let norm = normalizedAngle(angle)
        let closest = positions.min { a, b in
            angularDistance(a.angle, norm) < angularDistance(b.angle, norm)
        }
        return closest?.angle ?? norm
    }

    private func angleLabel(_ angle: Double) -> String {
        let norm = normalizedAngle(angle)
        let closest = positions.min { a, b in
            angularDistance(a.angle, norm) < angularDistance(b.angle, norm)
        }
        if let closest = closest, angularDistance(closest.angle, norm) < 22.5 {
            return closest.label
        }
        return "\(Int(round(norm)))°"
    }

    private func normalizedAngle(_ angle: Double) -> Double {
        fmod(fmod(angle, 360) + 360, 360)
    }

    private func angularDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return min(diff, 360 - diff)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WindDirectionSelector(
            selectedAngle: .constant(45),
            isManual: .constant(true),
            compassAngle: 42
        )
    }
}
