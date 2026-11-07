import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Entry point of the Sahaayi application.
///
/// Responsibilities:
/// - Initialise Flutter engine bindings.
/// - Initialise Firebase.
/// - Enable accessibility semantics.
/// - Wrap the app in [ProviderScope] for Riverpod state management.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable full accessibility semantics tree so screen readers (TalkBack)
  // can traverse every widget correctly.
  SemanticsBinding.instance.ensureSemantics();

  // Initialise Firebase (requires google-services.json in android/app/).
  await _initFirebase();

  runApp(
    const ProviderScope(
      child: SahaayiApp(),
    ),
  );
}

/// Initialises Firebase, catching errors gracefully so the app can still
/// launch (in limited mode) if Firebase is misconfigured during development.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e, stackTrace) {
    // Log to console during development; production logging handled by
    // the AppLogger singleton once the app is running.
    debugPrint('[Firebase] Initialization failed: $e\n$stackTrace');
  }
}
