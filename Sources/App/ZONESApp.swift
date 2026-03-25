import SwiftUI

struct ZONESApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add City...") {
                    appState.showAddCitySheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .toolbar) {
                Button("Refresh") {
                    appState.refreshTimes()
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            CommandGroup(after: .appInfo) {
                Button("Settings...") {
                    appState.showSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        MenuBarExtra {
            MenuBarPopoverView()
                .environmentObject(appState)
        } label: {
            Label(appState.menuBarTimeString, systemImage: "clock")
        }
    }
}
