import Foundation
import SwiftData
import SwiftUI

enum Appearance: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Model
final class UserSettings {
    var dailyGoal: Int
    var reminderEnabled: Bool
    var reminderTime: Date
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var autoPlayAudio: Bool
    var appearanceRaw: String
    var currentStreak: Int
    var lastStudyDate: Date?
    var perQuestionSeconds: Int

    var appearance: Appearance {
        get { Appearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    init(
        dailyGoal: Int = 20,
        reminderEnabled: Bool = false,
        reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        autoPlayAudio: Bool = true,
        appearance: Appearance = .system,
        currentStreak: Int = 0,
        lastStudyDate: Date? = nil,
        perQuestionSeconds: Int = 15
    ) {
        self.dailyGoal = dailyGoal
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.autoPlayAudio = autoPlayAudio
        self.appearanceRaw = appearance.rawValue
        self.currentStreak = currentStreak
        self.lastStudyDate = lastStudyDate
        self.perQuestionSeconds = perQuestionSeconds
    }
}
