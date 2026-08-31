import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> AppStatusWidgetHomeWidgetEntry {
    AppStatusWidgetHomeWidgetEntry(
      date: Date(),
      title: "CodeStore Status",
      message: "All services operational 🚀",
      status: "Active",
      actionUrl: nil
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (AppStatusWidgetHomeWidgetEntry) -> Void) {
    completion(createEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    completion(Timeline(entries: [createEntry()], policy: .atEnd))
  }

  private func createEntry() -> AppStatusWidgetHomeWidgetEntry {
    let title = WidgetBridge.string(forKey: "title", fallback: "CodeStore Status")
    let message = WidgetBridge.string(forKey: "message", fallback: "All services operational 🚀")
    let status = WidgetBridge.string(forKey: "status", fallback: "Active")
    let actionUrl = WidgetBridge.actionUrl(forKey: "action_uri") ?? WidgetBridge.actionUrl(forKey: "title")

    return AppStatusWidgetHomeWidgetEntry(
      date: Date(),
      title: title,
      message: message,
      status: status,
      actionUrl: actionUrl
    )
  }
}

struct AppStatusWidgetHomeWidgetEntry: TimelineEntry {
  let date: Date
  let title: String
  let message: String
  let status: String
  let actionUrl: URL?
}

struct AppStatusWidgetHomeWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header Row: App Icon + Title + Status Pill
      HStack(spacing: 8) {
        ZStack {
          RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(
              LinearGradient(
                colors: [Color.purple, Color.indigo],
                begin: .topLeading,
                end: .bottomTrailing
              )
            )
            .frame(width: 24, height: 24)
          Image(systemName: "app.badge.checkmark.fill")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white)
        }

        Text(entry.title)
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(.primary)
          .lineLimit(1)

        Spacer()

        Text(entry.status)
          .font(.system(size: 10, weight: .bold))
          .padding(.horizontal, 7)
          .padding(.vertical, 3)
          .background(Color.green.opacity(0.2))
          .foregroundColor(.green)
          .clipShape(Capsule())
      }

      // Message Body
      Text(entry.message)
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(.secondary)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      Spacer()

      // Footer: Live Time & Date
      HStack {
        HStack(spacing: 4) {
          Circle()
            .fill(Color.green)
            .frame(width: 6, height: 6)
          Text(entry.date, style: .time)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.secondary)
        }

        Spacer()

        Text(entry.date, style: .date)
          .font(.system(size: 9))
          .foregroundColor(.secondary.opacity(0.8))
      }
    }
    .padding(12)
    .applyContainerBackground()
    .widgetURL(entry.actionUrl)
  }
}

struct AppStatusWidgetHomeWidget: Widget {
  let kind: String = "AppStatusWidgetHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      AppStatusWidgetHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("CodeStore Status")
    .description("Live operational status and quick shortcuts.")
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
  AppStatusWidgetHomeWidgetEntryView(
    entry: AppStatusWidgetHomeWidgetEntry(
      date: Date(),
      title: "CodeStore Status",
      message: "All services operational 🚀",
      status: "Active",
      actionUrl: nil
    )
  )
}
