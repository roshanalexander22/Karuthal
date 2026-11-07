package com.sahaayi.android.sensors

import kotlin.math.abs
import kotlin.math.sqrt

/**
 * FallDetectionAlgorithm
 *
 * Implements a heuristic, threshold-based approach to detect potential fall events
 * using raw accelerometer and gyroscope data.
 *
 * =========================================================================
 * ⚠️  DISCLAIMER & LIMITATIONS — MUST BE UNDERSTOOD BEFORE USE
 * =========================================================================
 * This algorithm is EXPERIMENTAL and has significant limitations:
 *
 *   - It uses simple threshold-based heuristics, NOT machine learning.
 *   - Accuracy varies by: phone placement, user body type, clothing, activity.
 *   - Activities that may cause false positives:
 *       * Sitting down quickly       * Jumping
 *       * Dropping the phone         * Vigorous exercise
 *       * Riding in a vehicle        * Hand gestures
 *   - Falls that may be missed:
 *       * Slow slides down a wall    * Falls in a seated position
 *       * Falls where phone stays still
 *
 * This feature is intended as an ASSISTIVE SAFETY NET only.
 * It MUST NOT be used as a primary or sole safety mechanism.
 * Always combine with manual check-ins and professional monitoring if needed.
 *
 * Future improvement: Replace threshold logic with a TFLite model trained
 * on labelled fall datasets (e.g., SisFall, MobiAct).
 * =========================================================================
 *
 * Algorithm Overview (3-Phase Detection):
 *   1. PRE-FALL: Detect a sudden free-fall phase (low SMA for a window).
 *   2. IMPACT:   Detect a sharp acceleration spike immediately after.
 *   3. POST-FALL: Detect a period of inactivity (person lying still).
 *
 * References:
 *   - Bourke et al. (2008): "A threshold-based fall-detection algorithm using a bi-axial gyroscope sensor"
 *   - Noury et al. (2007): "Fall Detection — Principles and Methods"
 */
class FallDetectionAlgorithm {

    companion object {
        // ---- Accelerometer Thresholds ----

        /** SMA below this value may indicate a free-fall phase (m/s²) */
        private const val FREE_FALL_SMA_THRESHOLD = 0.6

        /** SMA above this value after free-fall may indicate an impact (m/s²) */
        private const val IMPACT_SMA_THRESHOLD = 2.5

        /** Raw acceleration magnitude above this triggers immediate impact check */
        private const val IMPACT_MAGNITUDE_THRESHOLD = 25.0

        // ---- Gyroscope Thresholds ----

        /** Angular velocity above this during/after fall suggests body rotation */
        private const val GYRO_ROTATION_THRESHOLD = 3.0

        // ---- Timing ----

        /** Number of samples in the sliding window for SMA calculation */
        private const val WINDOW_SIZE = 20

        /** Post-impact inactivity window in sample count */
        private const val INACTIVITY_WINDOW = 30

        /** SMA below this for INACTIVITY_WINDOW samples → person is lying still */
        private const val INACTIVITY_SMA_THRESHOLD = 0.3
    }

    // ---- State Machine ----
    private enum class Phase { IDLE, FREE_FALL, IMPACT_DETECTED }
    private var currentPhase = Phase.IDLE

    // ---- Sliding Window Buffers ----
    private val accelBuffer = ArrayDeque<Double>(WINDOW_SIZE)
    private val gyroBuffer = ArrayDeque<Double>(WINDOW_SIZE)
    private var postImpactSamples = 0

    // Latest gyroscope magnitude (updated from onSensorChanged)
    private var latestGyroMagnitude = 0.0

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    /**
     * Process a new accelerometer reading.
     *
     * @param ax X-axis acceleration (m/s²)
     * @param ay Y-axis acceleration (m/s²)
     * @param az Z-axis acceleration (m/s²)
     * @return [FallIndicator] with the current detection result.
     */
    fun processAccelerometer(ax: Float, ay: Float, az: Float): FallIndicator {
        val magnitude = calculateMagnitude(ax.toDouble(), ay.toDouble(), az.toDouble())
        updateAccelBuffer(magnitude)
        val sma = calculateSMA()

        return when (currentPhase) {
            Phase.IDLE -> {
                if (sma < FREE_FALL_SMA_THRESHOLD) {
                    currentPhase = Phase.FREE_FALL
                }
                FallIndicator(isFallIndicated = false, confidence = 0.0, phase = currentPhase)
            }

            Phase.FREE_FALL -> {
                if (detectImpact(sma)) {
                    currentPhase = Phase.IMPACT_DETECTED
                    postImpactSamples = 0
                }
                FallIndicator(isFallIndicated = false, confidence = 0.5, phase = currentPhase)
            }

            Phase.IMPACT_DETECTED -> {
                postImpactSamples++
                if (detectInactivity(sma, postImpactSamples)) {
                    val confidence = calculateConfidence(sma)
                    currentPhase = Phase.IDLE
                    FallIndicator(isFallIndicated = true, confidence = confidence, phase = Phase.IDLE)
                } else if (postImpactSamples > INACTIVITY_WINDOW * 2) {
                    // Person resumed movement — probably not a fall
                    currentPhase = Phase.IDLE
                    FallIndicator(isFallIndicated = false, confidence = 0.0, phase = Phase.IDLE)
                } else {
                    FallIndicator(isFallIndicated = false, confidence = 0.7, phase = currentPhase)
                }
            }
        }
    }

