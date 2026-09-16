import Foundation
import Observation

/// UI の言語。`.system` は macOS の言語設定に従う。
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case japanese = "ja"
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case korean = "ko"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: L("Follow System")
        case .japanese: "日本語"
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        case .traditionalChinese: "繁體中文"
        case .korean: "한국어"
        }
    }

    /// macOS の言語識別子（"ja-JP" "zh-Hant-TW" "zh-CN" など）から決める
    static func matching(_ identifier: String) -> AppLanguage {
        let lower = identifier.lowercased()
        if lower.hasPrefix("ja") { return .japanese }
        if lower.hasPrefix("ko") { return .korean }
        if lower.hasPrefix("zh") {
            let traditional = ["hant", "-tw", "-hk", "-mo"].contains { lower.contains($0) }
            return traditional ? .traditionalChinese : .simplifiedChinese
        }
        return .english
    }

    /// 数値と単位の間の空白（"5 min" / "5分"）
    var unitSpace: String { self == .english ? " " : "" }
    /// 時間の長さの部品をつなぐ文字（"1 h 30 min" / "1시간 30분" / "1時間30分"）
    var durationJoiner: String { self == .english || self == .korean ? " " : "" }
    /// 曜日の短縮形をつなぐ文字（"Mon, Wed" / "月水"）
    var weekdayJoiner: String { self == .english ? ", " : "" }
    /// ラベルを列挙するときの区切り
    var listJoiner: String {
        switch self {
        case .japanese, .simplifiedChinese, .traditionalChinese: "、"
        default: ", "
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
        if language == .system {
            return AppLanguage.matching(Locale.preferredLanguages.first ?? "en")
        }
        return language
    }

    func string(_ key: String) -> String {
        let language = effective
        guard language != .english, let table = Self.tables[language] else { return key }
        return table[key] ?? key
    }

    /// 英語キー → 各言語。ここにない文言は英語のまま出る
    static let tables: [AppLanguage: [String: String]] = [
        .japanese: japanese,
        .simplifiedChinese: simplifiedChinese,
        .traditionalChinese: traditionalChinese,
        .korean: korean,
    ]

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
        "Sunday": "日曜日", "Monday": "月曜日", "Tuesday": "火曜日", "Wednesday": "水曜日", "Thursday": "木曜日", "Friday": "金曜日", "Saturday": "土曜日",
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

    static let simplifiedChinese: [String: String] = [
        "Alarm": "闹钟",
        "Timer": "计时器",
        "Cancel": "取消",
        "Save": "保存",
        "Delete": "删除",
        "Settings": "设置",
        "Quit": "退出",
        "Test": "测试显示",
        "Runs the countdown and the full-screen display once": "完整演示一次倒计时和全屏提醒",
        "Next: {0}": "下一个: {0}",

        "Start": "开始",
        "h": "小时",
        "min": "分",
        "s": "秒",
        "Label (optional), e.g. Call Sam": "标签（可选），例如：给小王打电话",
        "Remove Preset": "从预设中删除",
        "Recent timers": "最近使用的计时器",
        "Time's up": "时间到",
        "Snooze": "稍后提醒",
        "{0} timer": "{0}计时器",
        "Snooze ({0})": "稍后提醒（{0}）",

        "Add Alarm": "添加闹钟",
        "No alarms": "没有闹钟",
        "Set from history": "从历史记录设置",
        "Show all ({0})": "显示全部（{0}）",
        "Show less": "收起",
        "Remove from History": "从历史记录中删除",
        "New Alarm": "新建闹钟",
        "Edit Alarm": "编辑闹钟",
        "Time": "时间",
        "Label": "标签",
        "e.g. Call Sam": "例如：给小王打电话",
        "Color": "颜色",
        "Details": "详细",
        "Repeat": "重复",
        "None": "无",
        "Every day": "每天",
        "Weekdays": "工作日",
        "Weekends": "周末",
        "Once": "一次",
        "Rings: {0}": "{0}响铃",
        "Turns off after ringing once": "响铃一次后自动关闭",
        "Sun": "日", "Mon": "一", "Tue": "二", "Wed": "三", "Thu": "四", "Fri": "五", "Sat": "六",
        "Sunday": "星期日", "Monday": "星期一", "Tuesday": "星期二", "Wednesday": "星期三", "Thursday": "星期四", "Friday": "星期五", "Saturday": "星期六",
        "Today {0}": "今天 {0}",
        "Tomorrow {0}": "明天 {0}",

        "Stop": "停止",
        "Dismiss": "关闭",
        "Snooze {0} min": "稍后提醒 {0} 分钟",
        "Click anywhere to dismiss": "点击屏幕任意位置关闭",
        "Up next: {0}": "即将: {0}",
        "{0} min elapsed": "已过 {0} 分钟",
        "{0} h {1} min elapsed": "已过 {0} 小时 {1} 分钟",

        "Auto": "自动",
        "Green": "绿",
        "Mint": "薄荷绿",
        "Teal": "青",
        "Sky": "天蓝",
        "Blue": "蓝",
        "Indigo": "靛蓝",
        "Lavender": "薰衣草紫",

        "Display": "显示",
        "Default color": "默认颜色",
        "Countdown: {0} s": "倒计时: {0} 秒",
        "Countdown dimming": "倒计时背景深度",
        "Full-screen opacity": "全屏提醒不透明度",
        "Behavior": "行为",
        "{0} min": "{0} 分钟",
        "{0} s": "{0} 秒",
        "Auto-dismiss": "自动关闭",
        "Never": "从不",
        "Show remaining time in menu bar": "在菜单栏显示剩余时间",
        "Launch at login": "登录时启动",
        "Language": "语言",
        "Follow System": "跟随系统",
        "History": "历史记录",
        "Clear History": "清除历史记录",
    ]

    static let traditionalChinese: [String: String] = [
        "Alarm": "鬧鐘",
        "Timer": "計時器",
        "Cancel": "取消",
        "Save": "儲存",
        "Delete": "刪除",
        "Settings": "設定",
        "Quit": "結束",
        "Test": "測試顯示",
        "Runs the countdown and the full-screen display once": "完整示範一次倒數與全螢幕提醒",
        "Next: {0}": "下一個: {0}",

        "Start": "開始",
        "h": "小時",
        "min": "分",
        "s": "秒",
        "Label (optional), e.g. Call Sam": "標籤（選填），例如：打電話給小王",
        "Remove Preset": "從預設中移除",
        "Recent timers": "最近使用的計時器",
        "Time's up": "時間到",
        "Snooze": "稍後提醒",
        "{0} timer": "{0}計時器",
        "Snooze ({0})": "稍後提醒（{0}）",

        "Add Alarm": "新增鬧鐘",
        "No alarms": "沒有鬧鐘",
        "Set from history": "從歷史記錄設定",
        "Show all ({0})": "顯示全部（{0}）",
        "Show less": "收合",
        "Remove from History": "從歷史記錄移除",
        "New Alarm": "新增鬧鐘",
        "Edit Alarm": "編輯鬧鐘",
        "Time": "時間",
        "Label": "標籤",
        "e.g. Call Sam": "例如：打電話給小王",
        "Color": "顏色",
        "Details": "詳細",
        "Repeat": "重複",
        "None": "無",
        "Every day": "每天",
        "Weekdays": "平日",
        "Weekends": "週末",
        "Once": "一次",
        "Rings: {0}": "{0}響鈴",
        "Turns off after ringing once": "響鈴一次後自動關閉",
        "Sun": "日", "Mon": "一", "Tue": "二", "Wed": "三", "Thu": "四", "Fri": "五", "Sat": "六",
        "Sunday": "星期日", "Monday": "星期一", "Tuesday": "星期二", "Wednesday": "星期三", "Thursday": "星期四", "Friday": "星期五", "Saturday": "星期六",
        "Today {0}": "今天 {0}",
        "Tomorrow {0}": "明天 {0}",

        "Stop": "停止",
        "Dismiss": "關閉",
        "Snooze {0} min": "稍後提醒 {0} 分鐘",
        "Click anywhere to dismiss": "點一下螢幕任意位置關閉",
        "Up next: {0}": "即將: {0}",
        "{0} min elapsed": "已過 {0} 分鐘",
        "{0} h {1} min elapsed": "已過 {0} 小時 {1} 分鐘",

        "Auto": "自動",
        "Green": "綠",
        "Mint": "薄荷綠",
        "Teal": "青",
        "Sky": "天藍",
        "Blue": "藍",
        "Indigo": "靛藍",
        "Lavender": "薰衣草紫",

        "Display": "顯示",
        "Default color": "預設顏色",
        "Countdown: {0} s": "倒數: {0} 秒",
        "Countdown dimming": "倒數背景深度",
        "Full-screen opacity": "全螢幕提醒不透明度",
        "Behavior": "行為",
        "{0} min": "{0} 分鐘",
        "{0} s": "{0} 秒",
        "Auto-dismiss": "自動關閉",
        "Never": "永不",
        "Show remaining time in menu bar": "在選單列顯示剩餘時間",
        "Launch at login": "登入時啟動",
        "Language": "語言",
        "Follow System": "跟隨系統",
        "History": "歷史記錄",
        "Clear History": "清除歷史記錄",
    ]

    static let korean: [String: String] = [
        "Alarm": "알람",
        "Timer": "타이머",
        "Cancel": "취소",
        "Save": "저장",
        "Delete": "삭제",
        "Settings": "설정",
        "Quit": "종료",
        "Test": "테스트 표시",
        "Runs the countdown and the full-screen display once": "카운트다운부터 전체 화면 표시까지 한 번 보여줍니다",
        "Next: {0}": "다음: {0}",

        "Start": "시작",
        "h": "시간",
        "min": "분",
        "s": "초",
        "Label (optional), e.g. Call Sam": "라벨 (선택), 예: 김 대리에게 전화",
        "Remove Preset": "프리셋에서 삭제",
        "Recent timers": "최근 사용한 타이머",
        "Time's up": "시간 종료",
        "Snooze": "다시 알림",
        "{0} timer": "{0} 타이머",
        "Snooze ({0})": "다시 알림 ({0})",

        "Add Alarm": "알람 추가",
        "No alarms": "알람 없음",
        "Set from history": "기록에서 설정",
        "Show all ({0})": "모두 보기 ({0})",
        "Show less": "접기",
        "Remove from History": "기록에서 삭제",
        "New Alarm": "새 알람",
        "Edit Alarm": "알람 편집",
        "Time": "시간",
        "Label": "라벨",
        "e.g. Call Sam": "예: 김 대리에게 전화",
        "Color": "색상",
        "Details": "세부 설정",
        "Repeat": "반복",
        "None": "없음",
        "Every day": "매일",
        "Weekdays": "평일",
        "Weekends": "주말",
        "Once": "한 번",
        "Rings: {0}": "{0}에 울립니다",
        "Turns off after ringing once": "한 번 울린 후 꺼집니다",
        "Sun": "일", "Mon": "월", "Tue": "화", "Wed": "수", "Thu": "목", "Fri": "금", "Sat": "토",
        "Sunday": "일요일", "Monday": "월요일", "Tuesday": "화요일", "Wednesday": "수요일", "Thursday": "목요일", "Friday": "금요일", "Saturday": "토요일",
        "Today {0}": "오늘 {0}",
        "Tomorrow {0}": "내일 {0}",

        "Stop": "정지",
        "Dismiss": "해제",
        "Snooze {0} min": "{0}분 후 다시 알림",
        "Click anywhere to dismiss": "화면 아무 곳이나 클릭하면 해제됩니다",
        "Up next: {0}": "곧: {0}",
        "{0} min elapsed": "{0}분 경과",
        "{0} h {1} min elapsed": "{0}시간 {1}분 경과",

        "Auto": "자동",
        "Green": "초록",
        "Mint": "민트",
        "Teal": "청록",
        "Sky": "하늘색",
        "Blue": "파랑",
        "Indigo": "남색",
        "Lavender": "라벤더",

        "Display": "표시",
        "Default color": "기본 색상",
        "Countdown: {0} s": "카운트다운: {0}초",
        "Countdown dimming": "카운트다운 배경 어둡기",
        "Full-screen opacity": "전체 화면 불투명도",
        "Behavior": "동작",
        "{0} min": "{0}분",
        "{0} s": "{0}초",
        "Auto-dismiss": "자동 해제",
        "Never": "안 함",
        "Show remaining time in menu bar": "메뉴 막대에 남은 시간 표시",
        "Launch at login": "로그인 시 실행",
        "Language": "언어",
        "Follow System": "시스템 설정 따르기",
        "History": "기록",
        "Clear History": "기록 지우기",
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
