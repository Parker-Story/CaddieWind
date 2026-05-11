import Foundation
import CoreLocation

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var windSpeed: Double = 0
    @Published var windDirection: Double = 0
    @Published var locationName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// Device heading in degrees clockwise from true north (0...360).
    /// 0 = user pointing the top of their phone at true north.
    @Published var heading: Double = 0

    private let locationManager = CLLocationManager()
    private let apiKey = Config.openWeatherMapAPIKey

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Update heading on every 1° change for smooth compass rotation
        locationManager.headingFilter = 1
        // Treat the top of the device as "forward" for heading
        locationManager.headingOrientation = .portrait
    }

    func requestLocation() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            startHeadingUpdatesIfAvailable()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }

    private func startHeadingUpdatesIfAvailable() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    deinit {
        locationManager.stopUpdatingHeading()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Heading errors also land here; don't clobber UI with transient heading failures
        let nsError = error as NSError
        if nsError.domain == kCLErrorDomain && nsError.code == CLError.headingFailure.rawValue {
            return
        }
        errorMessage = "Failed to get location: \(error.localizedDescription)"
        isLoading = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // trueHeading is -1 when unavailable (e.g. location services off); fall back to magnetic.
        let value = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        // Only accept reasonably accurate readings (headingAccuracy < 0 means invalid)
        guard newHeading.headingAccuracy >= 0 else { return }
        heading = value
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
            startHeadingUpdatesIfAvailable()
        }
    }

    private func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        errorMessage = nil

        // Using imperial units for mph
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(WeatherResponse.self, from: data)

                    self?.windSpeed = response.wind.speed
                    self?.windDirection = Double(response.wind.deg)
                    self?.locationName = response.name
                } catch {
                    self?.errorMessage = "Failed to parse weather data"
                }
            }
        }.resume()
    }
}
