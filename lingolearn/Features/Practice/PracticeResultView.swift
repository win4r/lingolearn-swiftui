import SwiftUI

struct PracticeResultView: View {
    let session: PracticeSession
    let kind: PracticeKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.brandGradient)
                        .padding(.top, 16)

                    Text("练习完成")
                        .font(.largeTitle.bold())

                    HStack(spacing: 16) {
                        stat("正确率", value: "\(Int(session.accuracy * 100))%", color: Theme.primary)
                        stat("用时", value: formatted(duration: session.duration), color: Theme.secondary)
                        stat("得分", value: "\(session.correctCount)/\(session.questions.count)", color: Theme.warning)
                    }
                    .padding(.horizontal)

                    if !session.wrongAnswers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("错题回顾")
                                .font(.headline)
                                .padding(.horizontal)
                            ForEach(Array(session.wrongAnswers.enumerated()), id: \.offset) { _, answer in
                                wrongRow(answer)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Theme.warning)
                            Text("完美一轮！全部答对")
                                .font(.headline)
                                .foregroundStyle(Theme.warning)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle(kind.title + " 结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func stat(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBackground))
    }

    private func wrongRow(_ answer: PracticeAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(answer.question.word.english).font(.title3.bold())
                Button {
                    Speech.shared.speak(answer.question.word.english)
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                }
                Spacer()
                Text(answer.question.word.category.displayName)
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Theme.primary.opacity(0.15)))
                    .foregroundStyle(Theme.primary)
            }
            Text(answer.question.word.phonetic)
                .font(.caption).foregroundStyle(.secondary)
            Text("释义：\(answer.question.word.chinese)")
                .font(.subheadline)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("你的答案:").font(.caption).foregroundStyle(.secondary)
                Text(answer.userAnswer.isEmpty ? "未作答" : answer.userAnswer)
                    .font(.caption)
                    .foregroundStyle(Theme.danger)
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("正确答案:").font(.caption).foregroundStyle(.secondary)
                Text(answer.question.correctAnswer)
                    .font(.caption)
                    .foregroundStyle(Theme.success)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBackground))
        .padding(.horizontal)
    }

    private func formatted(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 { return "\(minutes)分\(seconds)秒" }
        return "\(seconds)秒"
    }
}
