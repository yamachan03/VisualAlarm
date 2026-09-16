import Foundation

/// 実行中のタイマー。終了時刻を持つので再起動しても続きから数えられる。
struct CountdownTimer: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case normal
        /// 本番表示の「スヌーズ」から作られたもの。履歴・プリセットには残さない
        case snooze
        /// 「テスト表示」から作られたもの。履歴・プリセットには残さない
        case test
    }

    var id: UUID = UUID()
    var label: String = ""
    var seconds: Int
    var endDate: Date
    var color: AlarmColor = .auto
    var kind: Kind = .normal

    var displayTitle: String {
        if !label.isEmpty { return label }
        switch kind {
        case .normal: return L("Time's up")
        case .snooze: return L("Snooze")
        case .test: return L("Test")
        }
    }

    func remaining(at now: Date) -> TimeInterval {
        max(0, endDate.timeIntervalSince(now))
    }
}
