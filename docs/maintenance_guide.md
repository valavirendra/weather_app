# Maintenance and Troubleshooting Guide

This guide provides instructions for maintaining and troubleshooting the WeatherNow codebase.

---

## 1. Troubleshooting Guide

Below are common issues developers or users may encounter, along with their solutions:

### Issue 1: App freezes on the custom loading screen
- **Cause**: Location services (GPS) or permission request queries did not return a response.
- **Solution**: Restart the application. If the issue persists, verify that location services are enabled on your device.

### Issue 2: Location permissions explanation dialog displays repeatedly on start
- **Cause**: Permission checking returned `denied` instead of updating the status flag on dismissal.
- **Solution**: Clear the application storage data and reset location permission request prompts.

---

## 2. Frequently Asked Questions (FAQ)

### Q: Why does the app show weather for Tokyo when launching?
- **A**: This is the default fallback city. If location permissions or location services are disabled, the app displays weather data for Tokyo.

### Q: Can I run this application offline?
- **A**: Yes. If you are offline, the app automatically generates simulated weather data based on your query or location coordinates.

---

## 3. Maintenance Guidelines

### Updating Project Packages
To upgrade all packages to their latest compatible versions:
1. Run the outdated checker:
   ```bash
   flutter pub outdated
   ```
2. Upgrade packages:
   ```bash
   flutter pub upgrade
   ```
3. Run the code analyzer to verify compatibility:
   ```bash
   flutter analyze
   ```

---

## 4. Glossary

- **Glassmorphism**: A UI design trend characterized by semi-transparent, frosted-glass-like elements.
- **Provider**: A state management package for Flutter that uses change notification objects to update widgets.
- **M3 (Material 3)**: The latest version of Google's open-source design system.
- **Geolocator**: A Flutter plugin that provides access to platform-specific location services.
