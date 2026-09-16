import SwiftUI

struct SettingsView: View {
    @Environment(AlarmStore.self) private var store
    let onClose: () -> Void

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchError: String?

    private let dismissChoices: [(Int, String)] = [
        (0, "しない"), (10, "10秒"), (30, "30秒"), (60, "1分"), (300, "5分"),
    ]
    private let snoozeChoices = [1, 3, 5, 10, 15]

    var body: some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(title: "設定", onBack: onClose)
            Divider()

            Form {
                Section("表示") {
                    LabeledContent("標準の色") {
                        ColorSwatchPicker(selection: $store.settings.defaultColor)
                    }
                    Stepper("カウントダウンの秒数: \(store.settings.countdownSeconds)秒",
                            value: $store.settings.countdownSeconds, in: 3...10)
                    LabeledContent("カウントダウンの背景の濃さ") {
                        HStack {
                            Slider(value: $store.settings.countdownDim, in: 0.1...0.7, step: 0.05)
                            Text("\(Int((store.settings.countdownDim * 100).rounded()))%")
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    LabeledContent("本番表示の不透明度") {
                        HStack {
                            Slider(value: $store.settings.overlayOpacity, in: 0.5...1.0, step: 0.05)
                            Text("\(Int((store.settings.overlayOpacity * 100).rounded()))%")
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }

                Section("動作") {
                    Picker("スヌーズ", selection: $store.settings.snoozeMinutes) {
                        ForEach(snoozeChoices, id: \.self) { minutes in
                            Text("\(minutes)分").tag(minutes)
                        }
                    }
                    Picker("自動で解除", selection: $store.settings.autoDismissSeconds) {
                        ForEach(dismissChoices, id: \.0) { choice in
                            Text(choice.1).tag(choice.0)
                        }
                    }
                    Toggle("メニューバーに残り時間を表示", isOn: $store.settings.showTimerInMenuBar)
                    Toggle("ログイン時に起動", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                try LaunchAtLogin.set(newValue)
                                launchError = nil
                            } catch {
                                launchError = error.localizedDescription
                                launchAtLogin = LaunchAtLogin.isEnabled
                            }
                        }
                    if let launchError {
                        Text(launchError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("履歴") {
                    Button("履歴を消去", role: .destructive) { store.clearHistory() }
                        .disabled(store.alarmHistory.isEmpty && store.timerHistory.isEmpty)
                }
            }
            .formStyle(.grouped)
            .frame(height: 480)
        }
    }
}
