import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCity: City?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.accentColor)

                Text("ZONES")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: { appState.showSettings = true }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Zone list
            ZoneListView()
                .environmentObject(appState)

            Divider()

            // Footer
            HStack {
                Button(action: { appState.showAddCitySheet = true }) {
                    Label("Add City", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                Text("\(appState.cities.count) cities")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $appState.showAddCitySheet) {
            AddCitySheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showSettings) {
            SettingsSheet()
                .environmentObject(appState)
        }
    }
}

struct SettingsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)

            Form {
                Toggle("Use 24-hour format", isOn: $appState.use24HourFormat)
            }
            .padding()

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 300, height: 180)
    }
}