    /**
     * Update the latest gyroscope data.
     *
     * Gyroscope data is used as supplementary evidence (body rotation during fall).
     *
     * @param gx X-axis angular velocity (rad/s)
     * @param gy Y-axis angular velocity (rad/s)
     * @param gz Z-axis angular velocity (rad/s)
     */
    fun processGyroscope(gx: Float, gy: Float, gz: Float) {
        latestGyroMagnitude = calculateMagnitude(gx.toDouble(), gy.toDouble(), gz.toDouble())
        updateGyroBuffer(latestGyroMagnitude)
    }

    // -------------------------------------------------------------------------
    // Core Calculations
    // -------------------------------------------------------------------------

    /**
     * Calculates the Signal Magnitude Area (SMA) over the current sliding window.
     *
     * SMA = (1/N) * Σ |xi|
     *
     * SMA is a measure of overall signal energy. Very low SMA → free-fall.
     * Very high SMA → vigorous movement or impact.
     *
     * @return Mean absolute value of acceleration magnitudes in the window.
     */
    fun calculateSMA(): Double {
        if (accelBuffer.isEmpty()) return 0.0
        return accelBuffer.sum() / accelBuffer.size
    }

    /**
     * Detects an impact phase based on SMA exceeding the impact threshold
     * or the raw magnitude crossing the immediate impact threshold.
     *
     * @param currentSMA The current SMA value.
     * @return True if impact conditions are met.
     */
    fun detectImpact(currentSMA: Double = calculateSMA()): Boolean {
        // Impact is indicated by a sharp rise in SMA after free-fall
        val smaImpact = currentSMA > IMPACT_SMA_THRESHOLD
        // Also check if gyroscope shows significant rotation (body falling)
        val gyroImpact = latestGyroMagnitude > GYRO_ROTATION_THRESHOLD
        return smaImpact && gyroImpact
    }

    /**
     * Detects inactivity following an impact — a strong indicator of a fall
     * where the person is lying still.
     *
     * @param currentSMA      Current SMA value.
     * @param samplesElapsed  Number of samples since impact was detected.
     * @return True if the signal has been inactive long enough to suggest lying still.
     */
    fun detectInactivity(currentSMA: Double = calculateSMA(), samplesElapsed: Int): Boolean {
        return samplesElapsed >= INACTIVITY_WINDOW && currentSMA < INACTIVITY_SMA_THRESHOLD
    }

    // -------------------------------------------------------------------------
    // Helper Functions
    // -------------------------------------------------------------------------

    private fun calculateMagnitude(x: Double, y: Double, z: Double): Double =
        sqrt(x * x + y * y + z * z)

    private fun updateAccelBuffer(value: Double) {
        if (accelBuffer.size >= WINDOW_SIZE) accelBuffer.removeFirst()
        accelBuffer.addLast(value)
    }

    private fun updateGyroBuffer(value: Double) {
        if (gyroBuffer.size >= WINDOW_SIZE) gyroBuffer.removeFirst()
        gyroBuffer.addLast(value)
    }

    /**
     * Estimates a rough confidence score for a fall event.
     * Confidence is higher when post-impact inactivity SMA is very low
     * and gyroscope showed rotation.
     *
     * NOTE: This is a heuristic estimate, not a calibrated probability.
     *
     * @param postImpactSMA The SMA value during inactivity phase.
     * @return Confidence score in range [0.0, 1.0].
     */
    private fun calculateConfidence(postImpactSMA: Double): Double {
        val inactivityScore = (INACTIVITY_SMA_THRESHOLD - postImpactSMA)
            .coerceIn(0.0, INACTIVITY_SMA_THRESHOLD) / INACTIVITY_SMA_THRESHOLD

        val gyroScore = if (latestGyroMagnitude > GYRO_ROTATION_THRESHOLD) 1.0 else 0.5

        return ((inactivityScore * 0.6) + (gyroScore * 0.4)).coerceIn(0.0, 1.0)
    }

    // -------------------------------------------------------------------------
    // Result Data Class
    // -------------------------------------------------------------------------

    /**
     * Represents the output of one cycle of fall detection processing.
     *
     * @property isFallIndicated True when all three phases (free-fall, impact,
     *                           inactivity) have been detected in sequence.
     * @property confidence      Rough heuristic estimate [0.0–1.0]. NOT a
     *                           calibrated medical probability.
     * @property phase           Internal state machine phase at time of result.
     */
    data class FallIndicator(
        val isFallIndicated: Boolean,
        val confidence: Double,
        val phase: Phase
    )
}
