# Sentinel

<p align="center">
    <img src="Resources/ic-sentinel.svg" width="300" max-width="50%" alt="Sentinel"/>
</p>

[![Build Status](https://app.bitrise.io/app/56dc4082e9c3bb9e/status.svg?token=aHG6rIR2XDrJ3xNOIO2hXw&branch=master)](https://app.bitrise.io/app/56dc4082e9c3bb9e)
[![Version](https://img.shields.io/cocoapods/v/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![License](https://img.shields.io/cocoapods/l/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel#license)
[![Platform](https://img.shields.io/cocoapods/p/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)

## Description

**Sentinel** is a simple library that gives developers the possibility to configure one entry point for every debug tool. The idea of **Sentinel** is to give the ability to developers to configure a screen with multiple debug tools which are available via some event (e.g. shake, notification).

**Sentinel** has a tab bar that contains five screens. Three of those aren't configurable, and two of them are. The first screen is the **Device** screen which allows the user to look into some of the device-specific information. The second screen is the **Application** screen which allows the user to look into some of the application-specific information from the <i>info.plist</i>. The third, the first configurable screen, is the **Tools** screen. **Tools** screen allows you to add as many `Tool` objects as your heart desires which can be used by the user to find out some specific information. The fourth, last configurable screen, is the **Preferences** screen. **Preferences** screen allows you to add options that allow or deny some activity inside the app. **Preferences** tab can also be used as a feature control entry point, the user will be able to enable or disable the features by pressing the option button. Last, but not the least, is the **Performance** screen which contains performance-specific information. Later on, we'll explain how you can configure those screens.

**Sentinel** contains a few custom tools which can be used, some of which are in their own subspecs. You can find out more about it in the [Usage](#usage) section.

This library supports both **Swift** and **Objective-C**.

## Table of contents

* [Requirements](#requirements)
* [Getting started](#getting-started)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)

## Requirements

* iOS 11 and above
* Xcode 15 and above

## Getting started

### Installation

#### CocoaPods

*Sentinel* is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Sentinel'
```

*Sentinel* is made of multiple subspecs:
- `Core` which will install only the core features for the *Sentinel* to be usable
- `UserDefaults` which will add the `UserDefaultsTool`
- `EmailSendel` which will add the `EmailSenderTool`
- `CustomLocation` which will add the `CustomLocationTool`
- `TextEditing` which will add the `TextEditingTool`
- `Default` - which will install `UserDefaults`, `Core`, `CustomLocation`, and `TextEditing`

*NOTE: All of the subspecs add `Core` as a dependency*

#### Swift Package Manager

If you are using SPM for your dependency manager, add this to the dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/infinum/ios-sentinel.git")
]
```

## Usage

`Sentinel` is the main class used to set up the *Sentinel* which will be used in the application. The `Sentinel` object can configured via `setup:` method by `Configuration` object. The `setup:` can be called in the `AppDelegate` method `application(_:didFinishLaunchingWithOptions:)`.

```swift
let optionSwitchItems: [OptionSwitchItem] = [
    OptionSwitchItem(
        name: "Analytics",
        setter: { AppSwitches.analyticsEnabled = $0 },
        getter: { AppSwitches.analyticsEnabled },
        userDefaults: .standard,
        userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
    ),
    OptionSwitchItem(
        name: "Crashlytics",
        setter: { AppSwitches.crashlyticsEnabled = $0 },
        getter: { AppSwitches.crashlyticsEnabled },
        userDefaults: .standard,
        userDefaultsKey: "com.infinum.sentinel.optionSwitch.crashlytics"
    )
]

let configuration = Sentinel.Configuration(
    trigger: Triggers.shake,
    tools: [
        UserDefaultsTool(),
        CustomLocationTool()
    ],
    preferences: optionSwitchItems
)

Sentinel.shared.setup(with: configuration)
```

### Configuration

To configure the `Sentinel` object, the `Configuration` object is introduced. `Configuration` contains multiple objects which define general *Sentinel* behaviour. The inputs which this object needs are; `trigger`, `sourceScreenProvider`, `tools`, and `preferences`.  

The `trigger` object is a type of `Trigger` which defines on which event the *Sentinel* will be triggered. Currently, three types are supported; `ShakeTrigger`, `ScreenshotTrigger`, `NotificationTrigger`. New triggers can be added as well, just by conforming to the `Trigger` protocol. Currently, available triggers can be accessed from the `Triggers` class by using its designated static properties like `shake`, `screenshot` or `notification(forName:)`.

In case there's a need for another `Trigger`, take a look at the currently implemented ones to gain some information on how it should be done.

```swift
/// Defines interaction with trigger.
@objc
public protocol Trigger: NSObjectProtocol {

    /// Subscribes to the triggering event.
    ///
    /// - Parameter events: The block which will be called when notification arrives.
    @objc(subscribeOnEvents:)
    func subscribe(on events: @escaping () -> ())
}
```

The `sourceScreenProvider` object is a type of `SourceScreenProvider` which should provide a view controller from where will *Sentinel* be presented. Currently, one type is supported; `default`, and the initializer will default to it. The `SourceScreenProvider.default` uses the current top ViewController to be the one providing the *Sentinel* screens. 

The `tools` object is an array of `Tool` objects. `Tool` objects represent tools which will be available from *Sentinel*. There are multiple tools already supported by the library, but custom tools can be created and added to the *Sentinel*.

Last, but not the least, is the `preferences` object which is an array of `OptionSwitchItem` objects. `OptionSwitchItem` is used to allow the user to switch of some of the preferences which are contained in the `UserDefaults`. To allow the user the interaction, you will have to add a `getter`, and a `setter` for the property from the `UserDefaults` object.

e.g. The app supports Analitycs and you can add an `OptionSwitchTool` which will be shown on the `Preferences` screen and the user can turn it off if he doesn't want it.

```swift
OptionSwitchItem(
    name: "Analytics",
    setter: { AppSwitches.analyticsEnabled = $0 },
    getter: { AppSwitches.analyticsEnabled },
    userDefaults: .standard,
    userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
)
```

### Custom tools

To be able to create a custom tool that will be available through the *Sentinel*, a new class should be created which conforms to the `Tool` protocol. This protocol is defined as:

```swift
/// Defines tool behaviour.
@objc
public protocol Tool {
    
    /// The name of the tool.
    var name: String { get }
    /// Presents the tool view controller from provided view controller.
    ///
    /// - Parameter viewController: The view controller used for presenting tool view controller.
    @objc(presentPreviewFromViewController:)
    func presentPreview(from viewController: UIViewController)
}
```

The `name` property will be available in the `Tools` tab as one of the cells. The `presentPreview` method needs to instantiate the screen you want to show, and it will use the view controller from the `sourceScreenProvider` to show your custom tool.

At Infinum, we're using `Pulse` as our network logger. We only use it for internal builds, and it helps a lot if we can somehow access the logs from `Pulse`, as well as other debug tools. That's why we have a need to create the `PulseTool` which will be an example on how to create your own tool.

```swift

final class PulseTool: Tool {
    var name: String { "Pulse" }

    func presentPreview(from viewController: UIViewController) {
        let pulse = UIHostingController(rootView: ConsoleView())
        let pulseNavigation = UINavigationController(rootViewController: pulse)
        viewController.present(pulseNavigation, animated: true)
    }
}
```

### Available custom tools

*CustomInfoTool* is used on the `Device`, and `Application` tabs. Its primary use is to list out properties and their values.

*CustomLocationTool* is used to change the current user's location. After changing the location, the application will have to be restarted.

*TextEditingTool* is used to give the ability to edit a value. Where you have to provide a `getter`, and a `setter` for the property you want to change dynamically.

*UserDefaultsTool* is used to give an overview of all the `UserDefaults` properties, their values, and the ability to delete properties.

*EmailSenderTool* is used to let the user send emails with attachments from the app with ease.

## Contributing

We believe that the community can help us improve and build better a product.
Please refer to our [contributing guide](CONTRIBUTING.md) to learn about the types of contributions we accept and the process for submitting them.

To ensure that our community remains respectful and professional, we defined a [code of conduct](CODE_OF_CONDUCT.md) that we expect all contributors to follow.

We appreciate your interest and look forward to your contributions.

## License

```text
Copyright 2024 Infinum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Credits

Maintained and sponsored by [Infinum](https://infinum.com).

<div align="center">
<a href='https://infinum.com'>
<picture>
<source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
<img src="https://assets.infinum.com/brand/logo/static/default.svg">
</picture>
</a>
</div>
