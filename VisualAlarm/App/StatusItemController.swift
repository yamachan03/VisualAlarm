import AppKit
import SwiftUI

/// メニューバーのアイコンとパネル（ポップオーバー）。
/// 本番表示中にアイコンをクリックしたときはパネルを開かずに解除だけ行う（設計書 3.7）。
@MainActor
final class StatusItemController: NSObject {
    private let store: AlarmStore
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()

    init(store: AlarmStore) {
        self.store = store
        super.init()

        let hosting = NSHostingController(rootView: MenuBarView().environment(store))
        hosting.sizingOptions = .preferredContentSize
        popover.contentViewController = hosting
        popover.behavior = .transient
        popover.animates = true

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(buttonClicked)
            button.imagePosition = .imageLeading
        }
        update()
    }

    func update() {
        guard let button = statusItem.button else { return }
        let symbol = store.hasActiveItems ? "alarm.fill" : "alarm"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: "VisualAlarm")
        image?.isTemplate = true
        button.image = image

        var title = ""
        if store.settings.showTimerInMenuBar, let timer = store.soonestTimer {
            title = " " + TimeFormatting.countdown(timer.remaining(at: store.now))
        }
        if button.title != title {
            button.title = title
        }
    }

    @objc private func buttonClicked() {
        if store.overlay.state.isRinging {
            store.overlay.dismissRinging()
            return
        }
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
