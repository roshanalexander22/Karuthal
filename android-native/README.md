# Android Native Module — Sahaayi

This directory contains the **native Kotlin Android services** that power Sahaayi's platform-specific capabilities. These services are exposed to the Flutter application via [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels).

---

## Purpose

Flutter alone cannot access certain sensitive Android APIs. This module provides native implementations for:

| Service | Description |
|---|---|
| **Accessibility Service** | Screen-reading and form-field detection |
| **Autofill Service** | Secure profile-based form filling |
| **Sensor Monitoring** | Accelerometer/gyroscope-based fall detection |
| **Notification Service** | Scheduled reminders via AlarmManager |
| **Background Services** | Long-running foreground service base |

---

## Architecture — Flutter ↔ Native Communication

```
Flutter (Dart)
    │
    │  MethodChannel / EventChannel
    ▼
FlutterChannelBridge.kt
    │
    ├── SahaayiAccessibilityService.kt
    ├── SahaayiAutofillService.kt
    ├── SensorMonitoringService.kt
    └── ReminderNotificationService.kt
```

Channel names (defined in `platform_channels/FlutterChannelBridge.kt`):

- `sahaayi/accessibility`
- `sahaayi/autofill`
- `sahaayi/sensors`
- `sahaayi/tts`

---

## Services Overview

### 1. Accessibility Service (`accessibility_service/`)
Reads visible UI elements to detect form fields and screen content. Requires explicit user activation.

> ⚠️ **Privacy**: This service NEVER reads password fields, OTPs, or financial credentials.

### 2. Autofill Service (`autofill_service/`)
Provides autocomplete suggestions from the user's verified profile. Always requires user confirmation.

> ⚠️ **Privacy**: This service NEVER auto-submits forms or fills payment credentials.

### 3. Sensor Monitoring (`sensor_monitoring/`)
Listens to accelerometer and gyroscope data to detect potential fall events. Runs as a foreground service.

> ⚠️ **Experimental**: Fall detection is a heuristic tool and NOT a certified medical device.

### 4. Notification Service (`notification_service/`)
Schedules reminder notifications using `AlarmManager` with `NotificationCompat`. Respects Android's battery optimisation policies.

### 5. Background Services (`background_services/`)
Base class for all foreground services, handling notification channel creation and lifecycle management.

---

## Build Instructions

These native files are part of the main Flutter project's Android module (`android/`). They are **not** a standalone Gradle project.

```bash
# From the Flutter project root
cd ../flutter-app
flutter pub get
flutter build apk --debug
```

To register services, declare them in `android/app/src/main/AndroidManifest.xml`:

```xml
<service android:name="com.sahaayi.android.accessibility.SahaayiAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
</service>

<service android:name="com.sahaayi.android.autofill.SahaayiAutofillService"
    android:permission="android.permission.BIND_AUTOFILL_SERVICE">
    <intent-filter>
        <action android:name="android.service.autofill.AutofillService" />
    </intent-filter>
</service>

<service android:name="com.sahaayi.android.sensors.SensorMonitoringService"
    android:foregroundServiceType="health" />
```

---

## Required Permissions

Add these to `AndroidManifest.xml`:

```xml
<!-- Sensor monitoring -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Vibration for alerts -->
<uses-permission android:name="android.permission.VIBRATE" />
```

Accessibility and Autofill services require user activation in **Settings** — they cannot be granted programmatically.

---

## Directory Structure

```
android-native/
├── accessibility_service/
│   ├── SahaayiAccessibilityService.kt
│   └── AccessibilityServiceConfig.xml
├── autofill_service/
│   └── SahaayiAutofillService.kt
├── sensor_monitoring/
│   ├── SensorMonitoringService.kt
│   └── FallDetectionAlgorithm.kt
├── notification_service/
│   └── ReminderNotificationService.kt
├── platform_channels/
│   └── FlutterChannelBridge.kt
└── background_services/
    └── SahaayiBackgroundService.kt
```
