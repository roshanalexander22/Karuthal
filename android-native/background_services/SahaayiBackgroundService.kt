package com.sahaayi.android.background

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

/**
 * SahaayiBackgroundService
 *
 * Base background orchestration service managing long-lived lifecycle tasks,
 * emergency watchdogs, and battery-conscious telemetry dispatch.
 */
class SahaayiBackgroundService : Service() {

    companion object {
        private const val TAG = "SahaayiBackgroundService"
        const val ACTION_START = "com.sahaayi.android.action.START"
        const val ACTION_STOP = "com.sahaayi.android.action.STOP"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "Sahaayi background orchestration service initialized.")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> Log.i(TAG, "Service started in background.")
            ACTION_STOP -> stopSelf()
        }
        return START_STICKY
    }
}
