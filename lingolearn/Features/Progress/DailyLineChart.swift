import SwiftUI
import Charts

struct DailyLineChart: View {
    let sessions: [StudySession]
    let days: Int

    var body: some View {
        Chart(data, id: \.date) { point in
            LineMark(
                x: .value("日期", point.date),
                y: .value("单词数", point.count)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Theme.brandGradient)
            .symbol(Circle().strokeBorder(lineWidth: 2))

            AreaMark(
                x: .value("日期", point.date),
                y: .value("单词数", point.count)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Theme.primary.opacity(0.15).gradient)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 180)
    }

    private var data: [DayPoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return (0..<days).reversed().map { offset -> DayPoint in
            let date = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            let count = sessions.first(where: { cal.startOfDay(for: $0.date) == date })?.wordsStudied ?? 0
            return DayPoint(date: date, count: count)
        }
    }
}

private struct DayPoint {
    let date: Date
    let count: Int
}
