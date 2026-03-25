import AppKit
import SwiftUI

@MainActor
class MenuBarController {
    private var statusItem: NSStatusItem?
    private var appState: AppState
    private var popover: NSPopover?
    private var timer: Timer?

    init(statusItem: NSStatusItem, appState: AppState, popover: NSPopover?) {
        self.statusItem = statusItem
        self.appState = appState
        self.popover = popover
        setupButton()
        startTimer()
    }

    private func setupButton() {
        if let button = statusItem?.button {
            updateButtonTitle()
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusItemClicked() {
        guard let button = statusItem?.button else { return }
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateButtonTitle()
            }
        }
    }

    private func updateButtonTitle() {
        guard let button = statusItem?.button else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = appState.use24HourFormat ? "HH:mm" : "h:mm a"
        button.title = formatter.string(from: Date())

        if let image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Clock") {
            image.isTemplate = true
            button.image = image
        }
    }

    func updateTitle() {
        updateButtonTitle()
    }
}
