package com.sahaayi.app.channels

import android.content.Context
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.sahaayi.app.accessibility.SahaayiAccessibilityService
import com.sahaayi.app.notifications.ReminderNotificationService
import com.sahaayi.app.sensors.SensorMonitoringService

/**
 * FlutterChannelBridge
 *
 * Centralized registry mapping Flutter MethodChannels and EventChannels to Native Android services:
 * - MethodChannels:
 *   - sahaayi/accessibility
 *   - sahaayi/autofill
 *   - sahaayi/sensors
 *   - sahaayi/tts
 *   - sahaayi/reminders
 * - EventChannels:
 *   - sahaayi/sensor_events
 *   - sahaayi/fall_events
 */
class FlutterChannelBridge(private val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_ACCESSIBILITY = "sahaayi/accessibility"
        const val CHANNEL_AUTOFILL = "sahaayi/autofill"
        const val CHANNEL_SENSORS = "sahaayi/sensors"
        const val CHANNEL_TTS = "sahaayi/tts"
        const val CHANNEL_REMINDERS = "sahaayi/reminders"

        const val EVENT_CHANNEL_SENSORS = "sahaayi/sensor_events"
        const val EVENT_CHANNEL_FALL = "sahaayi/fall_events"

        var sensorEventSink: EventChannel.EventSink? = null
            private set
        var fallEventSink: EventChannel.EventSink? = null
            private set
    }

    private val accessibilityChannel = MethodChannel(messenger, CHANNEL_ACCESSIBILITY)
    private val autofillChannel = MethodChannel(messenger, CHANNEL_AUTOFILL)
    private val sensorChannel = MethodChannel(messenger, CHANNEL_SENSORS)
    private val ttsChannel = MethodChannel(messenger, CHANNEL_TTS)
    private val reminderChannel = MethodChannel(messenger, CHANNEL_REMINDERS)

    private val sensorEventChannel = EventChannel(messenger, EVENT_CHANNEL_SENSORS)
    private val fallEventChannel = EventChannel(messenger, EVENT_CHANNEL_FALL)

    private val reminderNotificationService = ReminderNotificationService(context)

    init {
        accessibilityChannel.setMethodCallHandler(this)
        autofillChannel.setMethodCallHandler(this)
        sensorChannel.setMethodCallHandler(this)
        ttsChannel.setMethodCallHandler(this)
        reminderChannel.setMethodCallHandler(this)

        sensorEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                sensorEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                sensorEventSink = null
            }
        })

        fallEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                fallEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                fallEventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // --- Accessibility Channel ---
            "isAccessibilityServiceEnabled" -> {
                val isEnabled = isAccessibilityServiceRunning(context)
                result.success(isEnabled)
            }
            "requestScreenRead" -> {
                val service = SahaayiAccessibilityService.instance
                if (service != null) {
                    val elements = service.extractScreenElements()
                    result.success(elements)
                } else {
                    result.error("SERVICE_DISABLED", "Accessibility service is not active in Android Settings.", null)
                }
            }
            "injectFieldValue" -> {
                val service = SahaayiAccessibilityService.instance
                if (service != null) {
                    val nodeId = call.argument<String>("nodeId") ?: ""
                    val value = call.argument<String>("value") ?: ""
                    val success = service.injectFieldValue(nodeId, value)
                    result.success(success)
                } else {
                    result.error("SERVICE_DISABLED", "Accessibility service is not active in Android Settings.", null)
                }
            }
            "openAccessibilitySettings" -> {
                val intent = android.content.Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                    addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                result.success(true)
            }

            // --- Autofill Channel ---
            "isAutofillSupported" -> {
                result.success(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O)
            }

            // --- Sensor Channel ---
            "startSensorMonitoring" -> {
                SensorMonitoringService.startService(context)
                result.success(true)
            }
            "stopSensorMonitoring" -> {
                SensorMonitoringService.stopService(context)
                result.success(true)
            }

            // --- Reminders Channel ---
            "scheduleExactReminder" -> {
                val reminderId = call.argument<String>("reminderId") ?: ""
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                val triggerAtMillis = call.argument<Long>("triggerAtMillis") ?: 0L
                reminderNotificationService.scheduleExactReminder(reminderId, title, message, triggerAtMillis)
                result.success(true)
            }
            "cancelReminder" -> {
                val reminderId = call.argument<String>("reminderId") ?: ""
                reminderNotificationService.cancelReminder(reminderId)
                result.success(true)
            }

            // --- TTS Channel ---
            "setSpeechRate" -> {
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun isAccessibilityServiceRunning(ctx: Context): Boolean {
        val expectedServiceName = "${ctx.packageName}/${SahaayiAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            ctx.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabledServices.split(":").any { it.equals(expectedServiceName, ignoreCase = true) }
    }
}
