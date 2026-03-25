import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DatabaseManager.shared.setup()
        CityStore.shared.loadCities()
        mainWindowController = MainWindowController()
        mainWindowController?.showWindow(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
}

extension Notification.Name {
    static let citiesUpdated = Notification.Name("citiesUpdated")
    static let showAddCitySheet = Notification.Name("showAddCitySheet")
}
