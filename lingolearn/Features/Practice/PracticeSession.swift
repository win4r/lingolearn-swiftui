import Foundation
import SwiftData

enum QuestionType { case multipleChoice, fillInBlank, listening }

struct PracticeQuestion: Identifiable {
    let id = UUID()
    let type: QuestionType
    let word: Word
    let options: [String] // empty for fillInBlank
    let prompt: String    // what to show the user
    let correctAnswer: String
}

struct PracticeAnswer {
    let question: PracticeQuestion
    let userAnswer: String
    let isCorrect: Bool
}

@Observable
final class PracticeSession {
    let questions: [PracticeQuestion]
    private(set) var answers: [PracticeAnswer] = []
    private(set) var index = 0
    private(set) var startedAt = Date()

    init(questions: [PracticeQuestion]) {
        self.questions = questions
    }

    var current: PracticeQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var isFinished: Bool { index >= questions.count }
    var progress: Double { questions.isEmpty ? 1 : Double(index) / Double(questions.count) }

    func submit(userAnswer: String) -> Bool {
        guard let q = current else { return false }
        let normalized = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let target = q.correctAnswer.lowercased()
        let correct = normalized == target
        answers.append(PracticeAnswer(question: q, userAnswer: userAnswer, isCorrect: correct))
        index += 1
        return correct
    }

    func skip() {
        guard let q = current else { return }
        answers.append(PracticeAnswer(question: q, userAnswer: "", isCorrect: false))
        index += 1
    }

    var correctCount: Int { answers.filter(\.isCorrect).count }
    var duration: Int { Int(Date().timeIntervalSince(startedAt)) }
    var accuracy: Double {
        answers.isEmpty ? 0 : Double(correctCount) / Double(answers.count)
    }
    var wrongAnswers: [PracticeAnswer] { answers.filter { !$0.isCorrect } }
}

enum PracticeBuilder {
    static func build(kind: PracticeKind, context: ModelContext, count: Int = 10) -> [PracticeQuestion] {
        let pool = (try? context.fetch(FetchDescriptor<Word>()))?.shuffled() ?? []
        guard pool.count >= 4 else { return [] }

        let subjects = Array(pool.prefix(count))
        return subjects.map { word in
            let type: QuestionType
            switch kind {
            case .multipleChoice: type = .multipleChoice
            case .fillInBlank: type = .fillInBlank
            case .listening: type = .listening
            case .random:
                type = [QuestionType.multipleChoice, .fillInBlank, .listening].randomElement() ?? .multipleChoice
            }
            return question(for: word, type: type, pool: pool)
        }
    }

    private static func question(for word: Word, type: QuestionType, pool: [Word]) -> PracticeQuestion {
        switch type {
        case .multipleChoice:
            let distractors = pool.filter { $0.id != word.id }.shuffled().prefix(3).map(\.chinese)
            let options = ([word.chinese] + distractors).shuffled()
            return PracticeQuestion(
                type: .multipleChoice,
                word: word,
                options: options,
                prompt: word.english,
                correctAnswer: word.chinese
            )
        case .fillInBlank:
            return PracticeQuestion(
                type: .fillInBlank,
                word: word,
                options: [],
                prompt: word.chinese,
                correctAnswer: word.english
            )
        case .listening:
            let distractors = pool.filter { $0.id != word.id }.shuffled().prefix(3).map(\.english)
            let options = ([word.english] + distractors).shuffled()
            return PracticeQuestion(
                type: .listening,
                word: word,
                options: options,
                prompt: "🔊",
                correctAnswer: word.english
            )
        }
    }
}
