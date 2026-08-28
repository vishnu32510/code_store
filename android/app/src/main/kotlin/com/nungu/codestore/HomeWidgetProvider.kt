package com.nungu.codestore

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout).apply {
                // Pending intent to open the app on tap
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                // Read values updated by Flutter HomeWidgetService
                val title = widgetData.getString("title", null)
                val message = widgetData.getString("message", null)
                val status = widgetData.getString("status", null)
                val imagePath = widgetData.getString("home_widget_image", null)

                if (imagePath != null && imagePath.isNotEmpty()) {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.widget_image, bitmap)
                        setViewVisibility(R.id.widget_image, View.VISIBLE)
                        setViewVisibility(R.id.widget_text_container, View.GONE)
                    } else {
                        setViewVisibility(R.id.widget_image, View.GONE)
                        setViewVisibility(R.id.widget_text_container, View.VISIBLE)
                    }
                } else {
                    setViewVisibility(R.id.widget_image, View.GONE)
                    setViewVisibility(R.id.widget_text_container, View.VISIBLE)
                }

                if (title != null) {
                    setTextViewText(R.id.widget_title, title)
                }
                if (message != null) {
                    setTextViewText(R.id.widget_message, message)
                }
                if (status != null) {
                    setTextViewText(R.id.widget_status, status)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
