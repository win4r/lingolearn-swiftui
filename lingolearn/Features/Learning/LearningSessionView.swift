import SwiftUI
import SwiftData

struct LearningSessionView: View {
    let route: LearningRoute
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var settingsList: [UserSettings]

    @State private var session: LearningSession?
    @State private var flipped = false
    @State private var offset: CGSize = .zero
    @State private var summary: SessionSummaryData?
    @State private var achievements: [AchievementEngine.UnlockEvent] = []

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            if let session, let word = session.current {
                VStack(spacing: 24) {
                    ProgressView(value: session.progress)
                        .tint(Theme.primary)
                        .padding(.horizontal)

                    ZStack {
                        if session.index + 1 < session.words.count {
                            // next card peeking behind
                            WordCard(word: session.words[session.index + 1], flipped: .constant(false))
                                .scaleEffect(0.95)
                                .opacity(0.5)
                                .offset(y: 14)
                        }

                        WordCard(word: word, flipped: $flipped, autoPlay: settings.autoPlayAudio)
                            .offset(offset)
                            .rotationEffect(.degrees(Double(offset.width / 20)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(overlayColor.opacity(overlayIntensity))
                                    .allowsHitTesting(false)
                            )
                            .gesture(dragGesture)
                            .onAppear {
                                flipped = false
                                if settings.autoPlayAudio { Speech.shared.speak(word.english) }
                            }
                            .onChange(of: session.index) { _, _ in
                                flipped = false
                                if let w = session.current, settings.autoPlayAudio {
                                    Speech.shared.speak(w.english)
                                }
                            }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 24) {
                        actionButton(icon: "xmark", tint: Theme.danger, label: "不认识") {
                            commit(.left)
                        }
                        actionButton(icon: "star.fill", tint: Theme.warning, label: "收藏") {
                            commit(.up)
                        }
                        actionButton(icon: "checkmark", tint: Theme.success, label: "认识") {
                            commit(.right)
                        }
                    }

                    Spacer()
                }
                .padding(.top)
            } else {
                ProgressView("准备单词中...")
            }
        }
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { if session == nil { buildSession() } }
        .sheet(item: $summary, onDismiss: { dismiss() }) { data in
            SessionSummary(data: data, achievements: achievements)
        }
    }

    private var settings: UserSettings { settingsList.first ?? UserSettings() }

    private var overlayColor: Color {
        if offset.width > 40 { return Theme.success }
        if offset.width < -40 { return Theme.danger }
        if offset.height < -40 { return Theme.warning }
        return .clear
    }

    private var overlayIntensity: Double {
        let w = abs(offset.width), h = abs(offset.height)
        return min(0.4, max(w, h) / 320)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in offset = value.translation }
            .onEnded { value in
                let t = value.translation
                if t.width > 120 { commit(.right); return }
                if t.width < -120 { commit(.left); return }
                if t.height < -120 { commit(.up); return }
                withAnimation(.spring) { offset = .zero }
            }
    }

    private func actionButton(icon: String, tint: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(tint.gradient)
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func commit(_ direction: SwipeDirection) {
        guard let session else { return }
        let targetX: CGFloat = direction == .right ? 600 : (direction == .left ? -600 : 0)
        let targetY: CGFloat = direction == .up ? -600 : 0
        withAnimation(.easeOut(duration: 0.22)) {
            offset = CGSize(width: targetX, height: targetY)
        }
        switch direction {
        case .right: Haptics.success(enabled: settings.hapticsEnabled)
        case .left: Haptics.error(enabled: settings.hapticsEnabled)
        case .up: Haptics.light(enabled: settings.hapticsEnabled)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            let bundle = session.advance(with: direction)
            offset = .zero
            if session.isFinished {
                achievements = bundle.unlocked
                summary = SessionSummaryData(
                    total: session.words.count,
                    correct: session.correctCount,
                    wrong: session.wrongCount,
                    title: route.title
                )
            }
        }
    }

    private func buildSession() {
        let target = max(5, settings.dailyGoal)
        let words: [Word]
        switch route {
        case .daily:
            words = ReviewQueue.todaysSession(in: context, target: target)
        case .review:
            words = ReviewQueue.dueWords(in: context, limit: target)
        case .favorites:
            let favs = (try? context.fetch(FetchDescriptor<WordProgress>(
                predicate: #Predicate<WordProgress> { $0.isFavorite == true }
            )))?.compactMap(\.word) ?? []
            words = Array(favs.prefix(target))
        case .category(let cat):
            let raw = cat.rawValue
            let all = (try? context.fetch(FetchDescriptor<Word>(
                predicate: #Predicate<Word> { $0.categoryRaw == raw }
            ))) ?? []
            words = Array(all.shuffled().prefix(target))
        }
        session = LearningSession(words: words, context: context, settings: settings)
    }
}
