import Foundation
import SwiftData

enum WordSeeder {
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<Word>())) ?? 0
        guard existing == 0 else { return }

        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        let decoder = JSONDecoder()
        guard let seeds = try? decoder.decode([WordSeed].self, from: data) else { return }

        for seed in seeds {
            let word = Word(
                id: seed.id,
                english: seed.english,
                phonetic: seed.phonetic,
                chinese: seed.chinese,
                example: seed.example,
                category: seed.category
            )
            word.progress = WordProgress(word: word)
            context.insert(word)
        }

        try? context.save()
    }
}
