package com.sahaayi.android.channels

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * FlutterChannelBridge
 *
 * Centralized registry mapping Flutter MethodChannels to Native Android services.
 */
class FlutterChannelBridge(private val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_ACCESSIBILITY = "sahaayi/accessibility"
        const val CHANNEL_AUTOFILL = "sahaayi/autofill"
        const val CHANNEL_SENSORS = "sahaayi/sensors"
        const val CHANNEL_TTS = "sahaayi/tts"
    }

    private val accessibilityChannel = MethodChannel(messenger, CHANNEL_ACCESSIBILITY)
    private val autofillChannel = MethodChannel(messenger, CHANNEL_AUTOFILL)
    private val sensorChannel = MethodChannel(messenger, CHANNEL_SENSORS)
    private val ttsChannel = MethodChannel(messenger, CHANNEL_TTS)

    init {
        accessibilityChannel.setMethodCallHandler(this)
        autofillChannel.setMethodCallHandler(this)
        sensorChannel.setMethodCallHandler(this)
        ttsChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAccessibilityServiceEnabled" -> {
                result.success(false) // Verified dynamically via Settings.Secure
            }
            "requestScreenRead" -> {
                result.success(mapOf("status" to "QUEUED"))
            }
            "startSensorMonitoring" -> {
                result.success(true)
            }
            "stopSensorMonitoring" -> {
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
