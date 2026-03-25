import Foundation

struct MeetingSlot: Identifiable, Hashable {
    let id: UUID
    let startTimeUTC: Date
    let duration: TimeInterval
    let conflicts: [Conflict]

    struct Conflict: Hashable {
        let cityId: String
        let reason: String
    }

    var isValid: Bool { conflicts.isEmpty }

    init(startTimeUTC: Date, duration: TimeInterval, conflicts: [Conflict] = []) {
        self.id = UUID()
        self.startTimeUTC = startTimeUTC
        self.duration = duration
        self.conflicts = conflicts
    }
}

struct WorkingHours: Codable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    var startMinutesFromMidnight: Int { startHour * 60 + startMinute }
    var endMinutesFromMidnight: Int { endHour * 60 + endMinute }

    static let `default` = WorkingHours(startHour: 9, startMinute: 0, endHour: 18, endMinute: 0)
}

struct EventNotification: Identifiable, Codable {
    let id: UUID
    var title: String
    var cityId: String
    var cityName: String
    var triggerTimeUTC: Date
    var isRecurring: Bool
    var repeatInterval: RepeatInterval?
    var isEnabled: Bool

    enum RepeatInterval: String, Codable {
        case daily
        case weekly
        case monthly
    }

    init(id: UUID = UUID(), title: String, cityId: String, cityName: String, triggerTimeUTC: Date, isRecurring: Bool = false, repeatInterval: RepeatInterval? = nil, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.cityId = cityId
        self.cityName = cityName
        self.triggerTimeUTC = triggerTimeUTC
        self.isRecurring = isRecurring
        self.repeatInterval = repeatInterval
        self.isEnabled = isEnabled
    }
}
