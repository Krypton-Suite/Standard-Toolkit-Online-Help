# Icon Extraction Feature - Documentation Index

Complete documentation for the Windows System Icon Extraction feature in Krypton Toolkit.

---

## 📚 Documentation Files

### For Developers

#### 1. [Icon Extraction API Reference](IconExtractionAPIReference.md) 
**Comprehensive API Documentation** ⭐ Primary developer reference

- Complete API reference for all methods
- Detailed parameter descriptions
- Return value documentation
- Code examples for every method
- Implementation details and internals
- Memory management guidelines
- Performance optimization strategies
- Extension guidelines for adding new DLL sources
- Platform compatibility matrix
- Error handling patterns

**Target Audience:** Developers integrating the icon extraction API  
**Length:** ~400 lines, comprehensive

---

#### 2. [Icon Extraction Quick Reference](IconExtractionQuickReference.md)
**Quick Reference Cheat Sheet** ⚡ Fast lookup

- One-page cheat sheet
- Common icon IDs and their indices
- All icon sizes with pixel dimensions
- Quick code examples
- Common patterns
- Best practices vs common mistakes
- Troubleshooting table

**Target Audience:** Developers needing quick reference  
**Length:** ~200 lines, concise

---

#### 3. [System Icons](SystemIcons.md)
**Feature Overview and Summary** 📋 High-level overview

- Feature summary and benefits
- List of all supported DLLs
- Files added/modified
- Build status
- API summary table
- Quick usage examples

**Target Audience:** Project managers, team leads, developers  
**Length:** ~260 lines, summary format

---

### For End Users

#### 4. [System Icons - Comprehensive Guide](SystemIconsComprehensiveGuide.md)
**Complete User Guide** 📖 Full user documentation

- Overview of all icon sources
- Quick start examples for each DLL
- Accessing undocumented icons
- Using icons in applications
- Icon categories by DLL
- Creating image lists
- Error handling best practices
- Performance tips
- Windows version compatibility

**Target Audience:** Application developers using Krypton Toolkit  
**Length:** ~380 lines, tutorial style

---

#### 5. [Icon Extraction Example](IconExtractionExample.md)
**Basic Usage Examples** 🎯 Getting started

- Simple usage examples
- Common imageres.dll icons
- Common shell32.dll icons
- Available icon sizes
- Error handling examples
- Complete working examples
- Advanced usage patterns

**Target Audience:** New users getting started  
**Length:** ~250 lines, example-focused

## 🗺️ Documentation Map by Use Case

### "I want to understand what this feature does"
1. Start with: [System Icons](SystemIcons.md)
2. Then read: [System Icons - Comprehensive Guide](SystemIconsComprehensiveGuide.md)

### "I want to integrate this into my app"
1. Start with: [Icon Extraction Example](IconExtractionExample.md)
2. Reference: [Icon Extraction Quick Reference](IconExtractionQuickReference.md)
3. Deep dive: [Icon Extraction API Reference](IconExtractionAPIReference.md)

### "I need a specific icon"
1. Check: [Icon Extraction Quick Reference](IconExtractionQuickReference.md) - Common icons section
2. Browse: Enum definitions in code or comprehensive guide

### "I want to extend this feature"
1. Read: [Icon Extraction API Reference](IconExtractionAPIReference.md) - Extension Guidelines section
2. Study: Existing implementation in source files

### "I have a problem"
1. Check: [Icon Extraction Quick Reference](IconExtractionQuickReference.md) - Troubleshooting section
2. Review: [Icon Extraction API Reference](IconExtractionAPIReference.md) - Error Handling section

---

## 📂 Source Code Files

### Core Implementation

| File | Location | Lines | Purpose |
|------|----------|-------|---------|
| `GraphicsExtensions.cs` | `Krypton.Toolkit/Utilities/` | 795 | Public API and extraction logic |
| `ImageNativeMethods.cs` | `Krypton.Toolkit/Utilities/` | 34 | P/Invoke declarations |
| `Definitions.cs` | `Krypton.Toolkit/General/` | 5193 | Icon ID enumerations |
| `PlatformInvoke.cs` | `Krypton.Toolkit/General/` | 5097 | Library path constants |

### Key Code Sections

**GraphicsExtensions.cs:**
- Lines 136-182: `ExtractIcon()` - Core extraction method
- Lines 364-390: `ExtractIconFromImageres()` methods
- Lines 689-706: `ExtractIconFromShell32()` methods
- Lines 708-791: Additional DLL extraction methods

**Definitions.cs:**
- Lines 3311-4362: `ImageresIconID` enum (~300 icons)
- Lines 4366-4843: `Shell32IconID` enum (~300 icons)
- Lines 4847-5131: Additional DLL enums

**PlatformInvoke.cs:**
- Lines 60-128: `Libraries` class with DLL constants

---

## 🎯 Quick Start

### Absolute Beginner
```csharp
// Extract a folder icon
var icon = GraphicsExtensions.ExtractIconFromShell32(
    (int)Shell32IconID.Folder, 
    IconSize.Medium
);

if (icon != null)
{
    myButton.Values.Image = icon.ToBitmap();
}
```

### Where to Learn More
2. Read [Icon Extraction Example](IconExtractionExample.md)
3. Refer to [Icon Extraction Quick Reference](IconExtractionQuickReference.md)

---

## 📊 Feature Statistics

- **Total Icons Available:** 1500+
- **Supported DLLs:** 7 (imageres, shell32, ieframe, moricons, compstui, setupapi, netshell)
- **Icon Sizes:** 10 standard sizes (8px to 256px)
- **Target Frameworks:** 6 (.NET Framework 4.7.2+, .NET 8-10)
- **Windows Support:** Windows 7 through Windows 11
- **Documentation Pages:** 6 comprehensive documents
- **Code Examples:** 50+ working examples

---

## 🔗 Related Resources

### Internal Links
- Main Krypton Toolkit documentation
- Control reference guides
- Theme system documentation

### External Resources
- [Windows Icon Resources](https://docs.microsoft.com/en-us/windows/win32/menurc/icons)
- [ExtractIconEx API Documentation](https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-extracticonexw)

---

## 🆘 Support

For questions or issues:
1. Check the [troubleshooting section](IconExtractionQuickReference.md#-troubleshooting)
2. Review the [API reference](IconExtractionAPIReference.md)
4. Consult the Krypton Toolkit repository

