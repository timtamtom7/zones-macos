import SwiftUI

struct CompareZonesView: View {
    let cities: [City]

    @State private var compareCities: [City] = []
    @State private var showCityPicker = false

    private let workingHoursService = WorkingHoursService.shared

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Compare Zones")
                    .font(.headline)
                Spacer()
                Button("Add Zone") {
                    showCityPicker = true
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(compareCities) { city in
                        zoneColumn(city)
                        if city.id != compareCities.last?.id {
                            Divider()
                        }
                    }

                    if compareCities.isEmpty {
                        Text("Add zones to compare")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }

            Divider()

            // Time differences
            if compareCities.count >= 2 {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<compareCities.count-1, id: \.self) { i in
                        let diff = timeDifference(from: compareCities[i], to: compareCities[i+1])
                        Text(diff)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showCityPicker) {
            CityPickerSheet(selectedCities: $compareCities, isPresented: $showCityPicker)
        }
        .onAppear {
            if compareCities.isEmpty {
                compareCities = Array(cities.prefix(4))
            }
        }
    }

    @ViewBuilder
    private func zoneColumn(_ city: City) -> some View {
        VStack(spacing: 8) {
            // City name
            Text(city.name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            // Current time
            if let tz = city.timezone {
                let timeString = currentTimeString(for: tz)
                Text(timeString)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
            }

            // Date
            if let tz = city.timezone {
                let dateString = currentDateString(for: tz)
                Text(dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Timezone abbreviation
            Text(city.timezoneAbbreviation)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)

            // Working hours bar
            if let tz = city.timezone {
                WorkingHoursBarView(timeZone: tz)
            }

            // Remove button
            Button(action: { compareCities.removeAll { $0.id == city.id } }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .frame(minWidth: 120)
        .padding(.horizontal, 8)
    }

    private func currentTimeString(for timezone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    private func currentDateString(for timezone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "EEE MMM d"
        return formatter.string(from: Date())
    }

    private func timeDifference(from source: City, to target: City) -> String {
        guard let sourceTz = source.timezone, let targetTz = target.timezone else { return "" }
        let diff = targetTz.secondsFromGMT() - sourceTz.secondsFromGMT()
        let hours = diff / 3600
        let sign = hours >= 0 ? "+" : ""
        return "\(source.name) is \(abs(hours))h \(sign)\(abs(hours)) from \(target.name)"
    }
}

struct WorkingHoursBarView: View {
    let timeZone: TimeZone

    var body: some View {
        let status = WorkingHoursService.shared.isWithinWorkingHours(for: City(id: UUID(), name: "", country: "", timezoneIdentifier: timeZone.identifier, sortOrder: 0, isLocal: false, isFavorite: false), at: Date())
        let color = Color(hex: status.color) ?? .gray

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.3))

                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: barWidth(in: geometry.size.width))
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 4)
    }

    private func barWidth(in totalWidth: CGFloat) -> CGFloat {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let minutesFromMidnight = hour * 60 + minute
        return max(0, min(totalWidth, CGFloat(minutesFromMidnight) / (24 * 60) * totalWidth))
    }
}

struct CityPickerSheet: View {
    @Binding var selectedCities: [City]
    @Binding var isPresented: Bool
    @StateObject private var cityStore = CityStore.shared

    var body: some View {
        VStack {
            Text("Select Cities")
                .font(.headline)
            List(cityStore.cities) { city in
                HStack {
                    Text(city.name)
                    Spacer()
                    if selectedCities.contains(where: { $0.id == city.id }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = selectedCities.firstIndex(where: { $0.id == city.id }) {
                        selectedCities.remove(at: index)
                    } else if selectedCities.count < 4 {
                        selectedCities.append(city)
                    }
                }
            }
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}
