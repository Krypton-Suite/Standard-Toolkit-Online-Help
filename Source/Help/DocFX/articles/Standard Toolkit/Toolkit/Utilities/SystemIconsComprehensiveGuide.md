# Comprehensive Guide to Windows System Icon Extraction

The Krypton Toolkit now provides access to **1500+ Windows system icons** from multiple DLLs across the Windows operating system.

## Overview of Icon Sources

| DLL | Approx. Icons | Description | Enum | Method |
|-----|--------------|-------------|------|--------|
| **imageres.dll** | ~300 | Modern Windows icons (Vista+) | `ImageresIconID` | `ExtractIconFromImageres()` |
| **shell32.dll** | ~300 | Classic Windows shell icons | `Shell32IconID` | `ExtractIconFromShell32()` |
| **ieframe.dll** | ~200 | Internet Explorer & web icons | `IeFrameIconID` | `ExtractIconFromIeFrame()` |
| **moricons.dll** | ~100 | Miscellaneous system icons | `MoreIconsIconID` | `ExtractIconFromMoreIcons()` |
| **compstui.dll** | ~100 | Printer & device UI icons | `CompStuiIconID` | `ExtractIconFromCompStui()` |
| **setupapi.dll** | ~60 | Setup & device icons | `SetupApiIconID` | `ExtractIconFromSetupApi()` |
| **netshell.dll** | ~40 | Network connection icons | `NetShellIconID` | `ExtractIconFromNetShell()` |
| **TOTAL** | **~1500+** | Complete system icon coverage | | |

## Quick Start Examples

### 1. imageres.dll - Modern System Icons

```csharp
// Extract UAC shield
var shield = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Shield, 
    IconSize.Large
);

// Extract lock icon
var lock = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Lock, 
    IconSize.Medium
);
```

### 2. shell32.dll - Classic Shell Icons

```csharp
// Extract folder icon
var folder = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.ExtraLarge
);

// Extract recycle bin
var recycleBin = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.RecycleBinEmpty, 
    IconSize.Medium
);

// Extract computer icon
var computer = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Computer, 
    IconSize.Large
);
```

### 3. ieframe.dll - Internet Explorer Icons

```csharp
// Extract Internet Explorer icon
var ie = GraphicsExtensions.ExtractIconFromIeFrame(
    (int)IeFrameIconID.InternetExplorer, 
    IconSize.Medium
);

// Extract download icon
var download = GraphicsExtensions.ExtractIconFromIeFrame(
    (int)IeFrameIconID.Download, 
    IconSize.Small
);

// Extract secure connection icon
var ssl = GraphicsExtensions.ExtractIconFromIeFrame(
    (int)IeFrameIconID.SecureConnection, 
    IconSize.Medium
);
```

### 4. moricons.dll - Miscellaneous Icons

```csharp
// Extract MS-DOS icon
var dos = GraphicsExtensions.ExtractIconFromMoreIcons(
    (int)MoreIconsIconID.MsDosIcon, 
    IconSize.Medium
);

// Extract archive icon
var archive = GraphicsExtensions.ExtractIconFromMoreIcons(
    (int)MoreIconsIconID.ArchiveFile, 
    IconSize.Small
);
```

### 5. compstui.dll - Printer & Device Icons

```csharp
// Extract printer icon
var printer = GraphicsExtensions.ExtractIconFromCompStui(
    (int)CompStuiIconID.Printer, 
    IconSize.Large
);

// Extract color settings icon
var color = GraphicsExtensions.ExtractIconFromCompStui(
    (int)CompStuiIconID.Color, 
    IconSize.Medium
);
```

### 6. setupapi.dll - Hardware & Setup Icons

```csharp
// Extract hardware device icon
var device = GraphicsExtensions.ExtractIconFromSetupApi(
    (int)SetupApiIconID.HardwareDevice, 
    IconSize.Medium
);

// Extract USB device icon
var usb = GraphicsExtensions.ExtractIconFromSetupApi(
    (int)SetupApiIconID.UsbDevice, 
    IconSize.Large
);
```

### 7. netshell.dll - Network Icons

```csharp
// Extract network connection icon
var network = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.NetworkConnection, 
    IconSize.Medium
);

// Extract wireless network icon
var wifi = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.WirelessNetwork, 
    IconSize.Large
);

// Extract VPN icon
var vpn = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.VpnConnection, 
    IconSize.Medium
);
```

## Accessing Undocumented Icons

Each DLL may contain more icons than are documented in the enums. You can access any icon by index:

```csharp
// Access shell32.dll icon at index 250
var customIcon1 = GraphicsExtensions.ExtractIconFromShell32(250, IconSize.Medium);

// Access ieframe.dll icon at index 50
var customIcon2 = GraphicsExtensions.ExtractIconFromIeFrame(50, IconSize.Large);

// Access any DLL directly
var customIcon3 = GraphicsExtensions.ExtractIcon(@"C:\Windows\System32\mydll.dll", 10, largeIcon: true);
```

## Using Icons in Your Application

### With Krypton Buttons

