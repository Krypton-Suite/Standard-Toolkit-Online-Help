# Administrator Suffix Feature for KryptonForm

## Overview
This feature adds the ability to display "(Administrator)" in the title bar of `KryptonForm` instances when the application is running with elevated privileges, similar to native Windows applications.

## Features
- **Automatic Detection**: Automatically detects if the application is running with administrator privileges
- **Global Configuration**: Centralized control through `KryptonManager` affects all `KryptonForm` instances
- **Localization Ready**: Uses `KryptonManager.Strings.GeneralStrings.Administrator` for the suffix text
- **Designer Support**: Full Visual Studio designer support with proper serialization
- **Runtime Updates**: Changes to the setting immediately update all open forms

## Usage

### Basic Usage
The feature is enabled by default. When your application runs with elevated privileges, all `KryptonForm` instances will automatically display "(Administrator)" in their title bars.

### Programmatic Control
```csharp
// Enable the administrator suffix feature
KryptonManager.UseAdministratorSuffix = true;

// Disable the administrator suffix feature
KryptonManager.UseAdministratorSuffix = false;

// Check current setting
bool isEnabled = KryptonManager.UseAdministratorSuffix;
```

### Designer Configuration
In the Visual Studio designer, you can configure the setting through the `KryptonManager` component:
1. Add a `KryptonManager` component to your form
2. Set the `ShowAdministratorSuffix` property to `true` or `false`

## Properties

### KryptonManager.ShowAdministratorSuffix (Static)
- **Type**: `bool`
- **Default**: `true`
- **Description**: Global setting that controls whether all `KryptonForm` instances should display the administrator suffix
- **Usage**: `KryptonManager.UseAdministratorSuffix = true;`

### KryptonManager.GlobalShowAdministratorSuffix (Instance)
- **Type**: `bool`
- **Default**: `true`
- **Description**: Designer-friendly instance property that mirrors the static `UseAdministratorSuffix` setting
- **Usage**: Set in Visual Studio designer or via `kryptonManager.ShowAdministratorSuffix = true;`

## Implementation Details

### Administrator Detection
The feature uses `WindowsPrincipal` and `WindowsIdentity.GetCurrent()` to check if the current process is running with `WindowsBuiltInRole.Administrator`.

### Title Bar Integration
The administrator suffix is appended to the form's title text through the `GetShortText()` method, which is part of the `IContentValues` interface used by Krypton's title bar rendering.

### Global Configuration
The setting is stored as a static field in `KryptonManager`, ensuring consistent behavior across all `KryptonForm` instances in the application.

```csharp
// Set globally for all forms
KryptonManager.UseAdministratorSuffix = true;
```

### Manual Testing Steps
1. Run the application normally - no "(Administrator)" suffix should appear
2. Run the application as Administrator - "(Administrator)" suffix should appear in the title bar
3. Toggle the `ShowAdministratorSuffix` setting - the title bar should update immediately

## Compatibility
- **Target Frameworks**: All supported .NET frameworks (`net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`)
- **Windows Versions**: Windows 7 and later
- **Krypton Toolkit**: Compatible with all Krypton Toolkit components

## Localization
The administrator suffix text is retrieved from `KryptonManager.Strings.GeneralStrings.Administrator`, making it fully localizable. The default English text is "(Administrator)".

## Performance Considerations
- Administrator detection is performed once per form instance
- Title bar updates are triggered only when the setting changes
- No performance impact during normal operation
