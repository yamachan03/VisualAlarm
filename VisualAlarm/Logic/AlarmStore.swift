import AppKit
import Observation

/// アラーム・タイマー・プリセット・履歴・設定の保持、永続化、発火判定をまとめて担当する。
@MainActor
@Observable
final class AlarmStore {
    private(set) var alarms: [Alarm] = []
    private(set) var timers: [CountdownTimer] = []
    private(set) var presets: [Int] = AppSettings.defaultPresets
    private(set) var alarmHistory: [AlarmHistoryEntry] = []
    private(set) var timerHistory: [TimerHistoryEntry] = []
    var settings = AppSettings() {
        didSet {
            overlay.state.settings = settings
            Localization.shared.language = settings.language
            save()
        }
    }
    /// UI の残り時間表示用に毎 tick 更新する現在時刻
    private(set) var now = Date()

    let overlay = OverlayController()

    /// メニューバーの表示更新など、状態が変わるたびに呼ばれる
    @ObservationIgnored var onUpdate: (() -> Void)?

    @ObservationIgnored private var ticker: Timer?
    @ObservationIgnored private var lastCheck = Date()
    /// カウントダウン中に「停止」された繰り返しアラーム。その回だけ鳴らさない
    @ObservationIgnored private var skippedFireDates: [UUID: Date] = [:]
    @ObservationIgnored private let defaults = UserDefaults.standard

    private enum Key {
        static let alarms = "alarms"
        static let timers = "timers"
        static let presets = "presets"
        static let alarmHistory = "alarmHistory"
        static let timerHistory = "timerHistory"
        static let settings = "settings"
    }