```csharp
var icon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

if (icon != null)
{
    kryptonButton1.Values.Image = icon.ToBitmap();
    kryptonButton1.Values.Text = "Open Folder";
}
```

### With Picture Boxes

```csharp
var icon = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.WirelessNetwork, 
    IconSize.ExtraLarge
);

if (icon != null)
{
    pictureBox1.Image = icon.ToBitmap();
}
```

### Creating an Image List

```csharp
var imageList = new ImageList();
imageList.ImageSize = new Size(32, 32);

// Add icons from multiple sources
var icons = new[]
{
    GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Folder, IconSize.Medium),
    GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Computer, IconSize.Medium),
    GraphicsExtensions.ExtractIconFromNetShell((int)NetShellIconID.NetworkConnection, IconSize.Medium),
    GraphicsExtensions.ExtractIconFromIeFrame((int)IeFrameIconID.InternetExplorer, IconSize.Medium),
};

foreach (var icon in icons)
{
    if (icon != null)
    {
        imageList.Images.Add(icon.ToBitmap());
        icon.Dispose(); // Remember to dispose icons when done
    }
}

// Use with TreeView, ListView, etc.
treeView1.ImageList = imageList;
```

## Icon Categories by DLL

### imageres.dll Categories
- System security (shields, locks, keys)
- User accounts
- Files and folders
- Media (audio, video, images)
- Devices (computers, printers, cameras)
- Actions (copy, paste, delete)
- Applications and tools

### shell32.dll Categories
- Basic files and folders (0-4)
- Drives and storage (5-12)
- Network and computers (13-21)
- System utilities (22-44)
- Hardware and devices (45-99)
- Media and entertainment (100-119)
- Internet and communication (120-149)
- System folders (150-179)
- Actions and operations (160-189)
- User accounts (220-234)
- Windows features (240-269)

### ieframe.dll Categories
- Browser navigation
- Favorites and bookmarks
- Security and privacy
- Download/upload
- Web feeds
- Internet settings

### moricons.dll Categories
- Legacy DOS/Windows icons
- Document types
- Archive files
- Database icons
- Media files

### compstui.dll Categories
- Printer icons
- Print settings
- Device configuration
- UI components

### setupapi.dll Categories
- Hardware devices
- Device drivers
- System devices
- Installation icons

### netshell.dll Categories
- Network connections
- Wireless networks
- VPN connections
- Network settings
- Firewall icons

## Icon Size Reference

```csharp
IconSize.Tiny          // 8x8
IconSize.ExtraSmall    // 16x16
IconSize.Small         // 20x20
IconSize.MediumSmall   // 24x24
IconSize.Medium        // 32x32 (default)
IconSize.Large         // 48x48
IconSize.ExtraLarge    // 64x64
IconSize.Jumbo         // 96x96
IconSize.ExtraJumbo    // 128x128
IconSize.Huge          // 256x256
```

## Error Handling Best Practices

Always check for null returns as icons may not be available on all Windows versions:

```csharp
var icon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

if (icon != null)
{
    try
    {
        // Use the icon
        myButton.Values.Image = icon.ToBitmap();
    }
    finally
    {
        // Dispose when done
        icon.Dispose();
    }
}
else
{
    // Use a fallback icon or embedded resource
    myButton.Values.Image = Properties.Resources.FallbackIcon;
}
```

## Performance Tips

1. **Cache extracted icons** if you're using them multiple times
2. **Dispose of icons** when no longer needed to free resources
3. **Extract icons once** during initialization, not on every render
4. **Use appropriate sizes** - don't extract 256x256 if you only need 16x16

```csharp
// Cache icons at startup
private Icon? _folderIcon;

public void InitializeIcons()
{
    _folderIcon = GraphicsExtensions.ExtractIconFromShell32(
        (int)Shell32IconID.Folder, 
        IconSize.Medium
    );
}

public void Cleanup()
{
    _folderIcon?.Dispose();
}
```

## Windows Version Compatibility

- **imageres.dll**: Windows Vista and later
- **shell32.dll**: All Windows versions (95+)
- **ieframe.dll**: Windows XP and later (varies by IE version)
- **moricons.dll**: Windows 95 and later
- **compstui.dll**: Windows 2000 and later
- **setupapi.dll**: Windows 2000 and later
- **netshell.dll**: Windows XP and later

Icon appearance and availability may vary across Windows versions. Test on your target platforms.

## Complete Example Application

See `IconExtractionTest.cs` in the TestForm project for a complete working example demonstrating icon extraction from multiple DLLs.

## Summary

You now have access to **1500+ Windows system icons** across 7 different DLLs:
- ✅ imageres.dll (~300 icons)
- ✅ shell32.dll (~300 icons)
- ✅ ieframe.dll (~200 icons)
- ✅ moricons.dll (~100 icons)
- ✅ compstui.dll (~100 icons)
- ✅ setupapi.dll (~60 icons)
- ✅ netshell.dll (~40 icons)

Each DLL provides specialized icons for different system functions, giving you comprehensive access to the Windows icon library without needing to embed custom resources.

