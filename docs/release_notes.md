# Release Notes

## WeatherNow Version 1.1.0 (Initial Production Release)

We are excited to release WeatherNow, a premium, production-ready weather application featuring high-fidelity glassmorphic visual widgets and robust permissions handling.

---

## What's New

### 1. Custom Animated Splash Screen
The application now launches directly into an animated splash screen, replacing the default native splash. This screen features a smooth fade-in and scale logo animation.

### 2. Live Location-Based Forecasts
On startup, the app automatically checks your device's location settings:
- Detects if location services (GPS) are enabled.
- Handles location permission requests cleanly.
- Fetches and displays weather forecasts for your current coordinates.

### 3. Beautiful Error & Fallback Dialogs
Features Material 3 alerts to guide users through enabling location permissions and settings redirects. Includes a simulated weather dataset to keep the app functional when offline or when API limits are reached.

---

## Known Issues
- Location services verification may return false on web platforms (Chrome). The app handles this by querying location permissions directly.
