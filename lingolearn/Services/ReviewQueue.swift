import Foundation
import SwiftData

enum ReviewQueue {
    /// Returns words whose progress is due for review (nextReviewDate <= now).
    static func dueWords(in context: ModelContext, now: Date = .now, limit: Int? = nil) -> [Word] {
        var descriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate<WordProgress> { $0.nextReviewDate <= now },
            sortBy: [SortDescriptor(\.nextReviewDate, order: .forward)]
        )
        if let limit { descriptor.fetchLimit = limit }
        let progresses = (try? context.fetch(descriptor)) ?? []
        return progresses.compactMap { $0.word }
    }

    /// Returns words never studied yet (status == .new), up to `limit`.
    static func newWords(in context: ModelContext, limit: Int) -> [Word] {
        let newRaw = LearningStatus.new.rawValue
        var descriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate<WordProgress> { $0.statusRaw == newRaw }
        )
        descriptor.fetchLimit = limit
        let progresses = (try? context.fetch(descriptor)) ?? []
        return progresses.compactMap { $0.word }
    }

    /// Mixes due reviews + new words up to a target session size.
    static func todaysSession(in context: ModelContext, target: Int) -> [Word] {
        let due = dueWords(in: context, limit: target)
        if due.count >= target { return Array(due.prefix(target)) }
        let remaining = target - due.count
        let fresh = newWords(in: context, limit: remaining)
        return due + fresh
    }

    static func randomWords(in context: ModelContext, count: Int) -> [Word] {
        let all = (try? context.fetch(FetchDescriptor<Word>())) ?? []
        return Array(all.shuffled().prefix(count))
    }

    static func dueCount(in context: ModelContext, now: Date = .now) -> Int {
        let descriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate<WordProgress> { $0.nextReviewDate <= now && $0.statusRaw != "new" }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
