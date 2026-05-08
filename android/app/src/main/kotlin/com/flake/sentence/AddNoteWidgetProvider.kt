package com.flake.sentence

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.content.Intent
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AddNoteWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.add_note_widget).apply {
                val intent = Intent(context, MainActivity::class.java).apply {
                    data = Uri.parse("sentence://add_note")
                    action = Intent.ACTION_VIEW
                }

                // KLJUČ: Koristimo unikatan ID (timestamp) umesto appWidgetId
                // Ovo sprečava Android da "zapamti" stari klik
                val requestCode = System.currentTimeMillis().toInt()

                val pendingIntent = PendingIntent.getActivity(
                    context, 
                    requestCode, 
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}