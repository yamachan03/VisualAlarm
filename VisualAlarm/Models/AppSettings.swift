import Foundation

struct AppSettings: Codable, Equatable {
    var defaultColor: AlarmColor = .auto
    /// カウントダウンの秒数（3〜10）
    var countdownSeconds: Int = 5
    /// カウントダウン中の背景の濃さ（黒の不透明度）
    var countdownDim: Double = 0.35
    /// 本番表示の背景の不透明度
    var overlayOpacity: Double = 0.9
    var snoozeMinutes: Int = 5
    /// 0 なら手動で解除するまで表示し続ける
    var autoDismissSeconds: Int = 0
    var showTimerInMenuBar: Bool = true
    var language: AppLanguage = .system

    static let defaultPresets = [60, 180, 300, 600, 900, 1800, 2700, 3600]

    init() {}

    // 項目を増やしても古い保存データを読めるように、欠けたキーは既定値で埋める
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        defaultColor = try c.decodeIfPresent(AlarmColor.self, forKey: .defaultColor) ?? defaultColor
        countdownSeconds = try c.decodeIfPresent(Int.self, forKey: .countdownSeconds) ?? countdownSeconds
        countdownDim = try c.decodeIfPresent(Double.self, forKey: .countdownDim) ?? countdownDim
        overlayOpacity = try c.decodeIfPresent(Double.self, forKey: .overlayOpacity) ?? overlayOpacity
        snoozeMinutes = try c.decodeIfPresent(Int.self, forKey: .snoozeMinutes) ?? snoozeMinutes
        autoDismissSeconds = try c.decodeIfPresent(Int.self, forKey: .autoDismissSeconds) ?? autoDismissSeconds
        showTimerInMenuBar = try c.decodeIfPresent(Bool.self, forKey: .showTimerInMenuBar) ?? showTimerInMenuBar
        language = try c.decodeIfPresent(AppLanguage.self, forKey: .language) ?? language
    }
}
