import SwiftUI

struct AlarmEditorView: View {
    @Environment(AlarmStore.self) private var store
    let onClose: () -> Void

    @State private var draft: Alarm
    @State private var time: Date
    @State private var showDetails: Bool
    private let isNew: Bool

    init(alarm: Alarm?, onClose: @escaping () -> Void) {
        self.onClose = onClose
        isNew = alarm == nil
        let base = alarm ?? Self.defaultAlarm()
        _draft = State(initialValue: base)
        _showDetails = State(initialValue: base.repeats)
        _time = State(initialValue: Calendar.current.date(bySettingHour: base.hour, minute: base.minute, second: 0, of: Date()) ?? Date())
    }

    /// 新規アラームの初期値: 次の正時
    private static func defaultAlarm() -> Alarm {
        var alarm = Alarm()
        alarm.hour = (Calendar.current.component(.hour, from: Date()) + 1) % 24
        alarm.minute = 0
        return alarm
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(title: isNew ? "新規アラーム" : "アラームを編集", onBack: onClose)
            Divider()

            VStack(alignment: .leading, spacing: 14) {
                LabeledContent("時刻") {
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.stepperField)
                        .labelsHidden()
                }

                LabeledContent("ラベル") {
                    TextField("例: 〇〇さんに電話", text: $draft.label)
                        .textFieldStyle(.roundedBorder)
                }

                LabeledContent("色") {
                    ColorSwatchPicker(selection: $draft.color)
                }

                DisclosureGroup("詳細", isExpanded: $showDetails) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("繰り返し").font(.caption).foregroundStyle(.secondary)
                        WeekdayPicker(selection: $draft.repeatWeekdays)
                        HStack(spacing: 6) {
                            Button("なし") { draft.repeatWeekdays = [] }
                            Button("毎日") { draft.repeatWeekdays = Alarm.everyDay }
                            Button("平日") { draft.repeatWeekdays = Alarm.weekdays }
                        }
                        .controlSize(.small)
                        Text(draft.repeats ? "\(draft.repeatDescription)に鳴らします" : "1回鳴ったら無効になります")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(12)

            Divider()

            HStack {
                if !isNew {
                    Button("削除", role: .destructive) {
                        store.remove(alarmID: draft.id)
                        onClose()
                    }
                }
                Spacer()
                Button("キャンセル", action: onClose)
                Button("保存", action: save)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
        .onAppear {
            if isNew { draft.color = store.settings.defaultColor }
        }
    }

    private func save() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        draft.hour = components.hour ?? 0
        draft.minute = components.minute ?? 0
        draft.isEnabled = true
        if isNew {
            store.add(draft)
        } else {
            store.update(draft)
        }
        onClose()
    }
}

struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { day in
                let isOn = selection.contains(day)
                Button {
                    if isOn { selection.remove(day) } else { selection.insert(day) }
                } label: {
                    Text(Alarm.weekdaySymbols[day - 1])
                        .font(.callout.weight(.medium))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(isOn ? Color.accentColor : Color.secondary.opacity(0.15)))
                        .foregroundStyle(isOn ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ColorSwatchPicker: View {
    @Binding var selection: AlarmColor

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AlarmColor.allCases) { item in
                Button {
                    selection = item
                } label: {
                    Circle()
                        .fill(item == .auto ? AnyShapeStyle(AlarmColor.autoGradient) : AnyShapeStyle(item.color))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().strokeBorder(Color.secondary.opacity(0.4), lineWidth: 1))
                        .overlay {
                            if selection == item {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(item.textColor)
                            }
                        }
                }
                .buttonStyle(.plain)
                .help(item.name)
            }
        }
    }
}
