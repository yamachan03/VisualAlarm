import Foundation
import Observation

/// UI の言語。`.system` は macOS の言語設定に従う（日本語なら日本語、それ以外は英語）。
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case japanese = "ja"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: L("Follow System")
        case .japanese: "日本語"
        case .english: "English"
        }
    }
}

/// 現在の言語を保持し、文言を引く。英語の文言がそのままキーになる（TagFinder と同じ方式）。
@Observable
final class Localization {
    static let shared = Localization()

    var language: AppLanguage = .system

    /// 実際に使う言語
    var effective: AppLanguage {
        switch language {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.hasPrefix("ja") ? .japanese : .english
        case .japanese, .english:
            return language
        }
    }

    func string(_ key: String) -> String {
        guard effective == .japanese else { return key }
        return Self.japanese[key] ?? key
    }

    /// 英語キー → 日本語。ここにない文言は英語のまま出る
    static let japanese: [String: String] = [
        // 共通
        "Alarm": "アラーム",
        "Timer": "タイマー",
        "Cancel": "キャンセル",
        "Save": "保存",
        "Delete": "削除",
        "Settings": "設定",
        "Quit": "終了",
        "Test": "テスト表示",
        "Runs the countdown and the full-screen display once": "カウントダウンから本番表示までを一通り見せます",
        "Next: {0}": "次: {0}",

        // タイマー
        "Start": "開始",
        "h": "時間",
        "min": "分",
        "s": "秒",
        "Label (optional), e.g. Call Sam": "ラベル（任意）例: 〇〇さんに電話",
        "Remove Preset": "プリセットから削除",
        "Recent timers": "最近使ったタイマー",
        "Time's up": "タイマー終了",
        "Snooze": "スヌーズ",
        "{0} timer": "{0}のタイマー",
        "Snooze ({0})": "スヌーズ（{0}）",

        // アラーム
        "Add Alarm": "アラームを追加",
        "No alarms": "アラームはありません",
        "Set from history": "履歴からセット",
        "Show all ({0})": "もっと見る（{0}）",
        "Show less": "閉じる",
        "Remove from History": "履歴から削除",
        "New Alarm": "新規アラーム",
        "Edit Alarm": "アラームを編集",
        "Time": "時刻",
        "Label": "ラベル",
        "e.g. Call Sam": "例: 〇〇さんに電話",
        "Color": "色",
        "Details": "詳細",
        "Repeat": "繰り返し",
        "None": "なし",
        "Every day": "毎日",
        "Weekdays": "平日",
        "Weekends": "週末",
        "Once": "1回",
        "Rings: {0}": "{0}に鳴らします",
        "Turns off after ringing once": "1回鳴ったら無効になります",
        "Sun": "日", "Mon": "月", "Tue": "火", "Wed": "水", "Thu": "木", "Fri": "金", "Sat": "土",
        "Today {0}": "今日 {0}",
        "Tomorrow {0}": "明日 {0}",

        // オーバーレイ
        "Stop": "停止",
        "Dismiss": "解除",
        "Snooze {0} min": "スヌーズ {0}分",
        "Click anywhere to dismiss": "画面のどこかをクリックで解除",
        "Up next: {0}": "まもなく: {0}",
        "{0} min elapsed": "{0}分経過",
        "{0} h {1} min elapsed": "{0}時間{1}分経過",

        // 色
        "Auto": "おまかせ",
        "Green": "緑",
        "Mint": "ミント",
        "Teal": "ティール",
        "Sky": "空",
        "Blue": "青",
        "Indigo": "藍",
        "Lavender": "ラベンダー",

        // 設定
        "Display": "表示",
        "Default color": "標準の色",
        "Countdown: {0} s": "カウントダウンの秒数: {0}秒",
        "Countdown dimming": "カウントダウンの背景の濃さ",
        "Full-screen opacity": "本番表示の不透明度",
        "Behavior": "動作",
        "{0} min": "{0}分",
        "{0} s": "{0}秒",
        "Auto-dismiss": "自動で解除",
        "Never": "しない",
        "Show remaining time in menu bar": "メニューバーに残り時間を表示",
        "Launch at login": "ログイン時に起動",
        "Language": "言語",
        "Follow System": "システムに従う",
        "History": "履歴",
        "Clear History": "履歴を消去",
    ]
}

/// 文言を引く。`{0}` `{1}` … を引数で置き換える
func L(_ key: String, _ arguments: CVarArg...) -> String {
    var text = Localization.shared.string(key)
    for (index, argument) in arguments.enumerated() {
        text = text.replacingOccurrences(of: "{\(index)}", with: "\(argument)")
    }
    return text
}
