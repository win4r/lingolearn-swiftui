import SwiftUI
import SwiftData

struct PracticeSessionView: View {
    let kind: PracticeKind
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var settingsList: [UserSettings]

    @State private var session: PracticeSession?
    @State private var textInput = ""
    @State private var selectedOption: String?
    @State private var feedback: Feedback?
    @State private var secondsLeft: Int = 15
    @State private var showResult = false

    private enum Feedback { case correct, wrong }

    private var settings: UserSettings { settingsList.first ?? UserSettings() }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            if let session, let q = session.current {
                VStack(spacing: 20) {
                    Countdown(secondsTotal: settings.perQuestionSeconds, secondsLeft: $secondsLeft)
                        .padding(.horizontal)

                    HStack {
                        Text("第 \(session.index + 1)/\(session.questions.count) 题")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("得分 \(session.correctCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    promptView(for: q)
                        .padding(.horizontal)
                    answerView(for: q)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)
                .modifier(ShakeEffect(animatableData: feedback == .wrong ? 1 : 0))
            } else if session != nil {
                ProgressView("加载中…")
            }
        }
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if session == nil {
                let qs = PracticeBuilder.build(kind: kind, context: context)
                session = PracticeSession(questions: qs)
                startTimer()
            }
        }
        .sheet(isPresented: $showResult, onDismiss: { dismiss() }) {
            if let session {
                PracticeResultView(session: session, kind: kind)
            }
        }
    }

    // MARK: - Prompt
    @ViewBuilder
    private func promptView(for q: PracticeQuestion) -> some View {
        VStack(spacing: 12) {
            switch q.type {
            case .multipleChoice:
                Text(q.prompt)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Button { Speech.shared.speak(q.word.english) } label: {
                    Label("发音", systemImage: "speaker.wave.2")
                        .font(.subheadline)
                }
            case .fillInBlank:
                Text(q.prompt)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("请输入对应的英文单词")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case .listening:
                Button {
                    Speech.shared.speak(q.word.english)
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.primary.gradient)
                        .frame(width: 140, height: 140)
                        .background(Circle().fill(Theme.primary.opacity(0.12)))
                }
                .buttonStyle(.plain)
                Text("点击喇叭再听一次").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Answer
    @ViewBuilder
    private func answerView(for q: PracticeQuestion) -> some View {
        switch q.type {
        case .multipleChoice, .listening:
            VStack(spacing: 10) {
                ForEach(q.options, id: \.self) { option in
                    optionButton(option, correct: q.correctAnswer)
                }
            }
        case .fillInBlank:
            VStack(spacing: 12) {
                TextField("键入英文", text: $textInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cardBackground))
                Button {
                    submitText(for: q)
                } label: {
                    Text("提交")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(textInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func optionButton(_ option: String, correct: String) -> some View {
        let isSelected = selectedOption == option
        let isRevealedCorrect = (feedback != nil) && option == correct
        let isRevealedWrong = feedback == .wrong && isSelected

        let background: Color = {
            if isRevealedCorrect { return Theme.success.opacity(0.18) }
            if isRevealedWrong { return Theme.danger.opacity(0.18) }
            return Theme.cardBackground
        }()

        return Button {
            guard feedback == nil else { return }
            selectedOption = option
            submitOption(option)
        } label: {
            HStack {
                Text(option).font(.body).multilineTextAlignment(.leading)
                Spacer()
                if isRevealedCorrect { Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.success) }
                if isRevealedWrong { Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.danger) }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(background))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Timer
    private func startTimer() {
        secondsLeft = settings.perQuestionSeconds
        Task { @MainActor in
            while let session, !session.isFinished, !showResult {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard feedback == nil else { continue }
                if secondsLeft > 0 {
                    secondsLeft -= 1
                } else {
                    submitOption("")
                }
            }
        }
    }

    // MARK: - Submission
    private func submitOption(_ option: String) {
        guard let session else { return }
        let correct = session.submit(userAnswer: option)
        feedback = correct ? .correct : .wrong
        correct ? Haptics.success(enabled: settings.hapticsEnabled) : Haptics.error(enabled: settings.hapticsEnabled)
        advanceAfterDelay()
    }

    private func submitText(for q: PracticeQuestion) {
        guard let session else { return }
        let correct = session.submit(userAnswer: textInput)
        selectedOption = textInput
        feedback = correct ? .correct : .wrong
        correct ? Haptics.success(enabled: settings.hapticsEnabled) : Haptics.error(enabled: settings.hapticsEnabled)
        advanceAfterDelay()
    }

    private func advanceAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            textInput = ""
            selectedOption = nil
            feedback = nil
            secondsLeft = settings.perQuestionSeconds
            if session?.isFinished ?? false {
                recordSession()
                showResult = true
            }
        }
    }

    private func recordSession() {
        guard let session else { return }
        SessionRecorder.record(
            context: context,
            settings: settings,
            wordsStudied: session.questions.count,
            correctCount: session.correctCount,
            durationSeconds: session.duration,
            perfectRound: session.correctCount == session.questions.count && session.questions.count >= 5
        )
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let amount = sin(animatableData * .pi * 6) * 6
        return ProjectionTransform(CGAffineTransform(translationX: amount, y: 0))
    }
}
