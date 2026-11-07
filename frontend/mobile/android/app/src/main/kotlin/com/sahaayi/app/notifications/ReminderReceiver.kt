package com.sahaayi.app.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * ReminderReceiver
 *
 * BroadcastReceiver triggered by AlarmManager when a scheduled reminder is due.
 */
class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val reminderId = intent.getStringExtra("reminder_id") ?: "default"
        val title = intent.getStringExtra("title") ?: "മരുന്ന് സമയം (Medication Time)"
        val message = intent.getStringExtra("message") ?: "ദയവായി നിങ്ങളുടെ മരുന്ന് കഴിക്കുക (Please take your prescribed medicine)."

        val builder = NotificationCompat.Builder(context, ReminderNotificationService.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)

        val notificationManager = NotificationManagerCompat.from(context)
        try {
            notificationManager.notify(reminderId.hashCode(), builder.build())
        } catch (_: SecurityException) {
            // Android 13+ POST_NOTIFICATIONS permission check
        }
    }
}
