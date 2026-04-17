import SwiftUI

enum Theme {
    static let primary = Color(red: 0x0E / 255, green: 0xA5 / 255, blue: 0xE9 / 255)
    static let secondary = Color(red: 0x14 / 255, green: 0xB8 / 255, blue: 0xA6 / 255)
    static let success = Color(red: 0x10 / 255, green: 0xB9 / 255, blue: 0x81 / 255)
    static let danger = Color(red: 0xEF / 255, green: 0x44 / 255, blue: 0x44 / 255)
    static let warning = Color(red: 0xF5 / 255, green: 0x9E / 255, blue: 0x0B / 255)

    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let cardShadow = Color.black.opacity(0.08)

    static func gradient(_ colors: [Color]) -> LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var brandGradient: LinearGradient {
        gradient([primary, secondary])
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBackground))
            .shadow(color: Theme.cardShadow, radius: 8, y: 2)
    }
}
