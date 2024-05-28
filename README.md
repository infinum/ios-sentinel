# Sentinel

<p align="center">
    <img src="ic-sentinel.svg" width="300" max-width="50%" alt="Sentinel"/>
</p>

[![Build Status](https://app.bitrise.io/app/56dc4082e9c3bb9e/status.svg?token=aHG6rIR2XDrJ3xNOIO2hXw&branch=master)](https://app.bitrise.io/app/56dc4082e9c3bb9e)
[![Version](https://img.shields.io/cocoapods/v/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![License](https://img.shields.io/cocoapods/l/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![Platform](https://img.shields.io/cocoapods/p/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)

## Description

**Sentinel** is a simple library that gives developers the possibility to configure one entry point for every debug tool. The idea of **Sentinel** is to give the ability to developers to configure a screen with multiple debug tools which are available via some event (e.g. shake, notification).

**Sentinel** has a tab bar that contains five screens. Three of those aren't configurable, and two of them are. The first screen is the **Device** screen which allows the user to look into some of the device-specific information. The second screen is the **Application** screen which allows the user to look into some of the application-specific information from the <i>info.plist</i>. The third, the first configurable screen, is the **Tools** screen. **Tools** screen allows you to add as much `Tool` object as your heart desires which can be used by the user to find out some specific information. The fourth, last configurable screen, is the **Preferences** screen. **Preferences** screen allows you to add options that allow or deny some activity inside the app. The last, but not the least, is the **Performance** screen which contains performance-specific information. Later on, we'll explain how you can configure those screens.

This library supports both **Swift** and **Objective-C**.

## Table of contents

* [Requirements](#requirements)
* [Getting started](#getting-started)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)

## Requirements

* iOS 10 and above
* Xcode 10 and above

## Getting started

### Installation

#### CocoaPods

Sentinel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Sentinel'
```

#### Swift Package Manager

If you are using SPM for your dependency manager, add this to the dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/infinum/ios-sentinel.git")
]
```

To add the *Sentinel* to your project, install the library as instructed above. After that, define *Sentinel* configuration with mandatory parameters and call `Sentinel.shared.setup:` in the `AppDelegate` method `application(_:didFinishLaunchingWithOptions:)`.

```swift
let configuration = Sentinel.Configuration(
    sourceScreenProvider: SourceScreenProviders.default,
    trigger: Triggers.shake,
    tools: [
        GeneralInfoTool(),
        UserDefaultsTool(),
        LoggieTool(),
    ],
    preferences: [
        OptionSwitchItem(
            name: "Analytics",
            setter: { AppSwitches.analyticsEnabled = $0 },
            getter: { AppSwitches.analyticsEnabled },
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
        )
    ]
)

Sentinel.shared.setup(with: configuration)
```

## Usage

### Basics

`Sentinel` is the main class used to setup the *Sentinel* which will be used in the application. The `Sentinel` object can configured via `setup:` method by `Configuration` object.

### Configuration

To be able to configure the `Sentinel` object, the `Configuration` object is introduced. This object contains multiple objects which define general *Sentinel* behaviour. The inputs which this object needs are; `trigger`, `sourceScreenProvider`, `tools`, and `preferences`.  

The `trigger` object is a type of `Trigger` which defines on which event the *Sentinel* will be triggered. Currently, three types of are supported; `ShakeTrigger`, `ScreenshotTrigger`, `NotificationTrigger`. New triggers can be added as well, just by conforming the `Trigger` protocol.

The `sourceScreenProvider` object is a type of `SourceScreenProvider` which should provide a view controller from where will *Sentinel* be presented. Currently, one type is supported; `default`.

The `tools` object is an array of `Tool` objects. `Tool` objects represent tools which will be available from *Sentinel*. There are multiple tools already supported by the library, but custom tools can be created and added to the *Sentinel*.

The last, but not the least, is the `preferences` object which is an array of `OptionSwitchItem` objects. `OptionSwitchItem` is used to allow the user to switch of some of the preferences which are contained in the app. e.g. The app supports Analitycs and you can add an `OptionSwitchTool` which will be shown on the `Preferences` screen and the user can turn it off if he doesn't want it.

### Custom tools

To be able to create a custom tool that will be available through the *Sentinel*, a new class should be created which conforms the `Tool` protocol. This protocol is defined as:

```swift
public protocol Tool {
    var name: String { get }
    func presentPreview(from viewController: UIViewController)
}

```

Based on this, only `name` should be provided as well as `presentPreview:` method which will present the tool view controller from the `sourceScreenProvider` view controller defined in the Sentinel configuration.

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