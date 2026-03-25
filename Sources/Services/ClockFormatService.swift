import Foundation

final class ClockFormatService {
    static let shared = ClockFormatService()

    func formatTime(_ date: Date, in timezone: TimeZone, format: ClockFormat) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone

        if format.use24Hour {
            formatter.dateFormat = format.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = format.showSeconds ? "h:mm:ss a" : "h:mm a"
        }

        var result = formatter.string(from: date)

        if format.showTimezoneAbbreviation {
            let abbrev = timezone.abbreviation(for: date) ?? timezone.identifier
            result += " \(abbrev)"
        }

        return result
    }

    func digitalFormats() -> [String] {
        [
            "HH:mm",
            "h:mm a",
            "HH:mm:ss",
            "h:mm:ss a",
            "HH:mm z",
            "HH:mm Z",
            "HH:mm:ss z",
            "HH:mm:ss Z"
        ]
    }
}
