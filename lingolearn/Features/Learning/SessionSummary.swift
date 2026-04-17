import SwiftUI

struct SessionSummaryData: Identifiable {
    let id = UUID()
    let total: Int
    let correct: Int
    let wrong: Int
    let title: String
}

struct SessionSummary: View {
    let data: SessionSummaryData
    let achievements: [AchievementEngine.UnlockEvent]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.brandGradient)
                .padding(.top, 32)

            Text("本轮完成")
                .font(.largeTitle.bold())

            HStack(spacing: 24) {
                stat(value: data.total, label: "已学")
                stat(value: data.correct, label: "认识", color: Theme.success)
                stat(value: data.wrong, label: "不认识", color: Theme.danger)
            }

            if data.total > 0 {
                VStack(spacing: 6) {
                    Text("正确率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(Double(data.correct) / Double(data.total) * 100))%")
                        .font(.title.bold())
                        .foregroundStyle(Theme.primary)
                }
            }

            if !achievements.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("解锁成就")
                        .font(.headline)
                    ForEach(achievements) { evt in
                        HStack {
                            Image(systemName: evt.achievement.iconName)
                                .foregroundStyle(Theme.warning)
                            Text(evt.achievement.title).bold()
                            Text(evt.achievement.desc)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.warning.opacity(0.12)))
                .padding(.horizontal)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("返回")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .presentationDetents([.large])
    }

    private func stat(value: Int, label: String, color: Color = Theme.primary) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
