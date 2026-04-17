import SwiftUI

enum PracticeKind: Hashable, Identifiable {
    case multipleChoice
    case fillInBlank
    case listening
    case random

    var id: String { "\(self)" }

    var title: String {
        switch self {
        case .multipleChoice: return "选择题"
        case .fillInBlank: return "填空题"
        case .listening: return "听力题"
        case .random: return "随机测试"
        }
    }

    var subtitle: String {
        switch self {
        case .multipleChoice: return "看单词选中文释义"
        case .fillInBlank: return "看中文写出英文"
        case .listening: return "听发音选出单词"
        case .random: return "三种题型混合 10 题"
        }
    }

    var icon: String {
        switch self {
        case .multipleChoice: return "checklist"
        case .fillInBlank: return "pencil.line"
        case .listening: return "ear.fill"
        case .random: return "dice.fill"
        }
    }

    var tint: Color {
        switch self {
        case .multipleChoice: return Theme.primary
        case .fillInBlank: return Theme.secondary
        case .listening: return Theme.warning
        case .random: return Theme.danger
        }
    }
}

struct PracticeEntryView: View {
    @State private var route: PracticeKind?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach([PracticeKind.multipleChoice, .fillInBlank, .listening, .random], id: \.self) { kind in
                        Button { route = kind } label: { card(kind) }
                            .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("练习")
            .navigationDestination(item: $route) { kind in
                PracticeSessionView(kind: kind)
            }
        }
    }

    private func card(_ kind: PracticeKind) -> some View {
        HStack(spacing: 16) {
            Image(systemName: kind.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(kind.tint.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title).font(.headline)
                Text(kind.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBackground))
    }
}
