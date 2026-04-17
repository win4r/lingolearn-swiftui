import SwiftUI

struct Countdown: View {
    let secondsTotal: Int
    @Binding var secondsLeft: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.primary.opacity(0.15))
                Capsule()
                    .fill(color.gradient)
                    .frame(width: geo.size.width * ratio)
                    .animation(.linear(duration: 1), value: secondsLeft)
            }
        }
        .frame(height: 6)
    }

    private var ratio: Double {
        guard secondsTotal > 0 else { return 0 }
        return max(0, min(1, Double(secondsLeft) / Double(secondsTotal)))
    }

    private var color: Color {
        if ratio > 0.5 { return Theme.primary }
        if ratio > 0.25 { return Theme.warning }
        return Theme.danger
    }
}
