# Krypton.Toolkit.Utilities documentation index

Public types in the **`Krypton.Toolkit.Utilities`** assembly ship with the **`Krypton.Standard.Toolkit`** NuGet package. Use `using Krypton.Toolkit.Utilities;`.

## Combo drop-down family

| Topic | Description |
| --- | --- |
| [KryptonComboDropDownControls](KryptonComboDropDownControls.md) | Architecture, contracts, tree/checked-list variants, troubleshooting |
| [KryptonComboBoxUserControl](KryptonComboDropDownControls.md#kryptoncomboboxusercontrol) | Generic UserControl drop-down host (#3443) |
| [KryptonTreeComboBox](KryptonComboDropDownControls.md#kryptontreecombobox) | Tree picker combo (#3444) |
| [KryptonCheckedListComboBox](KryptonComboDropDownControls.md#kryptoncheckedlistcombobox) | Multi-select checked combo (#3445) |

## Input, search, and buttons

| Topic | Description |
| --- | --- |
| [KryptonTagInputControl](KryptonTagInput.md) | Wrap-capable tag editor with themed chips |
| [KryptonSearchBox](../Toolkit/Controls/KryptonSearchBox.md) | Search box with suggestions and history |
| [KryptonCountdownButton](KryptonCountdownButton.md) | Button with live countdown suffix |
| [KryptonAutoTextSuggestion](KryptonAutoTextSuggestion.md) | Auto-complete suggestions for text controls |
| [KryptonCommandLinkButton](../Toolkit/Controls/KryptonCommandLinkButton.md) | Windows command-link button |
| [KryptonEnumButton](KryptonEnumButton.md) | Button that cycles enum values on click (#3838) |
| [KryptonCheckBoxExtended](KryptonCheckBoxExtended.md) | Word-wrapped check box with optional subtext |

## Display and media

| Topic | Description |
| --- | --- |
| [KryptonQRCode](KryptonQRCode.md) | Native QR code display (#3305) |
| [KryptonCodeEditor](KryptonCodeEditor.md) | Syntax-highlighted code editor |
| [KryptonCircularProgressBar](../Toolkit/Controls/KryptonCircularProgressBar.md) | Circular progress indicator |
| [KryptonLoadingCircle](KryptonLoadingCircle.md) | Animated spoke busy spinner |
| [KryptonPrintPreviewControl](../Toolkit/Controls/KryptonPrintPreviewControl.md) | Themed print preview |
| [KryptonAdvancedDataGridView](KryptonAdvancedDataGridView.md) | Grid with Excel-style filters and multi-column sort |

## File system and browsing

| Topic | Description |
| --- | --- |
| [KryptonFileSystemControls](KryptonFileSystemControls.md) | Explorer, browser composite, tree/list views |
| [KryptonFileSystemTreeView](KryptonFileSystemTreeView.md) | Lazy-loaded directory tree with shell icons |
| [KryptonFileSystemListView](KryptonFileSystemListView.md) | File list with folder/file icons |
| [KryptonSystemTreeView](KryptonSystemTreeView.md) | Drive-rooted file system tree |
| [KryptonMultiSelectTreeView](KryptonMultiSelectTreeView.md) | Tree view with ListView-style multi-select |

## Toolbars and menus

| Topic | Description |
| --- | --- |
| [KryptonFloatingToolbars](KryptonFloatingToolbars.md) | Floatable tool strip and menu strip |
| [KryptonFloatingToolbarPanels](KryptonFloatingToolbarPanels.md) | Dock panel hosts (`ToolStripPanelExtended`, etc.) |
| [KryptonRadialMenu](KryptonRadialMenu.md) | The Krypton radial menu |
| [KryptonEnhancedContextMenu](KryptonEnhancedContextMenu.md) | Office-style menu with Mini Toolbar (#3862) |

## Web and authentication

| Topic | Description |
| --- | --- |
| [KryptonWebView2](KryptonWebView2.md) | WebView2 with Krypton theming |
| [KryptonOAuth2Login](KryptonOAuth2Login.md) | OAuth2 sign-in dialog (WebView2) |
| [OAuth2 with PKCE](OAuth2PKCE.md) | OAuth2 Proof Key for Code Exchange flow |

## Dialogs and static APIs

| Topic | Description |
| --- | --- |
| [KryptonMessageBoxExtended](../Toolkit/Components/KryptonMessageBoxExtended.md) | Extended message box (timers, footers, extra buttons) |
| [KryptonFoldableDialog](KryptonFoldableDialog.md) | Message dialog with collapsible details region |
| [KryptonAboutBox](../Toolkit/Components/KryptonAboutBox.md) | About box |
| [KryptonExceptionDialog](../Toolkit/Components/KryptonExceptionDialog.md) | Exception dialog |
| [BugReportingDialogAPI](BugReportingDialogAPI.md) | E-mail/file bug reporting dialog |
| [KryptonGitHubIssueReportDialog](KryptonGitHubIssueReportDialog.md) | GitHub Issues API bug report dialog |
| [KryptonFileCheckSumDialogs](KryptonFileCheckSumDialogs.md) | Compute and verify file hash dialogs |
| [KryptonSplashScreenManager](KryptonSplashScreenManager.md) | Non-blocking splash on a dedicated STA thread (#4180) |
| [KryptonSystemInformation](KryptonSystemInformation.md) | Themed System Information dialog (#3176) |
| [KryptonScreenColorPicker](KryptonScreenColorPicker.md) | Full-screen eyedropper colour sampler |
| [Custom Theme Generator](CustomThemeGenerator.md) | Build custom palettes from seed colours (#4234) |

## Logging

| Topic | Description |
| --- | --- |
| [KryptonLogger](KryptonLogger.md) | Opt-in logging pipeline (`KryptonLog`) (#4223) |

## Localization

| Topic | Description |
| --- | --- |
| [KryptonCustomStrings](KryptonCustomStrings.md) | Application custom strings (#3757) |
| [Localization index](LocalizationIndex.md) | Built-in `KryptonManager.Strings` |

## Supporting topics

| Topic | Description |
| --- | --- |
| [Exception Handler](ExceptionHandler.md) | Exception handling helpers |
| [Icon extraction index](IconExtractionIndex.md) | Extract icons from files and assemblies |
| [System icons](SystemIcons.md) | System and stock icon helpers |
| [Taskbar thumbnail buttons](TaskbarThumbnailButtons.md) | Taskbar thumbnail toolbar buttons |
| [UIA providers](UIAProviders.md) | UI Automation provider patterns |

## Related

- [Controls index](../Toolkit/Controls.md)
- [Components](../Toolkit/Components.md) — managers, context menus, standard dialogs
- [Documentation images](../Toolkit/Images/README.md)
- V110 rename: `Krypton.Utilities` → `Krypton.Toolkit.Utilities` ([#3455](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3455))
