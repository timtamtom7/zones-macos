import Foundation

final class WorkingHoursService {
    static let shared = WorkingHoursService()

    private let defaults = UserDefaults.standard
    private let key = "workingHours"

    func getWorkingHours(for cityId: String) -> WorkingHours {
        guard let data = defaults.data(forKey: "\(key)_\(cityId)"),
              let hours = try? JSONDecoder().decode(WorkingHours.self, from: data) else {
            return .default
        }
        return hours
    }

    func setWorkingHours(_ hours: WorkingHours, for cityId: String) {
        if let data = try? JSONEncoder().encode(hours) {
            defaults.set(data, forKey: "\(key)_\(cityId)")
        }
    }

    func isWithinWorkingHours(for city: City, at time: Date = Date()) -> WorkingHoursStatus {
        let hours = getWorkingHours(for: city.id.uuidString)
        guard let tz = city.timezone else { return .outside }

        var calendar = Calendar.current
        calendar.timeZone = tz
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let minutesFromMidnight = (components.hour ?? 0) * 60 + (components.minute ?? 0)

        if minutesFromMidnight >= hours.startMinutesFromMidnight && minutesFromMidnight < hours.endMinutesFromMidnight {
            return .within
        }

        let distFromStart = abs(minutesFromMidnight - hours.startMinutesFromMidnight)
        let distFromEnd = abs(minutesFromMidnight - hours.endMinutesFromMidnight)
        let threshold = 60

        if distFromStart < threshold || distFromEnd < threshold {
            return .near
        }

        return .outside
    }

    enum WorkingHoursStatus {
        case within
        case near
        case outside

        var color: String {
            switch self {
            case .within: return "#34C759"
            case .near: return "#FFCC00"
            case .outside: return "#FF3B30"
            }
        }
    }
}
