import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [UserSettings]
    @Query private var sessions: [StudySession]

    @State private var learningTarget: LearningRoute?
    @State private var practiceTarget: PracticeKind?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressCard
                    HStack(spacing: 12) {
                        StreakBadge(days: settings.currentStreak)
                        ReviewBadge(count: reviewDueCount)
                    }
                    quickActions
                }
                .padding()
            }
            .navigationTitle("LingoLearn")
            .navigationDestination(item: $learningTarget) { route in
                LearningSessionView(route: route)
            }
            .navigationDestination(item: $practiceTarget) { kind in
                PracticeSessionView(kind: kind)
            }
        }
    }

    private var settings: UserSettings { settingsList.first ?? UserSettings() }

    private var todayStudied: Int {
        let today = Calendar.current.startOfDay(for: .now)
        return sessions.first(where: { $0.date == today })?.wordsStudied ?? 0
    }

    private var reviewDueCount: Int {
        ReviewQueue.dueCount(in: context)
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            ZStack {
                ProgressRing(progress: Double(todayStudied) / Double(max(1, settings.dailyGoal)))
                VStack(spacing: 4) {
                    Text("今日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(todayStudied)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Theme.primary)
                    Text("/ \(settings.dailyGoal)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text(encouragement)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var encouragement: String {
        let ratio = Double(todayStudied) / Double(max(1, settings.dailyGoal))
        switch ratio {
        case 0: return "开始学习，点亮今天吧 ✨"
        case 0..<0.5: return "已经迈出第一步，继续加油！"
        case 0.5..<1: return "过半啦，坚持就是胜利"
        default: return "目标达成，太棒了！"
        }
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            QuickActionButton(
                icon: "book.fill",
                title: "开始学习",
                subtitle: "今日计划 \(settings.dailyGoal) 词",
                tint: Theme.primary
            ) {
                learningTarget = .daily
            }

            QuickActionButton(
                icon: "arrow.clockwise.circle.fill",
                title: "快速复习",
                subtitle: reviewDueCount > 0 ? "\(reviewDueCount) 个单词待复习" : "当前没有待复习单词",
                tint: Theme.secondary
            ) {
                learningTarget = .review
            }

            QuickActionButton(
                icon: "dice.fill",
                title: "随机测试",
                subtitle: "10 道混合题型",
                tint: Theme.warning
            ) {
                practiceTarget = .random
            }
        }
    }
}

private struct ReviewBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundStyle(Theme.secondary)
                if count > 0 {
                    Text("\(min(count, 99))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.danger))
                        .offset(x: 10, y: -8)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("待复习")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(count) 词")
                    .font(.headline)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBackground))
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(tint.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBackground))
        }
        .buttonStyle(.plain)
    }
}
