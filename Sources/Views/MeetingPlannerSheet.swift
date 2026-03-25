import SwiftUI

struct MeetingPlannerSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var plannerService = MeetingPlannerService()
    @StateObject private var cityStore = CityStore.shared

    @State private var selectedCities: Set<String> = []
    @State private var duration: TimeInterval = 3600
    @State private var workingHoursStart = Date()
    @State private var workingHoursEnd = Date()
    @State private var slots: [MeetingSlot] = []
    @State private var showResults = false

    private let durationOptions: [TimeInterval] = [1800, 3600, 5400, 7200, 10800]

    var body: some View {
        VStack(spacing: 16) {
            Text("Plan a Meeting")
                .font(.headline)

            Form {
                Picker("Duration", selection: $duration) {
                    ForEach(durationOptions, id: \.self) { dur in
                        Text(formatDuration(dur)).tag(dur)
                    }
                }
                .labelsHidden()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Participants")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(Array(selectedCities), id: \.self) { cityId in
                        if let city = cityStore.cities.first(where: { $0.id.uuidString == cityId }) {
                            HStack {
                                Text(city.name)
                                Spacer()
                                Button(action: { selectedCities.remove(cityId) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Menu {
                        ForEach(cityStore.cities) { city in
                            Button(city.name) {
                                selectedCities.insert(city.id.uuidString)
                            }
                        }
                    } label: {
                        Label("Add Timezone", systemImage: "plus")
                    }
                }

                HStack {
                    DatePicker("From", selection: $workingHoursStart, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    DatePicker("To", selection: $workingHoursEnd, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }

            Divider()

            if showResults {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(slots) { slot in
                            slotRow(slot)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("Find Slots") {
                    calculateSlots()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 500, height: 500)
    }

    private func slotRow(_ slot: MeetingSlot) -> some View {
        let participants = cityStore.cities.filter { selectedCities.contains($0.id.uuidString) }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatter.string(from: slot.startTimeUTC))
                    .font(.system(size: 13, weight: .medium))

                if slot.isValid {
                    Text("All within working hours")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    ForEach(slot.conflicts, id: \.cityId) { conflict in
                        Text(conflict.reason)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            Spacer()
        }
        .padding(8)
        .background(slot.isValid ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(6)
    }

    private func calculateSlots() {
        let participants = cityStore.cities.filter { selectedCities.contains($0.id.uuidString) }
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: workingHoursStart)
        startComponents.hour = 9
        startComponents.minute = 0
        let startDate = calendar.date(from: startComponents) ?? Date()

        var endComponents = calendar.dateComponents([.year, .month, .day], from: workingHoursEnd)
        endComponents.hour = 18
        endComponents.minute = 0

        var hours = WorkingHours.default
        hours.startHour = 9
        hours.endHour = 18

        slots = plannerService.calculateSlots(
            duration: duration,
            participants: participants,
            workingHours: hours,
            onDate: Date()
        )

        showResults = true
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if minutes == 0 {
            return "\(hours) hr"
        }
        return "\(hours) hr \(minutes) min"
    }
}
