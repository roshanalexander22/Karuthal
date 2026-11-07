package com.sahaayi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        const val CHANNEL_ACCESSIBILITY = "sahaayi/accessibility"
        const val CHANNEL_AUTOFILL = "sahaayi/autofill"
        const val CHANNEL_SENSORS = "sahaayi/sensors"
        const val CHANNEL_TTS = "sahaayi/tts"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_ACCESSIBILITY).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> result.success(false)
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SENSORS).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSensorMonitoring" -> result.success(true)
                "stopSensorMonitoring" -> result.success(true)
                else -> result.notImplemented()
            }
        }
    }
}
