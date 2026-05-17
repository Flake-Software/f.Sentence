package com.flake.sentence

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class NotesWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return NotesRemoteViewsFactory(this.applicationContext)
    }
}

class NotesRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var notes: List<String> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        // Fetching the pipe-separated string updated by Flutter from Shared Preferences
        val prefs = context.getSharedPreferences("HomeWidgetPausedData", Context.MODE_PRIVATE)
        val titlesString = prefs.getString("note_titles", "") ?: ""
        notes = if (titlesString.isEmpty()) listOf() else titlesString.split("|")
    }

    override fun onDestroy() {}
    override fun getCount(): Int = notes.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.note_item)
        views.setTextViewText(R.id.note_item_title, notes[position])

        // Creating a fill-in intent so clicking a specific row can be handled by the main provider
        val fillInIntent = Intent().apply {
            putExtra("note_index", position)
            putExtra("note_title", notes[position])
        }
        views.setOnClickFillInIntent(R.id.note_item_root, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}
