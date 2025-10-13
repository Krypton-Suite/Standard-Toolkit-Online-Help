# Icon Extraction from System DLLs

This document demonstrates how to extract icons from Windows system DLLs (`imageres.dll` and `shell32.dll`) using the Krypton Toolkit.

## Overview

The Krypton Toolkit provides easy-to-use methods for extracting icons from two important Windows system DLLs:

- **imageres.dll**: Modern Windows icons (Vista and later)
- **shell32.dll**: Classic Windows icons (available since early Windows versions)

## Usage Examples

### Extracting Icons from imageres.dll

```csharp
using Krypton.Toolkit;

// Extract a UAC shield icon
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Shield, 
    IconSize.Medium
);

// Extract a lock icon
var lockIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Lock, 
    IconSize.Large
);

// Extract a user icon with small size
var userIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.User, 
    IconSize.Small
);

// Use the icon with a button
if (shieldIcon != null)
{
    myButton.Values.Image = shieldIcon.ToBitmap();
}
```

### Extracting Icons from shell32.dll

```csharp
using Krypton.Toolkit;

// Extract a folder icon
var folderIcon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

// Extract a computer icon
var computerIcon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Computer, 
    IconSize.Large
);

// Extract a network icon
var networkIcon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Network, 
    IconSize.ExtraLarge
);

// Extract a recycle bin icon
var recycleBinIcon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.RecycleBinEmpty, 
    IconSize.Small
);

// Use the icon with a picture box
if (folderIcon != null)
{
    myPictureBox.Image = folderIcon.ToBitmap();
}
```

## Available Icon Sizes

The `IconSize` enum provides standard sizes:

| Size | Dimensions |
|------|------------|
| `IconSize.Tiny` | 8x8 |
| `IconSize.ExtraSmall` | 16x16 |
| `IconSize.Small` | 20x20 |
| `IconSize.MediumSmall` | 24x24 |
| `IconSize.Medium` | 32x32 |
| `IconSize.Large` | 48x48 |
| `IconSize.ExtraLarge` | 64x64 |
| `IconSize.Jumbo` | 96x96 |
| `IconSize.ExtraJumbo` | 128x128 |
| `IconSize.Huge` | 256x256 |

## Common imageres.dll Icons

Some commonly used icons from imageres.dll:

- `ImageresIconID.Shield` - UAC elevation shield
- `ImageresIconID.Lock` - Security/locked state
- `ImageresIconID.Unlock` - Unlocked state
- `ImageresIconID.Key` - Authentication/access
- `ImageresIconID.User` - User account
- `ImageresIconID.Users` - Multiple users
- `ImageresIconID.Computer` - Computer/workstation
- `ImageresIconID.Network` - Network connection
- `ImageresIconID.Folder` - Generic folder
- `ImageresIconID.File` - Generic file

## Common shell32.dll Icons

The `Shell32IconID` enum now contains **300+ icons** organized into categories:

### Basic Icons
- `Shell32IconID.Folder` - Folder (closed)
- `Shell32IconID.FolderOpen` - Folder (open)
- `Shell32IconID.Document` - Default document
- `Shell32IconID.Application` - Executable/Application

### Storage and Drives
- `Shell32IconID.HardDrive` - Hard disk drive
- `Shell32IconID.CDRom` - CD/DVD drive
- `Shell32IconID.RemovableDrive` - Removable drive
- `Shell32IconID.NetworkDrive` - Network drive
- `Shell32IconID.Floppy35` - 3.5" floppy disk

### Network and Computers
- `Shell32IconID.Computer` - Computer/workstation
- `Shell32IconID.Network` - Network
- `Shell32IconID.Server` - Server
- `Shell32IconID.NetworkNeighborhood` - Network neighborhood

### System Utilities
- `Shell32IconID.Search` - Search/find
- `Shell32IconID.RecycleBinEmpty` - Empty recycle bin
- `Shell32IconID.RecycleBinFull` - Full recycle bin
- `Shell32IconID.ControlPanel` - Control Panel
- `Shell32IconID.Printer` - Printer
- `Shell32IconID.Help` - Help/Question mark
- `Shell32IconID.Run` - Run/Execute

### Actions
- `Shell32IconID.Cut` - Cut (scissors)
- `Shell32IconID.Copy` - Copy
- `Shell32IconID.Paste` - Paste
- `Shell32IconID.Delete` - Delete
- `Shell32IconID.Properties` - Properties
- `Shell32IconID.Print` - Print

### Hardware & Devices
- `Shell32IconID.Keyboard` - Keyboard
- `Shell32IconID.Mouse` - Mouse
- `Shell32IconID.Monitor` - Monitor
- `Shell32IconID.Speakers` - Speakers
- `Shell32IconID.Camera` - Camera
- `Shell32IconID.Scanner` - Scanner
- `Shell32IconID.Laptop` - Laptop

### User Accounts
- `Shell32IconID.UserAccount` - User account
- `Shell32IconID.Administrator` - Administrator
- `Shell32IconID.Guest` - Guest
- `Shell32IconID.UserGroup` - User group

### Special Folders
- `Shell32IconID.MyDocuments` - My Documents
- `Shell32IconID.MyPictures` - My Pictures
- `Shell32IconID.MyMusic` - My Music
- `Shell32IconID.MyVideos` - My Videos
- `Shell32IconID.Recent` - Recent documents

### Windows Features
- `Shell32IconID.WindowsUpdate` - Windows Update
- `Shell32IconID.WindowsDefender` - Windows Defender
- `Shell32IconID.WindowsFirewall` - Windows Firewall
- `Shell32IconID.DeviceManager` - Device Manager

**Total: 300+ icons across 15 categories** - See the `Shell32IconID` enum for the complete list!

## Error Handling

Both extraction methods return `null` if the icon cannot be extracted. Always check for null before using:

```csharp
var icon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

if (icon != null)
{
    // Use the icon
    myButton.Values.Image = icon.ToBitmap();
}
else
{
    // Handle the case where extraction failed
    // Use a fallback icon or show an error message
}
```

## Complete Example

See `IconExtractionTest.cs` in the TestForm project for a complete working example that demonstrates extracting and displaying icons from both DLLs.

## Notes

- Icon availability may vary across different Windows versions
- shell32.dll contains hundreds of icons (indices 0-300+)
- imageres.dll is available on Windows Vista and later
- shell32.dll icons work on all Windows versions
- For resource-constrained scenarios, consider caching extracted icons
- Remember to dispose of Icon objects when done to free resources

## Advanced Usage

### Using with Krypton Buttons

```csharp
// Add a shield icon to a Krypton button
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)ImageresIconID.Shield, 
    IconSize.Medium
);

if (shieldIcon != null)
{
    kryptonButton1.Values.Image = shieldIcon.ToBitmap();
    kryptonButton1.Values.Text = "Run as Administrator";
}
```

### Creating Image Lists

```csharp
// Create an image list with shell32 icons
var imageList = new ImageList();
imageList.ImageSize = new Size(32, 32);

var icons = new[]
{
    Shell32IconID.Folder,
    Shell32IconID.Computer,
    Shell32IconID.Network,
    Shell32IconID.Printer
};

foreach (var iconId in icons)
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

// Use with TreeView, ListView, etc.
treeView1.ImageList = imageList;
```

## See Also

- `ImageresIconID` enum - Full list of imageres.dll icon IDs
- `Shell32IconID` enum - Full list of shell32.dll icon IDs  
- `GraphicsExtensions` class - Icon extraction methods
- `IconSize` enum - Standard icon sizes

