package com.sahaayi.android.channels

import android.content.Context
import android.content.Intent
import com.sahaayi.android.notification.ReminderNotificationService
import com.sahaayi.android.sensors.SensorMonitoringService
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
        const val CHANNEL_REMINDERS = "sahaayi/reminders"
    }

    private val accessibilityChannel = MethodChannel(messenger, CHANNEL_ACCESSIBILITY)
    private val autofillChannel = MethodChannel(messenger, CHANNEL_AUTOFILL)
    private val sensorChannel = MethodChannel(messenger, CHANNEL_SENSORS)
    private val ttsChannel = MethodChannel(messenger, CHANNEL_TTS)
    private val reminderChannel = MethodChannel(messenger, CHANNEL_REMINDERS)

    init {
        accessibilityChannel.setMethodCallHandler(this)
        autofillChannel.setMethodCallHandler(this)
        sensorChannel.setMethodCallHandler(this)
        ttsChannel.setMethodCallHandler(this)
        reminderChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAccessibilityServiceEnabled" -> {
                result.success(false)
            }
            "requestScreenRead" -> {
                result.success(mapOf("status" to "QUEUED"))
            }
            "startSensorMonitoring" -> {
                try {
                    val intent = Intent(context, SensorMonitoringService::class.java)
                    context.startService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SERVICE_START_FAILED", e.message, null)
                }
            }
            "stopSensorMonitoring" -> {
                try {
                    val intent = Intent(context, SensorMonitoringService::class.java)
                    context.stopService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SERVICE_STOP_FAILED", e.message, null)
                }
            }
            "scheduleReminder" -> {
                try {
                    val reminderId = call.argument<String>("reminderId") ?: ""
                    val title = call.argument<String>("title") ?: "മരുന്ന് സമയം"
                    val message = call.argument<String>("message") ?: "നിങ്ങളുടെ മരുന്ന് കഴിക്കുക"
                    val triggerAtMillis = call.argument<Long>("triggerAtMillis") ?: (System.currentTimeMillis() + 60000L)
                    ReminderNotificationService(context).scheduleExactReminder(reminderId, title, message, triggerAtMillis)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("REMINDER_SCHEDULE_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
