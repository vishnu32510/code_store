package com.nungu.codestore

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Universal communication bridge for decoding Flutter structured models and values in Android AppWidgets / Glance.
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
     * Retrieves an action URI for deep linking when the widget is clicked.
     */
    fun getActionUri(context: Context, key: String): Uri? {
        val uriString = getString(context, "${key}_action_uri", "")
            .ifEmpty { getString(context, key, "") }
        if (uriString.isEmpty()) return null
        return try {
            Uri.parse(uriString)
        } catch (e: Exception) {
            null
        }
    }
}
