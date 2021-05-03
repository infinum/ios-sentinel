# Sentinel

[![Version](https://img.shields.io/cocoapods/v/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![License](https://img.shields.io/cocoapods/l/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)
[![Platform](https://img.shields.io/cocoapods/p/Sentinel.svg?style=flat)](https://cocoapods.org/pods/Sentinel)

<p align="center">
    <img src="ic-sentinel.svg" width="300" max-width="50%" alt="Sentinel"/>
</p>

## About

*Sentinel* is a simple library which gives developers a possibility to configure one entry point for every debug tool. The idea of *Sentinel* is to give ability to developers to configure screen with multiple debug tools which are available via some event (e.g. shake, notification).

This library supports both **Swift** and **Objective-C**.

*Note*: Current release is an **alpha** release.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 10 and above
* Xcode 10 and above

## Installation

Sentinel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Sentinel'
```

## Usage

### Features

In this chapter, some of the most important pieces of the library will be introduced.

#### Sentinel

`Sentinel` is the main class used to setup the *Sentinel* which will be used in the application. The `Sentinel` object can configured via `setup:` method by `Configuration` object.

#### Configuration

To be able to configure `Sentinel` object, the `Configuration` object is introduced. This object contains multiple objects which defines general *Sentinel* behaviour. The inputs which this object needs are; `trigger`, `sourceScreenProvider` and `tools`. 

The `trigger` object is a type of `Trigger` which defines on which event the *Sentinel* will be triggered. Currently, three types of are supported; `ShakeTrigger`, `ScreenshotTrigger`, `NotificationTrigger`. New triggers can be added as well, just by conforming the `Trigger` protocol.

The `sourceScreenProvider` object is a type of `SourceScreenProvider` which should provide a view controller from where will *Sentinel* be presented. Currently, one type is supported; `default`.

The last object needed for configuration is `tools`, which is an array of `Tool` objects. `Tool` objects represents tools which will be available from *Sentinel*. There are multiple tools already supported by the library, but custom tools can be created and added to the *Sentinel*.

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
    ]
)

Sentinel.shared.setup(with: configuration)
```

## Authors

* Vlaho Poluta, vlaho.poluta@infinum.com
* Nikola Majcen, nikola.majcen@infinum.com

## License

Sentinel is available under the MIT license. See the [license](LICENSE) file for more information.

## Credits

Maintained and sponsored by [Infinum](http://www.infinum.com).

<a href='https://infinum.co'>
  <img src='https://infinum.co/infinum.png' href='https://infinum.com' width='264'>
</a>
