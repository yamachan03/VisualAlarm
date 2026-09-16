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

    private static let weekdayKeys = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private static let weekdayLongKeys = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    /// 曜日の短い表示（1=日 … 7=土）
    static func weekdaySymbol(_ weekday: Int) -> String { L(weekdayKeys[weekday - 1]) }
    /// 曜日の正式名（「次: 金曜日 07:30」など単独で出すとき用）
    static func weekdayName(_ weekday: Int) -> String { L(weekdayLongKeys[weekday - 1]) }
    static let everyDay: Set<Int> = Set(1...7)
    static let weekdays: Set<Int> = Set(2...6)

    var timeString: String { String(format: "%02d:%02d", hour, minute) }
    var repeats: Bool { !repeatWeekdays.isEmpty }
    var displayTitle: String { label.isEmpty ? L("Alarm") : label }

    var repeatDescription: String {
        switch repeatWeekdays {
        case []: return L("Once")
        case Self.everyDay: return L("Every day")
        case Self.weekdays: return L("Weekdays")
        case [1, 7]: return L("Weekends")
        default:
            return repeatWeekdays.sorted().map { Self.weekdaySymbol($0) }
                .joined(separator: Localization.shared.effective.weekdayJoiner)
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
