# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This project can use AI assistance freely.

## What this is

Sentinel is an Infinum library (iOS 15+, macOS 13+) that gives an app one debug screen hosting all of its debug tools, opened by a trigger such as a shake, a screenshot or a notification. It is distributed only through SwiftPM (`Package.swift`); CocoaPods support was dropped after 2.3.0.

## Commands

The example apps consume the repository root as a local Swift package (`Example/Sentinel.xcodeproj` → package reference `..`), so new source files are picked up without any extra step.

```bash
xcodebuild -project Example/Sentinel.xcodeproj -scheme Example-iOS -destination 'generic/platform=iOS Simulator' build
```

```bash
xcodebuild -project Example/Sentinel.xcodeproj -scheme Example-MacOS -destination 'platform=macOS' build
```

```bash
xcodebuild -project SentinelMac/SentinelMac.xcodeproj -scheme SentinelMac -destination 'platform=macOS' build
```

Build the SwiftPM package for iOS (a plain `swift build` on a Mac only builds the macOS variant):

```bash
xcodebuild -scheme Sentinel -destination 'generic/platform=iOS' build
```

## Tests

There are three layers. Unit and integration tests use Swift Testing; UI tests use XCTest, because Swift Testing can't drive `XCUIApplication`.

- **Unit tests** (`Tests/SentinelTests`, `Tests/SentinelPulseTests`) are SwiftPM test targets with `@testable import Sentinel`. They run on macOS and on the iOS simulator; iOS-only types are tested behind `#if os(iOS)`. Tests that touch shared state get a throwaway `UserDefaults` suite (`IsolatedUserDefaults`) or temp directory (`TemporaryDirectory`), because Swift Testing runs tests in parallel.
- **Integration tests** (`Example/Tests`, target `Sentinel_Tests`) run inside the iOS example app (`TEST_HOST`) for anything that needs an app: the Keychain, the sandboxed Documents directory, `UIApplication` swizzling, presenting Sentinel. The bundle doesn't link the `Sentinel` product; it reaches the host app's copy through `BUNDLE_LOADER`, so there is one `Sentinel.shared`. Every suite is nested in the `.serialized` `IntegrationTests` suite. The example app skips its own Sentinel setup while hosting these tests.
- **UI tests** (`Example/UITests`, target `Example-iOSUITests`) launch the example app with `-uiTesting` (shows an "Open Sentinel" button that sends a shake event, since XCUITest can't shake) and `-resetState` (wipes defaults and saved crashes). They find Sentinel views by the identifiers in `Core/Internal/AccessibilityIdentifier.swift`.

Known bugs are pinned with `withKnownIssue` (Swift Testing) or `XCTExpectFailure` (XCTest), so the suites stay green and say when a bug gets fixed.

```bash
swift test
```

```bash
xcodebuild test -scheme Sentinel-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

```bash
xcodebuild test -project Example/Sentinel.xcodeproj -scheme Example-iOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

If several runtimes have a simulator with the same name, pass its `id=` instead of `name=`.

## Architecture

**Entry point.** `Sentinel.shared.setup(with: Configuration)` takes a `Trigger`, a `SourceScreenProvider`, the app's `[Tool]` and `[PreferencesTool.Section]`. When the trigger fires, the source screen provider toggles presentation of a `SentinelTabBarView`. The tab layout is fixed in `Core/Internal/SentinelInternal.swift`: Device, Application, Tools (the configured tools), Preferences and Performance.

**Triggers.** `Triggers.shake` works by swizzling `UIApplication.motionEnded(_:with:)` and reposting it as a notification; `screenshot` and `notification(forName:)` wrap `NotificationTrigger`.

**The `Tool` protocol differs per platform** because navigation differs: on iOS a tool provides `var content: any View`; on macOS it provides `func createContent(selection: Binding<String?>) -> any View`, where setting `selection` to `nil` navigates back. Every tool implements the right one behind `#if os(macOS)`. List-style tools are usually built from `ToolTable` + `ToolTableSection` + `ToolTableItem` (`navigation`, `toggle`, `customInfo`, `performance`, `custom`) instead of a bespoke view.

**One folder per tool.** Each directory in `Sentinel/Classes/` holds one tool (`Core` holds the framework itself); they all compile into the single `Sentinel` SwiftPM target, so every tool ships with the `Sentinel` product. Non-public types live in `Internal/` subfolders. Adding a tool means: a new folder, a section under "Available custom tools" in `README.md` and in the DocC `Setup` article, and registering it in the example app's `AppDelegate` if it should be showcased.

**`SentinelPulse` is the one tool outside the `Sentinel` target.** It lives in the top-level `SentinelPulse/` folder as its own SwiftPM target and product, so only apps that use it pull in [Pulse](https://github.com/kean/Pulse). Pulse is linked for iOS only through `condition: .when(platforms: [.iOS])`, because Pulse 5 has no embeddable macOS console. Pulse 5 is also why the package requires iOS 15 / macOS 13. SwiftPM platforms apply to the whole package, so raising Pulse's major version can raise the minimum platforms for every Sentinel user; check Pulse's requirements before widening the version range in `Package.swift`.

**iOS-only code.** Guard it with `#if os(iOS)` inside the source files, as `ClearAppData` does. Don't exclude it in `Package.swift`: the manifest's `#if os(iOS)` is evaluated on the host when SwiftPM compiles it, so a manifest exclusion also drops the code from iOS builds made on a Mac. SwiftPM also can't restrict a resource to one platform, so iOS-only tools build their UI in code rather than in storyboards or XIBs.

**Resources.** `Sentinel/Assets` and `SupportingFiles/PrivacyInfo.xcprivacy` are declared in `Package.swift` (`resources`); declare new resources there.

## Sentinel for Mac

`SentinelMac/` is a Mac app that shows a device's network requests live and controls its API mocks. It's a thin shell around `SentinelMacView`, which lives in the `Sentinel` target behind `@_spi(SentinelMac)`, and it consumes the repository as a local package like the example apps. Devices connect through `MacConnectionTool`; the code for both sides is in `Sentinel/Classes/MacConnection`. Connections run over Network.framework with Bonjour (`_sentinel._tcp`), and the Simulator connects on localhost. Pairing and encryption use CryptoKit rather than TLS, because a TLS server can't pick a pre-shared key after the device says who it is. Network entries come from `SentinelPulse`, which reaches `RemoteNetworkRecorder` through `package` access.

## Example apps

- `Example/iOSExample` is a SwiftUI `App` that keeps an `AppDelegate` through `UIApplicationDelegateAdaptor`; Sentinel is configured there.
- `Example/MacOSExample` is an AppKit storyboard app. Its product is named `Sentinel` but `PRODUCT_MODULE_NAME` is pinned to `Example_MacOS`, so the app module doesn't clash with the `Sentinel` framework it imports.

## Conventions

- Swift sources use 4-space indentation, the Xcode file header, `// MARK: -` sections and `///` doc comments on public API.
- Public API is documented in both `README.md` and the DocC catalog in `Sentinel/Documentation.docc`.
- The library version is the git tag; there is no version number in the sources.
