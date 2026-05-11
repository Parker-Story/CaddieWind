# CaddieWind - Project Context

## Project Overview
- **Name**: CaddieWind
- **Type**: iOS Mobile App (SwiftUI)
- **Core Feature**: A compass that shows wind direction and speed in mph for golfers
- **Target Users**: Golfers who need wind information on the course
- Keep files modular and around at most 600 lines

## Technical Stack
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Minimum iOS**: 15.0
- **Weather API**: OpenWeatherMap (free tier)
- **Architecture**: Simple MVCL (Model-View-Controller lightweight)

## Current Project State
- `project.yml` exists (XcodeGen configuration)
- `App/WindCompassApp.swift` exists (app entry point, references ContentView)
- **Missing**: ContentView.swift, models, API service, compass UI

## Key Requirements
1. **Wind Data**: Fetch real-time wind from OpenWeatherMap API
2. **Compass UI**: Show wind direction visually on a compass
3. **Wind Speed**: Display speed in mph
4. **Location**: Use device GPS to get location for accurate wind data

## API Setup
- User needs to sign up at https://openweathermap.org/api
- Get a free API key
- API endpoint: `https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=imperial`

## Testing Requirements
- **Required**: A Mac with Xcode installed (iOS development requires macOS)
- Can test on iOS Simulator (built into Xcode) or physical device
- For physical device: need an Apple Developer account ($99/year) to run apps, or use free provisioning with limitations

## User Context
- This is the user's first iOS/Swift project
- They need guidance on setup and testing

## Next Steps
1. Create the Swift source files (models, API service, views)
2. Guide user to get Xcode and an OpenWeatherMap API key
3. Build and test the app