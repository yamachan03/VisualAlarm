import Foundation

/// 過去にセットしたアラーム（ラベル＋時刻）。同じ組み合わせは 1 件にまとめる。
struct AlarmHistoryEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var label: String
    var hour: Int
    var minute: Int
    var color: AlarmColor
    var lastUsed: Date

    var timeString: String { String(format: "%02d:%02d", hour, minute) }

    func matches(_ alarm: Alarm) -> Bool {
        label == alarm.label && hour == alarm.hour && minute == alarm.minute
    }
}

/// 過去に開始したタイマー（ラベル＋長さ）。同じ組み合わせは 1 件にまとめる。
struct TimerHistoryEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var label: String
    var seconds: Int
    var color: AlarmColor
    var lastUsed: Date

    func matches(label: String, seconds: Int) -> Bool {
        self.label == label && self.seconds == seconds
    }
}

enum HistoryLimit {
    static let maxEntries = 20
}
