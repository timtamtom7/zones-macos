import Foundation

final class DSTCalendarService {
    static let shared = DSTCalendarService()

    struct DSTTransition {
        let cityId: String
        let cityName: String
        let transitionDate: Date
        let type: TransitionType
        let daysUntil: Int

        enum TransitionType: String {
            case starts = "DST Starts"
            case ends = "DST Ends"
        }
    }

    func upcomingTransitions(for cities: [City], withinDays: Int = 60) -> [DSTTransition] {
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: withinDays, to: now)!

        var transitions: [DSTTransition] = []

        for city in cities {
            guard let tz = city.timezone else { continue }

            if let nextTransition = tz.nextDaylightSavingTimeTransition(after: now) {
                let daysUntil = Calendar.current.dateComponents([.day], from: now, to: nextTransition).day ?? 0
                if nextTransition <= endDate {
                    let type: DSTTransition.TransitionType = tz.isDaylightSavingTime(for: now) ? .ends : .starts
                    transitions.append(DSTTransition(
                        cityId: city.id.uuidString,
                        cityName: city.name,
                        transitionDate: nextTransition,
                        type: type,
                        daysUntil: daysUntil
                    ))
                }
            }
        }

        return transitions.sorted { $0.daysUntil < $1.daysUntil }
    }

    func formatTransitionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
