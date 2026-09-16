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

    /// 長さを "25分" / "1時間30分" / "90秒"（英語では "25m" / "1h 30m" / "90s"）のように
    static func duration(seconds total: Int) -> String {
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        var parts: [String] = []
        if hours > 0 { parts.append(Localization.shared.effective == .japanese ? "\(hours)\(L("h"))" : "\(hours) \(L("h"))") }
        if minutes > 0 { parts.append(Localization.shared.effective == .japanese ? "\(minutes)\(L("min"))" : "\(minutes) \(L("min"))") }
        if seconds > 0 || parts.isEmpty { parts.append(Localization.shared.effective == .japanese ? "\(seconds)\(L("s"))" : "\(seconds) \(L("s"))") }
        return parts.joined(separator: Localization.shared.effective == .japanese ? "" : " ")
    }

    /// 設定時刻からの経過。1 分未満は nil
    static func elapsed(since date: Date, now: Date) -> String? {
        let total = Int(now.timeIntervalSince(date))
        guard total >= 60 else { return nil }
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return hours > 0 ? L("{0} h {1} min elapsed", hours, minutes) : L("{0} min elapsed", minutes)
    }

    /// 次に鳴る日時を "今日 07:30" / "明日 07:30" / "水 07:30" で
    static func upcoming(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        let time = String(format: "%02d:%02d",
                          calendar.component(.hour, from: date),
                          calendar.component(.minute, from: date))
        if calendar.isDate(date, inSameDayAs: now) { return L("Today {0}", time) }
        if calendar.isDateInTomorrow(date) { return L("Tomorrow {0}", time) }
        let weekday = Alarm.weekdaySymbol(calendar.component(.weekday, from: date))
        return "\(weekday) \(time)"
    }
}
