package com.nungu.codestore

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
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

class AppStatusWidgetHomeWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { WidgetContent(context, currentState()) }
  }

  @Composable
  private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
    val title = WidgetBridge.getString(context, "title", "CodeStore Status")
    val message = WidgetBridge.getString(context, "message", "All services operational 🚀")
    val status = WidgetBridge.getString(context, "status", "Active")

    Column(
      modifier = GlanceModifier
        .fillMaxSize()
        .background(Color(0xFF13131A))
        .padding(14.dp)
    ) {
      // Header
      Row(
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(
          text = title,
          style = TextStyle(
            color = Color.White,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold
          )
        )
        Spacer(modifier = GlanceModifier.defaultWeight())
        Box(
          modifier = GlanceModifier
            .background(Color(0x2E4CAF50))
            .cornerRadius(12.dp)
            .padding(horizontal = 8.dp, vertical = 2.dp)
        ) {
          Text(
            text = status,
            style = TextStyle(
              color = Color(0xFF81C784),
              fontSize = 10.sp,
              fontWeight = FontWeight.Bold
            )
          )
        }
      }

      Spacer(modifier = GlanceModifier.height(8.dp))

      // Message
      Text(
        text = message,
        style = TextStyle(
          color = Color(0xFFB0B0C0),
          fontSize = 12.sp
        )
      )

      Spacer(modifier = GlanceModifier.defaultWeight())

      // Footer
      Row(
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(
          text = "● Operational",
          style = TextStyle(
            color = Color(0xFF81C784),
            fontSize = 10.sp
          )
        )
      }
    }
  }
}
