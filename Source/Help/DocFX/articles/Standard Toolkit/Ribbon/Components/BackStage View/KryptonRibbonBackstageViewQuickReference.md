# Ribbon Backstage View — Quick Reference

## Enable Backstage (recommended)

```csharp
kryptonRibbon.RibbonFileAppTab.UseBackstageView = true;
kryptonRibbon.RibbonFileAppTab.BackstageView = kryptonBackstageView1; // designer-created
```

## Add pages (runtime)

```csharp
var backstage = new KryptonBackstageView { Dock = DockStyle.Fill };

backstage.Pages.Add(new KryptonBackstagePage { Text = "Info" });
backstage.Pages.Add(new KryptonBackstagePage { Text = "Save" });

kryptonRibbon.RibbonFileAppTab.UseBackstageView = true;
kryptonRibbon.RibbonFileAppTab.BackstageView = backstage;
```

## Remove pages (runtime)

```csharp
var page = backstage.Pages["Save"];
if (page != null)
{
    backstage.Pages.Remove(page);
}
```

## Close Backstage (runtime)

```csharp
kryptonRibbon.CloseBackstageView();
```

## Hook lifecycle events

```csharp
kryptonRibbon.BackstageOpening += (_, e) =>
{
    // e.Cancel = true;
};

kryptonRibbon.BackstageOpened += (_, __) => { };

kryptonRibbon.BackstageClosing += (_, e) =>
{
    // e.Cancel = true;
};

kryptonRibbon.BackstageClosed += (_, __) => { };
```

## Designer workflow (pages)

- Drop a `KryptonBackstageView` on the form.
- Right click → **Add Page** / **Remove Page** / **Clear Pages**.
- Select a `KryptonBackstagePage` and design it like a normal panel.

**See also**: [Creating Backstage Pages - In-Depth Guide](Ribbon-BackstageView-CreatingPages.md) for comprehensive examples and best practices.

## Customize colors

```csharp
// Custom colors (or set to null for theme defaults)
backstage.Colors.NavigationBackgroundColor = Color.FromArgb(45, 45, 48);
backstage.Colors.ContentBackgroundColor = Color.White;
backstage.Colors.SelectedItemHighlightColor = Color.FromArgb(68, 114, 196);
```

## Handle Close button

```csharp
backstage.CloseRequested += (sender, e) =>
{
    // Show confirmation or save data
    if (MessageBox.Show("Exit?", "Confirm", MessageBoxButtons.YesNo) == DialogResult.No)
    {
        e.Cancel = true; // Prevent close
    }
};
```


