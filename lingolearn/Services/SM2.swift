import Foundation

enum SM2 {
    struct Result: Equatable {
        let easinessFactor: Double
        let interval: Int
        let repetitions: Int
        let nextReview: Date
    }

    /// Compute the next SM-2 state given an answer quality (0...5).
    /// - Parameters:
    ///   - quality: 0 total blackout, 3 pass, 5 perfect recall.
    ///   - ef: current easiness factor (start at 2.5).
    ///   - interval: current interval in days.
    ///   - repetitions: successful repetitions so far.
    ///   - now: date anchor (for testability).
    static func next(
        quality: Int,
        ef: Double,
        interval: Int,
        repetitions: Int,
        now: Date = .now
    ) -> Result {
        let q = max(0, min(5, quality))
        let qDouble = Double(q)
        let newEF = max(1.3, ef + 0.1 - (5 - qDouble) * (0.08 + (5 - qDouble) * 0.02))

        let newReps: Int
        let newInterval: Int
        if q < 3 {
            newReps = 0
            newInterval = 1
        } else {
            newReps = repetitions + 1
            switch newReps {
            case 1: newInterval = 1
            case 2: newInterval = 6
            default: newInterval = max(1, Int((Double(interval) * newEF).rounded()))
            }
        }

        let next = Calendar.current.date(byAdding: .day, value: newInterval, to: Calendar.current.startOfDay(for: now)) ?? now
        return Result(easinessFactor: newEF, interval: newInterval, repetitions: newReps, nextReview: next)
    }

    /// Map a higher-level answer to the SM-2 quality scale.
    enum Answer { case knowConfident, knowHesitant, forgotButRecognized, forgot }

    static func quality(for answer: Answer) -> Int {
        switch answer {
        case .knowConfident: return 5
        case .knowHesitant: return 4
        case .forgotButRecognized: return 2
        case .forgot: return 1
        }
    }
}
