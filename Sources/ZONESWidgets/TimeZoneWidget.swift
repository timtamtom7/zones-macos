import WidgetKit
import SwiftUI

struct TimeZoneEntry: TimelineEntry {
    let date: Date
    let zones: [WidgetCityTime]
    var showDST: Bool = true
    var use24h: Bool = false
}

struct WidgetCityTime: Identifiable, Codable {
    let id: UUID
    let cityName: String
    let country: String
    let timezoneIdentifier: String
    let offset: String
    let isDST: Bool
    
    init(from city: City) {
        self.id = city.id
        self.cityName = city.name
        self.country = city.country
        self.timezoneIdentifier = city.timezoneIdentifier
        
        let tz = city.timezone ?? TimeZone.current
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds / 60) % 60
        if minutes == 0 {
            self.offset = hours >= 0 ? "+\(hours)" : "\(hours)"
        } else {
            self.offset = hours >= 0 ? "+\(hours):\(minutes)" : "\(hours):\(minutes)"
        }
        
        self.isDST = tz.isDaylightSavingTime(for: Date())
    }
    
    var currentTime: String {
        let tz = TimeZone(identifier: timezoneIdentifier) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    var currentTime24h: String {
        let tz = TimeZone(identifier: timezoneIdentifier) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimeZoneEntry {
        TimeZoneEntry(
            date: Date(),
            zones: [
                WidgetCityTime(from: City(id: UUID(), name: "Los Angeles", country: "US", timezoneIdentifier: "America/Los_Angeles", sortOrder: 0, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "New York", country: "US", timezoneIdentifier: "America/New_York", sortOrder: 1, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "London", country: "UK", timezoneIdentifier: "Europe/London", sortOrder: 2, isLocal: false, isFavorite: false))
            ],
            showDST: true,
            use24h: false
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeZoneEntry) -> Void) {
        let showDST = UserDefaults.standard.bool(forKey: "widgetShowDST")
        let use24h = UserDefaults.standard.string(forKey: "widgetTimeFormat") == "24h"
        let entry = TimeZoneEntry(date: Date(), zones: loadSelectedZones(), showDST: showDST, use24h: use24h)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeZoneEntry>) -> Void) {
        let showDST = UserDefaults.standard.bool(forKey: "widgetShowDST")
        let use24h = UserDefaults.standard.string(forKey: "widgetTimeFormat") == "24h"
        let entry = TimeZoneEntry(date: Date(), zones: loadSelectedZones(), showDST: showDST, use24h: use24h)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadSelectedZones() -> [WidgetCityTime] {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zones.app"),
              let data = try? Data(contentsOf: containerURL.appendingPathComponent("widget_zones.json")),
              let cities = try? JSONDecoder().decode([City].self, from: data) else {
            return [
                WidgetCityTime(from: City(id: UUID(), name: "Los Angeles", country: "US", timezoneIdentifier: "America/Los_Angeles", sortOrder: 0, isLocal: false, isFavorite: false)),
                WidgetCityTime(from: City(id: UUID(), name: "New York", country: "US", timezoneIdentifier: "America/New_York", sortOrder: 1, isLocal: false, isFavorite: false))
            ]
        }
        return cities.map { WidgetCityTime(from: $0) }
    }
}

struct TimeZoneWidget: Widget {
    let kind: String = "TimeZoneWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeZoneWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("World Clock")
        .description("Shows current times for your selected zones.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct TimeZoneWidgetView: View {
    var entry: TimeZoneEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: TimeZoneEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ZONES")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Divider()
            
            ForEach(entry.zones.prefix(3)) { zone in
                HStack {
                    Text(zone.cityName.prefix(3).uppercased())
                        .font(.caption2)
                        .fontWeight(.medium)
                    Spacer()
                    Text(entry.use24h ? zone.currentTime24h : zone.currentTime)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(8)
    }
}

struct MediumWidgetView: View {
    let entry: TimeZoneEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ZONES")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("World Clock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            ForEach(entry.zones.prefix(4)) { zone in
                VStack(alignment: .leading, spacing: 2) {
                    Text(zone.cityName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.use24h ? zone.currentTime24h : zone.currentTime)
                        .font(.headline)
                        .fontWeight(.semibold)
                    if zone.isDST && entry.showDST {
                        Text("DST")
                            .font(.system(size: 8))
                            .padding(.horizontal, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(12)
    }
}

struct CircularWidgetView: View {
    let entry: TimeZoneEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(entry.zones.first.map { entry.use24h ? $0.currentTime24h : $0.currentTime } ?? "--:--")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }
        }
    }
}

struct RectangularWidgetView: View {
    let entry: TimeZoneEntry
    
    var body: some View {
        HStack {
            if let first = entry.zones.first {
                VStack(alignment: .leading) {
                    Text(first.cityName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.use24h ? first.currentTime24h : first.currentTime)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            Spacer()
            if entry.zones.count > 1, let second = entry.zones.dropFirst().first {
                VStack(alignment: .trailing) {
                    Text(second.cityName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.use24h ? second.currentTime24h : second.currentTime)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
    }
}
