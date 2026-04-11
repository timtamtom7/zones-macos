import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCity: City?

    var body: some View {
        VStack(spacing: 0) {
            LiquidGlassHeader {
                HStack {
                    Image(systemName: "globe")
                        .foregroundStyle(.tint)

                    Text("ZONES")
                        .font(.title3)
                        .fontWeight(.bold)

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
            }

            ZoneListView()
                .environmentObject(appState)

            LiquidGlassFooter {
                HStack {
                    Button(action: { appState.showAddCitySheet = true }) {
                        Label("Add City", systemImage: "plus")
                    }
                    .buttonStyle(.capsule)
                    .accessibilityLabel("Add City")
                    .accessibilityHint("Opens the add city sheet to search and add a new timezone city")

                    Spacer()

                    Text("\(appState.cities.count) cities")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
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

struct LiquidGlassHeader<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
    }
}

struct LiquidGlassFooter<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: -3)
    }
}

struct LiquidGlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
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
                .buttonStyle(.capsule)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 300, height: 180)
    }
}
