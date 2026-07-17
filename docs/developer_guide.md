# Developer Guide

This guide details code architecture, project design guidelines, lifecycles, and code style standards for developers working on the WeatherNow application.

---

## 1. Code Guidelines and Styling Rules

- **Lint Compliance**: The project strictly conforms to standard Flutter and Dart code rules configured in `analysis_options.yaml`.
- **Constructors**: Declare widgets with `const` constructors wherever possible to optimize performance.
- **Null Safety**: Avoid using force-unwraps (`!`) unless safety assertions are validated.

---

## 2. Location & Permission State Lifecycles

Developers extending the permission check framework should refer to the code logic in `_getCurrentLocation` inside `lib/screens/weather_screen.dart`:

```dart
Future<void> _getCurrentLocation() async {
  setState(() => _isFetchingLocation = true);
  try {
    // 1. Check Location Service Status
    final isServiceEnabled = await _locationService.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      // Handle disabled service
      return;
    }
    
    // 2. Verify Permissions
    ph.PermissionStatus permission = await _permissionService.checkLocationPermission();
    if (permission == ph.PermissionStatus.denied) {
      // Prompt explain/request
    }
    
    // 3. Obtain Position
    if (permission == ph.PermissionStatus.granted) {
      final position = await _locationService.getCurrentPosition();
      // Fetch coordinates via WeatherProvider
    }
  } finally {
    if (mounted) setState(() => _isFetchingLocation = false);
  }
}
```

---

## 3. Extending Features

### Adding a New Weather Information Grid Cell
To add a new indicator tile (e.g. UV Index) to the dashboard:
1. Open [weather_model.dart](file:///c:/fluter/flutter/weather_app/lib/models/weather_model.dart) and add the field configuration to your JSON conversion models.
2. In [weather_screen.dart](file:///c:/fluter/flutter/weather_app/lib/screens/weather_screen.dart#L1041-L1086), append a new `WeatherInfoTile` entry inside `_buildDetailsGrid`:
   ```dart
   WeatherInfoTile(
     icon: Icons.wb_sunny_rounded,
     label: 'UV Index',
     value: '${weather.uvIndex}',
     iconColor: Colors.redAccent,
   )
   ```
3. Format and analyze changes:
   ```bash
   dart format lib
   flutter analyze
   ```
