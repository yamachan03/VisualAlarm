import SwiftUI

struct SettingsView: View {
    @Environment(AlarmStore.self) private var store
    let onClose: () -> Void

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchError: String?

    private let dismissChoices = [0, 10, 30, 60, 300]
    private let snoozeChoices = [1, 3, 5, 10, 15]

    private func dismissLabel(_ seconds: Int) -> String {
        switch seconds {
        case 0: L("Never")
        case ..<60: L("{0} s", seconds)
        default: L("{0} min", seconds / 60)
        }
    }

    var body: some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(title: L("Settings"), onBack: onClose)
            Divider()

            Form {
                Section(L("Language")) {
                    Picker(L("Language"), selection: $store.settings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .labelsHidden()
                }

                Section(L("Display")) {
                    LabeledContent(L("Default color")) {
                        ColorSwatchPicker(selection: $store.settings.defaultColor)
                    }
                    Stepper(L("Countdown: {0} s", store.settings.countdownSeconds),
                            value: $store.settings.countdownSeconds, in: 3...10)
                    LabeledContent(L("Countdown dimming")) {
                        HStack {
                            Slider(value: $store.settings.countdownDim, in: 0.1...0.7, step: 0.05)
                            Text("\(Int((store.settings.countdownDim * 100).rounded()))%")
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    LabeledContent(L("Full-screen opacity")) {
                        HStack {
                            Slider(value: $store.settings.overlayOpacity, in: 0.5...1.0, step: 0.05)
                            Text("\(Int((store.settings.overlayOpacity * 100).rounded()))%")
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }

                Section(L("Behavior")) {
                    Picker(L("Snooze"), selection: $store.settings.snoozeMinutes) {
                        ForEach(snoozeChoices, id: \.self) { minutes in
                            Text(L("{0} min", minutes)).tag(minutes)
                        }
                    }
                    Picker(L("Auto-dismiss"), selection: $store.settings.autoDismissSeconds) {
                        ForEach(dismissChoices, id: \.self) { seconds in
                            Text(dismissLabel(seconds)).tag(seconds)
                        }
                    }
                    Toggle(L("Show remaining time in menu bar"), isOn: $store.settings.showTimerInMenuBar)
                    Toggle(L("Launch at login"), isOn: $launchAtLogin)
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

                Section(L("History")) {
                    Button(L("Clear History"), role: .destructive) { store.clearHistory() }
                        .disabled(store.alarmHistory.isEmpty && store.timerHistory.isEmpty)
                }
            }
            .formStyle(.grouped)
            .frame(height: 540)
        }
    }
}
