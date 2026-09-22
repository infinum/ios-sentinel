# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This project can use AI assistance freely.

## What this is

Sentinel is an Infinum library (iOS 14+, macOS 12+) that gives an app one debug screen hosting all of its debug tools, opened by a trigger such as a shake, a screenshot or a notification. It is distributed through both CocoaPods (`Sentinel.podspec`) and SwiftPM (`Package.swift`), and the two must be kept in sync.

## Commands

The example apps consume the library as local pods, so run `pod install` in `Example/` after changing the Podfile or adding/removing source files in a subspec.

```bash
cd Example && pod install
```

```bash
xcodebuild -workspace Example/Sentinel.xcworkspace -scheme Example-iOS -destination 'generic/platform=iOS Simulator' build
```

```bash
xcodebuild -workspace Example/Sentinel.xcworkspace -scheme Example-MacOS -destination 'platform=macOS' build
```

Build the SwiftPM package for iOS (a plain `swift build` on a Mac only builds the macOS variant):

```bash
xcodebuild -scheme Sentinel -destination 'generic/platform=iOS' build
```

```bash
pod lib lint Sentinel.podspec
```

There is no real test suite: `Example/Tests/Tests.swift` is an empty placeholder for the `Sentinel_Tests` target. Verify changes by building both platforms and running the example apps.

## Architecture

**Entry point.** `Sentinel.shared.setup(with: Configuration)` takes a `Trigger`, a `SourceScreenProvider`, the app's `[Tool]` and `[PreferencesTool.Section]`. When the trigger fires, the source screen provider toggles presentation of a `SentinelTabBarView`. The tab layout is fixed in `Core/Internal/SentinelInternal.swift`: Device, Application, Tools (the configured tools), Preferences and Performance.

**Triggers.** `Triggers.shake` works by swizzling `UIApplication.motionEnded(_:with:)` and reposting it as a notification; `screenshot` and `notification(forName:)` wrap `NotificationTrigger`.

**The `Tool` protocol differs per platform** because navigation differs: on iOS a tool provides `var content: any View`; on macOS it provides `func createContent(selection: Binding<String?>) -> any View`, where setting `selection` to `nil` navigates back. Every tool implements the right one behind `#if os(macOS)`. List-style tools are usually built from `ToolTable` + `ToolTableSection` + `ToolTableItem` (`navigation`, `toggle`, `customInfo`, `performance`, `custom`) instead of a bespoke view.

**One folder per subspec.** Each directory in `Sentinel/Classes/` is a CocoaPods subspec depending on `Sentinel/Core`. `Default` bundles Core, UserDefaults, TextEditing and CrashDetection; the others (EmailSender, CustomLocation, ClearAppData, Database) are opt-in. Non-public types live in `Internal/` subfolders. Adding a tool means: a new folder, a subspec in the podspec, a section under "Available custom tools" in `README.md`, and registering it in the example app (Podfile + `AppDelegate`) if it should be showcased.

**iOS-only code.** Guard it with `#if os(iOS)` inside the source files, as `ClearAppData` does. Don't exclude it in `Package.swift`: the manifest's `#if os(iOS)` is evaluated on the host when SwiftPM compiles it, so a manifest exclusion also drops the code from iOS builds made on a Mac. The existing exclusions of `CustomLocation` and `EmailSender` there have that problem.

**Resources.** `Sentinel/Assets` and `SupportingFiles/PrivacyInfo.xcprivacy` are declared in both the podspec (`resource_bundles`) and `Package.swift` (`resources`); update both when adding resources.

## Example apps

- `Example/iOSExample` is a SwiftUI `App` that keeps an `AppDelegate` through `UIApplicationDelegateAdaptor`; Sentinel is configured there.
- `Example/MacOSExample` is an AppKit storyboard app. Its product is named `Sentinel` but `PRODUCT_MODULE_NAME` is pinned to `Example_MacOS`, so the app module doesn't clash with the `Sentinel` framework it imports.
- The `[CP] Embed Pods Frameworks` phase in `project.pbxproj` references a path that encodes the enabled subspecs (e.g. `Sentinel.common-ClearAppData-EmailSender`); `pod install` rewrites it when the Podfile's subspecs change.

## Conventions

- Swift sources use 4-space indentation, the Xcode file header, `// MARK: -` sections and `///` doc comments on public API.
- Public API is documented in both `README.md` and the DocC catalog in `Sentinel/Documentation.docc`.
- The library version lives in `Sentinel.podspec` (`s.version`).
