import WidgetKit
import SwiftUI


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry { let date: Date }

struct LaunchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Image(systemName: "list.bullet.circle")
            .resizable()
            .scaledToFit()
            .privacySensitive(false)
    }
}

struct LaunchWidget: Widget {
    let kind: String = "LaunchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LaunchWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quick Access")
        .description("ロック画面からアプリを開くことができます。")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    LaunchWidget()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}
