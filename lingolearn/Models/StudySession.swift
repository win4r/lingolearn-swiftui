import Foundation
import SwiftData

@Model
final class StudySession {
    var date: Date
    var wordsStudied: Int
    var correctCount: Int
    var durationSeconds: Int

    init(date: Date, wordsStudied: Int, correctCount: Int, durationSeconds: Int) {
        self.date = Calendar.current.startOfDay(for: date)
        self.wordsStudied = wordsStudied
        self.correctCount = correctCount
        self.durationSeconds = durationSeconds
    }
}
