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

struct MenuBarPopoverView: View {
    @StateObject private var cityStore = CityStore.shared
    @State private var showWorldMap = false
    @State private var showMeetingPlanner = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.accentColor)
                Text("ZONES")
                    .font(.headline)
                Spacer()
                Button(action: {
                    NotificationCenter.default.post(name: Notification.Name("openSettings"), object: nil)
                }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(cityStore.cities) { city in
                        MenuBarCityRow(city: city)
                        Divider()
                    }
                }
            }

            Divider()

            // Footer actions
            HStack(spacing: 16) {
                Button(action: { showWorldMap = true }) {
                    Label("World Map", systemImage: "map")
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Button(action: { showMeetingPlanner = true }) {
                    Label("Meeting", systemImage: "calendar")
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    NSApp.activate(ignoringOtherApps: true)
                }) {
                    Text("Open ZONES")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .sheet(isPresented: $showWorldMap) {
            Text("World Map")
        }
        .sheet(isPresented: $showMeetingPlanner) {
            Text("Meeting Planner")
        }
    }
}

struct MenuBarCityRow: View {
    let city: City
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            // Analog mini clock
            if let tz = city.timezone {
                AnalogClockView(timeZone: tz, size: 40, showSecondHand: false, handColor: .primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.system(size: 13, weight: .medium))

                if let tz = city.timezone {
                    let timeString = currentTimeString(for: tz)
                    Text(timeString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // DST indicator
            if let tz = city.timezone, tz.isDaylightSavingTime(for: Date()) {
                Image(systemName: "sun.max.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private func currentTimeString(for timezone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: currentTime)
    }
}
