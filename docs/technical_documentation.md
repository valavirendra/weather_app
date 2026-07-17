# Technical Documentation

This document describes the technical implementation details, architectural choices, and structural patterns of the WeatherNow application.

---

## 1. System Architecture Diagram

```mermaid
graph TD
    subgraph Presentation Layer
        UI[Widgets/Screens] --> State[WeatherProvider]
    end
    subgraph Application Service Layer
        State --> LS[LocationService]
        State --> PS[PermissionService]
    end
    subgraph Data Layer
        State --> API[OpenWeatherMap API]
    end
```

---

## 2. Widget Hierarchy

The UI follows a unidirectional hierarchy:
- `MyApp` ([app.dart](file:///c:/fluter/flutter/weather_app/lib/app.dart))
  - `MaterialApp`
    - `SplashScreen` ([splash_screen.dart](file:///c:/fluter/flutter/weather_app/lib/screens/splash_screen.dart))
      - Navigate to `WeatherScreen` ([weather_screen.dart](file:///c:/fluter/flutter/weather_app/lib/screens/weather_screen.dart))
        - `LoadingScreen` ([loading_screen.dart](file:///c:/fluter/flutter/weather_app/lib/screens/loading_screen.dart)) (while loading)
        - `SavedLocationsDrawer` ([saved_locations_drawer.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/saved_locations_drawer.dart))
        - `GlassContainer` ([glass_container.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/glass_container.dart))
          - `HourlyForecastCard` ([hourly_forecast_card.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/hourly_forecast_card.dart))
          - `DailyForecastList` ([daily_forecast_list.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/daily_forecast_list.dart))
          - `SunriseSunsetVisual` ([sunrise_sunset_visual.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/sunrise_sunset_visual.dart))
          - `WeatherInfoTile` ([weather_info_tile.dart](file:///c:/fluter/flutter/weather_app/lib/widgets/weather_info_tile.dart))

---

## 3. Application Workflow Sequence

The diagram below details the sequence of location query, permissions verification, and coordinate request during application startup.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant App as WeatherScreen
    participant PM as PermissionService
    participant LM as LocationService
    participant State as WeatherProvider

    App->>LM: isLocationServiceEnabled()
    LM-->>App: Service Status (Enabled/Disabled)
    alt GPS Disabled
        App->>User: Show M3 GPS Activation Request Dialog
    end

    App->>PM: checkLocationPermission()
    PM-->>App: Current PermissionStatus
    alt Permission Denied
        App->>User: Show Explanation Dialog
        App->>PM: requestLocationPermission()
        PM-->>App: New PermissionStatus
    else Permission Permanently Denied
        App->>User: Show Settings Redirect Dialog
        App->>PM: openSettings()
    end

    alt Permission Granted
        App->>LM: getCurrentPosition()
        LM-->>App: Latitude, Longitude
        App->>State: fetchWeatherByCoords(lat, lon)
        State-->>App: WeatherState.loaded
    end
```

---

## 4. State Management (Provider)

WeatherNow uses the `provider` library to orchestrate state updates:
- **WeatherProvider** holds application state variables: `state`, `weather`, `errorMessage`, `lastCity`, `isCelsius`, and `savedCities`.
- It notifies consumers of adjustments via `notifyListeners()`.
- It integrates fallback mechanisms to provide realistic weather simulations when remote servers are unreachable.

---

## 5. Navigation Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Splash: Application Launch
    Splash --> WeatherScreen: Fade Transition after 2.8s
    
    state WeatherScreen {
        [*] --> CheckingLocation
        CheckingLocation --> LoadingOverlay: Fetching Location
        LoadingOverlay --> WeatherDetails: Location Resolved
        LoadingOverlay --> TokyoDefault: Permission / GPS Refused
        
        WeatherDetails --> SearchSubmit: Query City
        SearchSubmit --> LoadingOverlay: API Call
        
        WeatherDetails --> DrawerLocations: Toggle Drawer
        DrawerLocations --> WeatherDetails: Select Saved Location
    }
```

---

## 6. Theme and Contrast Management

We employ a dark mode configuration leveraging standard Material 3 color tokens:
- **Primary background**: Deep charcoal/midnight tone `0xFF0F0E17`.
- **Dynamic Accent Glows**: Custom radial gradients generated according to current weather status:
  - **Sunny**: `#0072FF` to `#00C6FF` (Sky cyan-blue)
  - **Rainy**: `#4776E6` to `#8E54E9` (Deep violet-indigo)
  - **Snowy**: `#4481EB` to `#04BEFE` (Icy blue-cyan)
  - **Stormy**: `#1A0533` to `#3D0C5E` (Charcoal purple)
- Contrast compliance is maintained through semitransparent layers with solid text colors, passing WCAG AAA scaling tests.
