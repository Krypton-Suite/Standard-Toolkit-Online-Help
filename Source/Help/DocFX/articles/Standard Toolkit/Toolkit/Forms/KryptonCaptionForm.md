# KryptonCaptionForm

Use `KryptonCaptionForm` when the title bar hosts controls. Ordinary `KryptonForm` keeps the previous designer surface. Each hosted control keeps its own left, centre, or right edge. `KryptonSearchBox` works because it derives from `KryptonTextBox` and lives in `Krypton.Toolkit.Utilities`. Toolkit does not reference Utilities.

The caption is non-client chrome. Hosted controls are real HWNDs, each parented to its own borderless owned window over a reserved caption slot. `KryptonForm` exposes empty protected chrome hooks (`PrepareCaptionChromeSlots`, `SyncCaptionChromeHosts`, and related members) that `KryptonCaptionForm` overrides.

## Public surface

| Member | Where | Role |
|--------|-------|------|
| `KryptonCaptionForm` | Derived form | Hosts caption controls without growing every `KryptonForm` designer. |
| `CaptionItems` | `KryptonCaptionForm` | Designer list of caption items, each with its own edge. |
| `KryptonFormCaptionItem` | Item on `CaptionItems` | One `Control` plus its `FormCaptionTextBoxEdge`. |
| `AddCaptionControl` / `SetCaptionControlEdge` / `RemoveCaptionControl` | `KryptonCaptionForm` | Advanced code API. |

## Designer usage

1. Change the form base type to `KryptonCaptionForm`.
2. Edit `CaptionItems` in the property grid (or add items in code).

```csharp
public partial class MainForm : KryptonCaptionForm
{
    public MainForm()
    {
        InitializeComponent();
        CaptionItems.Add(new KryptonFormCaptionItem(button, FormCaptionTextBoxEdge.Left));
        CaptionItems.Add(new KryptonFormCaptionItem(search, FormCaptionTextBoxEdge.Right));
    }
}
```
