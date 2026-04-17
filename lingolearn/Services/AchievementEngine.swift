import Foundation
import SwiftData

enum AchievementEngine {
    /// Seeds all achievements from the catalog on first launch. Idempotent.
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        let existingKeys = Set(existing.map(\.key))

        for seed in AchievementCatalog.all where !existingKeys.contains(seed.key) {
            context.insert(Achievement(
                key: seed.key,
                title: seed.title,
                desc: seed.desc,
                iconName: seed.iconName,
                progressTarget: seed.target,
                sortOrder: seed.order
            ))
        }
        try? context.save()
    }

    struct UnlockEvent: Identifiable {
        let id = UUID()
        let achievement: Achievement
    }

    /// Re-evaluates achievement progress against current state and returns newly unlocked events.
    @discardableResult
    static func evaluate(_ context: ModelContext, settings: UserSettings, perfectRoundJustAchieved: Bool = false) -> [UnlockEvent] {
        let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        let sessionCount = (try? context.fetchCount(FetchDescriptor<StudySession>())) ?? 0
        let masteredRaw = LearningStatus.mastered.rawValue
        let mastered = (try? context.fetchCount(FetchDescriptor<WordProgress>(
            predicate: #Predicate<WordProgress> { $0.statusRaw == masteredRaw }
        ))) ?? 0
        let streak = settings.currentStreak

        var unlocked: [UnlockEvent] = []
        for ach in achievements {
            let previousUnlock = ach.unlockedAt
            let target: Int
            let current: Int
            switch ach.key {
            case "first_study":
                target = 1; current = sessionCount
            case "streak_3":
                target = 3; current = streak
            case "streak_7":
                target = 7; current = streak
            case "streak_30":
                target = 30; current = streak
            case "mastered_10":
                target = 10; current = mastered
            case "mastered_50":
                target = 50; current = mastered
            case "mastered_100":
                target = 100; current = mastered
            case "perfect_round":
                target = 1; current = (ach.progressCurrent >= 1 || perfectRoundJustAchieved) ? 1 : 0
            default:
                continue
            }
            ach.progressCurrent = min(current, target)
            ach.progressTarget = target

            if previousUnlock == nil, current >= target {
                ach.unlockedAt = .now
                unlocked.append(UnlockEvent(achievement: ach))
            }
        }
        try? context.save()
        return unlocked
    }
}
