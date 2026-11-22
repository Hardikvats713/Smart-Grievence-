# Google Maps & Google Places API Setup Guide

This guide describes how to configure Google Maps, Places Autocomplete, and Geocoding in the **Smart Grievance** Flutter mobile app.

---

## 1. Security & Architecture
To follow security best practices and prevent hardcoding secrets in Git:
- **No API keys are committed** to source code.
- Keys are supplied at build or run time via Flutter's compile-time environment flags (`--dart-define`).
- On Android, the Google Maps API key is injected into `AndroidManifest.xml` using Gradle `manifestPlaceholders`.
- In Dart, keys are read via `AppConfig` (`lib/core/config/app_config.dart`).

---

## 2. Google Cloud Platform (GCP) Configuration

### Step A: Enable Required APIs
In the [Google Cloud Console](https://console.cloud.google.com/), enable the following 3 APIs:
1. **Maps SDK for Android** — Renders the interactive map on Android devices and emulators.
2. **Places API (New) / Places API** — Powers real-time address autocomplete when searching for civic locations.
3. **Geocoding API** — Converts between GPS coordinates (latitude / longitude) and readable street addresses (reverse geocoding when marker moves).

### Step B: Create & Restrict API Keys
It is recommended to use **two separate restricted keys**:

#### Key 1: Android Maps Key (Client-Side)
- **Application restriction**: Android apps
- **Package name**: `in.gov.arunachal.smartgrievance.smart_grievance`
- **SHA-1 certificate fingerprint**:
  - Debug SHA-1 (get by running `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
  - Release SHA-1 (from your production release signing keystore)
- **API restrictions**: Restrict key to **Maps SDK for Android**.

#### Key 2: Web Service Key (Places & Geocoding)
- **Application restriction**: None or IP-restricted (or API restrictions only).
- **API restrictions**: Restrict key to **Places API** and **Geocoding API**.

---

## 3. Running & Building the App with API Keys

### Running with Flutter CLI
Pass the keys at runtime via `--dart-define`:

```bash
flutter run \
  --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyYourAndroidMapsApiKeyHere \
  --dart-define=GOOGLE_PLACES_API_KEY=AIzaSyYourPlacesApiKeyHere
```

### Building APK
```bash
flutter build apk --release \
  --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyYourAndroidMapsApiKeyHere \
  --dart-define=GOOGLE_PLACES_API_KEY=AIzaSyYourPlacesApiKeyHere
```

### Passing to Android Gradle
You can also set the key in `android/local.properties` (which is in `.gitignore`):
```properties
MAPS_API_KEY=AIzaSyYourAndroidMapsApiKeyHere
```

---

## 4. Built-in Offline & Testing Fallback
If no API keys are provided (e.g. during offline demos, automated CI runs, or unit/widget tests):
- The app automatically uses the built-in **Arunachal Pradesh / Itanagar civic database** (13+ administrative and landmark locations).
- The map automatically falls back to the **high-fidelity slippy vector cartography** engine (`LiveMapView`), ensuring **100% test pass rate** and zero crashes.

---

## 5. Android Permissions (`AndroidManifest.xml`)
The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.INTERNET` — Network connectivity for maps, tiles, and grievance submission.
- `android.permission.CAMERA` — Capturing grievance evidence and profile photos.
- `android.permission.READ_EXTERNAL_STORAGE` (maxSdkVersion=32) — Accessing gallery photos on Android 12 and below.
- `android.permission.READ_MEDIA_IMAGES` — Accessing gallery photos on Android 13+ (API 33+).
- `android.permission.ACCESS_FINE_LOCATION` — Exact GPS coordinates for grievance location verification.
- `android.permission.ACCESS_COARSE_LOCATION` — Approximate location for general city-level positioning.
