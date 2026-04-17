import SwiftUI

struct AchievementWall: View {
    let achievements: [Achievement]

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(achievements.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.key) { ach in
                VStack(spacing: 8) {
                    Image(systemName: ach.iconName)
                        .font(.system(size: 30))
                        .foregroundStyle(ach.isUnlocked ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Color.secondary.opacity(0.5)))
                    Text(ach.title)
                        .font(.caption.bold())
                        .multilineTextAlignment(.center)
                    Text(ach.desc)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    if !ach.isUnlocked {
                        ProgressView(value: Double(ach.progressCurrent), total: Double(max(1, ach.progressTarget)))
                            .tint(Theme.primary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBackground))
                .opacity(ach.isUnlocked ? 1.0 : 0.7)
            }
        }
    }
}
