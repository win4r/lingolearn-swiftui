import Foundation
import SwiftData

enum LearningStatus: String, Codable, CaseIterable {
    case new
    case learning
    case mastered

    var displayName: String {
        switch self {
        case .new: return "新学"
        case .learning: return "学习中"
        case .mastered: return "已掌握"
        }
    }
}

@Model
final class WordProgress {
    var word: Word?
    var easinessFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewedAt: Date?
    var statusRaw: String
    var isFavorite: Bool
    var timesCorrect: Int
    var timesWrong: Int

    var status: LearningStatus {
        get { LearningStatus(rawValue: statusRaw) ?? .new }
        set { statusRaw = newValue.rawValue }
    }

    init(
        word: Word? = nil,
        easinessFactor: Double = 2.5,
        interval: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date = .now,
        lastReviewedAt: Date? = nil,
        status: LearningStatus = .new,
        isFavorite: Bool = false,
        timesCorrect: Int = 0,
        timesWrong: Int = 0
    ) {
        self.word = word
        self.easinessFactor = easinessFactor
        self.interval = interval
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.lastReviewedAt = lastReviewedAt
        self.statusRaw = status.rawValue
        self.isFavorite = isFavorite
        self.timesCorrect = timesCorrect
        self.timesWrong = timesWrong
    }
}
