import WidgetKit
import SwiftUI

struct WorldClockWidget: Widget {
    let kind: String = "WorldClockWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorldClockProvider()) { entry in
            WorldClockWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("World Clock Pro")
        .description("Detailed world clock with DST indicators.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct WorldClockEntry: TimelineEntry {
    let date: Date
    let zones: [WidgetCityTime]
}

struct WorldClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorldClockEntry {
        WorldClockEntry(date: Date(), zones: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorldClockEntry) -> Void) {
        let entry = WorldClockEntry(date: Date(), zones: loadZones())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorldClockEntry>) -> Void) {
        let entry = WorldClockEntry(date: Date(), zones: loadZones())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadZones() -> [WidgetCityTime] {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zones.app"),
              let data = try? Data(contentsOf: containerURL.appendingPathComponent("widget_zones.json")),
              let cities = try? JSONDecoder().decode([City].self, from: data) else {
            return [
                WidgetCityTime(from: City(id: UUID(), name: "Los Angeles", country: "US", timezoneIdentifier: "America/Los_Angeles", sortOrder: 0, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "New York", country: "US", timezoneIdentifier: "America/New_York", sortOrder: 1, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "London", country: "UK", timezoneIdentifier: "Europe/London", sortOrder: 2, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "Tokyo", country: "JP", timezoneIdentifier: "Asia/Tokyo", sortOrder: 3, isLocal: false, isFavorite: false))
            ]
        }
        return cities.map { WidgetCityTime(from: $0) }
    }
}

struct WorldClockWidgetView: View {
    var entry: WorldClockEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("ZONES")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(entry.zones.prefix(6)) { zone in
                    ZoneCardView(zone: zone)
                }
            }
        }
        .padding(12)
    }
}

struct ZoneCardView: View {
    let zone: WidgetCityTime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(zone.cityName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(zone.currentTime)
                .font(.title3)
                .fontWeight(.bold)
            
            HStack {
                Text("UTC\(zone.offset)")
                    .font(.caption2)
                if zone.isDST {
                    Text("• DST")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
