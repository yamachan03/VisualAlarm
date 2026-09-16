import Foundation

enum TimeFormatting {
    /// 残り時間を "mm:ss" または "h:mm:ss" で
    static func countdown(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.up)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
    }

    /// 長さを "25分" / "1時間30分" / "90秒" のように
    static func duration(seconds total: Int) -> String {
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours)時間") }
        if minutes > 0 { parts.append("\(minutes)分") }
        if seconds > 0 || parts.isEmpty { parts.append("\(seconds)秒") }
        return parts.joined()
    }

    /// 設定時刻からの経過。1 分未満は nil
    static func elapsed(since date: Date, now: Date) -> String? {
        let total = Int(now.timeIntervalSince(date))
        guard total >= 60 else { return nil }
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return hours > 0 ? "\(hours)時間\(minutes)分経過" : "\(minutes)分経過"
    }

    /// 次に鳴る日時を "今日 07:30" / "明日 07:30" / "水 07:30" で
    static func upcoming(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        let time = String(format: "%02d:%02d",
                          calendar.component(.hour, from: date),
                          calendar.component(.minute, from: date))
        if calendar.isDate(date, inSameDayAs: now) { return "今日 \(time)" }
        if calendar.isDateInTomorrow(date) { return "明日 \(time)" }
        let weekday = Alarm.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        return "\(weekday) \(time)"
    }
}
