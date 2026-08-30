package com.nungu.codestore

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

/**
 * Universal communication bridge for decoding Flutter data, JSON, and image assets in Android AppWidgets / Glance.
 */
object WidgetBridge {

    /**
     * Shared SharedPreferences instance managed by home_widget plugin.
     */
    fun getPreferences(context: Context): SharedPreferences {
        return HomeWidgetPlugin.getData(context)
    }

    /**
     * Reads a String value synchronized from Flutter.
     */
    fun getString(context: Context, key: String, fallback: String = ""): String {
        return getPreferences(context).getString(key, fallback) ?: fallback
    }

    /**
     * Reads an Int value synchronized from Flutter.
     */
    fun getInt(context: Context, key: String, fallback: Int = 0): Int {
        val prefs = getPreferences(context)
        return try {
            prefs.getInt(key, fallback)
        } catch (e: ClassCastException) {
            prefs.getString(key, null)?.toIntOrNull() ?: fallback
        }
    }

    /**
     * Reads a Boolean value synchronized from Flutter.
     */
    fun getBoolean(context: Context, key: String, fallback: Boolean = false): Boolean {
        val prefs = getPreferences(context)
        return try {
            prefs.getBoolean(key, fallback)
        } catch (e: ClassCastException) {
            prefs.getString(key, null)?.toBooleanStrictOrNull() ?: fallback
        }
    }

    /**
     * Reads a Double / Float value synchronized from Flutter.
     */
    fun getDouble(context: Context, key: String, fallback: Double = 0.0): Double {
        val prefs = getPreferences(context)
        return try {
            prefs.getFloat(key, fallback.toFloat()).toDouble()
        } catch (e: ClassCastException) {
            prefs.getString(key, null)?.toDoubleOrNull() ?: fallback
        }
    }

    /**
     * Reads the file path of an off-screen Flutter rendered image snapshot.
     */
    fun getImagePath(context: Context, key: String): String? {
        val path = getString(context, key, "")
        if (path.isEmpty() || !File(path).exists()) return null
        return path
    }

    /**
     * Decodes and loads an off-screen Flutter rendered image snapshot as a Bitmap.
     */
    fun getImageBitmap(context: Context, key: String): Bitmap? {
        val path = getImagePath(context, key) ?: return null
        return BitmapFactory.decodeFile(path)
    }

    /**
     * Retrieves an action URI for deep linking when the widget is clicked.
     */
    fun getActionUri(context: Context, key: String): Uri? {
        val uriString = getString(context, "${key}_action_uri", "")
        if (uriString.isEmpty()) return null
        return Uri.parse(uriString)
    }
}
