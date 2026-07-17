# Installation Guide

This guide details the step-by-step setup procedure to install, configure, and execute the WeatherNow project locally.

---

## 1. Prerequisites

Ensure your development environment matches the target platform requirements:

| Tool | Version Requirement | Purpose |
|------|---------------------|---------|
| Flutter SDK | `^3.11.3` | Mobile app compilation framework |
| Dart SDK | `^3.11.3` | Core programming language environment |
| Android Studio / VS Code | Recommended | IDE containing Flutter & Dart extensions |
| Android SDK Platform | API Level 34+ | Compilation tools for Android builds |
| Xcode | 15.0+ (macOS only) | Compilation tools for iOS builds |

---

## 2. Setting Up the Project

Follow these steps to set up the codebase:

### Step 2.1: Clone the Codebase
Clone the source code repository to your local directory:
```bash
git clone https://github.com/your-repo/weather_app.git
cd weather_app
```

### Step 2.2: Download Application Dependencies
Fetch the required package configurations configured in `pubspec.yaml`:
```bash
flutter pub get
```

### Step 2.3: Configure API Keys
The application contains a built-in fallback mock mechanism. However, to fetch real-time forecasts:
1. Register for a free account at [OpenWeatherMap API Portal](https://openweathermap.org/api).
2. Generate your API key.
3. Open [weather_provider.dart](file:///c:/fluter/flutter/weather_app/lib/providers/weather_provider.dart) and update the `_apiKey` variable at line 13:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

---

## 3. Launching the App

### Option A: VS Code
1. Open the project root folder in VS Code.
2. Select your mobile emulator/simulator or physical testing device.
3. Open `lib/main.dart` and press `F5` to start debugging.

### Option B: Terminal Command Line
1. Identify connected hardware:
   ```bash
   flutter devices
   ```
2. Execute the run command target:
   ```bash
   flutter run
   ```
