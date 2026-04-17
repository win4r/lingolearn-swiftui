import Foundation
import SwiftData

enum SessionRecorder {
    /// Records a completed study/practice session: writes a StudySession row, updates streak, evaluates achievements.
    /// Merges into today's StudySession row if one already exists (day-level granularity).
    @discardableResult
    static func record(
        context: ModelContext,
        settings: UserSettings,
        wordsStudied: Int,
        correctCount: Int,
        durationSeconds: Int,
        perfectRound: Bool = false
    ) -> [AchievementEngine.UnlockEvent] {
        let today = Calendar.current.startOfDay(for: .now)
        let existing: StudySession? = {
            let descriptor = FetchDescriptor<StudySession>(
                predicate: #Predicate<StudySession> { $0.date == today }
            )
            return (try? context.fetch(descriptor))?.first
        }()

        if let existing {
            existing.wordsStudied += wordsStudied
            existing.correctCount += correctCount
            existing.durationSeconds += durationSeconds
        } else {
            context.insert(StudySession(
                date: today,
                wordsStudied: wordsStudied,
                correctCount: correctCount,
                durationSeconds: durationSeconds
            ))
        }

        updateStreak(settings: settings, today: today)
        try? context.save()
        return AchievementEngine.evaluate(context, settings: settings, perfectRoundJustAchieved: perfectRound)
    }

    private static func updateStreak(settings: UserSettings, today: Date) {
        let cal = Calendar.current
        guard let last = settings.lastStudyDate else {
            settings.currentStreak = 1
            settings.lastStudyDate = today
            return
        }
        let lastDay = cal.startOfDay(for: last)
        if lastDay == today { return }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
            settings.currentStreak += 1
        } else {
            settings.currentStreak = 1
        }
        settings.lastStudyDate = today
    }
}
