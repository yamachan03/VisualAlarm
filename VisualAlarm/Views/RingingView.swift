import SwiftUI

/// 設定時刻になったときの全画面表示。背景は静止、ラベルがゆっくり波打つ。
struct RingingView: View {
    var state: OverlayState
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    private var settings: AppSettings { state.settings }
    private var primary: AlarmColor { state.ringing.first?.color ?? .teal }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            // 背景はごくゆっくり明暗が呼吸する（1 周期 4 秒、±5%）
            let breath = 1 + 0.05 * sin(t * 2 * .pi / 4)
            ZStack {
                primary.color.opacity(min(1, settings.overlayOpacity * breath))
                content(time: t, now: context.date)
                    .foregroundStyle(primary.textColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
    }

    private func content(time: Double, now: Date) -> some View {
        GeometryReader { geometry in
            // 1080pt の高さを基準に、画面の大きさに比例して拡大縮小する
            let scale = geometry.size.height / 1080
            VStack(spacing: 26 * scale) {
                Image(systemName: "alarm.fill")
                    .font(.system(size: 96 * scale, weight: .bold))

                VStack(spacing: 30 * scale) {
                    ForEach(state.ringing) { item in
                        VStack(spacing: 8 * scale) {
                            WavyText(text: item.title, time: time,
                                     availableWidth: geometry.size.width - 120 * scale, scale: scale)
                            Text(item.subtitle)
                                .font(.system(size: 34 * scale, weight: .medium))
                                .opacity(0.85)
                        }
                    }
                }

                if let earliest = state.ringing.map(\.fireDate).min(),
                   let elapsed = TimeFormatting.elapsed(since: earliest, now: now) {
                    Text(elapsed)
                        .font(.system(size: 30 * scale, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 20 * scale)
                        .padding(.vertical, 8 * scale)
                        .background(.black.opacity(0.18), in: Capsule())
                }

                HStack(spacing: 20 * scale) {
                    Button(action: onDismiss) {
                        Label(L("Dismiss"), systemImage: "xmark.circle.fill")
                    }
                    Button(action: onSnooze) {
                        Label(L("Snooze {0} min", settings.snoozeMinutes), systemImage: "zzz")
                    }
                }
                .buttonStyle(OverlayButtonStyle(scale: scale))
                .padding(.top, 10 * scale)

                Text(L("Click anywhere to dismiss"))
                    .font(.system(size: 20 * scale))
                    .opacity(0.7)

                if !state.countdown.isEmpty {
                    Text(L("Up next: {0}", state.countdown.map(\.title).joined(separator: Localization.shared.effective.listJoiner)))
                        .font(.system(size: 20 * scale))
                        .opacity(0.7)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// 1 文字ずつ位相をずらして上下にうねる文字。長い文字列は全体がゆっくり上下する。
struct WavyText: View {
    let text: String
    let time: Double
    let availableWidth: CGFloat
    var scale: CGFloat = 1

    private static let period = 2.4
    private static let perCharLimit = 16

    var body: some View {
        let characters = Array(text)
        if characters.count <= Self.perCharLimit {
            let fontSize = min(130 * scale, availableWidth / (CGFloat(max(characters.count, 4)) * 1.15))
            HStack(spacing: 0) {
                ForEach(characters.indices, id: \.self) { index in
                    Text(String(characters[index]))
                        .font(.system(size: fontSize, weight: .heavy))
                        .offset(y: sin(time * 2 * .pi / Self.period - Double(index) * 0.45) * fontSize * 0.12)
                }
            }
        } else {
            Text(text)
                .font(.system(size: 96 * scale, weight: .heavy))
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: availableWidth)
                .offset(y: sin(time * 2 * .pi / Self.period) * 8 * scale)
        }
    }
}

struct OverlayButtonStyle: ButtonStyle {
    var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 26 * scale, weight: .semibold))
            .padding(.horizontal, 28 * scale)
            .padding(.vertical, 14 * scale)
            .background(.regularMaterial, in: Capsule())
            .foregroundStyle(.primary)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
