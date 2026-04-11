import SwiftUI

struct MeetingPlannerSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var cityStore = CityStore.shared
    private let plannerService = MeetingPlannerService()

    @State private var selectedCities: Set<String> = []
    @State private var duration: TimeInterval = 3600
    @State private var workingHoursStart = Date()
    @State private var workingHoursEnd = Date()
    @State private var slots: [MeetingSlot] = []
    @State private var showResults = false

    private let durationOptions: [TimeInterval] = [1800, 3600, 5400, 7200, 10800]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Plan a Meeting")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close meeting planner")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)

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
                        .foregroundStyle(.secondary)

                    ForEach(Array(selectedCities), id: \.self) { cityId in
                        if let city = cityStore.cities.first(where: { $0.id.uuidString == cityId }) {
                            HStack {
                                Text(city.name)
                                Spacer()
                                Button(action: { selectedCities.remove(cityId) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
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
                    .accessibilityLabel("Add timezone participant")
                    .accessibilityHint("Opens a menu to select additional cities for the meeting")
                }

                HStack {
                    DatePicker("From", selection: $workingHoursStart, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accessibilityLabel("Working hours start time")
                    DatePicker("To", selection: $workingHoursEnd, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accessibilityLabel("Working hours end time")
                }
            }
            .padding(16)

            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(height: 1)

            if showResults {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(slots) { slot in
                            slotRow(slot)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: 200)
                .scrollContentBackground(.hidden)
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("Find Slots") {
                    calculateSlots()
                }
                .buttonStyle(.capsule)
                .accessibilityLabel("Find meeting slots")
                .accessibilityHint("Calculates optimal meeting times across all selected timezones")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
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
                        .foregroundStyle(.green)
                } else {
                    ForEach(slot.conflicts, id: \.cityId) { conflict in
                        Text(conflict.reason)
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(slot.isValid ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }

    private func calculateSlots() {
        let participants = cityStore.cities.filter { selectedCities.contains($0.id.uuidString) }
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: workingHoursStart)
        let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: workingHoursEnd)

        let hours = WorkingHours(
            startHour: startComponents.hour ?? 9,
            startMinute: startComponents.minute ?? 0,
            endHour: endComponents.hour ?? 18,
            endMinute: endComponents.minute ?? 0
        )

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
