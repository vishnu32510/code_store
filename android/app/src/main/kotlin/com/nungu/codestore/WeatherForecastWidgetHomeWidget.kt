package com.nungu.codestore

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class WeatherForecastWidgetHomeWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { WidgetContent(context, currentState()) }
  }

  @Composable
  private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
    val bitmap = WidgetBridge.getImageBitmap(context, "home_widget_image")
    val title = WidgetBridge.getString(context, "title", "Weather Forecast")
    val message = WidgetBridge.getString(context, "message", "Sunny, 72°F")
    val status = WidgetBridge.getString(context, "status", "Live")

    if (bitmap != null) {
      Box(modifier = GlanceModifier.fillMaxSize()) {
        Image(
          provider = ImageProvider(bitmap),
          contentDescription = "Widget Snapshot",
          modifier = GlanceModifier.fillMaxSize()
        )
      }
    } else {
      Column(
        modifier = GlanceModifier
          .fillMaxSize()
          .background(Color(0xFF1E1E2E))
          .padding(12.dp)
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(
            text = title,
            style = TextStyle(color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
          )
        }
        Spacer(modifier = GlanceModifier.height(4.dp))
        Text(
          text = message,
          style = TextStyle(color = Color(0xFFCCCCCC), fontSize = 12.sp)
        )
        Spacer(modifier = GlanceModifier.defaultWeight())
        Text(
          text = status,
          style = TextStyle(color = Color(0xFF64B5F6), fontSize = 10.sp)
        )
      }
    }
  }
}
