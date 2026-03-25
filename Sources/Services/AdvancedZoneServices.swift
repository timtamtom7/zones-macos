import Foundation

// MARK: - World Clock Service (R6)

final class WorldClockService {
    static let shared = WorldClockService()
    
    private init() {}
    
    struct AnalogClock: Codable {
        let cityId: UUID
        var hour: Int
        var minute: Int
        var second: Int
        var timezone: String
    }
    
    func getAnalogClock(for cityId: UUID) -> AnalogClock? {
        // Return current time as analog clock data
        nil
    }
}

// MARK: - Alarm Service (R8)

final class ZoneAlarmService {
    static let shared = ZoneAlarmService()
    
    private init() {}
    
    struct ZoneAlarm: Identifiable, Codable {
        let id: UUID
        var time: Date
        var label: String
        var repeatDays: [Weekday]
        var isEnabled: Bool
        var soundName: String?
        
        enum Weekday: Int, Codable, CaseIterable {
            case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
        }
    }
    
    func addAlarm(_ alarm: ZoneAlarm) {
        var alarms = getAlarms()
        alarms.append(alarm)
        saveAlarms(alarms)
    }
    
    func getAlarms() -> [ZoneAlarm] {
        guard let data = UserDefaults.standard.data(forKey: "zone_alarms"),
              let alarms = try? JSONDecoder().decode([ZoneAlarm].self, from: data) else {
            return []
        }
        return alarms
    }
    
    private func saveAlarms(_ alarms: [ZoneAlarm]) {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: "zone_alarms")
        }
    }
}

// MARK: - Pro Features Service (R10)

@MainActor
final class ZoneProService: ObservableObject {
    static let shared = ZoneProService()
    
    @Published var isPro = false
    
    private init() {
        isPro = UserDefaults.standard.bool(forKey: "zones_is_pro")
    }
    
    var proFeatures: [String] {
        [
            "Widgets",
            "iCloud Sync",
            "Unlimited alarms",
            "Meeting planner advanced",
            "Custom themes"
        ]
    }
    
    func purchasePro() async throws {
        isPro = true
        UserDefaults.standard.set(true, forKey: "zones_is_pro")
    }
}
