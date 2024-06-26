# Sentinel
[![Build Status](https://app.bitrise.io/app/56dc4082e9c3bb9e/status.svg?token=aHG6rIR2XDrJ3xNOIO2hXw&branch=master)](https://app.bitrise.io/app/56dc4082e9c3bb9e)
[![Version](https://img.shields.io/cocoapods/v/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![License](https://img.shields.io/cocoapods/l/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![Platform](https://img.shields.io/cocoapods/p/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)

<p align="center">
    <img src="ic-sentinel.svg" width="300" max-width="50%" alt="Sentinel"/>
</p>

## About

**Sentinel** is a simple library that gives developers the possibility to configure one entry point for every debug tool. The idea of **Sentinel** is to give the ability to developers to configure a screen with multiple debug tools which are available via some event (e.g. shake, notification).

**Sentinel** has a tab bar that contains five screens. Three of those aren't configurable, and two of them are. The first screen is the **Device** screen which allows the user to look into some of the device-specific information. The second screen is the **Application** screen which allows the user to look into some of the application-specific information from the <i>info.plist</i>. The third, the first configurable screen, is the **Tools** screen. **Tools** screen allows you to add as much `Tool` object as your heart desires which can be used by the user to find out some specific information. The fourth, last configurable screen, is the **Preferences** screen. **Preferences** screen allows you to add options that allow or deny some activity inside the app. The last, but not the least, is the **Performance** screen which contains performance-specific information. Later on, we'll explain how you can configure those screens.

This library supports both **Swift** and **Objective-C**.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 10 and above
* Xcode 10 and above

## Installation

### CocoaPods

Sentinel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Sentinel'
```

### Swift Package Manager

If you are using SPM for your dependency manager, add this to the dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/infinum/ios-sentinel.git")
]
```

## Usage

### Features

In this chapter, some of the most important pieces of the library will be introduced.

#### Sentinel

`Sentinel` is the main class used to setup the *Sentinel* which will be used in the application. The `Sentinel` object can configured via `setup:` method by `Configuration` object.

#### Configuration

To be able to configure the `Sentinel` object, the `Configuration` object is introduced. This object contains multiple objects which define general *Sentinel* behaviour. The inputs which this object needs are; `trigger`, `sourceScreenProvider`, `tools`, and `preferences`.  

The `trigger` object is a type of `Trigger` which defines on which event the *Sentinel* will be triggered. Currently, three types of are supported; `ShakeTrigger`, `ScreenshotTrigger`, `NotificationTrigger`. New triggers can be added as well, just by conforming the `Trigger` protocol.

The `sourceScreenProvider` object is a type of `SourceScreenProvider` which should provide a view controller from where will *Sentinel* be presented. Currently, one type is supported; `default`.

The `tools` object is an array of `Tool` objects. `Tool` objects represent tools which will be available from *Sentinel*. There are multiple tools already supported by the library, but custom tools can be created and added to the *Sentinel*.

The last, but not the least, is the `preferences` object which is an array of `OptionSwitchItem` objects. `OptionSwitchItem` is used to allow the user to switch of some of the preferences which are contained in the app. e.g. The app supports Analitycs and you can add an `OptionSwitchTool` which will be shown on the `Preferences` screen and the user can turn it off if he doesn't want it.

#### Custom tools

To be able to create a custom tool that will be available through the *Sentinel*, a new class should be created which conforms the `Tool` protocol. This protocol is defined as:

```swift
public protocol Tool {
    var name: String { get }
    func presentPreview(from viewController: UIViewController)
}

```

Based on this, only `name` should be provided as well as `presentPreview:` method which will present the tool view controller from the `sourceScreenProvider` view controller defined in the Sentinel configuration.

### Getting started

To add the *Sentinel* to your project, install the library via CocoaPods as instructed above. After that, define *Sentinel* configuration with mandatory parameters and call `Sentinel.shared.setup:` in the `AppDelegate` method `application(_:didFinishLaunchingWithOptions:)`.

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

## Privacy

Sentinel does not collect any user data. We have provided a [privacy manifest](https://github.com/infinum/ios-sentinel/blob/master/Sentinel/SupportingFiles/PrivacyInfo.xcprivacy) file that can be included in your app.


## Authors

* Vlaho Poluta, vlaho.poluta@infinum.com
* Nikola Majcen, nikola.majcen@infinum.com

## License

Sentinel is available under the MIT license. See the [license](LICENSE) file for more information.

## Credits

Maintained and sponsored by [Infinum](http://www.infinum.com).

<a href='https://infinum.co'>
   <img src='https://cloud.githubusercontent.com/assets/1422973/24369980/9c36b0a6-12da-11e7-898a-b711ed7ca52f.png' href='https://infinum.com' width='264'>
</a>
