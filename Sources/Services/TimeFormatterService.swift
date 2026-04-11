import Foundation

@MainActor
final class TimeFormatterService {
    static let shared = TimeFormatterService()

    private let formatter12Format = "h:mm:ss a"
    private let formatter24Format = "HH:mm:ss"
    private let formatter12ShortFormat = "h:mm a"
    private let formatter24ShortFormat = "HH:mm"

    private init() {}

    func formatTime(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        let format = use24Hour ? formatter24Format : formatter12Format
        return formatTime(date, timezone: timezone, format: format)
    }

    func formatTimeShort(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        let format = use24Hour ? formatter24ShortFormat : formatter12ShortFormat
        return formatTime(date, timezone: timezone, format: format)
    }

    func formatTimeWithSeconds(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        formatTime(date, timezone: timezone, use24Hour: use24Hour)
    }

    private func formatTime(_ date: Date, timezone: TimeZone, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timezone
        return formatter.string(from: date)
    }

    func getTimezoneAbbreviation(for city: City) -> String {
        city.timezone?.abbreviation() ?? ""
    }

    func getTimezoneOffset(for city: City) -> String {
        guard let tz = city.timezone else { return "" }
        let offset = tz.secondsFromGMT()
        let hours = offset / 3600
        let minutes = abs((offset % 3600) / 60)
        if minutes == 0 {
            return String(format: "UTC%+d", hours)
        }
        return String(format: "UTC%+d:%02d", hours, minutes)
    }
}
