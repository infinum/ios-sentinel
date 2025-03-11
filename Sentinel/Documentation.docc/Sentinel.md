# ``Sentinel``

A toolshed for all of your debugging tools available on iOS, and MacOS.

## Overview

Sentinel is a debug tool which contains multiple debug tools with a single point of entry. The farmework contains a few debugging tools but you can always easily create your own. The implementation of custom debugging tools is easy, and there are no limits to how many you can add.

## Topics

### Essentials

- <doc:Setup>
- <doc:CustomTools>

### Initial setup
- ``Sentinel``
- ``Sentinel/Configuration``
- ``Triggers``
- ``SentinelTabBarView``

### Triggers
- ``NotificationTrigger``
- ``ScreenshotTrigger``
- ``ShakeTrigger``

### Predefined tools
- ``CustomInfoTool``
- ``PreferencesTool``
- ``UserDefaultsTool``
- ``ToolTable``
- ``TextEditingTool``

### Predefined items
- ``ToolTableItem``
- ``ToolTableSection``
- ``ToggleToolItem``
- ``PerformanceInfoItem``
- ``NavigationToolItem``

### Creating your custom tools
- ``Tool``
- ``CustomToolTableItem``

### Show sentinel in a different way
- ``SourceScreenProvider``
- ``Trigger``
- ``DefaultSourceScreenProvider``
- ``SourceScreenProviders``
