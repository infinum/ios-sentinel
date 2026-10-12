# Plan: drop CocoaPods, add Pulse as an opt-in SwiftPM product

## Context

Many Infinum projects use [Pulse](https://github.com/kean/Pulse) and want its console inside Sentinel's debug screen. Two facts shape the solution:

- **Pulse is SwiftPM-only now.** 5.1 stopped publishing to CocoaPods trunk and 5.2 removed the podspec. A `Sentinel/Pulse` subspec could only depend on the frozen `PulseUI 4.2.7` (iOS only).
- **Pulse 5 needs iOS 15 / macOS 13.** Sentinel declares iOS 14 / macOS 12. SwiftPM rejects a product whose dependency has a higher minimum, and `platforms` applies to the whole package.

Decisions agreed with the user:
1. Drop CocoaPods support from Sentinel entirely, because CocoaPods is shutting down.
2. Ship Pulse support from this repo as a separate SwiftPM product, `SentinelPulse`.
3. Raise the package minimums to iOS 15 / macOS 13.

Raising the minimums and removing the pod are both breaking changes, so this is released as **3.0.0**. With the podspec gone, the version lives only in git tags.

Projects that don't import `SentinelPulse` will still resolve the Pulse package, but they never compile or link it.

## Part 1: Remove CocoaPods

1. `git rm` these: `Sentinel.podspec`, `Example/Podfile`, `Example/Podfile.lock`, `Example/Pods/` (53 tracked files) and `Example/Sentinel.xcworkspace/`. The project is used directly from then on.
2. Clean `Example/Sentinel.xcodeproj/project.pbxproj` by hand:
   - remove the `Pods_*.framework` build files, file references and Frameworks-phase entries;
   - remove the `Pods` and `Podspec Metadata` groups;
   - remove the `[CP] Check Pods Manifest.lock` and `[CP] Embed Pods Frameworks` script phases and their entries in each target's `buildPhases`;
   - remove every `baseConfigurationReference` that points at a `Pods-*.xcconfig`;
   - add an `XCLocalSwiftPackageReference` to `..` (objectVersion is 77, so this is supported);
   - add `XCSwiftPackageProductDependency` entries: `Sentinel` and `SentinelPulse` for Example-iOS and Example-MacOS.
   - Pulse is a dependency of a dependency (transitive), and Xcode only links products from packages the project references directly. Add a remote `XCRemoteSwiftPackageReference` for `https://github.com/kean/Pulse.git` with the same version range so the example app can use the `Pulse` product to log.
   - `Sentinel_Tests` is an empty placeholder, so only unlink it from Pods.
   - Raise the targets' `IPHONEOS_DEPLOYMENT_TARGET` to 15.0 and `MACOSX_DEPLOYMENT_TARGET` to 13.0.
3. `.gitignore`: drop the CocoaPods/travis comment block.
4. Docs:
   - `README.md`: remove the CocoaPods badges (lines 8–10), the CocoaPods install section and the subspec list. Add a sentence that every tool comes with the `Sentinel` product. Set Requirements to iOS 15 / macOS 13. Show the SPM install with a version: `.package(url: "https://github.com/infinum/ios-sentinel.git", from: "3.0.0")`.
   - `Sentinel/Documentation.docc/Articles/Setup.md`: remove the CocoaPods section.
5. `CLAUDE.md`:
   - remove the `pod install` and `pod lib lint` commands and the "kept in sync" sentence;
   - rewrite "One folder per subspec" as one folder per tool inside the single `Sentinel` target;
   - drop the `[CP] Embed Pods Frameworks` bullet;
   - change the build commands to `-project Example/Sentinel.xcodeproj`;
   - say the version comes from git tags;
   - document the `SentinelPulse` product (Part 2).

## Part 2: Add the `SentinelPulse` product

### `Package.swift`
- Set `platforms` to `.iOS(.v15)` and `.macOS(.v13)`.
- Add `dependencies: [.package(url: "https://github.com/kean/Pulse.git", from: "5.0.0")]`.
- Add the product `.library(name: "SentinelPulse", targets: ["SentinelPulse"])`.
- Add the target `.target(name: "SentinelPulse", dependencies: ["Sentinel", .product(name: "Pulse", package: "Pulse"), .product(name: "PulseUI", package: "Pulse")], path: "SentinelPulse")`.
- Keep the code in a top-level `SentinelPulse/` folder instead of `Sentinel/Classes/Pulse`. The `Sentinel` target uses `path: "Sentinel"`, so a folder there would get pulled into it and need an `exclude`.
- `swift-tools-version` stays at 5.5. Pulse's own 5.10 manifest is read by the consumer's toolchain, and the README already requires Xcode 16.

### `SentinelPulse/PulseTool.swift`
- Use the Xcode file header, 4-space indentation, `// MARK: -` sections and `///` docs, as in the rest of the repo.
- Model it on `Sentinel/Classes/EmailSender/EmailSenderTool.swift`:

```swift
import SwiftUI
import Sentinel
import Pulse
import PulseUI

/// Tool which shows Pulse's console (logs and network requests) inside Sentinel.
public struct PulseTool: Tool {

    // MARK: - Public properties

    public let name: String

    // MARK: - Private properties

    private let store: LoggerStore

    // MARK: - Lifecycle

    /// - Parameters:
    ///   - store: The Pulse store to display. Defaults to `LoggerStore.shared`.
    ///   - name: The name of the tool. Defaults to "Pulse".
    public init(store: LoggerStore = .shared, name: String = "Pulse") { ... }
}

public extension PulseTool {
    #if os(macOS)
    func createContent(selection: Binding<String?>) -> any View { ConsoleView(store: store) }
    #else
    var content: any View { ConsoleView(store: store) }
    #endif
}
```
- Sentinel already pushes each tool's content inside its `NavigationView` (`Core/Internal/SentinelTabItem.swift:81-83`, `SentinelTabBarView.swift:36`), so the console is pushed rather than wrapped again.
- On iOS, `ConsoleView.init(store:mode:delegate:)` is public. macOS has its own `ConsoleView` in a separate file; check its public init when implementing. If the signature differs, adjust only the macOS branch. Also check whether either platform needs `.closeButtonHidden()` or a similar modifier when the view is pushed.

### Example apps
- `Example/iOSExample/AppDelegate.swift`: add `PulseTool()` to `tools`. Log a few sample messages through `LoggerStore.shared.storeMessage(...)` and send one request through a Pulse-logged `URLSession` so the console isn't empty. Use whatever logging API Pulse 5 currently documents.
- `Example/MacOSExample/AppDelegate.swift`: make the same change so the macOS branch is exercised.

### Docs
- `README.md`: add a `#### PulseTool` entry under "Available custom tools" that covers:
  - adding the `SentinelPulse` product;
  - `PulseTool()` and the `store:` parameter;
  - a link to Pulse's guide for setting up network logging.
- DocC: add `PulseTool` to `Sentinel/Documentation.docc` alongside the other tools. DocC can't add symbol links across modules, so describe it in text.

## Branches and commits (no push, no PR, no AI trailer)
0. Copy this plan to `Docs/pulse-tool-plan.md` in the repo. Leave it untracked and ask before committing it.
1. Branch `feature/project-update` off the current `HEAD` (`feature/clear-data-tool`). Commit there:
   1. "Drop CocoaPods support": Part 1, but keep the iOS 14 / macOS 12 minimums.
   2. "Raise minimum platforms to iOS 15 and macOS 13": `Package.swift`, deployment targets, README requirements.
   - Run the Part 1 verification before moving on (package plus both example builds).
2. Branch `feature/pulse-tool` off `feature/project-update`. Commit "Add SentinelPulse product with PulseTool": Part 2.
3. When PRs are requested later:
   - run `pr-review-code-simplicity` first; AI review is allowed on this project;
   - open `feature/project-update` against `master`, and `feature/pulse-tool` against `feature/project-update`;
   - add the `ai-assisted` label to both.

## Verification
- `xcodebuild -scheme Sentinel -destination 'generic/platform=iOS' build` (root package, iOS)
- `xcodebuild -scheme SentinelPulse -destination 'generic/platform=iOS' build` and `... -destination 'platform=macOS' build`
- `swift build` (macOS variant of both products)
- `xcodebuild -project Example/Sentinel.xcodeproj -scheme Example-iOS -destination 'generic/platform=iOS Simulator' build` and `-scheme Example-MacOS -destination 'platform=macOS' build`
- Run the iOS example in the simulator, open Sentinel, go to Tools → Pulse, and screenshot the console showing the sample logs and network request. Push and pop the screen and check the navigation looks right. Run the macOS example and check the same flow.
- `grep -rni "cocoapods\|podspec\|pod install"` across the repo (excluding `.git`, `.build` and `.claude`) should return nothing.

## Out of scope (mention, don't do)
- Splitting the single `Sentinel` target into a product per tool, which would bring back the opt-in subspec granularity.
- Removing `@available(iOS 15, *)` checks the new minimums make redundant.

## Deviations found during implementation
- `swift-tools-version` went from 5.5 to **5.9**: `.macOS(.v13)` needs 5.7 or newer. 5.9 keeps Swift 5 language mode.
- **PulseTool is iOS-only.** Pulse 5.0 removed the embeddable macOS console; Pulse points macOS users to its standalone Mac app. `SentinelPulse` links Pulse with `condition: .when(platforms: [.iOS])`, and the macOS example isn't wired to it.
- Pulse 5.2+ `ConsoleView` needs **iOS 18 at runtime** (5.1 needs iOS 16). On older systems it shows an "Unsupported" placeholder. This is documented in README and DocC.
- `.closeButtonHidden()` is applied because the console is pushed onto Sentinel's `NavigationView`.
- The README says the last CocoaPods release is **2.3.0**, which is the latest on trunk; 2.4.0 was never published there.
- The root `Package.resolved` is gitignored; the example project's `Package.resolved` is tracked.
