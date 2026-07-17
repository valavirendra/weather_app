# Testing Documentation

This document describes the testing strategy, manual test scenarios, and validation suites for the WeatherNow application.

---

## 1. Testing Strategy

The application undergoes three levels of validation:
1. **Unit Testing**: Tests core business logic, model serialization (`Weather.fromJson`), and unit conversion methods.
2. **Widget Testing**: Validates UI layouts, rendering logic, and theme colors.
3. **Integration Testing**: Verifies hardware location calls and end-to-end API workflows.

---

## 2. Manual Test Scripts

Use the following test scenarios to manually verify location permissions, GPS status, and error handling states:

### Test Case 1: Location Services (GPS) Disabled on Launch
1. Disable GPS/location services on the test device.
2. Launch the WeatherNow app.
3. **Expected Behavior**: The app displays the **Enable Location** alert dialog.
   - Tap **Cancel**: The app loads default weather data for Tokyo.
   - Tap **Open Settings**: The app opens system location settings.

### Test Case 2: Location Permission Denied on First Launch
1. Grant the app location permissions, then clear all app data to reset permissions.
2. Ensure GPS is enabled.
3. Launch the app.
4. **Expected Behavior**: The app displays the location permission explanation dialog.
   - Tap **Cancel**: The app loads default weather data for Tokyo.
   - Tap **Grant**: The app displays the system location permission dialog.

### Test Case 3: Location Permission Permanently Denied
1. Open the device settings and deny location permission for the app permanently.
2. Launch the app.
3. **Expected Behavior**: The app displays the **Permission Required** settings redirect dialog.
   - Tap **Open Settings**: The app redirects you to its system settings page.

---

## 3. Running Automated Tests

Run the following command to execute the project's automated test suite:
```bash
flutter test
```
