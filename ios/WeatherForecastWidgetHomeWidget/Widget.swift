import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> WeatherForecastWidgetHomeWidgetEntry {
    WeatherForecastWidgetHomeWidgetEntry(
      date: Date(),
      title: "Weather Forecast",
      message: "Sunny, 72°F in New York",
      status: "NYC",
      image: nil,
      actionUrl: nil
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (WeatherForecastWidgetHomeWidgetEntry) -> Void) {
    completion(createEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    completion(Timeline(entries: [createEntry()], policy: .atEnd))
  }

  private func createEntry() -> WeatherForecastWidgetHomeWidgetEntry {
    let title = WidgetBridge.string(forKey: "title", fallback: "Weather Forecast")
    let message = WidgetBridge.string(forKey: "message", fallback: "Sunny, 72°F")
    let status = WidgetBridge.string(forKey: "status", fallback: "Live")
    let image = WidgetBridge.image(forKey: "home_widget_image")
    let actionUrl = WidgetBridge.actionUrl(forKey: "home_widget_image") ?? WidgetBridge.actionUrl(forKey: "title")

    return WeatherForecastWidgetHomeWidgetEntry(
      date: Date(),
      title: title,
      message: message,
      status: status,
      image: image,
      actionUrl: actionUrl
    )
  }
}

struct WeatherForecastWidgetHomeWidgetEntry: TimelineEntry {
  let date: Date
  let title: String
  let message: String
  let status: String
  let image: UIImage?
  let actionUrl: URL?
}

struct WeatherForecastWidgetHomeWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    Group {
      if let image = entry.image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
      } else {
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Image(systemName: "sun.max.fill")
              .foregroundColor(.yellow)
            Text(entry.title)
              .font(.system(size: 13, weight: .bold))
              .foregroundColor(.primary)
            Spacer()
            Text(entry.status)
              .font(.system(size: 10, weight: .semibold))
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.blue.opacity(0.2))
              .foregroundColor(.blue)
              .cornerRadius(6)
          }

          Text(entry.message)
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .lineLimit(2)

          Spacer()

          HStack {
            Text(entry.date, style: .time)
              .font(.system(size: 10))
              .foregroundColor(.secondary)
            Spacer()
            Text(entry.date, style: .date)
              .font(.system(size: 9))
              .foregroundColor(.secondary)
          }
        }
        .padding(12)
        .applyContainerBackground()
      }
    }
    .widgetURL(entry.actionUrl)
  }
}

struct WeatherForecastWidgetHomeWidget: Widget {
  let kind: String = "WeatherForecastWidgetHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WeatherForecastWidgetHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Weather Forecast")
    .description("Displays real-time weather forecasts and updates.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

extension View {
  @ViewBuilder
  func applyContainerBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self.containerBackground(.fill.tertiary, for: .widget)
    } else if #available(iOSApplicationExtension 15.0, *) {
      self.background()
    } else {
      self
    }
  }
}

#Preview {
  WeatherForecastWidgetHomeWidgetEntryView(
    entry: WeatherForecastWidgetHomeWidgetEntry(
      date: Date(),
      title: "Weather Forecast",
      message: "Sunny, 72°F in New York",
      status: "NYC",
      image: nil,
      actionUrl: nil
    )
  )
}
