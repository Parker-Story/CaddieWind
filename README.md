# CaddieWind 🧭

> A lightweight iOS compass that shows real-time wind direction and speed for golfers.

https://github.com/user-attachments/assets/027941eb-6a17-4c80-a2d3-96abf4fe8c69

---

## What it does

CaddieWind fetches live weather data for your current GPS location and overlays wind direction and speed onto a rotating compass face. Point your phone toward your target and the app tells you:

- **Wind speed** in mph
- **Wind direction** relative to where you're aiming
- **"Plays Like" yardage** - an adjusted distance that accounts for headwind, tailwind, and crosswind drift
- **Drift estimate** - how many yards left or right the wind will push the ball

You can also switch to a **manual wind direction mode** if you want to plan a shot without pointing the phone, or if the compass heading is unreliable.

---

## Tech Stack & Why

| Layer | Choice | Reasoning |
|-------|--------|-----------|
| **UI** | SwiftUI | Modern declarative framework with fast prototyping. As a first iOS project, SwiftUI's preview system and state-driven layout made it easy to iterate on the compass UI without wrestling with Auto Layout constraints. |
| **Language** | Swift 5.9 | Native iOS language with excellent type safety and first-party Apple support. |
| **Minimum iOS** | 15.0 | Balances modern SwiftUI APIs (like `.onChange`) with broad device coverage. |
| **Weather Data** | OpenWeatherMap (free tier) | Simple REST API, no OAuth complexity—just an API key. The free tier covers current weather, which is all a golfer needs before a shot. |
| **Project Management** | XcodeGen (`project.yml`) | Keeps the `.xcodeproj` file out of meaningful diffs. Adding new Swift files is just a filesystem operation; regenerating the project is one command. This avoids merge conflicts in Xcode's opaque project bundle. |
| **Architecture** | MVCL (lightweight) | Kept it simple: models → service → views. No external dependency injection framework needed for an app this size. |

---

## Solving the Magnetic Declination Problem

One of the trickiest parts of building an accurate compass is **true north vs. magnetic north**. iOS exposes both values via `CLHeading`:

- `trueHeading` - points to geographic north (what you want for aligning with wind data from a weather API)
- `magneticHeading` - points to magnetic north (varies by location and shifts over time)

The catch: `trueHeading` returns `-1` when location services are disabled or unavailable, which would silently break the compass. CaddieWind handles this by **falling back to `magneticHeading`** when true heading is invalid, and it filters out readings with negative `headingAccuracy` so the user never sees a wild, incorrect rotation.

This matters because wind data from OpenWeatherMap is relative to true north. If the compass showed magnetic north while the wind direction was reported in true north, the arrow could be off by 10–20 degrees depending on where you are in the world. Which is enough to make the "Plays Like" calculation misleading.

---

## Other Noteworthy Details

### Smooth Rotation Across the 0°/360° Boundary
SwiftUI's default `.rotationEffect` animation has a classic problem: if the compass rotates from 359° to 1°, it animates the long way around (358°) instead of the short way (2°). CaddieWind implements a **shortest-path angle interpolation** that keeps cumulative rotation state, so the compass always spins the shortest direction. The first real heading reading also snaps instantly to avoid a jarring sweep from 0° on app launch.

### Non-Linear Wind Effect Curve
A 10 mph headwind doesn't simply subtract a fixed number of yards. The impact varies with angle: a direct headwind hurts more than a quartering wind. `WindCalculator` uses an anchored, non-linear curve that models realistic headwind/tailwind effects and produces a range (`effectLow`/`effectHigh`) rather than a single number, acknowledging that real-world golf shots have variance.

### Club Presets for Quick Yardage Entry
Instead of typing a number, golfers can tap presets (Driver → SW) to instantly set a base distance. The slider and ±5 buttons handle fine-tuning.

### Manual Wind Direction Override
Sometimes you want to plan a shot without taking your phone out of your pocket. The circular **Wind Direction Selector** lets you tap "Into", "Down", "Cross L", etc., to manually set the relative wind angle. A one-tap "↻ Compass" button snaps back to the sensor-driven reading.

### Graceful Error Handling
The app distinguishes between **location-denied errors** (shows a helpful Settings message) and **transient heading failures** (silently ignores them so the UI doesn't flicker).

---

## Setup & Build

### Prerequisites
- macOS with Xcode 15+
- An iOS 15+ device or simulator
- A free [OpenWeatherMap API key](https://openweathermap.org/api)

### 1. Clone the repo
```bash
git clone https://github.com/yourusername/CaddieWind.git
cd CaddieWind
```

### 2. Add your API key
Copy the example config file and fill in your key:
```bash
cp Config.swift.example Config.swift
```
Then open `Config.swift` and paste your OpenWeatherMap API key.

> **Important:** `Config.swift` is listed in `.gitignore` so your API key never gets committed.

### 3. Regenerate the Xcode project
Because this repo uses XcodeGen, the `.xcodeproj` file is generated, not hand-maintained:
```bash
brew install xcodegen   # if you haven't already
xcodegen generate
```

### 4. Build & run
Open `CaddieWind.xcodeproj` in Xcode, select your target device or simulator, and press `Cmd + R`.

---

## A Note on This Project

This was my **first iOS/Swift project**. I built it to solve a real problem I had on the golf course—trying to feel the wind and guess how it would affect my club selection. Building CaddieWind taught me how to bridge SwiftUI state with CoreLocation, handle REST API decoding, and deal with the subtle edge cases of compass UI animation. There's plenty I'd refactor now, but it works, and it genuinely helps me play better golf and it's fun to use and watch my family use when we're out there playing.

---

*Built with ⛳ and a lot of trial and error.*
