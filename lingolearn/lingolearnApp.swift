import SwiftUI
import SwiftData

@main
struct lingolearnApp: App {
    let container: ModelContainer = {
        let schema = Schema([
            Word.self,
            WordProgress.self,
            StudySession.self,
            UserSettings.self,
            Achievement.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    WordSeeder.seedIfNeeded(container.mainContext)
                    AchievementEngine.seedIfNeeded(container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
