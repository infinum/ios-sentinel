# Setup

How you can set up Sentinel.

## 1. Add Sentinel

### SPM

You can add Sentinel via SPM. All of the tools are part of the `Sentinel` product.

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

Another way to set up Sentinel is by using the ``createViewSentinelView`` method needs to be used. The method will provide a SentinelTabBarView which can be shown anywhere in the App.

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

The `preferences` can be added as part of the configuration setup of **Sentinel**. Preferences add items to the Preferences tab of Sentinel which are editable items. Each section consists of `PreferenceItem` objects.

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

## Add Tools

As mentioned before, the **Configuration** struct has a property named tools which will add `Tool` items to the `SentinelTabBarView`.
Tool is a name for the wrapper around a debug tool that Sentinel will provide. There are a couple of predefined tools which come with Sentinel but new ones can be easily added.

### CustomInfoTool

**CustomInfoTool** is used on the `Device`, and `Application` tabs. Its primary use is to list out properties and their values. The tool is available on iOS, and MacOS platforms.

### TextEditingTool

**TextEditingTool** is used to give the ability to edit a value where you have to provide a `getter`, and a `setter` for the property you want to change dynamically. The tool is available on both iOS, and MacOS platforms.

### UserDefaultsTool

**UserDefaultsTool** is used to give an overview of all the `UserDefaults` properties, their values, and the ability to update or delete properties. The list of properties can be searched as well. The tool is available on both iOS, and MacOS platforms.

### DatabaseTool

**DatabaseImportExportTool** gives the ability to import or export the database file which is located in the documents folder of the app. The tool is available on iOS and MacOS.

The Tool expects the database file to be in the Documents folder of the App. You have to provide the the `UTType` for the database file so it can be properly imported, and you have to provide the relative path in the documents folder of the app.

The tool will export the database file as a zip, and the file should be imported as is. The existing database file will be replaced with the new one.

### CrashDetectionTool

**CrashDetectionTool** sets up listeners on system exceptions which will be logged into a local json file with the stack trace. The tool is available on iOS.

### CustomLocationTool

**CustomLocationTool** is used to change the user's current location. While it's turned on, every `CLLocationManager` that calls `startUpdatingLocation()` receives the custom location instead of the real one, so restart location updates (or the app) after changing it. `requestLocation()` isn't affected. The tool is available on iOS.

### EmailSenderTool

**EmailSenderTool** is used to let the user send emails with attachments from the app with ease. The tool is available on iOS.

### APIMockingTool

**APIMockingTool** answers the app's network requests with mocked responses: an HTTP response with a JSON body, or a network error, optionally after a delay. The app passes the ``APIMock``s it ships with, and testers create more in the tool by pasting a response body, without rebuilding the app. A mock matches requests by method and by a `.wildcard` URL pattern, which matches URLs ending with the pattern and where `*` stands for any run of characters, or by a `.regex`. Switching a mock on switches off the others for the same endpoint. Mocks are served by a `URLProtocol` that the tool adds to every `default` and `ephemeral` session configuration created after it, and to `URLSession.shared`; call ``APIMockingTool/register(in:)`` for a configuration created earlier. Mocks made in the tool and the switches survive relaunches and ``ClearAppDataTool``. The tool is available on iOS and macOS.

### PulseTool

**PulseTool** shows the [Pulse](https://github.com/kean/Pulse) console with the app's logs and network requests. It is part of the separate `SentinelPulse` product, so add that product and `import SentinelPulse` to use it. The app also needs Pulse itself as a dependency, to log messages and network requests. The tool shows `LoggerStore.shared` unless a different store is passed in. The tool is available on iOS, and Pulse 5.2 and newer need iOS 18 to show the console.

### MacConnectionTool

**MacConnectionTool** connects the app to Sentinel Companion, the Mac app in the repository's `SentinelCompanion` folder, which shows the requests the app logs through Pulse live and controls its API mocks. Switching on the connection in the tool lists the Macs found over Bonjour, on the same network or through peer-to-peer Wi-Fi; in the iOS Simulator, the Mac is reached on localhost. The first connection to a Mac pairs the two: both show a six-digit code, which the user confirms on the device and allows on the Mac. Later connections are made without asking, and everything sent between the two is encrypted. The app's Info.plist needs `NSLocalNetworkUsageDescription` and `_sentinel._tcp` under `NSBonjourServices`; nothing is searched for until the connection is switched on. The tool is available on iOS.

## Creating your own tools

The next step on your Sentiel journey is tailoring a new tool to your own needs in <doc:CustomTools>
