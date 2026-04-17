import Foundation
import SwiftData

enum WordCategory: String, Codable, CaseIterable {
    case cet4
    case cet6

    var displayName: String {
        switch self {
        case .cet4: return "CET-4"
        case .cet6: return "CET-6"
        }
    }
}

@Model
final class Word {
    @Attribute(.unique) var id: UUID
    var english: String
    var phonetic: String
    var chinese: String
    var example: String
    var categoryRaw: String

    @Relationship(deleteRule: .cascade, inverse: \WordProgress.word)
    var progress: WordProgress?

    var category: WordCategory {
        get { WordCategory(rawValue: categoryRaw) ?? .cet4 }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        english: String,
        phonetic: String,
        chinese: String,
        example: String,
        category: WordCategory
    ) {
        self.id = id
        self.english = english
        self.phonetic = phonetic
        self.chinese = chinese
        self.example = example
        self.categoryRaw = category.rawValue
    }
}

struct WordSeed: Codable {
    let id: UUID
    let english: String
    let phonetic: String
    let chinese: String
    let example: String
    let category: WordCategory
}
