# Changelog

All notable changes to the WeatherNow project are documented in this file.

---

## [1.1.0] - 2026-07-17

### Added
- Created custom `SplashScreen` featuring scale-up and fade-in animations with a progress indicator.
- Created custom `LoadingScreen` displaying location status.
- Added `PermissionService` using `permission_handler` to manage permissions cleanly.
- Added `LocationService` using `geolocator` to query device coordinates.

### Fixed
- Fixed initialization bug where location updates were blocked by `_isFetchingLocation` flag on startup.
- Fixed RenderFlex row layout overflow (8.3 pixels) in `DailyForecastList`.
- Fixed RenderFlex text layout overflow in `WeatherInfoTile` on small screens.
- Cleaned up deprecated `withOpacity` usages and replaced them with `withValues(alpha: ...)`.
- Enclosed single-line conditional statements inside curly braces to pass lint analyzer rules.

---

## [1.0.0] - 2026-07-17
- Initial release featuring dashboard UI, saved locations drawer, unit switcher, and OpenWeatherMap simulation engine.
