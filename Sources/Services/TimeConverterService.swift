import Foundation

final class TimeConverterService: ObservableObject {
    struct ConversionResult: Identifiable {
        let id = UUID()
        let city: City
        let localTime: Date
        let formattedTime: String
        let isNextDay: Bool
    }

    func convert(time: Date, in sourceZone: TimeZone, to targetZones: [City]) -> [ConversionResult] {
        targetZones.compactMap { city in
            guard let tz = city.timezone else { return nil }

            var sourceCalendar = Calendar(identifier: .gregorian)
            sourceCalendar.timeZone = sourceZone

            var targetCalendar = Calendar(identifier: .gregorian)
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
        let sourceOffset = Double(source.secondsFromGMT()) / 3600.0
        let targetOffset = Double(target.secondsFromGMT()) / 3600.0
        let diff = targetOffset - sourceOffset
        let sign = diff >= 0 ? "+" : ""
        if diff.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(sign)\(Int(diff))h"
        } else {
            return "\(sign)\(diff)h"
        }
    }
}
