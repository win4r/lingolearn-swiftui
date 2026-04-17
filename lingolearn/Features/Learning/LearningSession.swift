import Foundation
import SwiftData

enum SwipeDirection { case right, left, up }

@Observable
final class LearningSession {
    private(set) var words: [Word]
    private(set) var index: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var wrongCount: Int = 0
    private let startedAt = Date()
    private let context: ModelContext
    private let settings: UserSettings

    init(words: [Word], context: ModelContext, settings: UserSettings) {
        self.words = words
        self.context = context
        self.settings = settings
    }

    var current: Word? {
        guard index < words.count else { return nil }
        return words[index]
    }

    var isFinished: Bool { index >= words.count }
    var progress: Double { words.isEmpty ? 1 : Double(index) / Double(words.count) }

    @discardableResult
    func advance(with direction: SwipeDirection) -> AchievementBundle {
        guard let word = current else { return .empty }
        let progress = word.progress ?? {
            let p = WordProgress(word: word)
            word.progress = p
            return p
        }()

        let answer: SM2.Answer
        switch direction {
        case .right:
            answer = progress.status == .new ? .knowConfident : .knowHesitant
            correctCount += 1
            progress.timesCorrect += 1
        case .left:
            answer = .forgot
            wrongCount += 1
            progress.timesWrong += 1
        case .up:
            progress.isFavorite.toggle()
            index += 1
            try? context.save()
            return .empty
        }

        let quality = SM2.quality(for: answer)
        let result = SM2.next(
            quality: quality,
            ef: progress.easinessFactor,
            interval: progress.interval,
            repetitions: progress.repetitions
        )
        progress.easinessFactor = result.easinessFactor
        progress.interval = result.interval
        progress.repetitions = result.repetitions
        progress.nextReviewDate = result.nextReview
        progress.lastReviewedAt = .now
        progress.status = deriveStatus(from: progress)

        index += 1
        try? context.save()

        if isFinished {
            let duration = Int(Date().timeIntervalSince(startedAt))
            let unlocked = SessionRecorder.record(
                context: context,
                settings: settings,
                wordsStudied: words.count,
                correctCount: correctCount,
                durationSeconds: duration,
                perfectRound: wrongCount == 0 && words.count >= 5
            )
            return AchievementBundle(unlocked: unlocked)
        }
        return .empty
    }

    private func deriveStatus(from progress: WordProgress) -> LearningStatus {
        if progress.repetitions >= 5 && progress.easinessFactor >= 2.5 { return .mastered }
        if progress.repetitions >= 1 { return .learning }
        return .new
    }
}

struct AchievementBundle {
    let unlocked: [AchievementEngine.UnlockEvent]
    static let empty = AchievementBundle(unlocked: [])
}
