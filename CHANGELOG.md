# Changelog

All notable changes to Sentinel are listed here. The version is the git tag; see [GitHub releases](https://github.com/infinum/ios-sentinel/releases) for every release.

## [3.0.0]

### Breaking changes

- **CocoaPods is no longer supported.** Sentinel is distributed only through Swift Package Manager; 2.3.0 is the last version published to CocoaPods. All of the tools are part of the `Sentinel` product, so the former subspecs need no replacement.
- **Minimum platforms are iOS 15 and macOS 13** (previously iOS 14 and macOS 12), and the package needs Swift tools 5.9.
- **The package depends on [Pulse](https://github.com/kean/Pulse) `4.0.0..<6.0.0`.** Only the new `SentinelPulse` product links it, but SwiftPM resolves it for every app that adds the package, so an app that already uses Pulse has to be on Pulse 4 or 5.

### Added

- `ClearAppDataTool` (iOS) wipes the app's user defaults, temporary, Documents and Library directories, URL cache, cookies, web site data and keychain items in the app's own access group, so the app can be tested from a clean state without reinstalling it. ([#65](https://github.com/infinum/ios-sentinel/pull/65))
- `APIMockingTool` (iOS, macOS) answers the app's network requests with mocked responses, either shipped in code as `APIMock`s or created by testers in the tool. Mocks match by method and a wildcard or regex URL pattern, return a response or a network error after an optional delay, and are served through a `URLProtocol` so the app's own networking code still runs. ([#69](https://github.com/infinum/ios-sentinel/pull/69))
- `PulseTool` (iOS), in the new `SentinelPulse` product, shows the Pulse console inside Sentinel. ([#67](https://github.com/infinum/ios-sentinel/pull/67))
- Show touches (iOS): a built-in **Sentinel** section in Preferences with a toggle that draws a circle under every finger, for screen recordings and QA. `Configuration(showsTouchesToggle: false)` leaves it out. ([#71](https://github.com/infinum/ios-sentinel/pull/71))
- The Device and Application tabs show much more information, such as the model, screen, locale, accessibility settings, app language and how the app was distributed. A share button shares both tabs as plain text, and a long press (a right-click on macOS) copies a row. `CustomInfoTool` gets the same share button. ([#73](https://github.com/infinum/ios-sentinel/pull/73))
- The crash list can be searched by crash name, date or stack trace. ([#72](https://github.com/infinum/ios-sentinel/pull/72))
- A Done button dismisses the keyboard while editing text in Sentinel's tools.
- Unit, integration and UI test suites. ([#68](https://github.com/infinum/ios-sentinel/pull/68))

### Changed

- The crash tool lists crashes newest first within each type, shows their timestamps, separates the exception name from its reason and formats the details screen better. ([#72](https://github.com/infinum/ios-sentinel/pull/72))
- `CustomLocationTool` applies the custom location the next time the app starts location updates, instead of after a restart, and its screen is built in code instead of a storyboard.
- iOS-only tools (`CustomLocationTool`, `EmailSenderTool`, `ClearAppDataTool`) are guarded in source instead of being excluded in `Package.swift`.

### Fixed

- `CustomLocationTool` had no effect, because its `startUpdatingLocation` swizzle was never installed. ([#68](https://github.com/infinum/ios-sentinel/pull/68))
- Setting up crash detection dropped the app's own signal handlers instead of calling them. ([#68](https://github.com/infinum/ios-sentinel/pull/68))
- Setting up crash detection twice could make the uncaught exception handler call itself forever. ([#68](https://github.com/infinum/ios-sentinel/pull/68))
- On iOS 26, tool content and pushed lists sat under the navigation bar or flush against the title and search bar, and the navigation bar had no background. ([#68](https://github.com/infinum/ios-sentinel/pull/68))

## [2.3.0] - 2025-05-20

- Added support for multiple preference types. ([#61](https://github.com/infinum/ios-sentinel/pull/61))
- Fixed images loading from the wrong bundle. ([#64](https://github.com/infinum/ios-sentinel/pull/64))

## [2.2.0] - 2025-04-17

- Added `DatabaseImportExportTool`. ([#58](https://github.com/infinum/ios-sentinel/pull/58))
- Added sharing to the crash detection tool. ([#63](https://github.com/infinum/ios-sentinel/pull/63))
- The trigger dismisses Sentinel if it is already shown. ([#60](https://github.com/infinum/ios-sentinel/pull/60))
- Added font styles. ([#59](https://github.com/infinum/ios-sentinel/pull/59))

## [2.1.0] - 2025-04-01

- Added `CrashDetectionTool`. ([#57](https://github.com/infinum/ios-sentinel/pull/57))

## [2.0.1] - 2025-03-12

- Added DocC documentation. ([#54](https://github.com/infinum/ios-sentinel/pull/54))
- The User Defaults tool got search, editing and values on the list screen. ([#53](https://github.com/infinum/ios-sentinel/pull/53))

## [2.0.0] - 2025-03-05

- Rewritten in SwiftUI, with macOS support and updated navigation. Objective-C is no longer supported; use 1.2.2 for it. ([#43](https://github.com/infinum/ios-sentinel/pull/43), [#46](https://github.com/infinum/ios-sentinel/pull/46), [#47](https://github.com/infinum/ios-sentinel/pull/47))
- Removed the Loggie and Collar integrations. ([#36](https://github.com/infinum/ios-sentinel/pull/36))

## [1.2.2] - 2024-09-30

- Added deleting values to the User Defaults tool. ([#39](https://github.com/infinum/ios-sentinel/pull/39))

## [1.2.1] - 2024-05-28

- Added a privacy manifest. ([#34](https://github.com/infinum/ios-sentinel/pull/34))
- Fixed warnings in the custom location tool. ([#31](https://github.com/infinum/ios-sentinel/pull/31))

## [1.2.0] - 2024-02-07

- Added `EmailSenderTool`. ([#28](https://github.com/infinum/ios-sentinel/pull/28))

## [1.1.2] - 2023-04-19

- Fixed multiple presentation windows when the device is shaken.

## [1.1.1] - 2022-08-04

- Added Swift Package Manager support.

## [1.1.0] - 2022-05-26

- The Tools tab is selected automatically.
- Fixed tool cells staying selected when a tool is presented modally.
- Podspec fixes.

## [1.0.0] - 2021-11-23

- Visual update with a new tab bar.

## [0.9.0] - 2021-04-22

- Initial alpha release.

[3.0.0]: https://github.com/infinum/ios-sentinel/compare/2.3.0...3.0.0
[2.3.0]: https://github.com/infinum/ios-sentinel/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/infinum/ios-sentinel/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/infinum/ios-sentinel/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/infinum/ios-sentinel/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/infinum/ios-sentinel/compare/1.2.2...2.0.0
[1.2.2]: https://github.com/infinum/ios-sentinel/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/infinum/ios-sentinel/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/infinum/ios-sentinel/compare/1.1.2...1.2.0
[1.1.2]: https://github.com/infinum/ios-sentinel/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/infinum/ios-sentinel/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/infinum/ios-sentinel/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/infinum/ios-sentinel/compare/0.9.0...1.0.0
[0.9.0]: https://github.com/infinum/ios-sentinel/releases/tag/0.9.0
