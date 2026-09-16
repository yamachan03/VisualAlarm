import Foundation

/// 時刻指定のアラーム。`repeatWeekdays` が空なら 1 回きり（鳴った後に無効化される）。
struct Alarm: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var label: String = ""
    var hour: Int = 7
    var minute: Int = 0
    /// `Calendar.component(.weekday)` と同じ 1=日 … 7=土
    var repeatWeekdays: Set<Int> = []
    var color: AlarmColor = .auto
    var isEnabled: Bool = true

    static let weekdaySymbols = ["日", "月", "火", "水", "木", "金", "土"]
    static let everyDay: Set<Int> = Set(1...7)
    static let weekdays: Set<Int> = Set(2...6)

    var timeString: String { String(format: "%02d:%02d", hour, minute) }
    var repeats: Bool { !repeatWeekdays.isEmpty }
    var displayTitle: String { label.isEmpty ? "アラーム" : label }

    var repeatDescription: String {
        switch repeatWeekdays {
        case []: return "1回"
        case Self.everyDay: return "毎日"
        case Self.weekdays: return "平日"
        case [1, 7]: return "週末"
        default:
            return repeatWeekdays.sorted().map { Self.weekdaySymbols[$0 - 1] }.joined()
        }
    }

    /// `date` より後で最初に鳴る日時
    func nextFireDate(after date: Date, calendar: Calendar = .current) -> Date? {
        for offset in 0..<8 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: date) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            components.minute = minute
            components.second = 0
            guard let candidate = calendar.date(from: components), candidate > date else { continue }
            if repeatWeekdays.isEmpty || repeatWeekdays.contains(calendar.component(.weekday, from: candidate)) {
                return candidate
            }
        }
        return nil
    }
}
