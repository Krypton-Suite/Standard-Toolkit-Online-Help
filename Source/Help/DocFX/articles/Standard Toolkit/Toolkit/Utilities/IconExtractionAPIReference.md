# Icon Extraction API - Developer Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Public API Reference](#public-api-reference)
4. [Enumerations](#enumerations)
5. [Usage Patterns](#usage-patterns)
6. [Implementation Details](#implementation-details)
7. [Error Handling](#error-handling)
8. [Performance Considerations](#performance-considerations)
9. [Extension Guidelines](#extension-guidelines)
10. [Platform Support](#platform-support)

---

## Overview

The Icon Extraction API provides a comprehensive, type-safe interface for extracting icons from Windows system DLLs. This feature set includes:

- **1500+ icons** across 7 system DLLs
- **Type-safe enums** with IntelliSense support
- **Flexible sizing** with 10 standard sizes (8x8 to 256x256)
- **Error handling** with null returns for missing icons
- **Memory management** with automatic cleanup
- **Cross-version support** for Windows 7 through Windows 11

### Key Benefits

- **No embedded resources required** - Extract icons on-demand from Windows
- **Consistent UI** - Icons match the user's Windows version
- **Type safety** - Strongly typed enums prevent invalid icon IDs
- **Performance** - Direct P/Invoke with minimal overhead
- **Documentation** - Full XML documentation for all APIs

---

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Public API Layer                        │
│  GraphicsExtensions.ExtractIconFrom{Source}()            │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Internal Type-Safe Layer                    │
│  GraphicsExtensions.ExtractIconFrom{Source}Internal()    │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                Core Extraction Layer                     │
│  GraphicsExtensions.ExtractIcon()                        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              P/Invoke Native Layer                       │
│  ImageNativeMethods.ExtractIconEx()                      │
│  ImageNativeMethods.DestroyIcon()                        │
└──────────────────────────────────────────────────────────┘
```

### File Structure

| File | Location | Purpose |
|------|----------|---------|
| `GraphicsExtensions.cs` | `Krypton.Toolkit/Utilities/` | Public API and extraction logic |
| `ImageNativeMethods.cs` | `Krypton.Toolkit/Utilities/` | P/Invoke declarations |
| `Definitions.cs` | `Krypton.Toolkit/General/` | Icon ID enumerations |
| `PlatformInvoke.cs` | `Krypton.Toolkit/General/` | Library path constants |

---

## Public API Reference

### Core Extraction Methods

#### ExtractIcon

```csharp
public static Icon? ExtractIcon(
    string filePath, 
    int imageIndex, 
    bool largeIcon = true)
```

**Description:**  
Generic icon extraction method that can extract from any DLL file.

**Parameters:**
- `filePath` (string): Full or relative path to the DLL file (e.g., "shell32.dll" or "C:\Windows\System32\custom.dll")
- `imageIndex` (int): Zero-based index of the icon to extract
- `largeIcon` (bool, optional): If `true`, extracts large icons (>32x32); if `false`, extracts small icons (≤32x32). Default: `true`

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Exceptions:**
- `ArgumentNullException`: Thrown if `filePath` is null or empty

**Example:**
```csharp
// Extract icon #42 from shell32.dll as large icon
var icon = GraphicsExtensions.ExtractIcon("shell32.dll", 42, largeIcon: true);

// Extract from custom DLL
var customIcon = GraphicsExtensions.ExtractIcon(
    @"C:\MyApp\resources.dll", 
    10, 
    largeIcon: false
);
```

---

### Specialized Extraction Methods

#### ExtractIconFromImageres

```csharp
public static Icon? ExtractIconFromImageres(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from Windows' imageres.dll (modern system icons, Vista+).

**Parameters:**
- `iconId` (int): Icon identifier from `ImageresIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails or icon doesn't exist

**Example:**
```csharp
// Extract UAC shield icon at 48x48
var shield = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Shield, 
    IconSize.Large
);

// Extract lock icon at default size (32x32)
var lock = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Lock
);

// Access undocumented icon by index
var customIcon = GraphicsExtensions.ExtractIconFromImageres(150, IconSize.Small);
```

**Related Enum:** `ImageresIconID` (300+ values)

---

#### ExtractIconFromShell32

```csharp
public static Icon? ExtractIconFromShell32(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from Windows' shell32.dll (classic shell icons, available on all Windows versions).

**Parameters:**
- `iconId` (int): Icon identifier from `Shell32IconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
```csharp
// Extract folder icon
var folder = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.ExtraLarge  // 64x64
);

// Extract recycle bin
var recycleBin = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.RecycleBinEmpty, 
    IconSize.Medium
);

// Access high-index icon (like #16805)
var highIndexIcon = GraphicsExtensions.ExtractIconFromShell32(16805, IconSize.Large);
```

**Related Enum:** `Shell32IconID` (300+ values)

---

#### ExtractIconFromIeFrame

```csharp
public static Icon? ExtractIconFromIeFrame(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from Internet Explorer's ieframe.dll (web and browser icons).

**Parameters:**
- `iconId` (int): Icon identifier from `IeFrameIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
```csharp
// Extract Internet Explorer icon
var ie = GraphicsExtensions.ExtractIconFromIeFrame(
    (int)IeFrameIconID.InternetExplorer, 
    IconSize.Large
);

// Extract download icon
var download = GraphicsExtensions.ExtractIconFromIeFrame(
    (int)IeFrameIconID.Download, 
    IconSize.Small
);
```

**Related Enum:** `IeFrameIconID` (25+ values)

---

#### ExtractIconFromMoreIcons

```csharp
public static Icon? ExtractIconFromMoreIcons(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from moricons.dll (miscellaneous system icons including DOS/legacy icons).

**Parameters:**
- `iconId` (int): Icon identifier from `MoreIconsIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
```csharp
// Extract MS-DOS icon
var dos = GraphicsExtensions.ExtractIconFromMoreIcons(
    (int)MoreIconsIconID.MsDosIcon, 
    IconSize.Medium
);

// Extract archive file icon
var archive = GraphicsExtensions.ExtractIconFromMoreIcons(
    (int)MoreIconsIconID.ArchiveFile, 
    IconSize.Small
);
```

**Related Enum:** `MoreIconsIconID` (20+ values)

---

#### ExtractIconFromCompStui

```csharp
public static Icon? ExtractIconFromCompStui(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from compstui.dll (printer, device, and composite UI icons).

**Parameters:**
- `iconId` (int): Icon identifier from `CompStuiIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
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

**Related Enum:** `CompStuiIconID` (18+ values)

---

#### ExtractIconFromSetupApi

```csharp
public static Icon? ExtractIconFromSetupApi(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from setupapi.dll (hardware, device, and installation icons).

**Parameters:**
- `iconId` (int): Icon identifier from `SetupApiIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
```csharp
// Extract generic hardware device icon
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

**Related Enum:** `SetupApiIconID` (16+ values)

---

#### ExtractIconFromNetShell

```csharp
public static Icon? ExtractIconFromNetShell(
    int iconId, 
    IconSize iconSize = IconSize.Medium)
```

**Description:**  
Extracts icons from netshell.dll (network connection and network-related icons).

**Parameters:**
- `iconId` (int): Icon identifier from `NetShellIconID` enum or any valid index
- `iconSize` (IconSize, optional): Desired icon size. Default: `IconSize.Medium` (32x32)

**Returns:**
- `Icon?`: The extracted icon, or `null` if extraction fails

**Example:**
```csharp
// Extract wireless network icon
var wifi = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.WirelessNetwork, 
    IconSize.ExtraLarge
);

// Extract VPN connection icon
var vpn = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.VpnConnection, 
    IconSize.Medium
);
```

**Related Enum:** `NetShellIconID` (13+ values)

---

## Enumerations

### IconSize

```csharp
public enum IconSize : int
{
    Tiny = 8,           // 8x8 pixels
    ExtraSmall = 16,    // 16x16 pixels
    Small = 20,         // 20x20 pixels
    MediumSmall = 24,   // 24x24 pixels
    Medium = 32,        // 32x32 pixels (default)
    Large = 48,         // 48x48 pixels
    ExtraLarge = 64,    // 64x64 pixels
    Jumbo = 96,         // 96x96 pixels
    ExtraJumbo = 128,   // 128x128 pixels
    Huge = 256          // 256x256 pixels
}
```

**Usage:**
```csharp
var icon16 = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.ExtraSmall);
var icon32 = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
var icon256 = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Huge);
```

---

### Icon ID Enumerations

#### ImageresIconID

```csharp
public enum ImageresIconID : int
{
    // System Icons (Security, Users, Files, Folders)
    Shield = 78,
    ShieldAlt = 79,
    Lock = 48,
    Unlock = 49,
    Key = 50,
    User = 51,
    Users = 52,
    // ... 300+ total values
}
```

**Categories:**
- System Icons (Security, Users, Files, Folders)
- Application Icons (Software, Tools, Productivity)
- Media Icons (Audio, Video, Photography, Storage)
- Device Icons (Hardware, Computing, Peripherals)
- Network Icons (Internet, Connectivity, Protocols)
- Action Icons (Commands, Operations)
- Status Icons (Indicators, States)
- Navigation Icons (Directions, Controls)

**Total Values:** 300+

---

#### Shell32IconID

```csharp
public enum Shell32IconID : int
{
    // Basic File and Folder Icons (0-4)
    UnknownFile = 0,
    Document = 1,
    Application = 2,
    Folder = 3,
    FolderOpen = 4,
    
    // Drive and Storage Icons (5-12)
    Floppy525 = 5,
    Floppy35 = 6,
    RemovableDrive = 7,
    HardDrive = 8,
    // ... 300+ total values
}
```

**Categories:**
- Basic File and Folder Icons (0-4)
- Drive and Storage Icons (5-12)
- Network and Computer Icons (13-21)
- System Utility Icons (22-30)
- Recycle Bin and Desktop (31-44)
- System Icons (45-60)
- Hardware and Devices (61-99)
- Media and Entertainment (100-119)
- Internet and Communication (120-149)
- System Folders (150-179)
- Actions and Operations (160-189)
- File Types (180-219)
- User Accounts (220-234)
- Windows Features (240-269)
- Accessibility (270-289)
- Additional System Icons (290-305)

**Total Values:** 300+

---

#### Other Icon ID Enumerations

| Enum | Purpose | Values | Availability |
|------|---------|--------|--------------|
| `IeFrameIconID` | Internet Explorer/browser icons | 25+ | Windows 7+ |
| `MoreIconsIconID` | Miscellaneous/legacy icons | 20+ | Windows 7+ |
| `CompStuiIconID` | Printer/device UI icons | 18+ | Windows 7+ |
| `SetupApiIconID` | Hardware/setup icons | 16+ | Windows 7+ |
| `NetShellIconID` | Network connection icons | 13+ | Windows 7+ |

---

## Usage Patterns

### Basic Extraction Pattern

```csharp
public void LoadIcon()
{
    // Extract icon
    var icon = GraphicsExtensions.ExtractIconFromShell32(
        (int)Shell32IconID.Folder, 
        IconSize.Medium
    );
    
    // Check for null
    if (icon != null)
    {
        // Use the icon
        myButton.Values.Image = icon.ToBitmap();
    }
    else
    {
        // Handle missing icon
        myButton.Values.Image = Properties.Resources.FallbackIcon;
    }
}
```

---

### Icon Caching Pattern

```csharp
public class IconCache : IDisposable
{
    private readonly Dictionary<string, Icon> _cache = new();
    
    public Icon? GetIcon(string key, Func<Icon?> extractor)
    {
        if (_cache.TryGetValue(key, out var cached))
        {
            return cached;
        }
        
        var icon = extractor();
        if (icon != null)
        {
            _cache[key] = icon;
        }
        
        return icon;
    }
    
    public void Dispose()
    {
        foreach (var icon in _cache.Values)
        {
            icon?.Dispose();
        }
        _cache.Clear();
    }
}

// Usage
using var cache = new IconCache();

var folder = cache.GetIcon("folder", () => 
    GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Folder, IconSize.Medium)
);
```

---

### Lazy Loading Pattern

```csharp
public class MyForm : KryptonForm
{
    private Lazy<Icon?> _folderIcon;
    
    public MyForm()
    {
        InitializeComponent();
        
        _folderIcon = new Lazy<Icon?>(() => 
            GraphicsExtensions.ExtractIconFromShell32(
                (int)Shell32IconID.Folder, 
                IconSize.Medium
            )
        );
    }
    
    private void OnButtonClick(object sender, EventArgs e)
    {
        if (_folderIcon.Value != null)
        {
            myButton.Values.Image = _folderIcon.Value.ToBitmap();
        }
    }
    
    protected override void Dispose(bool disposing)
    {
        if (disposing && _folderIcon.IsValueCreated)
        {
            _folderIcon.Value?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

---

### Batch Extraction Pattern

```csharp
public Dictionary<string, Icon?> LoadIconSet()
{
    var icons = new Dictionary<string, Icon?>();
    
    var iconDefinitions = new[]
    {
        ("folder", Shell32IconID.Folder),
        ("computer", Shell32IconID.Computer),
        ("network", Shell32IconID.Network),
        ("printer", Shell32IconID.Printer)
    };
    
    foreach (var (name, iconId) in iconDefinitions)
    {
        icons[name] = GraphicsExtensions.ExtractIconFromShell32(
            (int)iconId, 
            IconSize.Medium
        );
    }
    
    return icons;
}
```

---

### Image List Population Pattern

```csharp
public ImageList CreateSystemIconList()
{
    var imageList = new ImageList
    {
        ImageSize = new Size(32, 32),
        ColorDepth = ColorDepth.Depth32Bit
    };
    
    var iconIds = new[]
    {
        Shell32IconID.Folder,
        Shell32IconID.Computer,
        Shell32IconID.Network,
        Shell32IconID.HardDrive
    };
    
    foreach (var iconId in iconIds)
    {
        var icon = GraphicsExtensions.ExtractIconFromShell32(
            (int)iconId, 
            IconSize.Medium
        );
        
        if (icon != null)
        {
            imageList.Images.Add(icon.ToBitmap());
        }
    }
    
    return imageList;
}
```

---

## Implementation Details

### Memory Management

The extraction API handles memory management automatically:

1. **Icon Handle Allocation**: Windows API allocates icon handles via `ExtractIconEx`
2. **Icon Cloning**: Icons are cloned to create managed copies
3. **Handle Cleanup**: Original handles are destroyed in `finally` block
4. **Managed Icon**: Returned icon is a managed .NET `Icon` object

**Code Flow:**
```csharp
var hIconEx = new IntPtr[] { IntPtr.Zero };
try
{
    // Extract icon (allocates handle)
    ImageNativeMethods.ExtractIconEx(filePath, -imageIndex, hIconEx, null, 1);
    
    // Clone to managed icon
    Icon? extractedIcon = Icon.FromHandle(hIconEx[0]).Clone() as Icon;
    return extractedIcon;
}
finally
{
    // Always destroy handle
    if (hIconEx[0] != IntPtr.Zero)
    {
        ImageNativeMethods.DestroyIcon(hIconEx[0]);
    }
}
```

**Developer Responsibility:**
- The API handles Windows handle cleanup automatically
- Developers should dispose returned `Icon` objects when done
- Use `using` statements or `Dispose()` calls for proper cleanup

---

### Icon Index Handling

The Windows `ExtractIconEx` API uses **negative indices** for extraction:

```csharp
// User specifies positive index
int userIndex = 42;

// API uses negative index for extraction
int apiIndex = -userIndex;  // -42

// Call Windows API
ExtractIconEx("shell32.dll", -42, hIconEx, null, 1);
```

This convention tells Windows to extract the icon rather than just query its availability.

---

### Size Selection Logic

The API automatically determines large vs. small icon extraction:

```csharp
var size = GetSizeFromIconSize(iconSize);  // Convert enum to pixel size
var isLargeIcon = size.Width > 32;         // Threshold at 32 pixels

if (isLargeIcon)
{
    // Extract from large icon set (typically 32x32 to 256x256)
    ExtractIconEx(filePath, -index, hIconEx, null, 1);
}
else
{
    // Extract from small icon set (typically 16x16)
    ExtractIconEx(filePath, -index, null, hIconEx, 1);
}
```

Windows DLLs typically contain two icon sets:
- **Small icons**: 16x16 (sometimes 20x20 or 24x24)
- **Large icons**: 32x32, 48x48, 64x64, 256x256

---

### Type Safety Mechanism

The API provides two-layer type safety:

1. **Public Layer** (accepts `int`):
   ```csharp
   public static Icon? ExtractIconFromShell32(int iconId, IconSize iconSize)
   ```
   - Allows accessing any index, including undocumented ones
   - Flexible for dynamic scenarios

2. **Internal Layer** (accepts enum):
   ```csharp
   internal static Icon? ExtractIconFromShell32Internal(Shell32IconID iconId, IconSize iconSize)
   ```
   - Provides type safety when using enums
   - Enables IntelliSense and compile-time checking

**Usage:**
```csharp
// Type-safe with enum
var icon1 = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder,  // Compile-time checked
    IconSize.Medium
);

// Flexible with int
var icon2 = GraphicsExtensions.ExtractIconFromShell32(
    16805,  // Access any index
    IconSize.Medium
);
```

---

## Error Handling

### Return Value Pattern

All extraction methods use **nullable return types** (`Icon?`) to indicate success or failure:

```csharp
var icon = GraphicsExtensions.ExtractIconFromShell32(42, IconSize.Medium);

if (icon != null)
{
    // Success: icon was extracted
}
else
{
    // Failure: icon not found or extraction error
}
```

---

### Exception Handling

The API **catches and logs exceptions** internally, returning `null` instead of throwing:

```csharp
try
{
    // Attempt extraction
    ExtractIconEx(filePath, -imageIndex, hIconEx, null, 1);
    // ...
}
catch (Exception ex)
{
    // Log exception
    KryptonExceptionHandler.CaptureException(ex, showStackTrace: DEFAULT_USE_STACK_TRACE);
    
    // Return null instead of throwing
    return null;
}
```

**Exception:** Only `ArgumentNullException` is thrown if `filePath` is null/empty in the base `ExtractIcon` method.

---

### Failure Scenarios

Icons may fail to extract for several reasons:

1. **Icon doesn't exist**: The specified index has no icon
2. **DLL not found**: The system DLL is missing (rare, except on older Windows)
3. **Invalid index**: Index is out of range for the DLL
4. **Insufficient permissions**: Rare, but possible in restricted environments
5. **Corrupted DLL**: System file corruption (very rare)

**Best Practice:**
```csharp
public void LoadIconSafe()
{
    var icon = GraphicsExtensions.ExtractIconFromShell32(
        (int)Shell32IconID.Folder, 
        IconSize.Medium
    );
    
    if (icon != null)
    {
        try
        {
            myButton.Values.Image = icon.ToBitmap();
        }
        catch (Exception ex)
        {
            // Handle conversion errors
            Log.Error($"Failed to convert icon: {ex.Message}");
            myButton.Values.Image = GetFallbackIcon();
        }
    }
    else
    {
        // Use fallback for missing icon
        myButton.Values.Image = GetFallbackIcon();
    }
}
```

---

## Performance Considerations

### Extraction Performance

Icon extraction is relatively fast but involves P/Invoke overhead:

- **Single extraction**: ~0.5-2ms per icon (depends on system)
- **Cached extraction**: ~0.001ms (dictionary lookup)
- **File I/O**: First access may load DLL into memory

**Benchmarks** (typical modern PC):
```
ExtractIcon (cold):     ~2.0ms
ExtractIcon (warm):     ~0.5ms
ExtractIcon (cached):   ~0.001ms
Icon.ToBitmap():        ~0.1ms
```

---

### Optimization Strategies

#### 1. **Cache Extracted Icons**

```csharp
// Inefficient: Extract every time
for (int i = 0; i < 100; i++)
{
    var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
    // Use icon...
    icon?.Dispose();
}

// Efficient: Extract once, cache
var folderIcon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
for (int i = 0; i < 100; i++)
{
    // Reuse cached icon...
}
folderIcon?.Dispose();
```

#### 2. **Lazy Load Icons**

```csharp
// Load icons only when needed
private Lazy<Icon?> _icon = new Lazy<Icon?>(() => 
    GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium)
);

public void ShowIcon()
{
    if (_icon.Value != null)
    {
        pictureBox.Image = _icon.Value.ToBitmap();
    }
}
```

#### 3. **Extract Appropriate Sizes**

```csharp
// Inefficient: Extract huge icon for small display
var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Huge);  // 256x256
pictureBox.Size = new Size(16, 16);  // Display at 16x16 (wasteful)

// Efficient: Extract matching size
var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.ExtraSmall);  // 16x16
pictureBox.Size = new Size(16, 16);
```

#### 4. **Batch Extractions**

```csharp
// Load all needed icons at startup
public void InitializeIcons()
{
    _icons = new Dictionary<string, Icon?>
    {
        ["folder"] = GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Folder, IconSize.Medium),
        ["computer"] = GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Computer, IconSize.Medium),
        ["network"] = GraphicsExtensions.ExtractIconFromShell32((int)Shell32IconID.Network, IconSize.Medium),
    };
}
```

---

### Memory Considerations

Each extracted icon consumes memory:

- **16x16 icon**: ~1-2 KB
- **32x32 icon**: ~4-8 KB
- **48x48 icon**: ~9-18 KB
- **256x256 icon**: ~256 KB (uncompressed)

**Guidelines:**
- Cache only icons you use frequently
- Dispose icons when no longer needed
- Consider weak references for large icon caches
- Monitor memory usage with 100+ cached icons

---

## Extension Guidelines

### Adding New DLL Sources

To add support for additional system DLLs:

1. **Add Library Constant** (`PlatformInvoke.cs`):
```csharp
/// <summary>My Custom DLL - contains custom icons</summary>
public const string MyCustomDll = "mycustom.dll";
```

2. **Create Icon ID Enum** (`Definitions.cs`):
```csharp
/// <summary>Icon resource IDs found in mycustom.dll</summary>
public enum MyCustomDllIconID : int
{
    /// <summary>First icon</summary>
    FirstIcon = 0,
    /// <summary>Second icon</summary>
    SecondIcon = 1,
    // ... more icons
}
```

3. **Add Extraction Methods** (`GraphicsExtensions.cs`):
```csharp
/// <summary>Extracts an icon from mycustom.dll</summary>
public static Icon? ExtractIconFromMyCustomDll(int iconId, IconSize iconSize = IconSize.Medium) 
    => ExtractIconFromMyCustomDllInternal((MyCustomDllIconID)iconId, iconSize);

internal static Icon? ExtractIconFromMyCustomDllInternal(MyCustomDllIconID iconId, IconSize iconSize = IconSize.Medium)
{
    var size = GetSizeFromIconSize(iconSize);
    var isLargeIcon = size.Width > 32;
    return ExtractIcon(Libraries.MyCustomDll, (int)iconId, isLargeIcon);
}
```

4. **Add XML Documentation**: Document all enum values and methods

5. **Add Tests**: Create test form examples

---

### Custom Icon Extraction Wrapper

Create custom wrappers for specialized needs:

```csharp
public static class CustomIconExtensions
{
    /// <summary>Extracts UAC shield icon with fallback</summary>
    public static Image GetUACShieldOrFallback(IconSize size = IconSize.Medium)
    {
        // Try imageres.dll
        var icon = GraphicsExtensions.ExtractIconFromImageres(
            (int)ImageresIconID.Shield, 
            size
        );
        
        if (icon != null)
        {
            return icon.ToBitmap();
        }
        
        // Try shell32.dll fallback
        icon = GraphicsExtensions.ExtractIconFromShell32(
            (int)Shell32IconID.Security, 
            size
        );
        
        if (icon != null)
        {
            return icon.ToBitmap();
        }
        
        // Use embedded resource as last resort
        return Properties.Resources.UACShieldFallback;
    }
}
```

---

## Platform Support

### Windows Version Compatibility

| DLL            | Windows 7, 8 and 8.1 | Windows 10+     |
|----------------|------------|-----------------|
| `shell32.dll`  | ✅          | ✅               |
| `moricons.dll` | ✅          | ✅               |
| `ieframe.dll`  | ✅          | ⚠️ (deprecated) |
| `imageres.dll` | ✅          | ✅               |
| `compstui.dll` | ✅          | ✅               |
| `setupapi.dll` | ✅          | ✅               |
| `netshell.dll` | ✅          | ✅               |

**Notes:**
- ✅ = Fully supported
- ⚠️ = Available but may be deprecated
- ❌ = Not available

---

### .NET Framework Support

The API supports all Krypton Toolkit target frameworks:

- ✅ .NET Framework 4.7.2
- ✅ .NET Framework 4.8
- ✅ .NET Framework 4.8.1
- ✅ .NET 8.0-windows
- ✅ .NET 9.0-windows
- ✅ .NET 10.0-windows

**Requirements:**
- Windows operating system (P/Invoke to Windows APIs)
- `System.Drawing.Common` (for `Icon` and `Bitmap` classes)

---

### Icon Appearance Variations

Icon appearance may vary across Windows versions:

| Windows Version | Icon Style | Example DLL |
|-----------------|-----------|-------------|
| Windows 7 | Glossy, Aero | imageres.dll |
| Windows 8/8.1 | Flat, Modern | imageres.dll |
| Windows 10 | Fluent, simplified | imageres.dll |
| Windows 11 | Rounded, colorful | imageres.dll |

**Best Practice:** Test icon appearance on your target Windows versions.

---

## API Summary

### Quick Reference Table

| Method | DLL | Icon Count | Min Windows | Common Use Cases |
|--------|-----|-----------|-------------|------------------|
| `ExtractIconFromImageres()` | imageres.dll | 300+ | Vista | Modern UI, security icons, system icons |
| `ExtractIconFromShell32()` | shell32.dll | 300+ | 95 | Files, folders, drives, classic Windows icons |
| `ExtractIconFromIeFrame()` | ieframe.dll | 200+ | XP | Web, browser, internet icons |
| `ExtractIconFromMoreIcons()` | moricons.dll | 100+ | 95 | Legacy, DOS, miscellaneous icons |
| `ExtractIconFromCompStui()` | compstui.dll | 100+ | 2000 | Printers, devices, UI components |
| `ExtractIconFromSetupApi()` | setupapi.dll | 60+ | 2000 | Hardware, drivers, installation |
| `ExtractIconFromNetShell()` | netshell.dll | 40+ | XP | Networks, connections, VPN |
| `ExtractIcon()` | Any DLL | Varies | 95 | Custom DLLs, direct access |

---

## See Also

- [System Icons](SystemIcons.md) - Feature overview
- [System Icons Comprehensive Guide](SystemIconsComprehensiveGuide.md) - User guide
- [Icon Extraction Example](IconExtractionExample.md) - Quick examples

