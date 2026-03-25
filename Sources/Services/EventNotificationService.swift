import Foundation
import UserNotifications

final class EventNotificationService: NSObject, ObservableObject {
    static let shared = EventNotificationService()

    @Published var events: [EventNotification] = []

    override private init() {
        super.init()
        loadEvents()
    }

    func addEvent(_ event: EventNotification) {
        events.append(event)
        saveEvents()
        scheduleNotification(for: event)
    }

    func removeEvent(id: UUID) {
        events.removeAll { $0.id == id }
        saveEvents()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    func toggleEvent(id: UUID) {
        if let index = events.firstIndex(where: { $0.id == id }) {
            events[index].isEnabled.toggle()
            saveEvents()

            if events[index].isEnabled {
                scheduleNotification(for: events[index])
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [events[index].id.uuidString])
            }
        }
    }

    private func scheduleNotification(for event: EventNotification) {
        guard event.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "Time in \(event.cityName)"
        content.sound = .default
        content.userInfo = ["cityId": event.cityId]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: event.triggerTimeUTC)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: event.isRecurring)

        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func loadEvents() {
        guard let data = UserDefaults.standard.data(forKey: "eventNotifications"),
              let decoded = try? JSONDecoder().decode([EventNotification].self, from: data) else {
            return
        }
        events = decoded
    }

    private func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "eventNotifications")
        }
    }
}