    init() {
        load()
        overlay.state.settings = settings
        Localization.shared.language = settings.language
        overlay.onStopCountdown = { [weak self] items in self?.stopCountdown(items) }
        overlay.onSnooze = { [weak self] items in self?.snooze(items) }
        startTicking()
        // スリープ復帰直後に取りこぼしを拾う
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    // MARK: - 派生値

    var sortedAlarms: [Alarm] {
        alarms.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    var sortedTimers: [CountdownTimer] {
        timers.sorted { $0.endDate < $1.endDate }
    }

    var soonestTimer: CountdownTimer? {
        timers.min { $0.endDate < $1.endDate }
    }

    var hasActiveItems: Bool {
        !timers.isEmpty || alarms.contains(where: \.isEnabled)
    }

    /// 次に鳴るアラームとその日時
    var nextAlarm: (alarm: Alarm, date: Date)? {
        alarms
            .filter(\.isEnabled)
            .compactMap { alarm in alarm.nextFireDate(after: now).map { (alarm, $0) } }
            .min { $0.1 < $1.1 }
    }

    // MARK: - アラーム

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        recordHistory(alarm)
        save()
    }

    func update(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        skippedFireDates[alarm.id] = nil
        recordHistory(alarm)
        save()
    }

    func remove(alarmID: UUID) {
        alarms.removeAll { $0.id == alarmID }
        skippedFireDates[alarmID] = nil
        save()
    }

    func setEnabled(_ enabled: Bool, alarmID: UUID) {
        guard let index = alarms.firstIndex(where: { $0.id == alarmID }) else { return }
        alarms[index].isEnabled = enabled
        skippedFireDates[alarmID] = nil
        save()
    }

    /// 履歴の項目をそのまま新しいアラームとしてセットする
    func apply(_ entry: AlarmHistoryEntry) {
        var alarm = Alarm()
        alarm.label = entry.label
        alarm.hour = entry.hour
        alarm.minute = entry.minute
        alarm.color = entry.color
        add(alarm)
    }

    func removeAlarmHistory(id: UUID) {
        alarmHistory.removeAll { $0.id == id }
        save()
    }

    private func recordHistory(_ alarm: Alarm) {
        alarmHistory.removeAll { $0.matches(alarm) }
        alarmHistory.insert(AlarmHistoryEntry(label: alarm.label, hour: alarm.hour, minute: alarm.minute,
                                              color: alarm.color, lastUsed: Date()), at: 0)
        alarmHistory = Array(alarmHistory.prefix(HistoryLimit.maxEntries))
    }

    // MARK: - タイマー

    func startTimer(seconds: Int, label: String = "", color: AlarmColor? = nil, kind: CountdownTimer.Kind = .normal) {
        let seconds = max(1, seconds)
        let timer = CountdownTimer(label: label,
                                   seconds: seconds,
                                   endDate: Date().addingTimeInterval(TimeInterval(seconds)),
                                   color: color ?? settings.defaultColor,
                                   kind: kind)
        timers.append(timer)
        if kind == .normal {
            if !presets.contains(seconds) {
                presets.append(seconds)
                presets.sort()
            }
            recordHistory(label: label, seconds: seconds, color: timer.color)
        }
        save()
    }

    func cancelTimer(id: UUID) {
        timers.removeAll { $0.id == id }
        save()
    }

    func removePreset(_ seconds: Int) {
        presets.removeAll { $0 == seconds }
        save()
    }

    func apply(_ entry: TimerHistoryEntry) {
        startTimer(seconds: entry.seconds, label: entry.label, color: entry.color)
    }

    func removeTimerHistory(id: UUID) {
        timerHistory.removeAll { $0.id == id }
        save()
    }

    func clearHistory() {
        alarmHistory = []
        timerHistory = []
        save()
    }

    private func recordHistory(label: String, seconds: Int, color: AlarmColor) {
        timerHistory.removeAll { $0.matches(label: label, seconds: seconds) }
        timerHistory.insert(TimerHistoryEntry(label: label, seconds: seconds, color: color, lastUsed: Date()), at: 0)
        timerHistory = Array(timerHistory.prefix(HistoryLimit.maxEntries))
    }

    // MARK: - 表示

    /// カウントダウンから本番表示までを一通り見せる
    func previewOverlay() {
        startTimer(seconds: settings.countdownSeconds + 1, kind: .test)
    }

    private func stopCountdown(_ items: [ScheduledItem]) {
        for item in items {
            switch item.source {
            case .timer(let id):
                timers.removeAll { $0.id == id }
            case .alarm(let id):
                guard let index = alarms.firstIndex(where: { $0.id == id }) else { continue }
                if alarms[index].repeats {
                    skippedFireDates[id] = item.fireDate
                } else {
                    alarms[index].isEnabled = false
                }
            }
        }
        save()
    }

    private func snooze(_ items: [ScheduledItem]) {
        for item in items {
            startTimer(seconds: settings.snoozeMinutes * 60, label: item.title, color: item.color, kind: .snooze)
        }
    }

    // MARK: - 発火判定

    private func startTicking() {
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        timer.tolerance = 0.05
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func tick() {
        let current = Date()
        now = current
        // カウントダウン開始の少し前からオーバーレイに渡しておく（表示のタイミングはビュー側が秒単位で合わせる）
        let lead = TimeInterval(settings.countdownSeconds + 1)
        var fired: [ScheduledItem] = []
        var upcoming: [ScheduledItem] = []

        for timer in sortedTimers {
            let item = ScheduledItem(timer: timer)
            if timer.endDate <= current {
                fired.append(item)
            } else if timer.endDate.timeIntervalSince(current) <= lead {
                upcoming.append(item)
            }
        }
        timers.removeAll { $0.endDate <= current }

        // 前回チェックから今までの間に鳴るべき時刻があれば鳴らす（スリープ中の取りこぼしも 1 回だけ拾う）
        for index in alarms.indices where alarms[index].isEnabled {
            let alarm = alarms[index]
            guard let fireDate = alarm.nextFireDate(after: lastCheck) else { continue }
            if skippedFireDates[alarm.id] == fireDate { continue }
            let item = ScheduledItem(alarm: alarm, fireDate: fireDate)
            if fireDate <= current {
                fired.append(item)
                if !alarm.repeats {
                    alarms[index].isEnabled = false
                }
            } else if fireDate.timeIntervalSince(current) <= lead {
                upcoming.append(item)
            }
        }
        skippedFireDates = skippedFireDates.filter { $0.value > current }
        lastCheck = current

        overlay.setCountdown(upcoming)
        if !fired.isEmpty {
            save()
            overlay.ring(fired)
        }
        onUpdate?()
    }

    // MARK: - 永続化

    private func load() {
        func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
            guard let data = defaults.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
        alarms = decode([Alarm].self, key: Key.alarms) ?? []
        timers = decode([CountdownTimer].self, key: Key.timers) ?? []
        presets = decode([Int].self, key: Key.presets) ?? AppSettings.defaultPresets
        alarmHistory = decode([AlarmHistoryEntry].self, key: Key.alarmHistory) ?? []
        timerHistory = decode([TimerHistoryEntry].self, key: Key.timerHistory) ?? []
        settings = decode(AppSettings.self, key: Key.settings) ?? AppSettings()
    }

    private func save() {
        let encoder = JSONEncoder()
        func store<T: Encodable>(_ value: T, key: String) {
            if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
        }
        store(alarms, key: Key.alarms)
        store(timers, key: Key.timers)
        store(presets, key: Key.presets)
        store(alarmHistory, key: Key.alarmHistory)
        store(timerHistory, key: Key.timerHistory)
        store(settings, key: Key.settings)
        onUpdate?()
    }
}
