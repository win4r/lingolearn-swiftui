import SwiftUI
import Charts

struct MasteryPie: View {
    let newCount: Int
    let learningCount: Int
    let masteredCount: Int

    var body: some View {
        Chart(data, id: \.label) { slice in
            SectorMark(
                angle: .value("数量", slice.value),
                innerRadius: .ratio(0.55),
                angularInset: 2
            )
            .cornerRadius(4)
            .foregroundStyle(by: .value("类别", slice.label))
        }
        .chartForegroundStyleScale([
            "新学": Theme.primary,
            "学习中": Theme.warning,
            "已掌握": Theme.success
        ])
        .frame(height: 220)
    }

    private var data: [Slice] {
        [
            Slice(label: "新学", value: max(newCount, 0)),
            Slice(label: "学习中", value: max(learningCount, 0)),
            Slice(label: "已掌握", value: max(masteredCount, 0))
        ].filter { $0.value > 0 }
    }

    private struct Slice {
        let label: String
        let value: Int
    }
}
