import Foundation

/// カウントダウン中／本番表示中の 1 件。アラームかタイマーのどちらかを指す。
struct ScheduledItem: Identifiable, Equatable {
    enum Source: Equatable {
        case alarm(UUID)
        case timer(UUID)
    }

    let id: String
    let source: Source
    let title: String
    let subtitle: String
    let color: AlarmColor
    let fireDate: Date

    init(alarm: Alarm, fireDate: Date) {
        id = "alarm:\(alarm.id.uuidString):\(fireDate.timeIntervalSinceReferenceDate)"
        source = .alarm(alarm.id)
        title = alarm.displayTitle
        subtitle = alarm.timeString
        color = alarm.color.resolved(seed: id)
        self.fireDate = fireDate
    }

    init(timer: CountdownTimer) {
        id = "timer:\(timer.id.uuidString)"
        source = .timer(timer.id)
        title = timer.displayTitle
        switch timer.kind {
        case .normal: subtitle = "\(TimeFormatting.duration(seconds: timer.seconds))のタイマー"
        case .snooze: subtitle = "スヌーズ（\(TimeFormatting.duration(seconds: timer.seconds))）"
        case .test: subtitle = "テスト"
        }
        color = timer.color.resolved(seed: id)
        fireDate = timer.endDate
    }
}
