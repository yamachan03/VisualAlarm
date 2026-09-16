import AppKit
import SwiftUI

/// オーバーレイに載せる内容。全ディスプレイの `OverlayRootView` が共有して監視する。
@MainActor
@Observable
final class OverlayState {
    var countdown: [ScheduledItem] = []
    var ringing: [ScheduledItem] = []
    var settings = AppSettings()

    var isRinging: Bool { !ringing.isEmpty }
    var isShowing: Bool { !countdown.isEmpty || !ringing.isEmpty }
}

/// 全ディスプレイを覆うパネルの生成・破棄と、クリックの受け方の切り替えを担当する。
///
/// パネルはアプリを前面化せず、キーウィンドウにもならない（設計書 3.5）。
/// - カウントダウン中: 本体パネルはクリックを下に通し、「停止」ボタンだけ別の小さなパネルで受ける
/// - 本番表示中: 本体パネルがクリックを受ける（どこをクリックしても解除）
@MainActor
final class OverlayController {
    let state = OverlayState()

    /// カウントダウン中に「停止」が押された
    var onStopCountdown: (([ScheduledItem]) -> Void)?
    /// 本番表示で「スヌーズ」が押された
    var onSnooze: (([ScheduledItem]) -> Void)?

    private var panels: [OverlayPanel] = []
    private var stopPanels: [OverlayPanel] = []
    private var autoDismissTimer: Timer?

    init() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.rebuildIfShowing() }
        }
    }

    // MARK: - 状態の更新

    func setCountdown(_ items: [ScheduledItem]) {
        guard items != state.countdown else { return }
        state.countdown = items
        refresh()
    }

    func ring(_ items: [ScheduledItem]) {
        let existing = Set(state.ringing.map(\.id))
        state.ringing.append(contentsOf: items.filter { !existing.contains($0.id) })
        scheduleAutoDismiss(after: state.settings.autoDismissSeconds)
        refresh()
    }

    func stopCountdown() {
        let items = state.countdown
        state.countdown = []
        refresh()
        onStopCountdown?(items)
    }

    func dismissRinging() {
        state.ringing = []
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        refresh()
    }

    func snooze() {
        let items = state.ringing
        dismissRinging()
        onSnooze?(items)
    }

    // MARK: - パネル

    private func refresh() {
        guard state.isShowing else {
            tearDown()
            return
        }
        if panels.isEmpty {
            build()
        }
        let ringing = state.isRinging
        for panel in panels {
            panel.ignoresMouseEvents = !ringing
        }
        for panel in stopPanels {
            if ringing {
                panel.orderOut(nil)
            } else {
                panel.orderFrontRegardless()
            }
        }
    }

    private func build() {
        for screen in NSScreen.screens {
            let panel = OverlayPanel(frame: screen.frame)
            let root = OverlayRootView(state: state,
                                       onDismiss: { [weak self] in self?.dismissRinging() },
                                       onSnooze: { [weak self] in self?.snooze() })
            panel.contentView = FirstMouseHostingView(rootView: root)
            panel.orderFrontRegardless()
            panels.append(panel)

            // 「停止」ボタンだけを載せた小さなパネル（画面下部中央）
            let scale = OverlayLayout.scale(for: screen.frame.height)
            let size = OverlayLayout.stopButtonSize(scale: scale)
            let origin = NSPoint(x: screen.frame.midX - size.width / 2,
                                 y: screen.frame.minY + OverlayLayout.stopButtonBottom(scale: scale))
            let stopPanel = OverlayPanel(frame: NSRect(origin: origin, size: size))
            stopPanel.contentView = FirstMouseHostingView(
                rootView: StopButtonView(onStop: { [weak self] in self?.stopCountdown() }, scale: scale)
            )
            stopPanels.append(stopPanel)
        }
    }

    private func tearDown() {
        (panels + stopPanels).forEach { $0.orderOut(nil) }
        panels.removeAll()
        stopPanels.removeAll()
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
    }

    private func rebuildIfShowing() {
        guard !panels.isEmpty else { return }
        (panels + stopPanels).forEach { $0.orderOut(nil) }
        panels.removeAll()
        stopPanels.removeAll()
        refresh()
    }

    private func scheduleAutoDismiss(after seconds: Int) {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        guard seconds > 0 else { return }
        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.dismissRinging() }
        }
    }
}

/// アプリを前面化せず、キーウィンドウにもならない全画面パネル
final class OverlayPanel: NSPanel {
    init(frame: NSRect) {
        super.init(contentRect: frame,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        level = .screenSaver
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        becomesKeyOnlyIfNeeded = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        setFrame(frame, display: true)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// キーウィンドウでなくても最初のクリックをそのままボタンに届ける
final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    required init(rootView: Content) {
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
