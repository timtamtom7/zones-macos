import SwiftUI

struct MenuBarPopoverView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.tint)

                Text("ZONES")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { appState.showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Settings")
                .accessibilityHint("Opens the settings sheet")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text("Search cities")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(appState.cities) { city in
                        MenuBarZoneRow(city: city, currentTime: appState.currentTime, use24Hour: appState.use24HourFormat)
                    }
                }
            }
            .frame(maxHeight: 300)
            .scrollContentBackground(.hidden)

            HStack {
                Button(action: { appState.showAddCitySheet = true }) {
                    Label("Add City", systemImage: "plus")
                }
                .buttonStyle(.capsule)
                .controlSize(.small)
                .accessibilityLabel("Add City")
                .accessibilityHint("Opens the add city sheet to add a new timezone city")

                Spacer()

                Button("Open ZONES...") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .accessibilityLabel("Open ZONES")
                .accessibilityHint("Opens the main ZONES application window")

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .accessibilityLabel("Quit ZONES")
                .accessibilityHint("Closes the ZONES application")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
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
                    .fill(.tint)
                    .frame(width: 8, height: 8)
            }

            Text(city.isLocal ? "Local" : city.name)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            Spacer()

            Text(timeFormatter.formatTimeShort(currentTime, timezone: city.timezone ?? .current, use24Hour: use24Hour))
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(city.isLocal ? Color.accentColor.opacity(0.08) : Color.clear)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}
