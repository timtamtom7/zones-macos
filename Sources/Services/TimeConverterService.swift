import Foundation

final class TimeConverterService {
    struct ConversionResult {
        let city: City
        let localTime: Date
        let formattedTime: String
        let isNextDay: Bool
    }

    func convert(time: Date, in sourceZone: TimeZone, to targetZones: [City]) -> [ConversionResult] {
        targetZones.compactMap { city in
            guard let tz = city.timezone else { return nil }

            var sourceCalendar = Calendar.current
            sourceCalendar.timeZone = sourceZone

            var targetCalendar = Calendar.current
            targetCalendar.timeZone = tz

            let sourceDay = sourceCalendar.component(.day, from: time)
            let targetDay = targetCalendar.component(.day, from: time)

            let formatter = DateFormatter()
            formatter.timeZone = tz
            formatter.dateFormat = "h:mm a"

            let formattedTime = formatter.string(from: time)
            let isNextDay = targetDay != sourceDay && targetCalendar.component(.hour, from: time) < sourceCalendar.component(.hour, from: time)

            return ConversionResult(
                city: city,
                localTime: time,
                formattedTime: formattedTime,
                isNextDay: isNextDay
            )
        }
    }

    func formatOffset(from source: TimeZone, to target: TimeZone) -> String {
        let sourceOffset = source.secondsFromGMT() / 3600
        let targetOffset = target.secondsFromGMT() / 3600
        let diff = targetOffset - sourceOffset
        let sign = diff >= 0 ? "+" : ""
        return "\(sign)\(diff)h"
    }
}
