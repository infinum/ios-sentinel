# Setup

How you can set up Sentinel.

## 1. Add Sentinel

### Cocoapods

You can add Sentinel via Cocoapods.

```
pod 'Sentinel'
```

This will add the default subspec, if you want additional tools, check out other subspecs.

### SPM

You can add Sentinel via SPM.

```
https://github.com/infinum/ios-sentinel.git
```

## 2. Integrate Sentinel

When setting up Sentinel, the `Sentinel.Configuration` will have to be provided. The Configuration struct can specify some other things as well, but the Trigger in this case has to be provided. It can also specify how will Sentinel be shown by specifying the `sourceScreenProvider` property. Other properties will be explained later on.

```swift
/// Defines configuration used to define Sentinel.
///
/// Based on the provided properties, Sentinel will be shown based on different event
/// and it will show different tools.
struct Configuration {

    // MARK: - Public properties

    /// The trigger event which starts the Sentinel.
    public let trigger: Trigger?

    /// The screen used for presenting the Sentinel.
    public let sourceScreenProvider: SourceScreenProvider

    /// Tools which are available from the Sentinel.
    public let tools: [Tool]

    /// Items which are shown on preferences screen
    public let preferences: [PreferencesTool.Section]

    // MARK: - Lifecycle

    /// Creates a new configuration.
    ///
    /// - Parameters:
    ///     - trigger: The trigger event which opens the Sentinel.
    ///     - sourceScreenProvider: The screen from which Sentinel can be presented.
    ///     - tools: Tools available from the Sentinel.
    ///     - preferences: Section items which can allow or deny an activity inside the app
    public init(
        trigger: Trigger? = nil,
        sourceScreenProvider: SourceScreenProvider = SourceScreenProviders.default,
        tools: [Tool],
        preferences: [PreferencesTool.Section] = []
    ) {
        self.trigger = trigger
        self.sourceScreenProvider = sourceScreenProvider
        self.tools = tools
        self.preferences = preferences
    }
}
```

There are two ways Sentinel can be integrated.

### 1. Setting up a Trigger

Sentinel can be set up by using one of the predefined or by creating your own Trigger. Trigger is used to trigger the Sentinel to show. Currently, there are three triggers available; `ShakeTrigger`, `NotificationTrigger`, `ScreenshotTrigger`.
When setting up with a Trigger, the setup method has to be used.

```swift
/// Setups the Sentinel with provided configuration.
///
/// - Parameter configuration: The configuration used to setup current instance of the Sentinel.
public func setup(with configuration: Configuration) {
    self.configuration = configuration
    configuration.trigger?.subscribe {
        configuration.sourceScreenProvider.showTools(for: Self.createSentinelView(with: configuration))
    }
}
```


### 2. Creating and showing a View

Another way to set up Sentinel is by using the `createViewSentinelView` method needs to be used. The method will provide a SentinelTabBarView which can be shown anywhere in the App.

```swift
/// Creates the Sentinel View with tools.
///
/// - Parameter configuration: The configuration used to setup current instance of the Sentinel.
public static func createSentinelView(with configuration: Configuration) -> SentinelTabBarView {
    let tabItems = createTabItems(
        with: configuration.tools,
        preferences: configuration.preferences
    )

    return SentinelTabBarView(tabs: tabItems)
}
```

## Add Preferences

The `prefernces` can be added as part of the configuration setup of **Sentinel**. Prefrences add items to the Preferences tab of Sentinel which are toggleable flags. Preference sections can be added:

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

The toggles can update a value in the `UserDefaults` so they ca nbe used as feature flags as well.

## Add Tools

As mentioned before, the **Configuration** struct has a property named tools which will add `Tool` items to the `SentinelTabBarView`.
Tool is a name for the wrapper around a debug tool that Sentinel will provide. There are a couple of predefined tools which come with Sentinel but new ones can be easily added.

### CustomInfoTool

**CustomInfoTool** is used on the `Device`, and `Application` tabs. Its primary use is to list out properties and their values. The tool is available on iOS, and MacOS platforms.

### TextEditingTool

**TextEditingTool** is used to give the ability to edit a value where you have to provide a `getter`, and a `setter` for the property you want to change dynamically. The tool is available on both iOS, and MacOS platforms.

### UserDefaultsTool

**UserDefaultsTool** is used to give an overview of all the `UserDefaults` properties, their values, and the ability to update or delete properties. The list of properties can be searched as well. The tool is available on both iOS, and MacOS platforms.

### CustomLocationTool

**CustomLocationTool** is used to change the user's current location. After changing the location, the application have to be restarted. The tool is available on iOS.

### EmailSenderTool

**EmailSenderTool** is used to let the user send emails with attachments from the app with ease. The tool is available on iOS.

## Creating your own tools

The next step on your Sentiel journey is tailoring a new tool to your own needs in <doc:CustomTools>
