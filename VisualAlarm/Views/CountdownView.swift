import SwiftUI

/// 設定時刻の N 秒前から 1 秒ごとに数字を出す。
/// 数字の切り替えは `TimelineView` を設定時刻に揃えて回すことで、秒の境目にぴったり合わせる。
struct CountdownView: View {
    var state: OverlayState

    var body: some View {
        let items = state.countdown
        let fireDate = items.map(\.fireDate).min() ?? .distantFuture
        let seconds = state.settings.countdownSeconds
        let start = fireDate.addingTimeInterval(-TimeInterval(seconds))

        TimelineView(.periodic(from: start, by: 1)) { context in
            let remaining = fireDate.timeIntervalSince(context.date)
            let digit = Int(remaining.rounded(.up))
            GeometryReader { geometry in
                let scale = geometry.size.height / 1080
                ZStack {
                    if digit >= 1 && digit <= seconds {
                        Color.black.opacity(state.settings.countdownDim)

                        DigitView(number: digit, exit: DigitExit.pick(for: digit, sequence: fireDate.timeIntervalSinceReferenceDate))
                            .id("\(fireDate.timeIntervalSinceReferenceDate)-\(digit)")

                        VStack {
                            Spacer()
                            VStack(spacing: 6 * scale) {
                                ForEach(items) { item in
                                    Text(item.title)
                                        .font(.system(size: 52 * scale, weight: .bold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 12 * scale)
                            .padding(.horizontal, 60 * scale)
                            .padding(.bottom, OverlayLayout.stopButtonBottom(scale: scale) + OverlayLayout.stopButtonSize(scale: scale).height + 24 * scale)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

/// 1 つの数字。ふくらむように現れてから 1 秒で消える。登場のしかた・消え方・色は毎回ランダム。
/// 動きは経過時間から直接計算する（`DigitMotion.at`）。
struct DigitView: View {
    let number: Int
    let exit: DigitExit

    @State private var entry = DigitEntry.allCases.randomElement() ?? .center
    @State private var palette = BalloonPalette.random()
    @State private var start = Date()

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let height = size.height * 0.7
            TimelineView(.animation(minimumInterval: 1 / 60)) { context in
                let t = context.date.timeIntervalSince(start)
                let motion = DigitMotion.at(t, entry: entry, exit: exit, size: size)
                ZStack {
                    BalloonText(text: "\(number)", palette: palette)
                        .frame(width: height * 0.75, height: height)
                        .rotation3DEffect(.degrees(motion.flip), axis: (x: 0, y: 1, z: 0))
                        .rotationEffect(.degrees(motion.rotation))
                        .scaleEffect(motion.scale)
                        .opacity(motion.opacity)
                    if motion.burst > 0 {
                        BurstView(progress: motion.burst, palette: palette, radius: height * 0.5)
                    }
                }
                .offset(motion.offset)
                .frame(width: size.width, height: size.height)
            }
        }
    }
}

enum DigitEntry: CaseIterable {
    case center, fromLeft, fromRight, fromTop, fromBottom

    func offset(in size: CGSize) -> CGSize {
        switch self {
        case .center: .zero
        case .fromLeft: CGSize(width: -size.width * 0.22, height: 0)
        case .fromRight: CGSize(width: size.width * 0.22, height: 0)
        case .fromTop: CGSize(width: 0, height: -size.height * 0.22)
        case .fromBottom: CGSize(width: 0, height: size.height * 0.22)
        }
    }
}

enum DigitExit: CaseIterable {
    /// 中央に吸い込まれる
    case suck
    case spinLeft, spinRight, spinFast
    /// 裏返りながら吸い込まれる
    case flip
    /// ふくらんで破裂する
    case pop
    /// しぼみながらジグザグに飛んでいく（口を離した風船）
    case deflate
    /// 重力で落ちていく
    case drop

    /// 出やすさ。派手なもの（破裂・しぼむ・落下）を厚めにし、似た見た目の「吸い込まれる」系は控えめにする
    var weight: Int {
        switch self {
        case .pop: 25
        case .deflate: 20
        case .drop: 15
        case .suck: 12
        case .flip: 10
        case .spinLeft, .spinRight: 6
        case .spinFast: 6
        }
    }

    /// 重み付きで選ぶ。直前の数字と同じ消え方は避ける。
    /// `sequence`（設定時刻）と `digit` から決めるので、同じカウントダウン内では再描画しても変わらない
    static func pick(for digit: Int, sequence: Double) -> DigitExit {
        // 最大の数字から順にたどって「直前の数字で実際に選ばれた消え方」を求める
        var previous: DigitExit?
        var current = 10
        while current > digit {
            previous = choose(seed: hash(sequence, current), excluding: previous)
            current -= 1
        }
        return choose(seed: hash(sequence, digit), excluding: previous)
    }

    private static func choose(seed: UInt64, excluding: DigitExit?) -> DigitExit {
        let candidates = allCases.filter { $0 != excluding }
        let total = candidates.reduce(0) { $0 + $1.weight }
        var roll = Int(seed % UInt64(total))
        for candidate in candidates {
            roll -= candidate.weight
            if roll < 0 { return candidate }
        }
        return candidates.last ?? .suck
    }

    private static func hash(_ sequence: Double, _ digit: Int) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in "\(sequence):\(digit)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        return hash
    }
}

struct DigitMotion {
    var scale = 1.0
    var rotation = 0.0
    var flip = 0.0
    var offset = CGSize.zero
    var opacity = 1.0
    /// 破裂の進み具合（0 なら破片を出さない）
    var burst = 0.0

    static let entryDuration = 0.2
    static let total = 1.0

    static func at(_ t: Double, entry: DigitEntry, exit: DigitExit, size: CGSize) -> DigitMotion {
        var motion = DigitMotion()
        let entryOffset = entry.offset(in: size)

        if t < entryDuration {
            // 登場: ふくらみながら（少し行き過ぎて戻る）、端から流れ込む
            let p = max(0, t / entryDuration)
            let settle = 1 - Easing.outCubic(p)
            motion.scale = 0.3 + 0.7 * Easing.outBack(p)
            motion.opacity = min(1, p * 2.5)
            motion.offset = CGSize(width: entryOffset.width * settle, height: entryOffset.height * settle)
            return motion
        }

        let p = min(1, (t - entryDuration) / (total - entryDuration))
        switch exit {
        case .suck:
            motion.scale = 1 - 0.98 * Easing.inCubic(p)
            motion.opacity = 1 - Easing.inQuad(p)
        case .spinLeft, .spinRight, .spinFast:
            let turns: Double = exit == .spinFast ? -720 : (exit == .spinLeft ? -360 : 360)
            motion.scale = 1 - 0.98 * Easing.inCubic(p)
            motion.rotation = turns * Easing.inQuad(p)
            motion.opacity = 1 - Easing.inQuad(p)
        case .flip:
            motion.flip = 540 * p
            motion.scale = 1 - 0.98 * Easing.inCubic(p)
            motion.opacity = 1 - Easing.inQuad(p)
        case .pop:
            let inflateEnd = 0.78
            if p < inflateEnd {
                let q = p / inflateEnd
                // だんだん速くふくらみ、限界が近づくと小刻みに震える
                motion.scale = 1 + 0.5 * Easing.inQuad(q) + 0.025 * sin(q * .pi * 10) * q
                motion.rotation = 3 * sin(q * .pi * 12) * q
            } else {
                motion.opacity = 0
                motion.burst = (p - inflateEnd) / (1 - inflateEnd)
            }
        case .deflate:
            motion.scale = 1 - 0.95 * Easing.inQuad(p)
            motion.offset = CGSize(width: size.width * 0.18 * sin(p * .pi * 3),
                                   height: -size.height * 0.38 * p)
            motion.rotation = 35 * sin(p * .pi * 4)
            motion.opacity = p > 0.85 ? 1 - (p - 0.85) / 0.15 : 1
        case .drop:
            motion.offset = CGSize(width: size.width * 0.04 * p, height: size.height * 1.1 * p * p)
            motion.rotation = 28 * p
            motion.opacity = p < 1 ? 1 : 0
        }
        return motion
    }
}

enum Easing {
    static func inQuad(_ p: Double) -> Double { p * p }
    static func inCubic(_ p: Double) -> Double { p * p * p }
    static func outCubic(_ p: Double) -> Double { 1 - pow(1 - p, 3) }
    /// 少し行き過ぎてから戻る
    static func outBack(_ p: Double) -> Double {
        let c1 = 1.70158, c3 = c1 + 1
        return 1 + c3 * pow(p - 1, 3) + c1 * pow(p - 1, 2)
    }
}

/// 破裂の破片。数字の色のかけらが放射状に飛び散り、白い輪が広がる。
struct BurstView: View {
    let progress: Double
    let palette: BalloonPalette
    let radius: CGFloat

    private let pieces = 16

    var body: some View {
        let spread = Easing.outCubic(progress)
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.9 * (1 - progress)), lineWidth: radius * 0.06 * (1 - progress) + 1)
                .frame(width: radius * 2 * (0.6 + 1.2 * spread), height: radius * 2 * (0.6 + 1.2 * spread))
            ForEach(0..<pieces, id: \.self) { index in
                let angle = Double(index) / Double(pieces) * 2 * .pi + Double(index % 3) * 0.13
                let wobble = 0.75 + 0.5 * Double((index * 7) % 5) / 4
                let distance = radius * (0.5 + 1.1 * spread) * wobble
                let pieceSize = radius * (0.10 + 0.06 * Double((index * 3) % 4) / 3) * (1 - 0.7 * progress)
                Group {
                    if index % 3 == 0 {
                        RoundedRectangle(cornerRadius: pieceSize * 0.3)
                            .fill(palette.top)
                            .frame(width: pieceSize, height: pieceSize * 0.6)
                            .rotationEffect(.degrees(angle * 180 / .pi + progress * 200))
                    } else {
                        Circle()
                            .fill(index % 2 == 0 ? palette.bottom : Color.white)
                            .frame(width: pieceSize, height: pieceSize)
                    }
                }
                .offset(x: cos(angle) * distance, y: sin(angle) * distance + radius * 0.5 * progress * progress)
                .opacity(1 - Easing.inQuad(progress))
            }
        }
    }
}
