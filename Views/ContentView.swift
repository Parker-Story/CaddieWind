import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()

    @State private var baseYards: Double = 150
    @State private var manualAngle: Double = 0
    @State private var isManualAngle: Bool = false

    private let clubPresets: [(club: String, yards: Int)] = [
        ("Driver", 250),
        ("3W", 220),
        ("5W", 200),
        ("4I", 180),
        ("6I", 160),
        ("8I", 140),
        ("9I", 130),
        ("PW", 115),
        ("SW", 85)
    ]

    private var compassAngle: Double {
        let raw = weatherService.windDirection - weatherService.heading
        return fmod(fmod(raw, 360) + 360, 360)
    }

    private var effectiveAngle: Double {
        isManualAngle ? manualAngle : compassAngle
    }

    private var windImpact: WindImpact? {
        guard weatherService.windSpeed > 0, baseYards > 0 else { return nil }
        return WindCalculator.getWindImpact(
            windSpeedMph: weatherService.windSpeed,
            windAngleDeg: effectiveAngle,
            baseYards: baseYards
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("CaddieWind")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // Location name
                    if !weatherService.locationName.isEmpty {
                        Text(weatherService.locationName.uppercased())
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Compass
                    ZStack {
                        if weatherService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else if let error = weatherService.errorMessage {
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(.orange)
                                Text(error)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.7))
                                Button("Try Again") {
                                    weatherService.requestLocation()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.black)
                            }
                            .padding()
                        } else if weatherService.windSpeed > 0 || weatherService.windDirection > 0 {
                            CompassView(
                                windDirection: weatherService.windDirection,
                                windSpeed: weatherService.windSpeed,
                                heading: weatherService.heading
                            )
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "location")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("Tap below to get wind info")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 280)

                    // Wind speed display
                    if weatherService.windSpeed > 0 {
                        VStack(spacing: 2) {
                            Text("\(Int(weatherService.windSpeed))")
                                .font(.system(size: 72, weight: .thin, design: .rounded))
                                .foregroundColor(.white)
                            Text("MPH")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // Plays Like section
                    if weatherService.windSpeed > 0 {
                        VStack(spacing: 16) {
                            // Yardage input
                            VStack(spacing: 10) {
                                Text("Base Yards")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))

                                HStack(spacing: 16) {
                                    Button {
                                        baseYards = max(50, baseYards - 5)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(.white.opacity(0.6))
                                    }

                                    Text("\(Int(baseYards))")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(minWidth: 80)

                                    Button {
                                        baseYards = min(300, baseYards + 5)
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }

                                Slider(value: $baseYards, in: 50...300, step: 1)
                                    .tint(.cyan)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(clubPresets.indices, id: \.self) { i in
                                            let preset = clubPresets[i]
                                            Button {
                                                baseYards = Double(preset.yards)
                                            } label: {
                                                Text(preset.club)
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                    .foregroundColor(baseYards == Double(preset.yards) ? .black : .white.opacity(0.8))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(baseYards == Double(preset.yards) ? Color.cyan : Color.white.opacity(0.12))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }

                            // Wind direction selector
                            WindDirectionSelector(
                                selectedAngle: $manualAngle,
                                isManual: $isManualAngle,
                                compassAngle: compassAngle
                            )

                            // Results
                            if let impact = windImpact {
                                VStack(spacing: 4) {
                                    Text("Plays Like: \(impact.playsLike) yds")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)

                                    HStack(spacing: 6) {
                                        let low = min(impact.effectLow, impact.effectHigh)
                                        let high = max(impact.effectLow, impact.effectHigh)

                                        if low == 0 && high == 0 {
                                            Text("Negligible wind effect")
                                                .foregroundColor(.white.opacity(0.6))
                                        } else if low >= 0 {
                                            if low == high {
                                                Text("Est. wind effect: +\(low) yds longer")
                                            } else {
                                                Text("Est. wind effect: +\(low)–\(high) yds longer")
                                            }
                                        } else if high <= 0 {
                                            let absLow = abs(low)
                                            let absHigh = abs(high)
                                            let shorterLow = min(absLow, absHigh)
                                            let shorterHigh = max(absLow, absHigh)
                                            if shorterLow == shorterHigh {
                                                Text("Est. wind effect: \(shorterLow) yds shorter")
                                            } else {
                                                Text("Est. wind effect: \(shorterLow)–\(shorterHigh) yds shorter")
                                            }
                                        } else {
                                            Text("Est. wind effect: \(low) to \(high) yds")
                                        }

                                        if impact.driftYards > 0 {
                                            Text("|")
                                                .foregroundColor(.white.opacity(0.3))

                                            let angleRad = effectiveAngle * .pi / 180
                                            let direction = sin(angleRad) > 0 ? "left" : "right"
                                            Text("Drift: aim \(impact.driftYards) yds \(direction)")
                                        }
                                    }
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                }
                            } else {
                                Text("Enter a base yardage to see wind effect")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Refresh button
                    Button(action: {
                        weatherService.requestLocation()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .padding(.bottom, 40)

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            weatherService.requestLocation()
        }
    }
}

#Preview {
    ContentView()
}
