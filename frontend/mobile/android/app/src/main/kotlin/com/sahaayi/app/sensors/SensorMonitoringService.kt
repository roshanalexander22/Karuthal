package com.sahaayi.app.sensors

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
 * Foreground Android service that reads accelerometer and gyroscope sensor data
 * to detect potential falls and physical distress for senior citizens.
 */
class SensorMonitoringService : Service(), SensorEventListener {

    companion object {
        private const val TAG = "SahaayiSensors"
        private const val CHANNEL_ID = "sahaayi_sensor_monitoring"
        private const val NOTIFICATION_ID = 1001
        const val FLUTTER_CHANNEL = "sahaayi/sensors"
        private const val ALERT_COOLDOWN_MS = 30_000L

        fun startService(context: Context) {
            val intent = Intent(context, SensorMonitoringService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stopService(context: Context) {
            val intent = Intent(context, SensorMonitoringService::class.java)
            context.stopService(intent)
        }
    }

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var gyroscope: Sensor? = null
    private val fallDetector = FallDetectionAlgorithm()
    private var lastAlertTime = 0L

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

    override fun onSensorChanged(event: SensorEvent?) {
        event ?: return

        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                val ax = event.values[0]
                val ay = event.values[1]
                val az = event.values[2]
                val result = fallDetector.processAccelerometer(ax, ay, az)

                if (result.isFallIndicated) {
                    handlePossibleFall(result)
                }
            }

            Sensor.TYPE_GYROSCOPE -> {
                val gx = event.values[0]
                val gy = event.values[1]
                val gz = event.values[2]
                fallDetector.processGyroscope(gx, gy, gz)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        Log.d(TAG, "Sensor accuracy changed: ${sensor?.name} -> $accuracy")
    }

    private fun handlePossibleFall(result: FallDetectionAlgorithm.FallIndicator) {
        val now = System.currentTimeMillis()
        if (now - lastAlertTime < ALERT_COOLDOWN_MS) return
        lastAlertTime = now

        Log.w(TAG, "⚠️ Possible fall detected! Confidence: ${result.confidence}")
    }

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

    private fun buildForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("സഹായി സുരക്ഷാ നിരീക്ഷണം (Sahaayi Active)")
            .setContentText("ശാരീരിക സുരക്ഷ നിരീക്ഷിക്കുന്നു (Monitoring sensor telemetry)")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
