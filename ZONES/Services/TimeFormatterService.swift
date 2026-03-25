import Foundation

class TimeFormatterService {
    static let shared = TimeFormatterService()

    private var formatters: [String: DateFormatter] = [:]

    private init() {}

    func formatTime(for city: City, at date: Date, use24Hour: Bool) -> String {
        let tz = city.timezone
        let formatter = getFormatter(for: tz, use24Hour: use24Hour)
        return formatter.string(from: date)
    }

    func formatTimezoneAbbreviation(for city: City) -> String {
        return city.timezone.abbreviation() ?? city.timezoneIdentifier
    }

    func formatDate(for city: City, at date: Date) -> String {
        let tz = city.timezone
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func getFormatter(for timezone: TimeZone, use24Hour: Bool) -> DateFormatter {
        let key = "\(timezone.identifier)-\(use24Hour)"
        if let existing = formatters[key] {
            return existing
        }

        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = use24Hour ? "HH:mm" : "h:mm a"
        formatters[key] = formatter
        return formatter
    }
}
