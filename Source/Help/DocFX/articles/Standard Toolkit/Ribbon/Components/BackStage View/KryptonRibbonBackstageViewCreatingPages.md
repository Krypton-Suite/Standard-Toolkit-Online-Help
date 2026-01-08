# Creating Backstage Pages - In-Depth Guide

## Table of Contents

- [Overview](#overview)
- [Understanding KryptonBackstagePage](#understanding-kryptonbackstagepage)
- [Creating Pages in the Designer](#creating-pages-in-the-designer)
- [Creating Pages at Runtime](#creating-pages-at-runtime)
- [Page Properties](#page-properties)
- [Designing Page Content](#designing-page-content)
  - [Basic Layout](#basic-layout)
  - [Using Layout Containers](#using-layout-containers)
  - [Common Page Patterns](#common-page-patterns)
- [Using Krypton Controls in Pages](#using-krypton-controls-in-pages)
- [Best Practices](#best-practices)
- [Complete Examples](#complete-examples)

---

## Overview

`KryptonBackstagePage` is the building block of the Backstage View. Each page represents a distinct section or view that users can navigate to from the left navigation panel. This guide provides comprehensive information on creating, designing, and implementing Backstage pages.

---

## Understanding KryptonBackstagePage

### What is KryptonBackstagePage?

`KryptonBackstagePage` inherits from `KryptonPanel`, which means:

- **It's a container control**: You can add any Windows Forms controls to it
- **It supports all panel properties**: Background styles, padding, margins, etc.
- **It's fully designable**: Works seamlessly with the Visual Studio designer
- **It's theme-aware**: Automatically adapts to the active Krypton theme

### Key Characteristics

- **Docking**: Pages are automatically docked to `Fill` by the `KryptonBackstageView`
- **Visibility**: Pages are hidden by default and shown when selected
- **Navigation**: Pages appear in the left navigation list (unless `VisibleInNavigation = false`)
- **Lifecycle**: Pages are created once and reused as users navigate

---

## Creating Pages in the Designer

### Step-by-Step: Adding Your First Page

1. **Add a KryptonBackstageView to your form**
   - Drag `KryptonBackstageView` from the toolbox onto your form
   - It will appear in the component tray (not visible on the form)

2. **Add a page using designer verbs**
   - Right-click the `KryptonBackstageView` in the component tray
   - Select **"Add Page"** from the context menu
   - A new `KryptonBackstagePage` will be created

3. **Configure the page**
   - Select the page in the **Document Outline** window (View → Other Windows → Document Outline)
   - In the Properties window, set:
     - `Text`: The display name (e.g., "Info", "Save", "Options")
     - `Image`: Optional icon/image for navigation
     - `VisibleInNavigation`: Whether to show in the navigation list

4. **Design the page content**
   - With the page selected, you can now add controls to it
   - Use the toolbox to drag controls onto the page
   - Arrange and configure controls as needed

5. **Link to the ribbon**
   ```csharp
   kryptonRibbon.RibbonFileAppTab.UseBackstageView = true;
   kryptonRibbon.RibbonFileAppTab.BackstageView = kryptonBackstageView1;
   ```

### Using the Collection Editor

Alternatively, you can use the collection editor:

1. Select the `KryptonBackstageView` in the designer
2. In the Properties window, find the `Pages` property
3. Click the **"..."** button to open the collection editor
4. Click **"Add"** to create new pages
5. Configure each page's properties in the editor
6. Use **"Remove"** and arrow buttons to reorder pages

### Designer Tips

- **Document Outline**: Use the Document Outline window to easily select pages and their child controls
- **Page Selection**: Pages are easier to select from Document Outline than from the designer surface
- **Nested Controls**: You can add any control hierarchy - panels, layout containers, user controls, etc.
- **Docking**: Child controls can use docking (`Dock = Fill`, `Dock = Top`, etc.) for flexible layouts

---

## Creating Pages at Runtime

### Basic Page Creation

```csharp
// Create a new page
var infoPage = new KryptonBackstagePage
{
    Text = "Info",
    VisibleInNavigation = true
};

// Add it to the backstage view
backstage.Pages.Add(infoPage);
```

### Creating Pages with Content

```csharp
// Create a page
var savePage = new KryptonBackstagePage
{
    Text = "Save",
    Dock = DockStyle.Fill  // Will be set automatically, but good practice
};

// Add controls to the page
var label = new KryptonLabel
{
    Text = "Save your work",
    Location = new Point(20, 20),
    AutoSize = true
};
savePage.Controls.Add(label);

var button = new KryptonButton
{
    Text = "Save Now",
    Location = new Point(20, 60),
    Size = new Size(120, 35)
};
button.Click += (s, e) => SaveDocument();
savePage.Controls.Add(button);

// Add the page to the backstage view
backstage.Pages.Add(savePage);
```

### Programmatic Page Management

```csharp
// Find a page by name
var page = backstage.Pages["Info"];

// Remove a page
if (page != null)
{
    backstage.Pages.Remove(page);
}

// Reorder pages
var firstPage = backstage.Pages[0];
backstage.Pages.Remove(firstPage);
backstage.Pages.Add(firstPage); // Moves to end

// Clear all pages
backstage.Pages.Clear();
```

---

## Page Properties

### Navigation Properties

#### `string Text`
- **Purpose**: Display text in the navigation list
- **Default**: Empty string
- **Example**: `page.Text = "Information"`

#### `Image? Image`
- **Purpose**: Optional image/icon for navigation (future enhancement)
- **Default**: `null`
- **Example**: `page.Image = Properties.Resources.InfoIcon`

#### `bool VisibleInNavigation`
- **Purpose**: Control whether the page appears in the navigation list
- **Default**: `true`
- **Use Case**: Hide pages that should be accessible programmatically but not via navigation
- **Example**: `page.VisibleInNavigation = false`

### Inherited Panel Properties

Since `KryptonBackstagePage` inherits from `KryptonPanel`, you have access to:

#### `PaletteBackStyle PanelBackStyle`
- Control the background style of the page
- **Example**: `page.PanelBackStyle = PaletteBackStyle.PanelClient`

#### `Padding Padding`
- Internal spacing for the page content
- **Example**: `page.Padding = new Padding(20)`

#### Standard Control Properties
- `BackColor`, `ForeColor`, `Font`, `Enabled`, `Visible`, `Dock`, `Anchor`, etc.

---

## Designing Page Content

### Basic Layout

#### Simple Centered Content

```csharp
var page = new KryptonBackstagePage { Text = "Welcome" };

var label = new KryptonLabel
{
    Text = "Welcome to the Backstage View",
    AutoSize = true,
    Location = new Point(50, 50)
};
page.Controls.Add(label);
```

#### Using Padding for Spacing

```csharp
var page = new KryptonBackstagePage
{
    Text = "Settings",
    Padding = new Padding(30) // 30 pixels on all sides
};

var label = new KryptonLabel
{
    Text = "Application Settings",
    AutoSize = true,
    Location = new Point(0, 0) // Will respect padding
};
page.Controls.Add(label);
```

### Using Layout Containers

#### TableLayoutPanel for Structured Layouts

```csharp
var page = new KryptonBackstagePage { Text = "Options" };

var tableLayout = new TableLayoutPanel
{
    Dock = DockStyle.Fill,
    ColumnCount = 2,
    RowCount = 3,
    Padding = new Padding(20)
};

// Configure columns
tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));

// Add controls
tableLayout.Controls.Add(new KryptonLabel { Text = "Theme:" }, 0, 0);
var themeCombo = new KryptonComboBox { Dock = DockStyle.Fill };
tableLayout.Controls.Add(themeCombo, 1, 0);

tableLayout.Controls.Add(new KryptonLabel { Text = "Language:" }, 0, 1);
var langCombo = new KryptonComboBox { Dock = DockStyle.Fill };
tableLayout.Controls.Add(langCombo, 1, 1);

page.Controls.Add(tableLayout);
```

#### FlowLayoutPanel for Dynamic Content

```csharp
var page = new KryptonBackstagePage { Text = "Recent Files" };

var flowLayout = new FlowLayoutPanel
{
    Dock = DockStyle.Fill,
    FlowDirection = FlowDirection.TopDown,
    WrapContents = false,
    Padding = new Padding(20)
};

// Add recent file buttons
foreach (var file in recentFiles)
{
    var button = new KryptonButton
    {
        Text = file.Name,
        Width = 300,
        Height = 40,
        Margin = new Padding(0, 5, 0, 5)
    };
    button.Click += (s, e) => OpenFile(file);
    flowLayout.Controls.Add(button);
}

page.Controls.Add(flowLayout);
```

#### SplitContainer for Two-Pane Layouts

```csharp
var page = new KryptonBackstagePage { Text = "Export" };

var splitContainer = new SplitContainer
{
    Dock = DockStyle.Fill,
    Orientation = Orientation.Horizontal,
    SplitterDistance = 200
};

// Left/top pane: Options
var optionsPanel = new KryptonPanel
{
    Dock = DockStyle.Fill,
    Padding = new Padding(20)
};
// Add option controls here
splitContainer.Panel1.Controls.Add(optionsPanel);

// Right/bottom pane: Preview
var previewPanel = new KryptonPanel
{
    Dock = DockStyle.Fill,
    Padding = new Padding(20)
};
// Add preview controls here
splitContainer.Panel2.Controls.Add(previewPanel);

page.Controls.Add(splitContainer);
```

### Common Page Patterns

#### Information Page

```csharp
var infoPage = new KryptonBackstagePage
{
    Text = "Info",
    Padding = new Padding(40)
};

var titleLabel = new KryptonLabel
{
    Text = "Application Information",
    LabelStyle = LabelStyle.TitlePanel,
    AutoSize = true,
    Location = new Point(0, 0)
};
infoPage.Controls.Add(titleLabel);

var versionLabel = new KryptonLabel
{
    Text = $"Version: {Application.ProductVersion}",
    AutoSize = true,
    Location = new Point(0, 40)
};
infoPage.Controls.Add(versionLabel);

var copyrightLabel = new KryptonLabel
{
    Text = "© 2025 Your Company",
    AutoSize = true,
    Location = new Point(0, 70)
};
infoPage.Controls.Add(copyrightLabel);
```

#### Settings/Options Page

```csharp
var optionsPage = new KryptonBackstagePage
{
    Text = "Options",
    Padding = new Padding(30)
};

var tableLayout = new TableLayoutPanel
{
    Dock = DockStyle.Fill,
    ColumnCount = 2,
    RowCount = 4,
    AutoSize = true
};

tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));

// Theme setting
tableLayout.Controls.Add(new KryptonLabel { Text = "Theme:", AutoSize = true }, 0, 0);
var themeCombo = new KryptonComboBox { Dock = DockStyle.Fill };
themeCombo.Items.AddRange(new[] { "Office 2010", "Office 2013", "Microsoft 365" });
tableLayout.Controls.Add(themeCombo, 1, 0);

// Language setting
tableLayout.Controls.Add(new KryptonLabel { Text = "Language:", AutoSize = true }, 0, 1);
var langCombo = new KryptonComboBox { Dock = DockStyle.Fill };
langCombo.Items.AddRange(new[] { "English", "French", "German" });
tableLayout.Controls.Add(langCombo, 1, 1);

// Checkbox settings
var autoSaveCheck = new KryptonCheckBox { Text = "Auto-save documents", AutoSize = true };
tableLayout.Controls.Add(autoSaveCheck, 0, 2);
tableLayout.SetColumnSpan(autoSaveCheck, 2);

optionsPage.Controls.Add(tableLayout);
```

#### Recent Files/Items Page

```csharp
var recentPage = new KryptonBackstagePage
{
    Text = "Recent",
    Padding = new Padding(20)
};

var scrollPanel = new KryptonPanel
{
    Dock = DockStyle.Fill,
    AutoScroll = true
};

var flowLayout = new FlowLayoutPanel
{
    AutoSize = true,
    FlowDirection = FlowDirection.TopDown,
    WrapContents = false,
    Dock = DockStyle.Top
};

foreach (var file in GetRecentFiles())
{
    var fileButton = new KryptonButton
    {
        Text = file.Name,
        Width = 400,
        Height = 50,
        Margin = new Padding(0, 5, 0, 5),
        TextAlign = ContentAlignment.MiddleLeft
    };
    fileButton.Click += (s, e) => OpenFile(file);
    flowLayout.Controls.Add(fileButton);
}

scrollPanel.Controls.Add(flowLayout);
recentPage.Controls.Add(scrollPanel);
```

---

## Using Krypton Controls in Pages

### Recommended Krypton Controls

Since `KryptonBackstagePage` is part of the Krypton Toolkit, you can use any Krypton controls for a consistent, theme-aware UI:

#### Labels and Text

```csharp
// Title label
var title = new KryptonLabel
{
    Text = "Page Title",
    LabelStyle = LabelStyle.TitlePanel,
    AutoSize = true
};

// Body text
var body = new KryptonLabel
{
    Text = "This is body text",
    LabelStyle = LabelStyle.NormalControl,
    AutoSize = true
};
```

#### Buttons

```csharp
var saveButton = new KryptonButton
{
    Text = "Save",
    ButtonStyle = ButtonStyle.Standalone,
    Size = new Size(120, 35)
};
saveButton.Click += (s, e) => SaveDocument();
```

#### Input Controls

```csharp
// Text box
var nameTextBox = new KryptonTextBox
{
    Width = 200,
    Height = 25
};

// Combo box
var themeCombo = new KryptonComboBox
{
    Width = 200,
    DropDownStyle = ComboBoxStyle.DropDownList
};
themeCombo.Items.AddRange(new[] { "Office 2010", "Office 2013", "Microsoft 365" });

// Check box
var autoSaveCheck = new KryptonCheckBox
{
    Text = "Enable auto-save",
    AutoSize = true
};
```

#### Data Grid

```csharp
var dataGrid = new KryptonDataGridView
{
    Dock = DockStyle.Fill,
    AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
};
dataGrid.Columns.Add("Name", "Name");
dataGrid.Columns.Add("Value", "Value");
```

### Theme Integration

All Krypton controls automatically:
- Adapt to the active theme
- Use consistent colors and styles
- Support theme switching at runtime
- Provide a cohesive user experience

---

## Best Practices

### 1. Page Organization

- **Logical grouping**: Group related functionality into pages
- **Clear naming**: Use descriptive `Text` properties (e.g., "Save & Export" not "Page1")
- **Reasonable page count**: Too many pages can overwhelm users (aim for 3-7 pages)

### 2. Layout Design

- **Consistent spacing**: Use `Padding` and `Margin` consistently
- **Responsive layouts**: Use docking and anchoring for flexible layouts
- **Readable content**: Ensure text is readable with appropriate font sizes
- **Visual hierarchy**: Use different label styles to create visual hierarchy

### 3. Performance

- **Lazy loading**: Load heavy content only when the page is first accessed
- **Efficient controls**: Use virtualized controls (like `KryptonDataGridView`) for large datasets
- **Event handling**: Unsubscribe from events when pages are removed to prevent memory leaks

### 4. User Experience

- **Clear navigation**: Ensure page `Text` clearly indicates the page's purpose
- **Immediate feedback**: Provide visual feedback for user actions
- **Error handling**: Handle errors gracefully and inform users
- **Accessibility**: Use appropriate control labels and tooltips

### 5. Code Organization

```csharp
// Good: Separate page creation into methods
private void InitializeBackstagePages()
{
    CreateInfoPage();
    CreateOptionsPage();
    CreateRecentPage();
}

private void CreateInfoPage()
{
    var page = new KryptonBackstagePage { Text = "Info" };
    // ... configure page
    backstage.Pages.Add(page);
}
```

---

## Complete Examples

### Example 1: Simple Information Page

```csharp
private KryptonBackstagePage CreateInfoPage()
{
    var page = new KryptonBackstagePage
    {
        Text = "Information",
        Padding = new Padding(40)
    };

    var title = new KryptonLabel
    {
        Text = Application.ProductName,
        LabelStyle = LabelStyle.TitlePanel,
        AutoSize = true,
        Location = new Point(0, 0)
    };
    page.Controls.Add(title);

    var version = new KryptonLabel
    {
        Text = $"Version {Application.ProductVersion}",
        AutoSize = true,
        Location = new Point(0, 40)
    };
    page.Controls.Add(version);

    var copyright = new KryptonLabel
    {
        Text = "© 2025 Your Company. All rights reserved.",
        AutoSize = true,
        Location = new Point(0, 70)
    };
    page.Controls.Add(copyright);

    return page;
}
```

### Example 2: Options Page with Settings

```csharp
private KryptonBackstagePage CreateOptionsPage()
{
    var page = new KryptonBackstagePage
    {
        Text = "Options",
        Padding = new Padding(30)
    };

    var tableLayout = new TableLayoutPanel
    {
        Dock = DockStyle.Fill,
        ColumnCount = 2,
        RowCount = 3,
        AutoSize = true
    };

    tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
    tableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));

    // Theme selection
    tableLayout.Controls.Add(new KryptonLabel { Text = "Theme:", AutoSize = true }, 0, 0);
    var themeCombo = new KryptonComboBox
    {
        Dock = DockStyle.Fill,
        DropDownStyle = ComboBoxStyle.DropDownList
    };
    themeCombo.Items.AddRange(new[] { "Office 2010", "Office 2013", "Microsoft 365" });
    themeCombo.SelectedIndexChanged += (s, e) => ChangeTheme(themeCombo.SelectedItem.ToString());
    tableLayout.Controls.Add(themeCombo, 1, 0);

    // Auto-save option
    var autoSaveCheck = new KryptonCheckBox
    {
        Text = "Enable auto-save",
        AutoSize = true
    };
    autoSaveCheck.CheckedChanged += (s, e) => EnableAutoSave(autoSaveCheck.Checked);
    tableLayout.Controls.Add(autoSaveCheck, 0, 1);
    tableLayout.SetColumnSpan(autoSaveCheck, 2);

    page.Controls.Add(tableLayout);
    return page;
}
```

### Example 3: Recent Files Page

```csharp
private KryptonBackstagePage CreateRecentFilesPage()
{
    var page = new KryptonBackstagePage
    {
        Text = "Recent Files",
        Padding = new Padding(20)
    };

    var scrollPanel = new KryptonPanel
    {
        Dock = DockStyle.Fill,
        AutoScroll = true
    };

    var flowLayout = new FlowLayoutPanel
    {
        AutoSize = true,
        FlowDirection = FlowDirection.TopDown,
        WrapContents = false,
        Dock = DockStyle.Top,
        Padding = new Padding(10)
    };

    var recentFiles = GetRecentFiles();
    foreach (var file in recentFiles)
    {
        var fileButton = new KryptonButton
        {
            Text = $"{file.Name}\n{file.Path}",
            Width = 450,
            Height = 60,
            Margin = new Padding(0, 5, 0, 5),
            TextAlign = ContentAlignment.MiddleLeft,
            ButtonStyle = ButtonStyle.Standalone
        };
        fileButton.Click += (s, e) => OpenFile(file);
        flowLayout.Controls.Add(fileButton);
    }

    scrollPanel.Controls.Add(flowLayout);
    page.Controls.Add(scrollPanel);

    return page;
}
```

---

## Summary

- `KryptonBackstagePage` inherits from `KryptonPanel`, giving you full control over page design
- Pages can be created in the designer or at runtime
- Use layout containers (`TableLayoutPanel`, `FlowLayoutPanel`, `SplitContainer`) for structured layouts
- Leverage Krypton controls for theme-aware, consistent UI
- Follow best practices for organization, performance, and user experience

For more information, see the main [Ribbon Backstage View](Ribbon-BackstageView.md) documentation.

