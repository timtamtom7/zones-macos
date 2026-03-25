import AppKit
import SwiftUI

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?

    override init() {
        super.init()
        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "ZONES")
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarPopoverView())
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showQuickMenu(sender)
        } else {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private func showQuickMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()

        menu.addItem(withTitle: "Quick Actions", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())

        // What time is it in... submenu
        let timezonesMenu = NSMenu()
        let cities = CityStore.shared.cities
        for city in cities.prefix(5) {
            let item = NSMenuItem(title: city.name, action: #selector(showCityTime(_:)), keyEquivalent: "")
            item.representedObject = city
            item.target = self
            timezonesMenu.addItem(item)
        }
        let timezonesItem = NSMenuItem(title: "What time is it in...", action: nil, keyEquivalent: "")
        timezonesItem.submenu = timezonesMenu
        menu.addItem(timezonesItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Open ZONES", action: #selector(openZONES), keyEquivalent: "")
        menu.addItem(withTitle: "Settings...", action: #selector(openSettings), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit ZONES", action: #selector(quitZONES), keyEquivalent: "")

        menu.delegate = self
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func showCityTime(_ sender: NSMenuItem) {
        guard let city = sender.representedObject as? City,
              let tz = city.timezone else { return }

        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: Date())

        let alert = NSAlert()
        alert.messageText = "\(time) in \(city.name)"
        alert.informativeText = city.timezoneAbbreviation
        alert.runModal()
    }

    @objc private func openZONES() {
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openSettings() {
        NotificationCenter.default.post(name: Notification.Name("openSettings"), object: nil)
    }

    @objc private func quitZONES() {
        NSApp.terminate(nil)
    }
}

extension MenuBarController: NSMenuDelegate {}

