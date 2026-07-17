# Deployment Guide

This guide details the procedures for building and deploying the WeatherNow application for production release.

---

## 1. Android Deployment

### Step 1.1: Configure Android Signing
Generate an upload keystore and reference it in your Android signing configuration:
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` with the keystore details:
   ```properties
   storePassword=yourStorePassword
   keyPassword=yourKeyPassword
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### Step 1.2: Build APK or App Bundle (AAB)
Compile the project to generate deployment files:
- **Build APK**:
  ```bash
  flutter build apk --release
  ```
- **Build Android App Bundle (Recommended for Play Store)**:
  ```bash
  flutter build appbundle --release
  ```
Target output directory: `build/app/outputs/flutter-apk/app-release.apk` or `build/app/outputs/bundle/release/app-release.aab`.

---

## 2. iOS Deployment

*Note: Xcode compilation requires a macOS environment.*

### Step 2.1: Configure App Signing
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the root **Runner** project.
3. In **Signing & Capabilities**, select your developer team and configure provisioning profiles.

### Step 2.2: Compile and Archive the Build
Run the following build command:
```bash
flutter build ipa --release
```
This generates a build archive located under `build/ios/archive/`. Open Xcode Organizer to upload the build to App Store Connect.
