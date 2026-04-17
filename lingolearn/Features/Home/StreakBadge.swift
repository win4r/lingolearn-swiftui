import SwiftUI

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: days > 0 ? "flame.fill" : "flame")
                .foregroundStyle(days > 0 ? Theme.warning : .secondary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("连续打卡")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(days) 天")
                    .font(.headline)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBackground))
    }
}
