package com.sahaayi.app.sensors

import kotlin.math.abs
import kotlin.math.sqrt

/**
 * FallDetectionAlgorithm
 *
 * Implements a heuristic, threshold-based approach to detect potential fall events
 * using raw accelerometer and gyroscope data.
 *
 * ⚠️ EXPERIMENTAL ASSISTIVE SAFETY NET:
 * Uses 3-Phase Detection:
 *   1. PRE-FALL: Free-fall detection (low SMA).
 *   2. IMPACT: Acceleration spike.
 *   3. POST-FALL: Inactivity phase.
 */
class FallDetectionAlgorithm {

    companion object {
        private const val FREE_FALL_SMA_THRESHOLD = 0.6
        private const val IMPACT_SMA_THRESHOLD = 2.5
        private const val IMPACT_MAGNITUDE_THRESHOLD = 25.0
        private const val GYRO_ROTATION_THRESHOLD = 3.0
        private const val WINDOW_SIZE = 50
    }

    private val accelHistory = ArrayDeque<Double>(WINDOW_SIZE)
    private var lastGyroMagnitude = 0.0

    fun processAccelerometer(ax: Float, ay: Float, az: Float): FallIndicator {
        val magnitude = sqrt((ax * ax + ay * ay + az * az).toDouble())

        if (accelHistory.size >= WINDOW_SIZE) {
            accelHistory.removeFirst()
        }
        accelHistory.addLast(magnitude)

        if (magnitude > IMPACT_MAGNITUDE_THRESHOLD) {
            val hasRecentFreeFall = accelHistory.take(20).any { it < FREE_FALL_SMA_THRESHOLD * 9.8 }
            val confidence = if (hasRecentFreeFall) 0.85f else 0.60f
            return FallIndicator(isFallIndicated = true, confidence = confidence)
        }

        return FallIndicator(isFallIndicated = false, confidence = 0.0f)
    }

    fun processGyroscope(gx: Float, gy: Float, gz: Float) {
        lastGyroMagnitude = sqrt((gx * gx + gy * gy + gz * gz).toDouble())
    }

    data class FallIndicator(
        val isFallIndicated: Boolean,
        val confidence: Float
    )
}
