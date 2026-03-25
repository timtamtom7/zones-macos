import Foundation

class TimeFormatterService {
    static let shared = TimeFormatterService()

    private var timeFormatter12: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm:ss a"
        return f
    }()

    private var timeFormatter24: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private var timeFormatter12Short: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private var timeFormatter24Short: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private init() {}

    func formatTime(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        let formatter = use24Hour ? timeFormatter24 : timeFormatter12
        formatter.timeZone = timezone
        return formatter.string(from: date)
    }

    func formatTimeShort(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        let formatter = use24Hour ? timeFormatter24Short : timeFormatter12Short
        formatter.timeZone = timezone
        return formatter.string(from: date)
    }

    func formatTimeWithSeconds(_ date: Date, timezone: TimeZone, use24Hour: Bool) -> String {
        let formatter = use24Hour ? timeFormatter24 : timeFormatter12
        formatter.timeZone = timezone
        return formatter.string(from: date)
    }

    func getTimezoneAbbreviation(for city: City) -> String {
        return city.timezone?.abbreviation() ?? ""
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
