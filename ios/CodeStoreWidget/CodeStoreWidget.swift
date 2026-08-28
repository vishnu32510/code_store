import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "CodeStore Widget",
            message: "Track habits and updates",
            status: "Active",
            imagePath: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntry() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.nungu.codestore")
        let title = userDefaults?.string(forKey: "title") ?? "CodeStore Widget"
        let message = userDefaults?.string(forKey: "message") ?? "No updates yet"
        let status = userDefaults?.string(forKey: "status") ?? "Ready"
        let imagePath = userDefaults?.string(forKey: "home_widget_image")

        return SimpleEntry(
            date: Date(),
            title: title,
            message: message,
            status: status,
            imagePath: imagePath
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let message: String
    let status: String
    let imagePath: String?
}

struct CodeStoreWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let imagePath = entry.imagePath,
           let uiImage = UIImage(contentsOfFile: imagePath) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(Color(red: 0.49, green: 0.30, blue: 1.0))
                    Text(entry.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(entry.status)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.49, green: 0.30, blue: 1.0).opacity(0.25))
                        .foregroundColor(Color(red: 0.70, green: 0.55, blue: 1.0))
                        .cornerRadius(8)
                }

                Text(entry.message)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.65, green: 0.68, blue: 0.78))
                    .lineLimit(3)

                Spacer()

                HStack {
                    Text("Updated \(entry.date, style: .time)")
                        .font(.system(size: 9))
                        .foregroundColor(Color.gray)
                    Spacer()
                }
            }
            .padding()
            .containerBackground(Color(red: 0.12, green: 0.12, blue: 0.18), for: .widget)
        }
    }
}

@main
struct CodeStoreWidget: Widget {
    let kind: String = "CodeStoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CodeStoreWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CodeStore Widget")
        .description("Displays real-time status and quick summaries from CodeStore.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
