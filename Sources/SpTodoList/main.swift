import AppKit

// Entry point: top-level code runs on the main actor.
let app = NSApplication.shared
app.setActivationPolicy(.accessory) // no Dock icon, no menu bar of its own
let delegate = AppDelegate()
app.delegate = delegate
app.run()
