import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Title
                Text("CaddieWind")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.top, 40)

                // Location name
                if !weatherService.locationName.isEmpty {
                    Text(weatherService.locationName)
                        .font(.title3)
                        .foregroundColor(.gray)
                }

                // Compass
                ZStack {
                    if weatherService.isLoading {
                        ProgressView("Loading wind data...")
                            .scaleEffect(1.5)
                    } else if let error = weatherService.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                            Button("Try Again") {
                                weatherService.requestLocation()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                        .padding()
                    } else if weatherService.windSpeed > 0 || weatherService.windDirection > 0 {
                        CompassView(
                            windDirection: weatherService.windDirection,
                            windSpeed: weatherService.windSpeed
                        )
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "location")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Tap below to get wind info")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 300)

                // Wind speed display
                if weatherService.windSpeed > 0 {
                    VStack(spacing: 5) {
                        Text("\(Int(weatherService.windSpeed))")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.blue)
                        Text("mph")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }

                // Refresh button
                Button(action: {
                    weatherService.requestLocation()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.bottom, 40)

                Spacer()
            }
        }
        .onAppear {
            weatherService.requestLocation()
        }
    }
}

#Preview {
    ContentView()
}