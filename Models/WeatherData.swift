import Foundation

// MARK: - OpenWeatherMap API Response Models

struct WeatherResponse: Codable {
    let wind: Wind
    let name: String
}

struct Wind: Codable {
    let speed: Double  // in mph (because we'll request imperial units)
    let deg: Int       // wind direction in degrees
}