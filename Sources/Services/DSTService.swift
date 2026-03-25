import Foundation

final class DSTService {
    static let shared = DSTService()

    struct DSTInfo {
        let isDST: Bool
        let abbreviation: String
        let offset: Int
        let nextTransition: Date?
        let daysUntilTransition: Int?
    }

    func getDSTInfo(for timezone: TimeZone) -> DSTInfo {
        let now = Date()
        let isDST = timezone.isDaylightSavingTime(for: now)
        let abbreviation = timezone.abbreviation(for: now) ?? timezone.identifier
        let offset = timezone.secondsFromGMT(for: now) / 3600

        let nextTransition = timezone.nextDaylightSavingTimeTransition(after: now)
        let daysUntilTransition: Int?
        if let next = nextTransition {
            daysUntilTransition = Calendar.current.dateComponents([.day], from: now, to: next).day
        } else {
            daysUntilTransition = nil
        }

        return DSTInfo(
            isDST: isDST,
            abbreviation: abbreviation,
            offset: offset,
            nextTransition: nextTransition,
            daysUntilTransition: daysUntilTransition
        )
    }

    func formatOffset(_ offset: Int) -> String {
        let sign = offset >= 0 ? "+" : ""
        return "GMT\(sign)\(offset)"
    }

    func isDSTTransitionSoon(for timezone: TimeZone, withinDays: Int = 7) -> Bool {
        guard let nextTransition = timezone.nextDaylightSavingTimeTransition(after: Date()) else {
            return false
        }
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextTransition).day ?? 0
        return daysUntil <= withinDays
    }
}
