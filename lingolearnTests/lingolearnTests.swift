import Testing
import Foundation
import SwiftUI
@testable import lingolearn

struct SM2Tests {

    @Test func firstSuccessfulReview_resetsToOneDayInterval() {
        let result = SM2.next(quality: 5, ef: 2.5, interval: 0, repetitions: 0)
        #expect(result.repetitions == 1)
        #expect(result.interval == 1)
        #expect(result.easinessFactor > 2.5) // EF grows on perfect recall
    }

    @Test func secondSuccessfulReview_isSixDays() {
        let first = SM2.next(quality: 5, ef: 2.5, interval: 0, repetitions: 0)
        let second = SM2.next(quality: 5, ef: first.easinessFactor, interval: first.interval, repetitions: first.repetitions)
        #expect(second.repetitions == 2)
        #expect(second.interval == 6)
    }

    @Test func thirdSuccessfulReview_multipliesByEF() {
        let ef = 2.5
        let third = SM2.next(quality: 5, ef: ef, interval: 6, repetitions: 2)
        #expect(third.repetitions == 3)
        #expect(third.interval >= 15) // 6 * ~2.6
    }

    @Test func lowQuality_resetsRepetitionsAndInterval() {
        let result = SM2.next(quality: 1, ef: 2.5, interval: 10, repetitions: 4)
        #expect(result.repetitions == 0)
        #expect(result.interval == 1)
    }

    @Test func easinessFactor_isClampedAtMinimum() {
        // Many consecutive quality=0 answers should not drop EF below 1.3
        var ef = 2.5
        for _ in 0..<20 {
            ef = SM2.next(quality: 0, ef: ef, interval: 1, repetitions: 0).easinessFactor
        }
        #expect(ef >= 1.3)
    }

    @Test func quality_mappingFromAnswer() {
        #expect(SM2.quality(for: .knowConfident) == 5)
        #expect(SM2.quality(for: .knowHesitant) == 4)
        #expect(SM2.quality(for: .forgotButRecognized) == 2)
        #expect(SM2.quality(for: .forgot) == 1)
    }

    @Test func nextReview_isInTheFuture() {
        let now = Date()
        let result = SM2.next(quality: 5, ef: 2.5, interval: 0, repetitions: 0, now: now)
        #expect(result.nextReview > now)
    }
}

struct SeedTests {

    @Test func wordsJson_loadsAndHasEnoughEntries() throws {
        let url = Bundle.main.url(forResource: "words", withExtension: "json")
        try #require(url != nil)
        let data = try Data(contentsOf: url!)
        let seeds = try JSONDecoder().decode([WordSeed].self, from: data)
        #expect(seeds.count >= 500)
    }

    @Test func wordsJson_hasBothCategories() throws {
        let url = try #require(Bundle.main.url(forResource: "words", withExtension: "json"))
        let seeds = try JSONDecoder().decode([WordSeed].self, from: Data(contentsOf: url))
        let cet4 = seeds.filter { $0.category == .cet4 }
        let cet6 = seeds.filter { $0.category == .cet6 }
        #expect(cet4.count > 100)
        #expect(cet6.count > 100)
    }

    @Test func wordsJson_idsAreUnique() throws {
        let url = try #require(Bundle.main.url(forResource: "words", withExtension: "json"))
        let seeds = try JSONDecoder().decode([WordSeed].self, from: Data(contentsOf: url))
        let ids = Set(seeds.map(\.id))
        #expect(ids.count == seeds.count)
    }
}

struct AppearanceTests {
    @Test func appearance_colorSchemeMapping() {
        #expect(Appearance.system.colorScheme == nil)
        #expect(Appearance.light.colorScheme == .light)
        #expect(Appearance.dark.colorScheme == .dark)
    }
}
