import AppKit

// Use a manual launch approach with proper main actor isolation
autoreleasepool {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}
