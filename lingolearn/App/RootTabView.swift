import SwiftUI
import SwiftData

struct RootTabView: View {
    @Query private var settingsList: [UserSettings]
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house.fill") }

            LearningEntryView()
                .tabItem { Label("学习", systemImage: "book.fill") }

            PracticeEntryView()
                .tabItem { Label("练习", systemImage: "pencil.and.list.clipboard") }

            ProgressDashboardView()
                .tabItem { Label("进度", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
        }
        .tint(Theme.primary)
        .preferredColorScheme(settings.appearance.colorScheme)
        .task { ensureSettings() }
    }

    private var settings: UserSettings {
        settingsList.first ?? UserSettings()
    }

    private func ensureSettings() {
        if settingsList.isEmpty {
            context.insert(UserSettings())
            try? context.save()
        }
    }
}
