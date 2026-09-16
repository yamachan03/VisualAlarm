import SwiftUI

/// メニューバーから開くパネル。一覧・アラーム編集・設定を切り替える。
struct MenuBarView: View {
    @State private var screen: Screen = .main

    enum Screen: Equatable {
        case main
        case editor(Alarm?)
        case settings
    }

    var body: some View {
        Group {
            switch screen {
            case .main:
                MainPanel(onEdit: { screen = .editor($0) },
                          onNew: { screen = .editor(nil) },
                          onSettings: { screen = .settings })
            case .editor(let alarm):
                AlarmEditorView(alarm: alarm) { screen = .main }
            case .settings:
                SettingsView { screen = .main }
            }
        }
        .frame(width: 360)
    }
}

// MARK: - 共通部品

/// 戻るボタン付きの見出し
struct PanelHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.plain)
            Text(title).font(.headline)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

/// 折り返して並べる横並び
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width == .infinity ? x : width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - 一覧

struct MainPanel: View {
    @Environment(AlarmStore.self) private var store
    let onEdit: (Alarm) -> Void
    let onNew: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            TimerSection()
            Divider()
            AlarmSection(onEdit: onEdit, onNew: onNew)
            Divider()
            footer
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "alarm.fill").foregroundStyle(Color.accentColor)
            Text("VisualAlarm").font(.headline)
            Spacer()
            if let next = store.nextAlarm {
                Text(L("Next: {0}", TimeFormatting.upcoming(next.date, now: store.now)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button(action: onSettings) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help(L("Settings"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var footer: some View {
        HStack {
            Button(L("Test")) { store.previewOverlay() }
                .help(L("Runs the countdown and the full-screen display once"))
            Spacer()
            Button(L("Quit")) { NSApplication.shared.terminate(nil) }
        }
        .padding(12)
    }
}

// MARK: - タイマー

struct TimerSection: View {
    @Environment(AlarmStore.self) private var store

    @State private var hours = 0
    @State private var minutes = 15
    @State private var seconds = 0
    @State private var label = ""
    @State private var showAllHistory = false

    private var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(L("Timer"))

            ForEach(store.sortedTimers) { timer in
                TimerRow(timer: timer)
            }

            FlowLayout(spacing: 6) {
                ForEach(store.presets, id: \.self) { preset in
                    Button(TimeFormatting.duration(seconds: preset)) {
                        store.startTimer(seconds: preset)
                    }
                    .contextMenu {
                        Button(L("Remove Preset"), role: .destructive) { store.removePreset(preset) }
                    }
                }
            }

            HStack(spacing: 4) {
                NumberField(value: $hours, range: 0...23, width: 34)
                Text(L("h")).font(.caption)
                NumberField(value: $minutes, range: 0...59, width: 34)
                Text(L("min")).font(.caption)
                NumberField(value: $seconds, range: 0...59, width: 34)
                Text(L("s")).font(.caption)
                Spacer(minLength: 4)
                Button(L("Start")) {
                    store.startTimer(seconds: totalSeconds, label: label)
                    label = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(totalSeconds < 1)
            }
            TextField(L("Label (optional), e.g. Call Sam"), text: $label)
                .textFieldStyle(.roundedBorder)

            HistoryList(title: L("Recent timers"),
                        entries: store.timerHistory,
                        showAll: $showAllHistory,
                        row: { entry in
                            HStack(spacing: 6) {
                                Circle().fill(entry.color.color).frame(width: 8, height: 8)
                                Text(TimeFormatting.duration(seconds: entry.seconds))
                                    .font(.callout.weight(.medium))
                                    .monospacedDigit()
                                Text(entry.label).foregroundStyle(.secondary).lineLimit(1)
                            }
                        },
                        onSelect: { store.apply($0) },
                        onDelete: { store.removeTimerHistory(id: $0.id) })
        }
        .padding(12)
    }
}

struct TimerRow: View {
    @Environment(AlarmStore.self) private var store
    let timer: CountdownTimer

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(timer.color.color).frame(width: 10, height: 10)
            Text(timer.displayTitle).lineLimit(1)
            Spacer()
            Text(TimeFormatting.countdown(timer.remaining(at: store.now)))
                .font(.title3.weight(.medium))
                .monospacedDigit()
            Button {
                store.cancelTimer(id: timer.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(L("Cancel"))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
    }
}

/// 0 埋め 2 桁の数値入力欄
struct NumberField: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let width: CGFloat

    var body: some View {
        TextField("", value: $value, format: .number)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .frame(width: width)
            .onChange(of: value) { _, newValue in
                let clamped = min(max(newValue, range.lowerBound), range.upperBound)
                if clamped != newValue { value = clamped }
            }
    }
}

// MARK: - アラーム

struct AlarmSection: View {
    @Environment(AlarmStore.self) private var store
    let onEdit: (Alarm) -> Void
    let onNew: () -> Void

    @State private var showAllHistory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionTitle(L("Alarm"))
                Spacer()
                Button(action: onNew) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .help(L("Add Alarm"))
            }

            if store.alarms.isEmpty {
                Text(L("No alarms"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(store.sortedAlarms) { alarm in
                            AlarmRow(alarm: alarm) { onEdit(alarm) }
                        }
                    }
                }
                .frame(maxHeight: 220)
            }

            HistoryList(title: L("Set from history"),
                        entries: store.alarmHistory,
                        showAll: $showAllHistory,
                        row: { entry in
                            HStack(spacing: 6) {
                                Circle().fill(entry.color.color).frame(width: 8, height: 8)
                                Text(entry.timeString)
                                    .font(.callout.weight(.medium))
                                    .monospacedDigit()
                                Text(entry.label).foregroundStyle(.secondary).lineLimit(1)
                            }
                        },
                        onSelect: { store.apply($0) },
                        onDelete: { store.removeAlarmHistory(id: $0.id) })
        }
        .padding(12)
    }
}

struct AlarmRow: View {
    @Environment(AlarmStore.self) private var store
    let alarm: Alarm
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { store.setEnabled($0, alarmID: alarm.id) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)

            Circle().fill(alarm.color.color).frame(width: 10, height: 10)

            Text(alarm.timeString)
                .font(.title2.weight(.medium))
                .monospacedDigit()

            VStack(alignment: .leading, spacing: 1) {
                if !alarm.label.isEmpty {
                    Text(alarm.label).lineLimit(1)
                }
                Text(alarm.repeatDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .opacity(alarm.isEnabled ? 1 : 0.55)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onEdit)
    }
}

// MARK: - 履歴

/// 3 件まで表示し、「もっと見る」で全件。クリックでセット、右クリックで削除。
struct HistoryList<Entry: Identifiable, Row: View>: View {
    let title: String
    let entries: [Entry]
    @Binding var showAll: Bool
    @ViewBuilder let row: (Entry) -> Row
    let onSelect: (Entry) -> Void
    let onDelete: (Entry) -> Void

    private static var collapsedCount: Int { 3 }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    if entries.count > Self.collapsedCount {
                        Button(showAll ? L("Show less") : L("Show all ({0})", entries.count)) { showAll.toggle() }
                            .buttonStyle(.plain)
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ForEach(showAll ? entries : Array(entries.prefix(Self.collapsedCount))) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        HStack {
                            row(entry)
                            Spacer()
                            Image(systemName: "arrow.uturn.backward")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                    .contextMenu {
                        Button(L("Remove from History"), role: .destructive) { onDelete(entry) }
                    }
                }
            }
            .padding(.top, 4)
        }
    }
}
