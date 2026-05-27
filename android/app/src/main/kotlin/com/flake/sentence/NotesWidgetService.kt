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

class NotesRemoteViewsFactory(
    private val context: Context
) : RemoteViewsService.RemoteViewsFactory {

    private var notes: List<String> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        // Reads widget data from the same SharedPreferences
        // bucket used by HomeWidget + appGroupId
        val prefs = context.getSharedPreferences(
            "group.sentence.widgets",
            Context.MODE_PRIVATE
        )

        val titlesString =
            prefs.getString("note_titles", "") ?: ""

        notes = if (titlesString.isBlank()) {
            listOf()
        } else {
            titlesString
                .split("|")
                .filter { it.isNotBlank() }
        }
    }

    override fun onDestroy() {}

    override fun getCount(): Int = notes.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(
            context.packageName,
            R.layout.note_item
        )

        views.setTextViewText(
            R.id.note_item_title,
            notes[position]
        )

        // Each note item gets its own intent
        // so MainActivity can identify it
        val fillInIntent = Intent().apply {
            putExtra("note_index", position)
            putExtra("note_title", notes[position])
        }

        views.setOnClickFillInIntent(
            R.id.note_item_root,
            fillInIntent
        )

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long =
        position.toLong()

    override fun hasStableIds(): Boolean = true
}