import SwiftUI

struct MenuBarPopoverView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.accentColor)

                Text("ZONES")
                    .font(.headline)

                Spacer()

                Button(action: { appState.showSettings = true }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search hint
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                Text("Search cities in the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Zone list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(appState.cities) { city in
                        MenuBarZoneRow(city: city, currentTime: appState.currentTime, use24Hour: appState.use24HourFormat)
                    }
                }
            }
            .frame(maxHeight: 300)

            Divider()

            // Footer
            HStack {
                Button(action: { appState.showAddCitySheet = true }) {
                    Label("Add City", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                Spacer()

                Button("Open ZONES...") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .font(.caption)

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            .padding()
        }
        .frame(width: 320)
    }
}

struct MenuBarZoneRow: View {
    let city: City
    let currentTime: Date
    let use24Hour: Bool

    private let timeFormatter = TimeFormatterService.shared

    var body: some View {
        HStack(spacing: 12) {
            if city.isLocal {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
            }

            Text(city.isLocal ? "Local" : city.name)
                .font(.system(size: 13))
                .fontWeight(city.isLocal ? .semibold : .regular)
                .lineLimit(1)

            Spacer()

            Text(timeFormatter.formatTimeShort(currentTime, timezone: city.timezone ?? .current, use24Hour: use24Hour))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(city.isLocal ? Color.accentColor.opacity(0.05) : Color.clear)
    }
}
