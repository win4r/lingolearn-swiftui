# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftUI iOS app scaffolded with Xcode 26. Universal (iPhone + iPad). Currently only contains the default `Hello, world!` view — no feature code yet.

- Deployment target: iOS 26.0
- Swift 5.0, but with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` — new types are MainActor-isolated unless declared otherwise.
- Bundle identifier prefix: `AI---.` (literal, from the generated project).

## Build & Test

No package manager, no scripts — use `xcodebuild` directly from the repo root. The three targets are `lingolearn` (app), `lingolearnTests` (unit), `lingolearnUITests` (UI).

```bash
# Build
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn -destination 'platform=iOS Simulator,name=iPhone 17' build

# All tests (unit + UI)
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn -destination 'platform=iOS Simulator,name=iPhone 17' test

# Single test — use -only-testing with Target/Class[/Method]
xcodebuild -project lingolearn.xcodeproj -scheme lingolearn -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:lingolearnTests/lingolearnTests/example
```

Adjust the simulator name if iPhone 17 isn't installed (`xcrun simctl list devices available`).

## Testing frameworks — two different ones

- `lingolearnTests/` uses the **Swift Testing** framework (`import Testing`, `@Test`, `#expect`). Not XCTest. New unit tests should follow this pattern.
- `lingolearnUITests/` uses **XCTest** (`import XCTest`, `XCUIApplication`). UI tests stay on XCTest.

## Adding files

The project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+). Any `.swift` file dropped into `lingolearn/`, `lingolearnTests/`, or `lingolearnUITests/` is automatically picked up — **do not hand-edit `project.pbxproj` to register new source files**. Only edit the pbxproj for things that genuinely live there (build settings, new targets, capabilities).

## Entry points

- `lingolearn/lingolearnApp.swift` — `@main` `App`, single `WindowGroup { ContentView() }`.
- `lingolearn/ContentView.swift` — the root view.
- `lingolearn/Assets.xcassets` — app icon + accent color.
