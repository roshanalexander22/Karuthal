package com.sahaayi.android.sensors

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * SensorMonitoringService
 *
 * A foreground Android service that continuously reads accelerometer and
 * gyroscope sensor data to perform heuristic fall detection for Sahaayi users.
 *
 * =========================================================================
 * ⚠️  IMPORTANT DISCLAIMER — PLEASE READ
 * =========================================================================
 * Fall detection in Sahaayi is an EXPERIMENTAL ASSISTIVE FEATURE.
 *
 *   - It is NOT a certified medical device or health monitoring system.
 *   - It is NOT a replacement for professional medical monitoring equipment.
 *   - It WILL produce false positives (alerts when no fall occurred).
 *   - It WILL produce false negatives (miss some actual falls).
 *   - Movement patterns vary greatly between individuals and environments.
 *   - Detection accuracy has NOT been validated in clinical trials.
 *
 * Users and caregivers must be informed of these limitations.
 * Emergency response should NEVER rely solely on this feature.
 * =========================================================================
 *
 * This service runs as a foreground service (required on Android 8.0+) and
 * displays a persistent notification to keep the user informed.
 *
 * Communication back to Flutter is done via an EventChannel on:
 *   "sahaayi/sensors"
 */
class SensorMonitoringService : Service(), SensorEventListener {

    companion object {
        private const val TAG = "SahaayiSensors"
        private const val CHANNEL_ID = "sahaayi_sensor_monitoring"
        private const val NOTIFICATION_ID = 1001
        const val FLUTTER_CHANNEL = "sahaayi/sensors"

        // Minimum pause between fall alerts (milliseconds) to avoid spam
        private const val ALERT_COOLDOWN_MS = 30_000L
    }

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var gyroscope: Sensor? = null
    private val fallDetector = FallDetectionAlgorithm()
    private var lastAlertTime = 0L

    // -------------------------------------------------------------------------
    // Service Lifecycle
    // -------------------------------------------------------------------------

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "SensorMonitoringService created.")

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "SensorMonitoringService starting.")
        startForeground(NOTIFICATION_ID, buildForegroundNotification())
        registerSensorListeners()
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
        Log.i(TAG, "SensorMonitoringService destroyed, sensors unregistered.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // -------------------------------------------------------------------------
    // Sensor Registration
    // -------------------------------------------------------------------------

    /**
     * Registers listeners for the accelerometer and gyroscope.
     * Uses [SensorManager.SENSOR_DELAY_GAME] for ~50Hz sampling — sufficient
     * for fall detection without excessive battery drain.
     */
    private fun registerSensorListeners() {
        accelerometer?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            Log.d(TAG, "Accelerometer registered.")
        } ?: Log.w(TAG, "No accelerometer available on this device.")

        gyroscope?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            Log.d(TAG, "Gyroscope registered.")
        } ?: Log.w(TAG, "No gyroscope available on this device.")
    }

    // -------------------------------------------------------------------------
    // SensorEventListener Implementation
    // -------------------------------------------------------------------------

    /**
     * Called each time a registered sensor reports a new value.
     *
     * Passes raw sensor readings to [FallDetectionAlgorithm] for processing.
     * If a fall is indicated and the cooldown has elapsed, an alert is sent
     * back to Flutter via the platform channel.
     *
     * @param event The new sensor reading.
     */
    override fun onSensorChanged(event: SensorEvent?) {
        event ?: return

        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                val ax = event.values[0]
                val ay = event.values[1]
                val az = event.values[2]

                // Update fall detector with accelerometer data
                val result = fallDetector.processAccelerometer(ax, ay, az)

                if (result.isFallIndicated) {
                    handlePossibleFall(result)
                }
            }

            Sensor.TYPE_GYROSCOPE -> {
                val gx = event.values[0]
                val gy = event.values[1]
                val gz = event.values[2]

                // Update fall detector with gyroscope data
                fallDetector.processGyroscope(gx, gy, gz)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        Log.d(TAG, "Sensor accuracy changed: ${sensor?.name} → $accuracy")
    }

    // -------------------------------------------------------------------------
    // Fall Event Handling
    // -------------------------------------------------------------------------

    /**
     * Handles a possible fall event detected by the algorithm.
     *
     * Applies a cooldown to prevent repeated alerts for the same event.
     * Sends a structured payload to Flutter via the platform channel.
     *
     * @param result The [FallDetectionAlgorithm.FallIndicator] from the detector.
     */
    private fun handlePossibleFall(result: FallDetectionAlgorithm.FallIndicator) {
        val now = System.currentTimeMillis()
        if (now - lastAlertTime < ALERT_COOLDOWN_MS) {
            Log.d(TAG, "Fall alert suppressed (cooldown active).")
            return
        }
        lastAlertTime = now

        Log.w(TAG, "⚠️ Possible fall detected! Confidence: ${result.confidence}")

        // TODO: Send event to Flutter via EventChannel
        // The FlutterChannelBridge should hold a reference to the EventSink.
        // Example payload:
        // val payload = mapOf(
        //     "event" to "FALL_DETECTED",
        //     "confidence" to result.confidence,
        //     "timestamp" to now,
        //     "disclaimer" to "EXPERIMENTAL: May be a false alarm."
        // )
        // eventSink?.success(payload)
    }

    // -------------------------------------------------------------------------
    // Notification Helpers
    // -------------------------------------------------------------------------

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Sahaayi Sensor Monitoring",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Sahaayi is monitoring for fall events in the background."
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    /**
     * Builds the persistent foreground notification shown while this service runs.
     * Android requires a visible notification for all foreground services.
     */
    private fun buildForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sahaayi — Active")
            .setContentText("Monitoring for falls. Tap to open.")
            .setSmallIcon(android.R.drawable.ic_menu_info_details) // Replace with app icon
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
