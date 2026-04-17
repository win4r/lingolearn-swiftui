import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [UserSettings]

    @State private var showResetAlert = false
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("学习目标") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("每日学习目标")
                            Spacer()
                            Text("\(settings.dailyGoal) 词")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(
                            value: Binding(
                                get: { Double(settings.dailyGoal) },
                                set: { settings.dailyGoal = Int($0); save() }
                            ),
                            in: 10...100,
                            step: 5
                        )
                    }
                    Stepper(value: Binding(
                        get: { settings.perQuestionSeconds },
                        set: { settings.perQuestionSeconds = $0; save() }
                    ), in: 5...60) {
                        HStack {
                            Text("练习每题时间")
                            Spacer()
                            Text("\(settings.perQuestionSeconds) 秒")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }

                Section("提醒") {
                    Toggle("学习提醒", isOn: Binding(
                        get: { settings.reminderEnabled },
                        set: { newValue in
                            settings.reminderEnabled = newValue
                            save()
                            Task { await applyReminder(newValue) }
                        }
                    ))
                    if settings.reminderEnabled {
                        DatePicker(
                            "提醒时间",
                            selection: Binding(
                                get: { settings.reminderTime },
                                set: { newValue in
                                    settings.reminderTime = newValue
                                    save()
                                    Task { await Notifications.scheduleDaily(at: newValue) }
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section("反馈") {
                    Toggle("音效", isOn: binding(\.soundEnabled))
                    Toggle("震动反馈", isOn: binding(\.hapticsEnabled))
                    Toggle("自动播放发音", isOn: binding(\.autoPlayAudio))
                }

                Section("外观") {
                    Picker("主题", selection: Binding(
                        get: { settings.appearance },
                        set: { settings.appearance = $0; save() }
                    )) {
                        ForEach(Appearance.allCases, id: \.self) { app in
                            Text(app.displayName).tag(app)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("重置学习进度")
                        }
                    }
                } footer: {
                    Text("会清除所有单词的学习状态、历史记录和成就。词库会被重新载入。")
                }

                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .alert("确认重置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("重置", role: .destructive) { resetAllProgress() }
            } message: {
                Text("这将清除你的所有学习数据，无法撤销。")
            }
            .alert("通知权限", isPresented: $showPermissionAlert) {
                Button("好") {}
            } message: {
                Text("未获得通知权限，无法发送每日提醒。请到系统设置中开启。")
            }
        }
    }

    private var settings: UserSettings {
        if let existing = settingsList.first { return existing }
        let created = UserSettings()
        context.insert(created)
        try? context.save()
        return created
    }

    private func binding(_ keyPath: ReferenceWritableKeyPath<UserSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0; save() }
        )
    }

    private func save() { try? context.save() }

    private func applyReminder(_ enabled: Bool) async {
        guard enabled else {
            Notifications.cancelDaily()
            return
        }
        let granted = await Notifications.requestAuthorization()
        if granted {
            await Notifications.scheduleDaily(at: settings.reminderTime)
        } else {
            settings.reminderEnabled = false
            save()
            showPermissionAlert = true
        }
    }

    private func resetAllProgress() {
        try? context.delete(model: Word.self)
        try? context.delete(model: WordProgress.self)
        try? context.delete(model: StudySession.self)
        try? context.delete(model: Achievement.self)
        settings.currentStreak = 0
        settings.lastStudyDate = nil
        try? context.save()
        WordSeeder.seedIfNeeded(context)
        AchievementEngine.seedIfNeeded(context)
    }
}
