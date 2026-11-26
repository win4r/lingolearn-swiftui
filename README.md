# LingoLearn

一款面向中国英语学习者的 iOS 单词背诵应用。SwiftUI + SwiftData + Swift Charts，支持 SM-2 间隔重复、三种练习题型、学习进度可视化，内置 525+ CET4/CET6 单词。

## 环境要求

- macOS + Xcode 26.0 (Beta or later)
- iOS 26.0 模拟器或真机
- 不依赖任何第三方包

## 运行

用 Xcode 打开 `lingolearn.xcodeproj`，选择 iPhone 17 模拟器，按 ⌘R。

首次启动会自动把 `lingolearn/Resources/words.json` 中的单词写入 SwiftData（幂等）。

### 命令行构建

```bash
# 构建
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# 运行单元测试（Swift Testing 框架）
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:lingolearnTests

# 运行 UI 测试（XCTest 框架）
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:lingolearnUITests

# 运行单个测试
xcodebuild ... test -only-testing:lingolearnTests/SM2Tests/firstSuccessfulReview_resetsToOneDayInterval
```

## 功能

| Tab   | 内容                                                         |
| ----- | ------------------------------------------------------------ |
| 首页  | 今日进度环形图、连续打卡、待复习计数，快捷开始学习/复习/随机测试 |
| 学习  | 今日计划、快速复习、收藏复习、按词表；3D 翻卡 + 左右/上滑手势、TTS 发音 |
| 练习  | 选择题、填空题、听力题、随机测试；每题倒计时、对错动画、错题回顾 |
| 进度  | 近 7/30 天折线图、20 周热力图、掌握度饼图、成就墙          |
| 设置  | 每日目标滑块、学习提醒、音效/震动/自动发音开关、外观切换、重置 |

## 项目结构

```
lingolearn/
├── lingolearnApp.swift       # @main + ModelContainer
├── App/
│   ├── RootTabView.swift     # 5-tab 容器
│   └── Theme.swift           # 色彩与样式常量
├── Models/                   # @Model: Word / WordProgress / StudySession / UserSettings / Achievement
├── Services/                 # SM2、Speech、Haptics、Notifications、Seeder、ReviewQueue、SessionRecorder、AchievementEngine
├── Features/                 # Home / Learning / Practice / Progress / Settings
├── Resources/words.json      # 525+ CET4/CET6 词条
└── Assets.xcassets           # AccentColor (#0EA5E9) + BrandSecondary (#14B8A6)
```

项目使用 Xcode 16+ 的 `PBXFileSystemSynchronizedRootGroup`，直接拖拽新文件进目录即可，**不要手动改 `project.pbxproj`**。

## SM-2 间隔重复

在 `Services/SM2.swift`。核心公式：

```
EF' = max(1.3, EF + 0.1 − (5−q) × (0.08 + (5−q) × 0.02))

q < 3 → repetitions = 0, interval = 1
q ≥ 3 → 第 1 次：1 天；第 2 次：6 天；后续：interval × EF'
```

答题 → SwipeDirection 映射到 SM-2 quality：
- 右滑（认识）：首次学习 q=5，复习 q=4
- 左滑（不认识）：q=1
- 上滑（收藏）：不评分，只切换收藏标记

## 测试

- `lingolearnTests/` 使用 **Swift Testing** 框架（`@Test` / `#expect`），共 11 个测试：
  - `SM2Tests`：7 个 — 已知向量、边界条件、EF 下限钳制
  - `SeedTests`：3 个 — JSON 可加载、词条数 ≥500、CET4/6 都存在、ID 唯一
  - `AppearanceTests`：1 个 — ColorScheme 映射
- `lingolearnUITests/` 使用 **XCTest**：5 个 Tab 存在、首页按钮、设置页跳转。

## 数据模型

五个 `@Model`：

- `Word`: id / english / phonetic / chinese / example / category，`@Relationship` 指向 `WordProgress`
- `WordProgress`: SM-2 状态（EF / interval / repetitions / nextReviewDate / lastReviewedAt / status / isFavorite / 正误次数）
- `StudySession`: 每天一行，累加 wordsStudied / correctCount / durationSeconds
- `UserSettings`: 单例行；dailyGoal / reminderEnabled+time / sound+haptics+audio / appearance / streak
- `Achievement`: 8 个预置（首次学习、连续 3/7/30 天、掌握 10/50/100 词、完美一轮）

## 词库

`lingolearn/Resources/words.json` 是一个 `[WordSeed]` 数组。字段：

```json
{
  "id": "uuid",
  "english": "abandon",
  "phonetic": "/əˈbændən/",
  "chinese": "放弃；抛弃",
  "example": "He decided to abandon the old plan.",
  "category": "cet4"
}
```

追加词条时保证 `id` 唯一，并遵循 `cet4` / `cet6` 两种取值。`WordSeeder` 在首次启动时幂等载入（再次启动若已存在词条则跳过）。

## 隐私

应用不联网、不采集数据；发音由系统 TTS 离线合成；所有数据存在本地 SwiftData 容器中。
