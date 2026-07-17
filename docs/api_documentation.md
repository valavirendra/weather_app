# API Documentation

This document describes the application program interfaces, core service classes, and data provider APIs.

---

## 1. Class: PermissionService

- **Path**: `lib/services/permission_service.dart`
- **Purpose**: Manages system location permission queries.
- **Dependencies**: `package:permission_handler`

### Methods

#### `checkLocationPermission`
- **Returns**: `Future<PermissionStatus>`
- **Description**: Returns the current status of the location permission.

#### `requestLocationPermission`
- **Returns**: `Future<PermissionStatus>`
- **Description**: Displays the platform permission dialog to the user.

---

## 2. Class: LocationService

- **Path**: `lib/services/location_service.dart`
- **Purpose**: Interacts with the device GPS hardware to retrieve coordinates.
- **Dependencies**: `package:geolocator`

### Methods

#### `isLocationServiceEnabled`
- **Returns**: `Future<bool>`
- **Description**: Checks if GPS/location services are enabled on the device.

#### `getCurrentPosition`
- **Returns**: `Future<Position>`
- **Description**: Queries current coordinate points with a 10-second request timeout limit.

---

## 3. Class: WeatherProvider

- **Path**: `lib/providers/weather_provider.dart`
- **Purpose**: Manages the application's weather data state and handles OpenWeatherMap API integrations.
- **Dependencies**: `package:http`, `package:provider`

### Methods

#### `fetchWeatherByCity`
- **Parameters**: `String city`
- **Returns**: `Future<void>`
- **Description**: Fetches current weather for the specified city. Falls back to simulated weather if the city is not found or a network error occurs.

#### `fetchWeatherByCoords`
- **Parameters**: `double lat`, `double lon`
- **Returns**: `Future<void>`
- **Description**: Fetches weather data for the specified coordinates. Falls back to simulated weather if the request fails.

---

## 4. OpenWeatherMap API Contract

The application calls the following external endpoints:

### Current Weather Request
- **Endpoint**: `https://api.openweathermap.org/data/2.5/weather`
- **Query Parameters**:
  - `q`: City query parameter (e.g. `New York`).
  - `lat` / `lon`: Coordinate query parameters.
  - `appid`: API developer key.
- **Success Response Code**: `200 OK`
- **Fallback Behavior**: When offline or if an API failure occurs, the app automatically falls back to a simulated weather dataset to keep the UI functional.
