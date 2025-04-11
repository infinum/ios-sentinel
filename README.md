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

**Sentinel** supports **iOS**, and **MacOS**. There are some differences which will be mentioned in the following sections.

**Sentinel** has a tab bar that contains five screens. Three of those aren't configurable, and two of them are. The first screen is the **Device** screen which allows the user to look into some of the device-specific information. The second screen is the **Application** screen which allows the user to look into some of the application-specific information from the <i>info.plist</i>. The third, the first configurable screen, is the **Tools** screen. **Tools** screen allows you to add as many `Tool` objects as your heart desires which can be used by the user to find out some specific information. The fourth, last configurable screen, is the **Preferences** screen. **Preferences** screen allows you to add options that allow or deny some activity inside the app. **Preferences** tab can also be used as a feature control entry point, the user will be able to enable or disable the features by pressing the option button. Last, but not the least, is the **Performance** screen which contains performance-specific information. Later on, we'll explain how you can configure those screens.

**Sentinel** contains a few custom tools which can be used, some of which are in their own subspecs. You can find out more about it in the [Usage](#usage) section.

This library supports **Swift**, and **SwiftUI**.

**Note: For Objective-C support, please use 1.2.2 version**

## Table of contents

* [Requirements](#requirements)
* [Getting started](#getting-started)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)

## Requirements

* iOS 14 and above
* MacOS 12 and above
* Xcode 16 and above

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
- `EmailSender` which will add the `EmailSenderTool`
- `CustomLocation` which will add the `CustomLocationTool`
- `TextEditing` which will add the `TextEditingTool`
- `CrashDetection` which will add the `CrashDetectionTool`
- `Default` - which will install `UserDefaults`, and `TextEditing`

#### Swift Package Manager

If you are using SPM for your dependency manager, add this to the dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/infinum/ios-sentinel.git")
]
```

## Usage

`Sentinel` is the main class used to set up the *Sentinel* which will be used in the application. `Sentinel` has a main View which is called `SentinelTabBarView`. The main View can be accessed in two different ways:

- by using the `setup(with:)` method on the `Sentinel` class, and providing a `Configuration` object. The `setup:` can be called in the `AppDelegate` method `application(_:didFinishLaunchingWithOptions:)`. *Sentinel* will be shown based on the *Trigger* which is specified in the `Configuration` object.

- by using the `createSentinelView(with:)` and providing the `Configuration` object. The method will return the `SentinelTabBarView` which can be shown in whichever way possible.

```swift
var optionSwitchItems: [PreferencesTool.Section] {
    [
        PreferencesTool.Section(
            title: "UserDefaults flags",
            items: [
                ToggleToolItem(
                    title: "Analytics",
                    userDefaults: .standard,
                    userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
                ),
                ToggleToolItem(
                    title: "Crashlytics",
                    setter: { AppSwitches.crashlyticsEnabled = $0 },
                    getter: { AppSwitches.crashlyticsEnabled }
                ),
                ToggleToolItem(
                    title: "Logging",
                    userDefaults: .standard,
                    userDefaultsKey: "com.infinum.sentinel.optionSwitch.logging"
                )
            ]
        )
    ]
 }

 var colorChangeTool: Tool {
    ToolTable(
        name: "Color Change Tool",
        sections: [
            ToolTableSection(
                title: "Color change", 
                items: [ToolTableItem.custom(ColorChangeToolTableItem())]
            )
        ]
    )
}

 var baseUrlTool: Tool {
    TextEditingTool(
        name: "Base URL",
        setter: { AppUrl.baseURL = $0 },
        getter: { AppUrl.baseURL },
        userDefaults: .standard,
        userDefaultsKey: "base_url_user_defaults_key"
    )
}

let configuration = Sentinel.Configuration(
    trigger: Triggers.shake,
    tools: [
        UserDefaultsTool(),
        baseUrlTool,
        colorChangeTool
    ],
    preferences: optionSwitchItems
)

Sentinel.shared.setup(with: configuration)
```

### Configuration

To configure the `Sentinel` object, the `Configuration` object is introduced. `Configuration` contains multiple objects which define general *Sentinel* behaviour. The inputs which this object needs are; `trigger`, `sourceScreenProvider`, `tools`, and `preferences`.

#### Trigger

The `trigger` object is a type of `Trigger` which defines on which event the *Sentinel* will be triggered. Currently, three types are supported on iOS; `ShakeTrigger`, `ScreenshotTrigger`, `NotificationTrigger`. On MacOS only the `NotificationTrigger` is available. New triggers can be added as well, just by conforming to the `Trigger` protocol. Currently, available triggers can be accessed from the `Triggers` class by using its designated static properties like `shake`, `screenshot` or `notification(forName:)`.

In case there's a need for another `Trigger`, take a look at the currently implemented ones to gain some information on how it should be done.

*Note: if the `Trigger` object hasn't been specified when using the `setup(with:)` method, Sentinel will **never** be shown!*

```swift
/// Defines interaction with trigger.
public protocol Trigger {

    /// Subscribes to the triggering event.
    ///
    /// - Parameter events: The block which will be called when notification arrives.
    func subscribe(on events: @escaping () -> ())
}
```

#### SourceScreenProvider

The `sourceScreenProvider` object is of type `SourceScreenProvider` which shows the *Sentinel* main View. Currently, one type is supported, `default`, and the initializer will default to it.

On iOS the `SourceScreenProvider.default` finds the current top ViewController, and presents *Sentinel* on top of it.

On MacOS the `SourceScreenProvider.default` finds the current top window, and presents a new modal Window on top of it.

#### Tool

The `tools` object is an array of `Tool` objects. `Tool` objects represent tools which will be available from *Sentinel*. There are multiple tools already supported by the library based on the platform, but custom tools can be created and added to the *Sentinel*.

#### Preferences

Last, but not the least, is the `preferences` object which is an array of `PreferencesTool.Section` objects. `PreferencesTool.Section` is used to allow the user to create sections of editable options. Each section consists of `PreferenceItem` objects.

```swift
public protocol PreferenceItem: Identifiable, Equatable {
    associatedtype T

    /// Name of the item
    var name: String { get }

    /// Description of the item
    var description: String? { get }

    /// This function is called when value is changed.
    ///
    /// It should be used to change the current variable value.
    var setter: (T) -> () { get }

    /// This function is called when value needs to be read.
    ///
    /// It should be used to provide the current variable value.
    var getter: () -> T { get }

    /// Array of validators used to define validation rules..
    var validators: [AnyPreferenceValidator<T>] { get }

    /// Default storage used for storing information if the key is provided.
    var userDefaults: UserDefaults { get }

    /// Defines key for storing information.
    ///
    /// If the value is not provided, the information won't be stored.
    var userDefaultsKey: String? { get }
}
```

**PreferenceItem** is a protocol which defines which properties are mandatory for a preference object. It provides a `setter`, and a `getter` so Sentinel can know how to store new values or fetch existing ones. There is an optional `userDefaultsKey` parameter which is used if the value should be stored in the `UserDefaults`.

`PreferenceItem` also supports validators. You can create your own validator by conforming to the `PreferenceValidator`.
```swift
///
/// Defines validator behavior for preference items.
///
public protocol PreferenceValidator<T> {
    associatedtype T

    ///
    /// Defines custom message which will be shown instead
    /// of default validator message.
    ///
    /// - Returns: Custom validation message.
    ///
    var validationMessage: String? { get }

    ///
    /// Validates the provided value and returns `true`
    /// if value is valid for the provided validator.
    ///
    /// - Parameter value: Value to be validated.
    /// - Returns: `true` if value is valid, `false` otherwise.
    ///
    func validate(value: T) -> Bool
}
```
There are two validators already created; `PreferenceCountValidator`, and `PreferenceValueValidator`.
When creating a `PreferenceItem`, you will need to wrap them in the `AnyPreferenceValidator` struct so that it is type agnostic.

There is a couple of supported `PreferenceItem` objects:
- **ToggleToolItem** - toggleable view
- **PreferencesTextItem** - view with a text field
- **PreferencesIntItem** - view witha a text field which only accepts Int when saving
- **PreferencesFloatItem** - view witha a text field which only accepts Float when saving
- **PreferencesDoubleItem** - view witha a text field which only accepts Double when saving
- **PreferencesPickerItem** - view witha a picker view

e.g. The app supports Analitycs and you can add an `PreferencesTool.Section` which will be shown on the `Preferences` screen and the user can turn it off if he doesn't want it.

```swift
PreferencesTool.Section(
    title: "UserDefaults flags",
    items: [
        ToggleToolItem(
            title: "Analytics",
            userDefaults: .standard,
            userDefaultsKey: "com.infinum.sentinel.optionSwitch.analytics"
        )
    ]
)
```

### Custom tools

To be able to create a custom tool that will be available through the *Sentinel*, a new class should be created which conforms to the `Tool` protocol. This protocol is defined as:

```swift
/// Defines tool behaviour and the content View.
public protocol Tool {
    
    /// The name of the tool.
    var name: String { get }

    #if os(macOS)
    /// Tool's content View. Selection is a binding provided from the parent view which should be set to nil if we want to navigate the user back to the previous screen.
    func createContent(selection: Binding<String?>) -> any View
    #else
    /// Tool's content View
    @ViewBuilder var content: any View { get }
    #endif
}
```
The `name` property will be available in the `Tools` tab as one of the cells.
Depending on the platform you are using, there are different conformances due to a bit different handling of the navigation.

#### MacOS
The `createContent(selection: Binding<String?>)` method provides the *View* which will be shown when the *Tool* is selected. If the *Tool* contains multiple navigation Views, you can provide the `selection` binding which needs to be set to `nil` when the user should be navigated back.

If you need more context, you can check out the `UserDefaultsTool` or `EditTextTool`.

#### iOS
The `content` property provides the *View* which will be shown when the *Tool* is selected.

At Infinum, we're using `Pulse` as our network logger. We only use it for internal builds, and it helps a lot if we can somehow access the logs from `Pulse`, as well as other debug tools. That's why we have a need to create the `PulseTool` which will be an example on how to create your own tool.

```swift
final class PulseTool: Tool {
    var name: String { "Pulse" }

    var content: any View {
        ConsoleView()
    }
}
```

When creating custom `Tool` objects. You can use the `ToolTable` object which will use `SentinelListView` as the main View which is a ScrollView with a predefined number of items which can be shown. To create a `ToolTable` you need to provide a name for that tool, and the section items. Section items are items of type `ToolTableSection` which can have a section title, and an array of items of type `ToolTableItem`. `ToolTableItem` is an Enum with five different states which can be shown just by providing the required information for it:
 - **navigation** - creates a View with title + arrow right which will lead to a different screen when tapped
 - **toggle** - creates a View with a Toggle which will change the state of the provided property when tapped
 - **customInfo** - creates a View with a title + value
 - **performance** - creates a View with a title + value which will be updated each second
 - **custom** - creates a View whichever you provide, gives the ability to show a custom View. The item will need to conform to the `CustomToolTableItem` protocol.

```swift
struct ColorChangeToolTableItem: CustomToolTableItem {

    var title: String {
        "Color change"
    }

    var content: any View {
        ColorChangeToolView()
    }
}

var colorChangeTool: Tool {
    ToolTable(
        name: "Color Change Tool",
        sections: [
            ToolTableSection(title: "Color change", items: [ToolTableItem.custom(ColorChangeToolTableItem())])
        ]
    )
}
```

### Available custom tools

#### CustomInfoTool

*CustomInfoTool* is used on the `Device`, and `Application` tabs. Its primary use is to list out properties and their values. The tool is available on both iOS, and MacOS platforms.

#### TextEditingTool

*TextEditingTool* is used to give the ability to edit a value. Where you have to provide a `getter`, and a `setter` for the property you want to change dynamically. The tool is available on both iOS, and MacOS platforms.

#### UserDefaultsTool

*UserDefaultsTool* is used to give an overview of all the `UserDefaults` properties, their values, and the ability to update or delete properties. The tool is available on both iOS, and MacOS platforms.

#### CrashDetectionTool

*CrashDetectionTool* sets up listeners on system exceptions which will be logged into a local json file with the stack trace. The tool is available on iOS.

#### Database tool

*DatabaseImportExportTool* gives the ability to import or export the database file which is located in the documents folder of the app. The tool is available on iOS and MacOS.

#### CustomLocationTool

*CustomLocationTool* is used to change the current user's location. After changing the location, the application will have to be restarted. The tool is available on iOS.

#### EmailSenderTool

*EmailSenderTool* is used to let the user send emails with attachments from the app with ease. The tool is available on iOS.

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
