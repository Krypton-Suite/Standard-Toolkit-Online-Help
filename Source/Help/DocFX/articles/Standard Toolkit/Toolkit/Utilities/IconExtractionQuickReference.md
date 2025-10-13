# Icon Extraction API - Quick Reference

## One-Page Cheat Sheet

### 📦 Available Icon Sources

```csharp
imageres.dll    →  ExtractIconFromImageres()   // 300+ modern icons (Vista+)
shell32.dll     →  ExtractIconFromShell32()    // 300+ classic icons (Win95+)
ieframe.dll     →  ExtractIconFromIeFrame()    // 200+ browser icons (XP+)
moricons.dll    →  ExtractIconFromMoreIcons()  // 100+ legacy icons (Win95+)
compstui.dll    →  ExtractIconFromCompStui()   // 100+ printer icons (Win2K+)
setupapi.dll    →  ExtractIconFromSetupApi()   // 60+ hardware icons (Win2K+)
netshell.dll    →  ExtractIconFromNetShell()   // 40+ network icons (XP+)
```

---

### 🎯 Basic Usage

```csharp
// Extract icon from shell32.dll
var icon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

if (icon != null)
{
    myButton.Values.Image = icon.ToBitmap();
}
```

---

### 📏 Icon Sizes

```csharp
IconSize.Tiny          // 8×8
IconSize.ExtraSmall    // 16×16
IconSize.Small         // 20×20
IconSize.MediumSmall   // 24×24
IconSize.Medium        // 32×32  ⭐ Default
IconSize.Large         // 48×48
IconSize.ExtraLarge    // 64×64
IconSize.Jumbo         // 96×96
IconSize.ExtraJumbo    // 128×128
IconSize.Huge          // 256×256
```

---

### 🔑 Common Icon IDs

#### From Shell32.dll
```csharp
Shell32IconID.Folder              // 3   - Closed folder
Shell32IconID.FolderOpen          // 4   - Open folder
Shell32IconID.Computer            // 15  - Computer/PC
Shell32IconID.HardDrive           // 8   - Hard disk
Shell32IconID.Network             // 18  - Network
Shell32IconID.Printer             // 16  - Printer
Shell32IconID.RecycleBinEmpty     // 31  - Empty recycle bin
Shell32IconID.RecycleBinFull      // 32  - Full recycle bin
Shell32IconID.Search              // 22  - Search/Find
Shell32IconID.Help                // 23  - Help/Question
Shell32IconID.Run                 // 24  - Run/Execute
Shell32IconID.Delete              // 161 - Delete
Shell32IconID.Properties          // 165 - Properties
```

#### From Imageres.dll
```csharp
ImageresIconID.Shield             // 78  - UAC shield
ImageresIconID.Lock               // 48  - Lock/Security
ImageresIconID.User               // 51  - User account
ImageresIconID.Key                // 50  - Key/Password
```

#### From NetShell.dll
```csharp
NetShellIconID.NetworkConnection  // 0   - Network connection
NetShellIconID.WirelessNetwork    // 3   - WiFi
NetShellIconID.VpnConnection      // 8   - VPN
```

---

### 💡 Quick Examples

#### Extract by Enum
```csharp
var folder = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Large
);
```

#### Extract by Index
```csharp
var icon = GraphicsExtensions.ExtractIconFromShell32(16805, IconSize.Medium);
```

#### Extract from Any DLL
```csharp
var icon = GraphicsExtensions.ExtractIcon("mydll.dll", 42, largeIcon: true);
```

---

### ✅ Best Practices

```csharp
// ✅ GOOD: Check for null
var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
if (icon != null)
{
    myButton.Values.Image = icon.ToBitmap();
}

// ✅ GOOD: Cache frequently used icons
private Icon? _folderIcon;

public void Initialize()
{
    _folderIcon = GraphicsExtensions.ExtractIconFromShell32(
        (int)Shell32IconID.Folder, 
        IconSize.Medium
    );
}

// ✅ GOOD: Dispose when done
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        _folderIcon?.Dispose();
    }
    base.Dispose(disposing);
}
```

---

### ❌ Common Mistakes

```csharp
// ❌ BAD: Not checking for null
var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
myButton.Values.Image = icon.ToBitmap(); // NullReferenceException!

// ❌ BAD: Extracting every time instead of caching
for (int i = 0; i < 1000; i++)
{
    var icon = GraphicsExtensions.ExtractIconFromShell32(3, IconSize.Medium);
    // Use icon... (very inefficient!)
}

// ❌ BAD: Not disposing icons
for (int i = 0; i < 1000; i++)
{
    var icon = GraphicsExtensions.ExtractIconFromShell32(i, IconSize.Medium);
    // Forgot to dispose - memory leak!
}
```

---

### 🎨 Common Patterns

#### With Krypton Button
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

#### With Picture Box
```csharp
var icon = GraphicsExtensions.ExtractIconFromNetShell(
    (int)NetShellIconID.WirelessNetwork, 
    IconSize.ExtraLarge
);

if (icon != null)
{
    kryptonPictureBox1.Image = icon.ToBitmap();
}
```

#### With Image List
```csharp
var imageList = new ImageList { ImageSize = new Size(32, 32) };

var icons = new[]
{
    Shell32IconID.Folder,
    Shell32IconID.Computer,
    Shell32IconID.Network
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

treeView1.ImageList = imageList;
```

---

### 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| Returns `null` | Icon doesn't exist at that index, or DLL not found |
| Wrong size | Use different `IconSize` value |
| Blurry icon | Extract at exact display size, don't scale |
| Memory leak | Remember to dispose icons when done |
| Slow performance | Cache icons, don't extract repeatedly |
| Icon looks different on other Windows | Icons vary by Windows version - test on target OS |

---

### 📚 Full Documentation

- **API Reference**: [Icon Extraction API Reference](IconExtractionAPIReference.md)
- **User Guide**: [System Icons Comprehensive Guide](SystemIconsComprehensiveGuide.md)
- **Examples**: [Icon Extraction Example](IconExtractionExample.md)

---

### 🚀 Total Available Icons

```
imageres.dll      300+
shell32.dll       300+
ieframe.dll       200+
moricons.dll      100+
compstui.dll      100+
setupapi.dll       60+
netshell.dll       40+
─────────────────────
TOTAL:           1500+
```
