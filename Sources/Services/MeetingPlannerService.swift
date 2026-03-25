import Foundation

final class MeetingPlannerService {
    func calculateSlots(
        duration: TimeInterval,
        participants: [City],
        workingHours: WorkingHours,
        onDate: Date
    ) -> [MeetingSlot] {
        var slots: [MeetingSlot] = []

        // Iterate through the day in 30-minute increments
        let calendar = Calendar.current
        var currentTime = calendar.startOfDay(for: onDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: currentTime)!

        while currentTime < endOfDay {
            let slot = evaluateSlot(at: currentTime, duration: duration, participants: participants, workingHours: workingHours)
            slots.append(slot)
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
        }

        return slots.filter { !$0.conflicts.isEmpty || true } // Keep all slots
    }

    private func evaluateSlot(
        at startTime: Date,
        duration: TimeInterval,
        participants: [City],
        workingHours: WorkingHours
    ) -> MeetingSlot {
        var conflicts: [MeetingSlot.Conflict] = []

        for city in participants {
            guard let tz = city.timezone else { continue }

            var calendar = Calendar.current
            calendar.timeZone = tz

            let components = calendar.dateComponents([.hour, .minute], from: startTime)
            let minutesFromMidnight = (components.hour ?? 0) * 60 + (components.minute ?? 0)

            if minutesFromMidnight < workingHours.startMinutesFromMidnight {
                let earlyBy = workingHours.startMinutesFromMidnight - minutesFromMidnight
                conflicts.append(MeetingSlot.Conflict(
                    cityId: city.id.uuidString,
                    reason: "\(city.name) is \(earlyBy) min before working hours"
                ))
            }

            if minutesFromMidnight + Int(duration / 60) > workingHours.endMinutesFromMidnight {
                let overBy = minutesFromMidnight + Int(duration / 60) - workingHours.endMinutesFromMidnight
                conflicts.append(MeetingSlot.Conflict(
                    cityId: city.id.uuidString,
                    reason: "\(city.name) is \(overBy) min past working hours"
                ))
            }
        }

        return MeetingSlot(startTimeUTC: startTime, duration: duration, conflicts: conflicts)
    }

    func formatSlot(_ slot: MeetingSlot, participants: [City], inZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = inZone
        formatter.dateFormat = "h:mm a"

        let startString = formatter.string(from: slot.startTimeUTC)
        let endString = formatter.string(from: slot.startTimeUTC.addingTimeInterval(slot.duration))

        var parts: [String] = []
        for city in participants {
            guard let tz = city.timezone else { continue }
            formatter.timeZone = tz
            let timeString = formatter.string(from: slot.startTimeUTC)
            parts.append("\(timeString) \(city.name)")
        }

        return "\(startString) - \(endString): \(parts.joined(separator: " | "))"
    }
}
