import SwiftUI
import SwiftData

enum LearningRoute: Hashable, Identifiable {
    case daily
    case review
    case favorites
    case category(WordCategory)

    var id: String {
        switch self {
        case .daily: return "daily"
        case .review: return "review"
        case .favorites: return "favorites"
        case .category(let c): return "cat-\(c.rawValue)"
        }
    }

    var title: String {
        switch self {
        case .daily: return "今日学习"
        case .review: return "快速复习"
        case .favorites: return "收藏复习"
        case .category(let c): return c.displayName
        }
    }
}

struct LearningEntryView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [UserSettings]
    @Query private var allProgress: [WordProgress]

    @State private var route: LearningRoute?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row(.daily, icon: "book.fill", tint: Theme.primary, trailing: "\(settings.dailyGoal) 词")
                    row(.review, icon: "arrow.clockwise.circle.fill", tint: Theme.secondary, trailing: "\(reviewCount) 待复习")
                    row(.favorites, icon: "star.fill", tint: Theme.warning, trailing: "\(favoriteCount) 词")
                }
                Section("按词表") {
                    ForEach(WordCategory.allCases, id: \.self) { cat in
                        row(.category(cat), icon: "books.vertical.fill", tint: Theme.primary, trailing: "\(categoryCount(cat)) 词")
                    }
                }
            }
            .navigationTitle("学习")
            .navigationDestination(item: $route) { LearningSessionView(route: $0) }
        }
    }

    private var settings: UserSettings { settingsList.first ?? UserSettings() }
    private var reviewCount: Int { ReviewQueue.dueCount(in: context) }
    private var favoriteCount: Int { allProgress.filter(\.isFavorite).count }
    private func categoryCount(_ cat: WordCategory) -> Int {
        let raw = cat.rawValue
        return (try? context.fetchCount(FetchDescriptor<Word>(predicate: #Predicate<Word> { $0.categoryRaw == raw }))) ?? 0
    }

    private func row(_ route: LearningRoute, icon: String, tint: Color, trailing: String) -> some View {
        Button { self.route = route } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(tint.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(route.title).font(.body)
                Spacer()
                Text(trailing).font(.caption).foregroundStyle(.secondary)
                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
