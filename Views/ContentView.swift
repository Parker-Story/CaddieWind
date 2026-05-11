import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()

    var body: some View {
        ZStack {
            // Full-bleed black background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
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
                .frame(maxWidth: .infinity, minHeight: 300)

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

                Spacer()
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
