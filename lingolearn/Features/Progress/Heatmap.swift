import SwiftUI

struct Heatmap: View {
    let sessions: [StudySession]
    let weeks: Int = 20

    var body: some View {
        let cells = buildCells()
        let columns = Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7)

        return VStack(alignment: .leading, spacing: 8) {
            LazyHGrid(rows: columns, alignment: .top, spacing: 3) {
                ForEach(cells, id: \.date) { cell in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color(for: cell.count))
                        .frame(width: 14, height: 14)
                }
            }
            HStack(spacing: 6) {
                Text("少").font(.caption2).foregroundStyle(.secondary)
                ForEach([0, 3, 8, 16, 30], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2).fill(color(for: level)).frame(width: 12, height: 12)
                }
                Text("多").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func buildCells() -> [Cell] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let total = weeks * 7
        let map = Dictionary(uniqueKeysWithValues: sessions.map { (cal.startOfDay(for: $0.date), $0.wordsStudied) })
        return (0..<total).reversed().map { offset -> Cell in
            let date = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            return Cell(date: date, count: map[date] ?? 0)
        }
    }

    private func color(for count: Int) -> Color {
        if count == 0 { return Theme.primary.opacity(0.08) }
        let intensity = min(1, Double(count) / 30.0)
        return Theme.primary.opacity(0.2 + intensity * 0.75)
    }

    private struct Cell {
        let date: Date
        let count: Int
    }
}
