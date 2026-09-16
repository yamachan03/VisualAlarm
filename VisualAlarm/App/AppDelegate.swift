import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: AlarmStore?
    private var statusItem: StatusItemController?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let store = AlarmStore()
        let statusItem = StatusItemController(store: store)
        store.onUpdate = { [weak statusItem] in statusItem?.update() }
        self.store = store
        self.statusItem = statusItem
    }
}
