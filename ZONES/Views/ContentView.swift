import SwiftUI

struct ContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentColor)
                Text("ZONES")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Button(action: { appState.showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .opacity(0.7)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                TextField("Search cities...", text: .constant(""))
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(NSColor.textBackgroundColor))

            Divider()

            // Zone list
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Local time section
                    LocalTimeRowView()
                        .padding(.vertical, 2)

                    Divider()
                        .padding(.vertical, 4)

                    // Other cities
                    ForEach(appState.cities) { city in
                        ZoneRowView(city: city, currentTime: appState.currentTime, use24Hour: appState.use24HourFormat)
                            .padding(.vertical, 2)
                        Divider()
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(maxHeight: 320)

            Divider()

            // Add city button
            Button(action: { appState.showingAddCity = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add City")
                }
                .font(.system(size: 12))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 340, height: 460)
        .sheet(isPresented: $appState.showingAddCity) {
            AddCitySheet(appState: appState)
        }
        .sheet(isPresented: $appState.showingSettings) {
            SettingsSheet(appState: appState)
        }
    }
}

struct LocalTimeRowView: View {
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Your Time (\(TimeZone.current.identifier))")
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Text(timeString)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
            Text(TimeZone.current.abbreviation() ?? "")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

struct SettingsSheet: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
            }

            Divider()

            Toggle("Use 24-hour format", isOn: Binding(
                get: { appState.use24HourFormat },
                set: { appState.setUse24HourFormat($0) }
            ))
            .font(.system(size: 13))

            Spacer()
        }
        .padding(20)
        .frame(width: 300, height: 200)
    }
}
