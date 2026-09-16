import SwiftUI

/// 全画面パネルの中身。本番表示があればそれを、なければカウントダウンを出す。
struct OverlayRootView: View {
    var state: OverlayState
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    var body: some View {
        ZStack {
            if state.isRinging {
                RingingView(state: state, onDismiss: onDismiss, onSnooze: onSnooze)
            } else if !state.countdown.isEmpty {
                CountdownView(state: state)
            }
        }
        .ignoresSafeArea()
    }
}

/// カウントダウン中に画面下部へ出す「停止」ボタン（クリックを受ける唯一の場所）
struct StopButtonView: View {
    let onStop: () -> Void
    var scale: CGFloat = 1

    var body: some View {
        Button(action: onStop) {
            Label(L("Stop"), systemImage: "xmark.circle.fill")
                .font(.system(size: 24 * scale, weight: .semibold))
                .padding(.horizontal, 28 * scale)
                .padding(.vertical, 12 * scale)
                .background(.regularMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 画面の高さ 1080pt を基準にした、オーバーレイ上の寸法
enum OverlayLayout {
    static func scale(for screenHeight: CGFloat) -> CGFloat { screenHeight / 1080 }
    static func stopButtonSize(scale: CGFloat) -> CGSize { CGSize(width: 240 * scale, height: 72 * scale) }
    static func stopButtonBottom(scale: CGFloat) -> CGFloat { 64 * scale }
}
