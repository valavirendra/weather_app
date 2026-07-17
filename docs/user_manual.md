# User Manual

This manual provides an operational overview of the WeatherNow application's features and user interfaces.

---

## 1. Application Launch Flow

Upon launch, the application displays a gradient splash screen featuring a pulsing weather icon and a progress indicator.

```
+---------------------------------------+
|                                       |
|             (  *  )                   |
|           Sunny Logo                  |
|                                       |
|           WeatherNow                  |
|     Real-time Weather Forecast        |
|                                       |
|              [---]                    |
|             Loading                   |
+---------------------------------------+
```

---

## 2. Location Services and Permissions Flow

1. **Service Verification**: The app checks if GPS is enabled on your device.
   - If GPS is disabled, you will see a prompt to enable Location Services:
     - **Cancel**: Displays default forecast details for Tokyo.
     - **Open Settings**: Redirects you to system settings to enable GPS.
2. **Permission Verification**: If GPS is enabled, the app checks for location permissions:
   - **First Launch**: Shows an explanation of why location access is required.
   - **Permission Allowed**: Automatically retrieves your location and updates the dashboard.
   - **Permanently Denied**: Displays a dialog explaining how to enable permission in your device's app settings.

---

## 3. Dashboard Features

After resolved location configurations, the main view loads:

```
+---------------------------------------+
|  [Menu]    [ Search City... ]    [C/F]|
|  📍 London, GB                        |
|  Friday, 17 July • 4:30 PM            |
|                                       |
|               (☼)  72°                |
|             CLEAR SKY                 |
|                                       |
|   +-------------------------------+   |
|   | Actual: 72° | H: 76° | L: 64° |   |
|   +-------------------------------+   |
|                                       |
|   [ 7-Day Forecast Card ]             |
|   [ Sunrise & Sunset Visuals ]        |
|   [ Weather Detail Grid (Humidity...) ]|
+---------------------------------------+
```

### Key Operations
- **Toggle Units**: Tap the unit toggle (e.g. `°C / °F`) in the top-right corner to instantly convert temperatures.
- **Search City**: Type a city name in the top search bar and press enter.
- **Favorites**: Tap the bookmark icon to save a city to your favorites menu. Open the side menu to view and select saved cities.
