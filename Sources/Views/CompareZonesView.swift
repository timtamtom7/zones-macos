import SwiftUI

struct CompareZonesView: View {
    let cities: [City]

    @State private var compareCities: [City] = []
    @State private var showCityPicker = false

    private let workingHoursService = WorkingHoursService.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Compare Zones")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Add Zone") {
                    showCityPicker = true
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add zone to compare")
                .accessibilityHint("Opens a picker to add up to 4 zones for side-by-side comparison")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(compareCities) { city in
                        zoneColumn(city)
                        if city.id != compareCities.last?.id {
                            Rectangle()
                                .fill(.secondary.opacity(0.2))
                                .frame(width: 1)
                                .padding(.vertical, 16)
                        }
                    }

                    if compareCities.isEmpty {
                        Text("Add zones to compare")
                            .foregroundStyle(.secondary)
                            .padding(32)
                    }
                }
            }
            .padding(.vertical, 16)

            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(height: 1)

            if compareCities.count >= 2 {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<compareCities.count-1, id: \.self) { i in
                        let diff = timeDifference(from: compareCities[i], to: compareCities[i+1])
                        Text(diff)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
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
            Text(city.name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            if let tz = city.timezone {
                let timeString = currentTimeString(for: tz)
                Text(timeString)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
            }

            if let tz = city.timezone {
                let dateString = currentDateString(for: tz)
                Text(dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(city.timezoneAbbreviation)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12, style: .continuous))

            if let tz = city.timezone {
                WorkingHoursBarView(timeZone: tz)
            }

            Button(action: { compareCities.removeAll { $0.id == city.id } }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(city.name) from comparison")
        }
        .frame(minWidth: 120)
        .padding(.horizontal, 12)
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
        let sign = hours >= 0 ? "ahead" : "behind"
        return "\(source.name) is \(abs(hours))h \(sign) \(target.name)"
    }
}

struct WorkingHoursBarView: View {
    let timeZone: TimeZone

    var body: some View {
        let status = WorkingHoursService.shared.isWithinWorkingHours(for: City(id: UUID(), name: "", country: "", timezoneIdentifier: timeZone.identifier, sortOrder: 0, isLocal: false, isFavorite: false), at: Date())
        let color = Color(hex: status.color) ?? .gray

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))

                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: barWidth(in: geometry.size.width))
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 8)
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
        VStack(spacing: 0) {
            HStack {
                Text("Select Cities")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)

            List(cityStore.cities) { city in
                HStack {
                    Text(city.name)
                    Spacer()
                    if selectedCities.contains(where: { $0.id == city.id }) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
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
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 300, height: 400)
    }
}
