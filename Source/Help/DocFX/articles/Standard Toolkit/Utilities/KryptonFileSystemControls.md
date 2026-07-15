# File system controls (Krypton.Toolkit.Utilities)

## Overview

The file-system suite provides Krypton-themed controls for browsing folders and files, from low-level tree/list views to a full explorer layout.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

| Control | Purpose |
| --- | --- |
| `KryptonFileSystemTreeView` | Lazy-loaded directory tree with shell icons |
| `KryptonFileSystemListView` | File list with folder/file icons |
| `KryptonSystemTreeView` | Tree rooted at all drives |
| `KryptonBrowserControl` | Split tree + list composite |
| `KryptonExplorerBrowser` | Full explorer: toolbar, address bar, tree, list, status bar |

## KryptonFileSystemTreeView

```csharp
var tree = new KryptonFileSystemTreeView
{
    Dock = DockStyle.Left,
    RootPath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)
};
tree.AfterSelect += (_, _) =>
{
    if (tree.SelectedPath != null)
    {
        list.CurrentPath = tree.SelectedPath;
    }
};
```

## KryptonFileSystemListView

```csharp
var list = new KryptonFileSystemListView
{
    Dock = DockStyle.Fill,
    CurrentPath = @"C:\"
};
```

## KryptonBrowserControl

Composite split control wiring tree selection to list content:

```csharp
var browser = new KryptonBrowserControl { Dock = DockStyle.Fill };
```

## KryptonExplorerBrowser

Full-featured explorer with navigation toolbar and address bar:

```csharp
var explorer = new KryptonExplorerBrowser { Dock = DockStyle.Fill };
explorer.NavigateTo(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile));
```

## KryptonSystemTreeView

Shows the full drive hierarchy (all logical drives as roots). Use when the tree should start above a single folder path.

## See also

- [KryptonTreeView](../Toolkit/Controls/KryptonTreeView.md)
- [KryptonListView](../Toolkit/Controls/KryptonListView.md)
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
