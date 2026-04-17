import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var key: String
    var title: String
    var desc: String
    var iconName: String
    var unlockedAt: Date?
    var progressCurrent: Int
    var progressTarget: Int
    var sortOrder: Int

    var isUnlocked: Bool { unlockedAt != nil }

    init(
        key: String,
        title: String,
        desc: String,
        iconName: String,
        progressTarget: Int,
        sortOrder: Int,
        unlockedAt: Date? = nil,
        progressCurrent: Int = 0
    ) {
        self.key = key
        self.title = title
        self.desc = desc
        self.iconName = iconName
        self.progressTarget = progressTarget
        self.sortOrder = sortOrder
        self.unlockedAt = unlockedAt
        self.progressCurrent = progressCurrent
    }
}

enum AchievementCatalog {
    static let all: [AchievementSeed] = [
        .init(key: "first_study", title: "破冰之旅", desc: "完成首次学习", iconName: "sparkles", target: 1, order: 0),
        .init(key: "streak_3", title: "三日坚持", desc: "连续学习 3 天", iconName: "flame", target: 3, order: 1),
        .init(key: "streak_7", title: "一周坚持", desc: "连续学习 7 天", iconName: "flame.fill", target: 7, order: 2),
        .init(key: "streak_30", title: "月度学霸", desc: "连续学习 30 天", iconName: "crown.fill", target: 30, order: 3),
        .init(key: "mastered_10", title: "初露锋芒", desc: "掌握 10 个单词", iconName: "star", target: 10, order: 4),
        .init(key: "mastered_50", title: "渐入佳境", desc: "掌握 50 个单词", iconName: "star.leadinghalf.filled", target: 50, order: 5),
        .init(key: "mastered_100", title: "词汇达人", desc: "掌握 100 个单词", iconName: "star.fill", target: 100, order: 6),
        .init(key: "perfect_round", title: "完美一轮", desc: "练习全对一次", iconName: "rosette", target: 1, order: 7)
    ]
}

struct AchievementSeed {
    let key: String
    let title: String
    let desc: String
    let iconName: String
    let target: Int
    let order: Int
}
