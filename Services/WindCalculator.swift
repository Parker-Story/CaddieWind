import Foundation

enum WindCalculator {
    // Nonlinear effect curve: fraction of wind speed that acts as headwind.
    // Positive = headwind (hurts distance), negative = tailwind (helps distance).
    private static let effectAnchors: [(angle: Double, effect: Double)] = [
        (0, 1.0),
        (45, 0.7),
        (90, 0.1),
        (135, -0.4),
        (180, -0.5),
        (225, -0.4),
        (270, 0.1),
        (315, 0.7)
    ]

    static func getWindImpact(windSpeedMph: Double, windAngleDeg: Double, baseYards: Double) -> WindImpact {
        let angle = normalizedAngle(windAngleDeg)

        // Effective headwind component via nonlinear anchor curve
        let effectFraction = interpolatedEffect(angle: angle)
        let effectiveMph = windSpeedMph * effectFraction

        // Distance adjustment
        let adjustment: Double
        if effectiveMph > 0 {
            // Headwind: base 0.012, +0.5% multiplier for each mph over 15
            let over15 = max(0, effectiveMph - 15)
            let multiplier = 1.0 + (over15 * 0.005)
            adjustment = effectiveMph * 0.012 * multiplier * baseYards / 100.0
        } else {
            // Tailwind: half the headwind coefficient
            adjustment = effectiveMph * 0.006 * baseYards / 100.0
        }

        let playsLike = baseYards + adjustment

        // Range: ±15% around the calculated wind adjustment
        let effectLow = Int(round(adjustment * 0.85))
        let effectHigh = Int(round(adjustment * 1.15))

        // Drift (crosswind component)
        let angleRad = angle * .pi / 180
        // Using 1.2 coefficient to align with spec's stated ~12 yds drift for
        // 10mph crosswind at 150yd. (0.08 as written would yield ~0.8 yds.)
        let drift = windSpeedMph * abs(sin(angleRad)) * 1.2 * (baseYards / 150.0)
        let driftYards = Int(round(drift))

        return WindImpact(
            playsLike: Int(round(playsLike)),
            effectLow: effectLow,
            effectHigh: effectHigh,
            driftYards: driftYards
        )
    }

    // MARK: - Private helpers

    private static func normalizedAngle(_ angle: Double) -> Double {
        fmod(fmod(angle, 360) + 360, 360)
    }

    private static func interpolatedEffect(angle: Double) -> Double {
        let norm = normalizedAngle(angle)

        // Exact match
        if let exact = effectAnchors.first(where: { abs($0.angle - norm) < 0.001 }) {
            return exact.effect
        }

        // Find enclosing anchor segment and linearly interpolate
        for i in 0..<effectAnchors.count {
            let current = effectAnchors[i]
            let next = effectAnchors[(i + 1) % effectAnchors.count]

            var currentAngle = current.angle
            var nextAngle = next.angle
            if nextAngle < currentAngle {
                nextAngle += 360
            }

            var testAngle = norm
            if testAngle < currentAngle {
                testAngle += 360
            }

            if testAngle >= currentAngle && testAngle <= nextAngle {
                let fraction = (testAngle - currentAngle) / (nextAngle - currentAngle)
                return current.effect + (next.effect - current.effect) * fraction
            }
        }

        // Fallback (should never reach here)
        return cos(norm * .pi / 180)
    }


}
