import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \StudySession.date, order: .reverse) private var sessions: [StudySession]
    @Query private var progresses: [WordProgress]
    @Query private var achievements: [Achievement]

    @State private var rangeDays: Int = 7

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if sessions.isEmpty {
                        ContentUnavailableView("暂无学习记录", systemImage: "chart.line.uptrend.xyaxis", description: Text("完成一次学习后这里会显示你的数据"))
                            .padding(.top, 40)
                    } else {
                        lineSection
                        heatmapSection
                        masterySection
                        achievementsSection
                    }
                }
                .padding()
            }
            .navigationTitle("进度")
        }
    }

    private var lineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("每日学习").font(.headline)
                Spacer()
                Picker("范围", selection: $rangeDays) {
                    Text("7 天").tag(7)
                    Text("30 天").tag(30)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            DailyLineChart(sessions: sessions, days: rangeDays)
        }
        .cardStyle()
    }

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习热力图").font(.headline)
            Heatmap(sessions: sessions)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("掌握度").font(.headline)
            let newCount = progresses.filter { $0.status == .new }.count
            let learning = progresses.filter { $0.status == .learning }.count
            let mastered = progresses.filter { $0.status == .mastered }.count
            if newCount + learning + mastered == 0 {
                Text("开始学习后这里会显示掌握分布")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                MasteryPie(newCount: newCount, learningCount: learning, masteredCount: mastered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("成就墙").font(.headline)
            AchievementWall(achievements: achievements)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
