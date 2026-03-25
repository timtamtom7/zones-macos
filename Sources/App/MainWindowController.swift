import AppKit
import SwiftUI

class MainWindowController: NSWindowController {
    convenience init() {
        let contentView = ContentView()
            .environmentObject(AppState.shared)

        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "ZONES"
        window.minSize = NSSize(width: 350, height: 400)
        window.center()
        window.contentViewController = hostingController

        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About ZONES", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit ZONES", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Add City...", action: #selector(addCity(_:)), keyEquivalent: "n")

        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")

        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu
        viewMenu.addItem(withTitle: "Refresh", action: #selector(refresh(_:)), keyEquivalent: "r")

        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        helpMenu.addItem(withTitle: "ZONES Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?")

        NSApp.mainMenu = mainMenu

        self.init(window: window)
    }

    @objc func addCity(_ sender: Any?) {
        NotificationCenter.default.post(name: .showAddCitySheet, object: nil)
    }

    @objc func refresh(_ sender: Any?) {
        NotificationCenter.default.post(name: Notification.Name("refreshTimes"), object: nil)
    }
}
