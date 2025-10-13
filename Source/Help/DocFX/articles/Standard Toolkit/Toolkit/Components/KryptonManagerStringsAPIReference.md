# KryptonManager.Strings API Reference

## Overview

This document provides a complete API reference for the `KryptonManager.Strings` localization system in the Krypton Toolkit. It covers all string categories, properties, methods, and technical implementation details.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit.dll  
**Root Class:** `KryptonGlobalToolkitStrings`

## Table of Contents

1. [Core API](#core-api)
2. [General String Categories](#general-string-categories)
3. [Component-Specific String Categories](#component-specific-string-categories)
4. [Style Converter String Categories](#style-converter-string-categories)
5. [Color String Categories](#color-string-categories)
6. [API Patterns and Conventions](#api-patterns-and-conventions)
7. [Technical Implementation](#technical-implementation)

---

## Core API

### KryptonManager.Strings

```csharp
public static class KryptonManager
{
    public static KryptonGlobalToolkitStrings Strings { get; }
}
```

**Description:** Static property providing access to the global string management system.

**Access Level:** Public  
**Thread Safety:** This property is thread-safe for reading. Modifications should be performed on the UI thread.

**Example:**
```csharp
var strings = KryptonManager.Strings;
string okText = strings.GeneralStrings.OK;
```

### KryptonGlobalToolkitStrings Class

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class KryptonGlobalToolkitStrings : GlobalId
```

**Description:** Container class that provides access to all string categories used throughout the Krypton Toolkit.

**Inheritance:** `GlobalId`  
**Type Converter:** `ExpandableObjectConverter` (enables designer support)

#### Properties

All string category properties follow this pattern:

| Property | Type | Description | Access |
|----------|------|-------------|--------|
| `GeneralStrings` | `GeneralToolkitStrings` | Common button and UI strings | `KryptonManager.Strings.GeneralStrings` |
| `CustomStrings` | `CustomToolkitStrings` | Custom action and navigation strings | `KryptonManager.Strings.CustomStrings` |
| `RibbonStrings` | `GeneralRibbonStrings` | Ribbon component strings | `KryptonManager.Strings.RibbonStrings` |
| `AboutBoxStrings` | `KryptonAboutBoxStrings` | About box label strings | `KryptonManager.Strings.AboutBoxStrings` |
| `ToastNotificationStrings` | `KryptonToastNotificationStrings` | Toast notification strings | `KryptonManager.Strings.ToastNotificationStrings` |
| `ScrollBarStrings` | `KryptonScrollBarStrings` | Scroll bar strings | `KryptonManager.Strings.ScrollBarStrings` |
| `OutlookGridStrings` | `KryptonOutlookGridStrings` | Outlook grid strings | `KryptonManager.Strings.OutlookGridStrings` |
| `SystemMenuStrings` | `SystemMenuStrings` | Win32 system menu strings | `KryptonManager.Strings.SystemMenuStrings` |
| `ToolBarStrings` | `IntegratedToolBarStrings` | Toolbar strings | `KryptonManager.Strings.ToolBarStrings` |
| `ColorStrings` | `GlobalColorStrings` | Color name strings | `KryptonManager.Strings.ColorStrings` |

#### Methods

##### Reset()
```csharp
public void Reset()
```

**Description:** Resets all string categories to their default English values.

**Example:**
```csharp
// Reset all strings to default
KryptonManager.Strings.Reset();
```

#### Instance Properties

##### IsDefault
```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool IsDefault { get; }
```

**Description:** Returns `true` if all string categories contain only default values; otherwise `false`.

**Example:**
```csharp
if (KryptonManager.Strings.IsDefault)
{
    Console.WriteLine("All strings are at default values");
}
```

---

## General String Categories

### GeneralToolkitStrings

**Access:** `KryptonManager.Strings.GeneralStrings`  
**Type:** `GeneralToolkitStrings`  
**Purpose:** Common button and message box strings used throughout the toolkit

#### Class Definition

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class GeneralToolkitStrings : GlobalId
```

#### Properties

##### OK
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("OK string used for message box buttons.")]
[DefaultValue("O&K")]
[RefreshProperties(RefreshProperties.All)]
public string OK { get; set; }
```

**Default Value:** `"O&K"`  
**Accelerator Key:** K (Alt+K)  
**Used In:** KryptonMessageBox, button controls

**Example:**
```csharp
// Spanish
KryptonManager.Strings.GeneralStrings.OK = "&Aceptar"; // Alt+A
```

##### Cancel
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Cancel string used for message box buttons.")]
[DefaultValue("Cance&l")]
[RefreshProperties(RefreshProperties.All)]
public string Cancel { get; set; }
```

**Default Value:** `"Cance&l"`  
**Accelerator Key:** L (Alt+L)  
**Used In:** KryptonMessageBox, dialog controls

##### Yes
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Yes string used for message box buttons.")]
[DefaultValue("&Yes")]
[RefreshProperties(RefreshProperties.All)]
public string Yes { get; set; }
```

**Default Value:** `"&Yes"`  
**Accelerator Key:** Y (Alt+Y)  
**Used In:** KryptonMessageBox with Yes/No buttons

##### No
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("No string used for message box buttons.")]
[DefaultValue("N&o")]
[RefreshProperties(RefreshProperties.All)]
public string No { get; set; }
```

**Default Value:** `"N&o"`  
**Accelerator Key:** O (Alt+O)  
**Used In:** KryptonMessageBox with Yes/No buttons

##### Abort
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Abort string used for message box buttons.")]
[DefaultValue("A&bort")]
[RefreshProperties(RefreshProperties.All)]
public string Abort { get; set; }
```

**Default Value:** `"A&bort"`  
**Accelerator Key:** B (Alt+B)  
**Used In:** KryptonMessageBox with Abort/Retry/Ignore buttons

##### Retry
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Retry string used for message box buttons.")]
[DefaultValue("Ret&ry")]
[RefreshProperties(RefreshProperties.All)]
public string Retry { get; set; }
```

**Default Value:** `"Ret&ry"`  
**Accelerator Key:** R (Alt+R)  
**Used In:** KryptonMessageBox with retry operations

##### Ignore
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Ignore string used for message box buttons.")]
[DefaultValue("I&gnore")]
[RefreshProperties(RefreshProperties.All)]
public string Ignore { get; set; }
```

**Default Value:** `"I&gnore"`  
**Accelerator Key:** G (Alt+G)  
**Used In:** KryptonMessageBox with Abort/Retry/Ignore buttons

##### Close
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Close string used for message box buttons.")]
[DefaultValue("Clo&se")]
[RefreshProperties(RefreshProperties.All)]
public string Close { get; set; }
```

**Default Value:** `"Clo&se"`  
**Accelerator Key:** S (Alt+S)  
**Used In:** Dialogs, forms, and close operations

##### Today
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Today string used for calendars.")]
[DefaultValue("&Today")]
[RefreshProperties(RefreshProperties.All)]
public string Today { get; set; }
```

**Default Value:** `"&Today"`  
**Accelerator Key:** T (Alt+T)  
**Used In:** KryptonMonthCalendar, date picker controls

##### Help
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Help string used for Message Box Buttons.")]
[DefaultValue("H&elp")]
[RefreshProperties(RefreshProperties.All)]
public string Help { get; set; }
```

**Default Value:** `"H&elp"`  
**Accelerator Key:** E (Alt+E)  
**Used In:** KryptonMessageBox with Help button

##### Continue
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Continue string used for Message Box Buttons.")]
[DefaultValue("Co&ntinue")]
public string Continue { get; set; }
```

**Default Value:** `"Co&ntinue"`  
**Accelerator Key:** N (Alt+N)  
**Used In:** KryptonMessageBox (requires .NET 6 or newer)

##### TryAgain
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Try Again string used for Message Box Buttons.")]
[DefaultValue("Try Aga&in")]
public string TryAgain { get; set; }
```

**Default Value:** `"Try Aga&in"`  
**Accelerator Key:** I (Alt+I)  
**Used In:** KryptonMessageBox (requires .NET 6 or newer)

#### Methods

##### Reset()
```csharp
public void Reset()
```

**Description:** Resets all properties to their default English values.

##### ToString()
```csharp
public override string ToString()
```

**Returns:** `"Modified"` if any property has been changed; otherwise empty string.

#### Complete Usage Example

```csharp
// Configure Spanish localization for message boxes
var general = KryptonManager.Strings.GeneralStrings;

general.OK = "&Aceptar";           // Alt+A
general.Cancel = "&Cancelar";      // Alt+C
general.Yes = "&Sí";               // Alt+S
general.No = "&No";                // Alt+N
general.Abort = "Abo&rtar";        // Alt+R
general.Retry = "&Reintentar";     // Alt+R
general.Ignore = "&Ignorar";       // Alt+I
general.Close = "C&errar";         // Alt+E
general.Today = "&Hoy";            // Alt+H
general.Help = "A&yuda";           // Alt+Y
general.Continue = "Co&ntinuar";   // Alt+N
general.TryAgain = "Reintentar"; // Alt+T

// Use in a message box
KryptonMessageBox.Show("¿Desea continuar?", "Confirmar", 
    KryptonMessageBoxButtons.YesNo);
// Shows buttons with "Sí" and "No"
```

---

### CustomToolkitStrings

**Access:** `KryptonManager.Strings.CustomStrings`  
**Type:** `CustomToolkitStrings`  
**Purpose:** Custom strings for specialized scenarios like navigation, editing, and application-specific actions

#### Class Definition

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class CustomToolkitStrings : GlobalId
```

#### Properties

##### Apply
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Apply string used for property dialogs.")]
[DefaultValue("A&pply")]
public string Apply { get; set; }
```

**Default Value:** `"A&pply"`  
**Accelerator Key:** P (Alt+P)  
**Used In:** Property dialogs, settings windows

##### Back
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Back string used for custom situations.")]
[DefaultValue("Bac&k")]
public string Back { get; set; }
```

**Default Value:** `"Bac&k"`  
**Accelerator Key:** K (Alt+K)  
**Used In:** Navigation controls, wizard dialogs

##### Collapse
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Collapse string used in expandable footers.")]
[DefaultValue("C&ollapse")]
public string Collapse { get; set; }
```

**Default Value:** `"C&ollapse"`  
**Accelerator Key:** O (Alt+O)  
**Used In:** Expandable panels, collapsible regions

##### Expand
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Expand string used in expandable footers.")]
[DefaultValue("Ex&pand")]
public string Expand { get; set; }
```

**Default Value:** `"Ex&pand"`  
**Accelerator Key:** P (Alt+P)  
**Used In:** Expandable panels, collapsible regions

##### Exit
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Exit string used for custom situations.")]
[DefaultValue("E&xit")]
public string Exit { get; set; }
```

**Default Value:** `"E&xit"`  
**Accelerator Key:** X (Alt+X)  
**Used In:** Application exit buttons, close operations

##### Finish
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Finish string used for custom situations.")]
[DefaultValue("&Finish")]
public string Finish { get; set; }
```

**Default Value:** `"&Finish"`  
**Accelerator Key:** F (Alt+F)  
**Used In:** Wizard completion, multi-step dialogs

##### Next
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Next string used for custom situations.")]
[DefaultValue("&Next")]
public string Next { get; set; }
```

**Default Value:** `"&Next"`  
**Accelerator Key:** N (Alt+N)  
**Used In:** Wizard navigation, multi-step dialogs

##### Previous
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Previous string used for custom situations.")]
[DefaultValue("Pre&vious")]
public string Previous { get; set; }
```

**Default Value:** `"Pre&vious"`  
**Accelerator Key:** V (Alt+V)  
**Used In:** Wizard navigation, multi-step dialogs

##### Cut
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Cut string used for custom situations.")]
[DefaultValue("C&ut")]
public string Cut { get; set; }
```

**Default Value:** `"C&ut"`  
**Accelerator Key:** U (Alt+U)  
**Used In:** Context menus, edit operations

##### Copy
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Copy string used for custom situations.")]
[DefaultValue("&Copy")]
public string Copy { get; set; }
```

**Default Value:** `"&Copy"`  
**Accelerator Key:** C (Alt+C)  
**Used In:** Context menus, edit operations

##### Paste
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Paste string used for custom situations.")]
[DefaultValue("Pas&te")]
public string Paste { get; set; }
```

**Default Value:** `"Pas&te"`  
**Accelerator Key:** T (Alt+T)  
**Used In:** Context menus, edit operations

##### SelectAll
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Select All string used for custom situations.")]
[DefaultValue("Sel&ect All")]
public string SelectAll { get; set; }
```

**Default Value:** `"Sel&ect All"`  
**Accelerator Key:** E (Alt+E)  
**Used In:** Context menus, edit operations

##### ClearClipboard
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Clear Clipboard string used for custom situations.")]
[DefaultValue("Clear Clipboa&rd")]
public string ClearClipboard { get; set; }
```

**Default Value:** `"Clear Clipboa&rd"`  
**Accelerator Key:** R (Alt+R)  
**Used In:** Clipboard operations

##### YesToAll
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Yes to All string used for custom situations.")]
[DefaultValue("Yes &to All")]
public string YesToAll { get; set; }
```

**Default Value:** `"Yes &to All"`  
**Accelerator Key:** T (Alt+T)  
**Used In:** Batch operations, confirmation dialogs

##### NoToAll
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("No to All string used for custom situations.")]
[DefaultValue("No t&o All")]
public string NoToAll { get; set; }
```

**Default Value:** `"No t&o All"`  
**Accelerator Key:** O (Alt+O)  
**Used In:** Batch operations, confirmation dialogs

##### OkToAll
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Ok to All string used for custom situations.")]
[DefaultValue("O&k to All")]
public string OkToAll { get; set; }
```

**Default Value:** `"O&k to All"`  
**Accelerator Key:** K (Alt+K)  
**Used In:** Batch operations, confirmation dialogs

##### Reset
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Reset string used for custom situations.")]
[DefaultValue("&Reset")]
public string Reset { get; set; }
```

**Default Value:** `"&Reset"`  
**Accelerator Key:** R (Alt+R)  
**Used In:** Settings dialogs, form reset operations

##### SystemInformation
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("System information string used for custom situations.")]
[DefaultValue("S&ystem Information")]
public string SystemInformation { get; set; }
```

**Default Value:** `"S&ystem Information"`  
**Accelerator Key:** Y (Alt+Y)  
**Used In:** About boxes, system dialogs

##### CurrentTheme
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Current theme string used for custom situations.")]
[DefaultValue("Current Theme")]
public string CurrentTheme { get; set; }
```

**Default Value:** `"Current Theme"`  
**Used In:** Theme selection dialogs

##### DoNotShowAgain
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Do not show again string used for custom situations.")]
[DefaultValue("&Do not show again")]
public string DoNotShowAgain { get; set; }
```

**Default Value:** `"&Do not show again"`  
**Accelerator Key:** D (Alt+D)  
**Used In:** Message boxes with "don't show again" option

#### Methods

##### ResetValues()
```csharp
public void ResetValues()
```

**Description:** Resets all properties to their default English values.

##### IsDefault
```csharp
[Browsable(false)]
public bool IsDefault { get; }
```

**Description:** Returns `true` if all properties are at default values.

#### Complete Usage Example

```csharp
// Configure French localization for custom strings
var custom = KryptonManager.Strings.CustomStrings;

custom.Apply = "&Appliquer";
custom.Back = "&Retour";
custom.Collapse = "&Réduire";
custom.Expand = "&Développer";
custom.Exit = "&Quitter";
custom.Finish = "&Terminer";
custom.Next = "&Suivant";
custom.Previous = "&Précédent";
custom.Cut = "Co&uper";
custom.Copy = "&Copier";
custom.Paste = "C&oller";
custom.SelectAll = "&Tout sélectionner";
custom.Reset = "&Réinitialiser";
custom.DoNotShowAgain = "&Ne plus afficher ce message";
```

---

## Component-Specific String Categories

### GeneralRibbonStrings

**Access:** `KryptonManager.Strings.RibbonStrings`  
**Type:** `GeneralRibbonStrings`  
**Purpose:** Strings specific to KryptonRibbon components

#### Properties

##### AppButtonText
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Button text for the AppButton.")]
[DefaultValue("File")]
[RefreshProperties(RefreshProperties.All)]
public string AppButtonText { get; set; }
```

**Default Value:** `"File"`  
**Used In:** Application button in ribbon controls

##### AppButtonKeyTip
```csharp
[Localizable(true)]
[Category("Values")]
[Description("Application button key tip string.")]
[DefaultValue("F")]
[RefreshProperties(RefreshProperties.All)]
public string AppButtonKeyTip { get; set; }
```

**Default Value:** `"F"`  
**Note:** Automatically converted to uppercase  
**Used In:** Keyboard navigation in ribbon

##### CustomizeQuickAccessToolbar
```csharp
[Localizable(true)]
[Category("Values")]
[Description("Heading for quick access toolbar menu.")]
[DefaultValue("Customize Quick Access Toolbar")]
[RefreshProperties(RefreshProperties.All)]
public string CustomizeQuickAccessToolbar { get; set; }
```

**Default Value:** `"Customize Quick Access Toolbar"`  
**Used In:** QAT customization menu

##### Minimize
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for minimizing the ribbon option.")]
[DefaultValue("Mi&nimize the Ribbon")]
[RefreshProperties(RefreshProperties.All)]
public string Minimize { get; set; }
```

**Default Value:** `"Mi&nimize the Ribbon"`  
**Used In:** Ribbon minimize/maximize options

##### MoreColors
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for a 'more colors' entry.")]
[DefaultValue("&More Colors...")]
[RefreshProperties(RefreshProperties.All)]
public string MoreColors { get; set; }
```

**Default Value:** `"&More Colors..."`  
**Used In:** Color picker dialogs

##### NoColor
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for a 'no color' entry.")]
[DefaultValue("&No Color")]
[RefreshProperties(RefreshProperties.All)]
public string NoColor { get; set; }
```

**Default Value:** `"&No Color"`  
**Used In:** Color picker dialogs

##### RecentDocuments
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Title for recent documents section of the application menu.")]
[DefaultValue("Recent Documents")]
[RefreshProperties(RefreshProperties.All)]
public string RecentDocuments { get; set; }
```

**Default Value:** `"Recent Documents"`  
**Used In:** Application menu recent items

##### RecentColors
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Title for recent colors section of the color button menu.")]
[DefaultValue("Recent Colors")]
[RefreshProperties(RefreshProperties.All)]
public string RecentColors { get; set; }
```

**Default Value:** `"Recent Colors"`  
**Used In:** Color picker recent colors section

##### ShowAboveRibbon
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for showing above the ribbon.")]
[DefaultValue("&Show Above the Ribbon")]
[RefreshProperties(RefreshProperties.All)]
public string ShowAboveRibbon { get; set; }
```

**Default Value:** `"&Show Above the Ribbon"`  
**Used In:** QAT positioning menu

##### ShowBelowRibbon
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for showing below the ribbon.")]
[DefaultValue("&Show Below the Ribbon")]
[RefreshProperties(RefreshProperties.All)]
public string ShowBelowRibbon { get; set; }
```

**Default Value:** `"&Show Below the Ribbon"`  
**Used In:** QAT positioning menu

##### ShowQATAboveRibbon
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for showing QAT above the ribbon.")]
[DefaultValue("&Show Quick Access Toolbar Above the Ribbon")]
[RefreshProperties(RefreshProperties.All)]
public string ShowQATAboveRibbon { get; set; }
```

**Default Value:** `"&Show Quick Access Toolbar Above the Ribbon"`  
**Used In:** QAT positioning menu

##### ShowQATBelowRibbon
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Menu string for showing QAT below the ribbon.")]
[DefaultValue("&Show Quick Access Toolbar Below the Ribbon")]
[RefreshProperties(RefreshProperties.All)]
public string ShowQATBelowRibbon { get; set; }
```

**Default Value:** `"&Show Quick Access Toolbar Below the Ribbon"`  
**Used In:** QAT positioning menu

##### StandardColors
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Title for standard colors section of the color button menu.")]
[DefaultValue("Standard Colors")]
[RefreshProperties(RefreshProperties.All)]
public string StandardColors { get; set; }
```

**Default Value:** `"Standard Colors"`  
**Used In:** Color picker standard colors section

##### ThemeColors
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Title for theme colors section of the color button menu.")]
[DefaultValue("Theme Colors")]
[RefreshProperties(RefreshProperties.All)]
public string ThemeColors { get; set; }
```

**Default Value:** `"Theme Colors"`  
**Used In:** Color picker theme colors section

#### Usage Example

```csharp
// Configure German localization for ribbon
var ribbon = KryptonManager.Strings.RibbonStrings;

ribbon.AppButtonText = "Datei";
ribbon.AppButtonKeyTip = "D";
ribbon.CustomizeQuickAccessToolbar = "Symbolleiste für den Schnellzugriff anpassen";
ribbon.Minimize = "&Menüband minimieren";
ribbon.MoreColors = "&Weitere Farben...";
ribbon.NoColor = "&Keine Farbe";
ribbon.RecentDocuments = "Zuletzt verwendete Dokumente";
ribbon.RecentColors = "Zuletzt verwendete Farben";
ribbon.StandardColors = "Standardfarben";
ribbon.ThemeColors = "Designfarben";
```

---

### KryptonAboutBoxStrings

**Access:** `KryptonManager.Strings.AboutBoxStrings`  
**Type:** `KryptonAboutBoxStrings`  
**Purpose:** Label strings for KryptonAboutBox component

#### Properties

##### About
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'About' string.")]
[DefaultValue("About")]
public string About { get; set; }
```

**Default Value:** `"About"`

##### Title
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Title' label string.")]
[DefaultValue("Title")]
public string Title { get; set; }
```

**Default Value:** `"Title"`

##### Copyright
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Copyright' label string.")]
[DefaultValue("Copyright")]
public string Copyright { get; set; }
```

**Default Value:** `"Copyright"`

##### Description
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Description' label string.")]
[DefaultValue("Description")]
public string Description { get; set; }
```

**Default Value:** `"Description"`

##### Company
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Company' label string.")]
[DefaultValue("Company")]
public string Company { get; set; }
```

**Default Value:** `"Company"`

##### Product
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Product' label string.")]
[DefaultValue("Product")]
public string Product { get; set; }
```

**Default Value:** `"Product"`

##### Trademark
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Trademark' label string.")]
[DefaultValue("Trademark")]
public string Trademark { get; set; }
```

**Default Value:** `"Trademark"`

##### Version
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Version' label string.")]
[DefaultValue("Version")]
public string Version { get; set; }
```

**Default Value:** `"Version"`

##### BuildDate
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The about box 'Build Date' label string.")]
[DefaultValue("Build Date")]
public string BuildDate { get; set; }
```

**Default Value:** `"Build Date"`

##### ImageRuntimeVersion
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The image runtime version string.")]
[DefaultValue("Image Runtime Version")]
public string ImageRuntimeVersion { get; set; }
```

**Default Value:** `"Image Runtime Version"`

##### LoadedFromGlobalAssemblyCache
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("The loaded from global assembly cache string.")]
[DefaultValue("Loaded from GAC")]
public string LoadedFromGlobalAssemblyCache { get; set; }
```

**Default Value:** `"Loaded from GAC"`

#### Usage Example

```csharp
// Configure Japanese localization for about box
var aboutBox = KryptonManager.Strings.AboutBoxStrings;

aboutBox.About = "について";
aboutBox.Title = "タイトル";
aboutBox.Copyright = "著作権";
aboutBox.Description = "説明";
aboutBox.Company = "会社";
aboutBox.Product = "製品";
aboutBox.Trademark = "商標";
aboutBox.Version = "バージョン";
aboutBox.BuildDate = "ビルド日";
aboutBox.ImageRuntimeVersion = "イメージランタイムバージョン";
aboutBox.LoadedFromGlobalAssemblyCache = "GACから読み込まれました";
```

---

### KryptonToastNotificationStrings

**Access:** `KryptonManager.Strings.ToastNotificationStrings`  
**Type:** `KryptonToastNotificationStrings`  
**Purpose:** Strings for toast notification components

#### Properties

##### DoNotShowAgain
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Dismiss string used for custom situations.")]
[DefaultValue("Do &not show again")]
public string DoNotShowAgain { get; set; }
```

**Default Value:** `"Do &not show again"`  
**Accelerator Key:** N (Alt+N)

##### Dismiss
```csharp
[Localizable(true)]
[Category("Visuals")]
[Description("Dismiss string used for custom situations.")]
[DefaultValue("&Dismiss")]
public string Dismiss { get; set; }
```

**Default Value:** `"&Dismiss"`  
**Accelerator Key:** D (Alt+D)

#### Usage Example

```csharp
// Configure Chinese localization for toast notifications
var toast = KryptonManager.Strings.ToastNotificationStrings;

toast.DoNotShowAgain = "不再显示(&N)";
toast.Dismiss = "关闭(&D)";
```

---

## API Patterns and Conventions

### Common Patterns

All string category classes follow these conventions:

#### 1. Class Structure

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class CategoryNameStrings : GlobalId
{
    // Private constants for defaults
    private const string DEFAULT_PROPERTY_NAME = "Default Value";
    
    // Public properties
    [Localizable(true)]
    [Category("Visuals")]
    [Description("Property description.")]
    [DefaultValue(DEFAULT_PROPERTY_NAME)]
    public string PropertyName { get; set; }
    
    // IsDefault property
    [Browsable(false)]
    public bool IsDefault { get; }
    
    // Reset method
    public void Reset();
    
    // ToString override
    public override string ToString();
}
```

#### 2. Property Attributes

All localizable string properties use these attributes:

- `[Localizable(true)]` - Enables designer localization support
- `[Category("Visuals")]` - Groups properties in the designer
- `[Description("...")]` - Provides property description
- `[DefaultValue("...")]` - Specifies default value
- `[RefreshProperties(RefreshProperties.All)]` - (Optional) Triggers property grid refresh

#### 3. Accelerator Keys

Strings containing `&` character define keyboard accelerators:
- `"&OK"` - Alt+O
- `"Cance&l"` - Alt+L
- `"&Yes"` - Alt+Y

**Best Practice:** Ensure unique accelerator keys within the same dialog or menu.

### Access Patterns

#### Static Access
```csharp
// Direct static access to string categories
string ok = KryptonGlobalToolkitStrings.GeneralToolkitStrings.OK;
```

#### Instance Access
```csharp
// Access through KryptonManager instance
string ok = KryptonManager.Strings.GeneralStrings.OK;
```

#### Designer Access
1. Add `KryptonManager` to form
2. Expand `ToolkitStrings` property
3. Expand desired string category
4. Modify individual strings

### Thread Safety

- **Reading strings:** Thread-safe
- **Modifying strings:** Should be performed on UI thread
- **Reset operations:** Should be performed on UI thread

### Performance Considerations

- String lookups are fast (direct property access)
- No caching required
- Minimal memory overhead
- Changes take effect immediately

---

## Technical Implementation

### Inheritance Hierarchy

```
Object
    └── GlobalId
        └── KryptonGlobalToolkitStrings
        └── GeneralToolkitStrings
        └── CustomToolkitStrings
        └── GeneralRibbonStrings
        └── [Other String Categories]
```

### GlobalId Base Class

```csharp
public abstract class GlobalId
{
    // Base class for all string categories
    // Provides common infrastructure
}
```

### Type Converter Support

All string categories use `ExpandableObjectConverter`:

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class StringCategory : GlobalId
{
    // Enables expandable behavior in property grids
}
```

This enables:
- Expandable nodes in Visual Studio designer
- Nested property display
- Designer serialization support

### Serialization

String categories support designer serialization:

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
```

This allows:
- Saving modified strings to .resx files
- Language-specific resource generation
- Automatic resource loading

### RefreshProperties Attribute

Some properties use `RefreshProperties`:

```csharp
[RefreshProperties(RefreshProperties.All)]
public string PropertyName { get; set; }
```

This triggers:
- Property grid refresh when changed
- Dependent property updates
- UI synchronization

### Default Value Handling

Each property has a private constant default:

```csharp
private const string DEFAULT_OK = "O&K";

[DefaultValue(DEFAULT_OK)]
public string OK { get; set; }
```

Benefits:
- Type-safe default values
- Easy maintenance
- Consistent reset behavior

### IsDefault Implementation

The `IsDefault` property checks all strings:

```csharp
public bool IsDefault => 
    Property1.Equals(DEFAULT_PROPERTY1) &&
    Property2.Equals(DEFAULT_PROPERTY2) &&
    // ... all properties
    PropertyN.Equals(DEFAULT_PROPERTYN);
```

This enables:
- Detecting modifications
- Conditional serialization
- Designer support

---

## See Also

- [Localization and String Management Guide](LocalizationGuide.md)
- [ExceptionHandler API Documentation](ExceptionHandlerAPIDocumentation.md)
- [.NET Globalization Documentation](https://docs.microsoft.com/en-us/dotnet/standard/globalization-localization/)

