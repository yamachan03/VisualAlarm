import SwiftUI

/// 本番表示の背景色。緑・青系の落ち着いた色だけを使う（赤・オレンジは「危険」を連想させるので使わない）。
/// `.auto` は鳴るたびにランダムに選ぶ。
enum AlarmColor: String, Codable, CaseIterable, Identifiable {
    case auto
    case green, mint, teal, sky, blue, indigo, lavender

    var id: String { rawValue }

    /// 実際に背景に使える色（`.auto` を除く）
    static let concrete: [AlarmColor] = allCases.filter { $0 != .auto }

    var name: String {
        switch self {
        case .auto: "おまかせ"
        case .green: "緑"
        case .mint: "ミント"
        case .teal: "ティール"
        case .sky: "空"
        case .blue: "青"
        case .indigo: "藍"
        case .lavender: "ラベンダー"
        }
    }

    var color: Color {
        switch self {
        case .auto: Color(red: 0.25, green: 0.60, blue: 0.70)
        case .green: Color(red: 0.18, green: 0.62, blue: 0.36)
        case .mint: Color(red: 0.18, green: 0.71, blue: 0.56)
        case .teal: Color(red: 0.12, green: 0.60, blue: 0.66)
        case .sky: Color(red: 0.18, green: 0.55, blue: 0.85)
        case .blue: Color(red: 0.18, green: 0.37, blue: 0.83)
        case .indigo: Color(red: 0.29, green: 0.29, blue: 0.71)
        case .lavender: Color(red: 0.48, green: 0.37, blue: 0.79)
        }
    }

    /// 「おまかせ」のスウォッチ用（緑→青のグラデーション）
    static let autoGradient = AngularGradient(
        colors: concrete.map(\.color) + [concrete[0].color], center: .center)

    /// この色を背景にしたときの文字色
    var textColor: Color { .white }

    /// `.auto` を実際の色に決める。同じ `seed` なら同じ色になる（tick ごとに変わらないように）
    func resolved(seed: String) -> AlarmColor {
        guard self == .auto else { return self }
        var hash: UInt64 = 1469598103934665603
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        let palette = Self.concrete
        return palette[Int(hash % UInt64(palette.count))]
    }

    /// 以前のバージョンの色名（赤など）が保存されていても読めるように、未知の値は `.auto` にする
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AlarmColor(rawValue: raw) ?? .auto
    }
}
