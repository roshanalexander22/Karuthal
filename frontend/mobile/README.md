# Sahaayi – Flutter Mobile Application

> **സഹായി** (Sahaayi) — AI-powered elderly assistance and accessibility platform for Android.

---

## Table of Contents

- [Purpose](#purpose)
- [Prerequisites](#prerequisites)
- [Project Setup](#project-setup)
- [Running the App](#running-the-app)
- [Feature Modules](#feature-modules)
- [Platform Channel Architecture](#platform-channel-architecture)
- [Android Permissions](#android-permissions)
- [Localization](#localization)
- [Testing](#testing)
- [Build & Release](#build--release)

---

## Purpose

Sahaayi is an Android application designed to empower elderly users, particularly Malayalam-speaking users in Kerala, by providing:

- **Voice Assistant** – Natural language voice interaction in Malayalam and English.
- **Text-to-Speech (TTS)** – Read aloud documents, messages, and UI text with customizable speed.
- **Document Reader** – Upload and read printed or digital documents with OCR support.
- **Smart Autofill** – AI-driven form filling using the user's verified personal data.
- **Medicine Reminders** – Scheduled medication and appointment reminders with notifications.
- **Audio Transcription** – Convert spoken audio to text for future reference.
- **Fall Detection** – Experimental accelerometer-based fall detection with emergency alert.
- **Emergency Contacts** – One-tap SOS with location sharing to caregiver contacts.
- **Caregiver Dashboard** – Allow designated caregivers to monitor and manage settings remotely.

---

## Prerequisites

| Tool | Minimum Version | Notes |
|------|----------------|-------|
| Flutter SDK | 3.22.0 | Stable channel |
| Dart SDK | 3.3.0 | Bundled with Flutter |
| Android Studio | Hedgehog (2023.1.1) | With Android SDK 34 |
| Java / JDK | 17 | Required for Gradle |
| Android Device / Emulator | API 26+ (Android 8.0) | Physical device recommended for sensors |

### Install Flutter

```bash
# Using Flutter's official installer or git
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

---

## Project Setup

```bash
# 1. Clone the repository (from project root)
cd c:/Users/ROSHAN ALEXANDER/Documents/Projects/Karuthal/frontend/mobile

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate code (Riverpod, Freezed, Retrofit, JSON serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Configure Firebase
#    - Add google-services.json to android/app/
#    - Run: flutterfire configure (requires Firebase CLI)

# 5. Set up environment config
#    - Copy lib/config/app_config.dart and update API base URL
```

### Android Studio Setup

1. Open `android/` folder in Android Studio to index the Gradle project.
2. Install **Flutter** and **Dart** plugins via `Settings → Plugins`.
3. Set `JAVA_HOME` to JDK 17.
4. Accept SDK licenses: `flutter doctor --android-licenses`.

---

## Running the App

```bash
# List available devices
flutter devices

# Run in debug mode on connected device
flutter run

# Run with specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## Feature Modules

The app follows a **feature-first** modular architecture under `lib/features/`:

```
lib/
├── app/                    # App widget, theme, routing bootstrap
├── config/                 # Environment configuration
├── core/
│   ├── constants/          # App-wide constants, API endpoints
│   ├── network/            # Dio client, interceptors, exceptions
│   ├── platform/           # Platform channel definitions
│   └── utils/              # Logger, permission handler, extensions
├── features/
│   ├── authentication/     # Login, register, JWT management
│   ├── home/               # Feature hub screen
│   ├── voice_assistant/    # Voice chat with AI backend
│   ├── text_to_speech/     # TTS playback with flutter_tts
│   ├── document_reader/    # Upload, OCR, read-aloud documents
│   ├── personal_memory/    # Profile data management
│   ├── smart_autofill/     # AI autofill via AccessibilityService
│   ├── medicine_reminders/ # Medication scheduling and notifications
│   ├── audio_transcription/# Record / upload → transcription
│   ├── fall_detection/     # Accelerometer-based fall alert
│   ├── emergency/          # SOS button, emergency contacts
│   └── caregiver/          # Caregiver pairing and monitoring
├── l10n/                   # ARB localization files (en, ml)
├── navigation/             # go_router configuration
└── shared/
    └── widgets/            # Reusable accessible UI components
```

---

## Platform Channel Architecture

Sahaayi uses Flutter Platform Channels to communicate with native Android code:

| Channel Name | Purpose |
|---|---|
| `com.sahaayi.app/accessibility` | Control and query the native `AccessibilityService` for smart autofill overlay |
| `com.sahaayi.app/autofill` | Coordinate with the native `AutofillService` for form detection and filling |
| `com.sahaayi.app/sensor` | High-frequency accelerometer/gyroscope data for fall detection |
| `com.sahaayi.app/tts` | Native Android TTS engine control (locale, pitch, rate) |

Channel definitions are in [`lib/core/platform/platform_channels.dart`](lib/core/platform/platform_channels.dart).  
Native implementations are in [`android/app/src/main/kotlin/com/sahaayi/app/MainActivity.kt`](android/app/src/main/kotlin/com/sahaayi/app/MainActivity.kt).

---

## Android Permissions

| Permission | Feature | Required |
|---|---|---|
| `INTERNET` | All network calls | ✅ |
| `RECORD_AUDIO` | Voice assistant, transcription | ✅ |
| `CAMERA` | Document scanning | ✅ |
| `READ_MEDIA_IMAGES` | Photo/document selection | ✅ |
| `FOREGROUND_SERVICE` | Fall detection, TTS background | ✅ |
| `RECEIVE_BOOT_COMPLETED` | Restart reminder alarms on boot | ✅ |
| `VIBRATE` | Reminder/emergency haptic feedback | ✅ |
| `BODY_SENSORS` | Fall detection accelerometer | ✅ |
| `ACCESS_FINE_LOCATION` | Emergency location sharing | ✅ |
| `BIND_ACCESSIBILITY_SERVICE` | Smart autofill overlay | Native only |
| `BIND_AUTOFILL_SERVICE` | Android autofill framework | Native only |

---

## Localization

The app supports **English** and **Malayalam** (`ml`).

- ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`
- Generated code: `lib/l10n/` (run `flutter pub get` to regenerate)
- Config: `l10n.yaml` at root

To add a new language:
1. Add `app_<locale>.arb` file.
2. Add locale to `AppLocalizations.supportedLocales` in `app.dart`.

---

## Testing

```bash
# Unit and widget tests
flutter test

# Integration tests (requires connected device)
flutter test integration_test/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Build & Release

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires keystore configured in android/key.properties)
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

Configure signing in `android/app/build.gradle` and `android/key.properties`.

---

*Sahaayi is part of the Karuthal platform. For backend API documentation, see the backend module README.*
