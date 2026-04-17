import SwiftUI

struct WordCard: View {
    let word: Word
    @Binding var flipped: Bool
    var autoPlay: Bool = true

    var body: some View {
        ZStack {
            front.opacity(flipped ? 0 : 1)
            back.opacity(flipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.cardBackground)
                .shadow(color: Theme.cardShadow, radius: 16, y: 6)
        )
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.55, dampingFraction: 0.75), value: flipped)
        .onTapGesture { flipped.toggle() }
    }

    private var front: some View {
        VStack(spacing: 18) {
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Text(word.english)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Button {
                    Speech.shared.speak(word.english)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)
            }
            Text(word.phonetic)
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            Text("轻触卡片查看释义")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom)
        }
        .padding()
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(word.english)
                    .font(.title2).bold()
                Spacer()
                Text(word.category.displayName)
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(Theme.primary.opacity(0.15)))
                    .foregroundStyle(Theme.primary)
            }
            Text(word.phonetic)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
            Text("释义").font(.caption).foregroundStyle(.secondary)
            Text(word.chinese)
                .font(.title3)
            Divider()
            Text("例句").font(.caption).foregroundStyle(.secondary)
            Text(word.example)
                .font(.body)
                .italic()
            Spacer()
        }
        .padding(24)
    }
}
