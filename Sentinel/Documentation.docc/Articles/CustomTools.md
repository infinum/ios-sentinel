# Custom Tools

If your project might need a specific tool which wasn't provided by **Sentinel**, we've got you covered. 

## Creating your own custom tools

### 1. Check the already available tools

First thing's first, check the available tools, maybe there's a tool which can help with your situation.

If there's nothing that can help you, please proceed with the following steps :)

### 2. Conform to the Tool protocol

The first thing is conforming to the `Tool` protocol. The `Tool` protocol defines a name of the tool, and what it should show. Due to usage of **NavigationView**, there's a slight difference for MacOS, and iOS. The MacOS needs to to provide the selection binding for the navigation to work properly. 

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

eg.

```swift
struct ColorChangeTool: Tool {

    let name = "Color Change Tool"

    var content: any View {
        ColorChangeToolView()
    }
}
```


### 3. Creating your own View

Your custom tool might need a specific View which will be shown when conforming to the `Tool` protocol in the previous step. eg.

```swift
struct ColorChangeToolView: View {

    @State var isBlue: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            (isBlue ? Color.blue : Color.red)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Change color") { isBlue.toggle() }
        }
    }
}
```

### 4. Adding your tool to the list of tools

Once you're happy with the custom tool you created, you can append it to the `Configuration` struct when you're setting up **Sentinel**.

```swift
Sentinel.Configuration(
    trigger: Triggers.shake,
    tools: [
        UserDefaultsTool(),
        ColorChangeTool()
    ],
    preferences: []
)
```
