# KryptonToolTip

This guide describes **`KryptonToolTip`**, a toolbox **component** in **`Krypton.Toolkit`** that shows **themed tooltip pop-ups** (the same **`VisualPopupToolTip`** rendering used elsewhere in the toolkit) on **any** `System.Windows.Forms.Control`, without requiring a `VisualControlBase` descendant.

- **Primary type**: [`KryptonToolTip`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Controls%20Toolkit/KryptonToolTip.cs) (`Krypton.Toolkit` assembly)

- **Sample harness**: `Source/Krypton Components/TestForm/KryptonToolTipTest.cs` (opened from **`StartScreen`** as **“KryptonToolTip”**)

---

## Table of contents

1. [Why KryptonToolTip exists](#why-kryptontooltip-exists)

2. [Architecture at a glance](#architecture-at-a-glance)

3. [Getting started](#getting-started)

4. [`KryptonToolTip` API](#kryptontooltip-api)

5. [Per-control content](#per-control-content)

6. [`ToolTipValues` and shared behaviour](#tooltipvalues-and-shared-behaviour)

7. [Placement](#placement)

8. [Palette](#palette)

9. [Runtime behaviour](#runtime-behaviour)

10. [Comparison with alternatives](#comparison-with-alternatives)

11. [Limitations and good practices](#limitations-and-good-practices)

12. [Extending or integrating](#extending-or-integrating)

---

## Why KryptonToolTip exists

### Problem

Across the toolkit, rich tooltips are built from:

| Piece | Role |
| -------- | ---- |
| [`ToolTipValues`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Values/ToolTipValues.cs) | Timing, shadow, label style, title/body imagery (via [`HeaderValues`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Values/HeaderValues.cs)), and [`ToolTipPosition`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Values/PopupPositionValues.cs). |
| [`ToolTipManager`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/General/TooltipManager.cs) | Mouse-driven show/cancel sequencing (paired with [`ToolTipController`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Controller/TooltipController.cs) and a **`ViewBase`** target). |
| [`VisualPopupToolTip`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Source/Krypton%20Components/Krypton.Toolkit/Controls%20Visuals/VisualPopupTooltip.cs) | The actual themed popup window. |

Controls that derive from **`VisualControlBase`** wire this stack automatically for their own **`ToolTipValues`**. **Plain WinForms controls** (and many third-party controls) do **not**, so developers previously had **no single component** analogous to **`System.Windows.Forms.ToolTip`** that still used **Krypton** rendering.

### Solution

**`KryptonToolTip`** fills that gap: drop one component on a form/user control, associate text (and optional image) **per control** via **`IExtenderProvider`** properties or **`SetToolTip`**, and the component drives **`VisualPopupToolTip`** with the same palette and **`ToolTipValues`** conventions.

---

## Architecture at a glance

```text

[KryptonToolTip Component]

       |

       +-- Palette / Renderer (PaletteMode, Palette, KryptonManager)

       |

       +-- ToolTipValues (shared delays, style, shadow, ToolTipPosition, EnableToolTips, …)

       |

       +-- Dictionary<Control, …> per-control Title / Description / Image

       |

       +-- Hooks: MouseEnter / MouseLeave / MouseDown (+ Disposed cleanup)

             |

             +-- timers (initial show delay; optional auto-close)

             |

             v

       [VisualPopupToolTip]  <-- PaletteRedirect + IContentValues + IRenderer

```

- **Content** shown in the popup implements **`IContentValues`**. Per-control associations use an internal **`PerControlToolTipContent`** adapter (maps **title → short text**, **description → long text**, optional **image**).

- **Placement** (unless legacy cursor mode): **`VisualPopupToolTip.ShowRelativeTo(Control, Point, PopupPositionValues)`**, which delegates to **`ApplyPlacementAndShow`** so behaviour stays aligned with **`ShowRelativeTo(ViewBase, Point)`**.

---

## Getting started

### 1. Add the component

- In the designer: drag **`KryptonToolTip`** onto the form from the toolbox ( **`Krypton.Toolkit`**).

- In code:

```csharp

var tips = new KryptonToolTip(components); // participates in IDisposable with container

tips.ContainerControl = this;               // optional: improves DPI scaling context when no control is hovered

```

### 2. Assign tooltips

#### Designer (extended properties)

On each **`Control`**, expand the extender entries provided by **`KryptonToolTip`** (often named after your component instance, e.g. `kryptonToolTip1`):

| Extender property | Purpose |
| ------------------- | --------- |
| **KryptonToolTipTitle** | Heading / short text (SuperTip-style title strip). |
| **KryptonToolTipDescription** | Body / longer description. |
| **KryptonToolTipImage** | Optional image beside the tooltip content. |

You need **non-empty title and/or description and/or image** for a tooltip to register; clearing all unregisteres hooks for that control.

#### Code (`SetToolTip`)

```csharp

kryptonToolTip1.SetToolTip(button1,

    title: "Save",

    description: "Writes the document to disk.",

    image: null,

    imageTransparentColor: default);

```

#### Clear

```csharp

kryptonToolTip1.ClearToolTip(button1);

```

### 3. Tune shared settings

Inspect **`ToolTipValues`** on the component (delays, style, shadow, **`ToolTipPosition`**, **`EnableToolTips`**).  

Run **`StartScreen → KryptonToolTip`** or open **`KryptonToolTipTest`** for a minimal interactive check.

---

## `KryptonToolTip` API

### Class

| Type | Description |
| --- | --- |
| **Namespace** | `Krypton.Toolkit` |
| **Base types** | `Component`, **`IExtenderProvider`** |
| **Toolbox** | Yes (`ToolboxItem(true)`, bitmap from **`System.Windows.Forms.ToolTip`**) |
| **Default property (designer)** | **`ToolTipValues`** |
| **`CanExtend`** | Returns **`true`** for any **`Control`**. |

### Constructors

| Signature | Notes |
| --------- | ----- |
| `KryptonToolTip()` | Typical for code-first usage; subscribes to **`KryptonManager.GlobalPaletteChanged`**. |
| `KryptonToolTip(IContainer container)` | Adds **`this`** to **`container`** (standard WinForms disposable pattern). |

### Public members (palette)

|Member|Type|Description|
|---|---|---|
|**`PaletteMode`**|`PaletteMode`|Palette source when not using a custom **`Palette`**. Updating a **non-Custom** mode refreshes redirector/renderer. **`Custom`** is a transition state until **`Palette`** is set.|
|**`Palette`**|`PaletteBase?`|Getter returns the custom palette **only when** **`PaletteMode == Custom`**; assigning a **`PaletteBase`** forces **Custom**. Assign **`null`** to return to **`Global`** and **`CurrentGlobalPalette`**.|

Behaviour matches the palette pattern used in components such as **`KryptonErrorProvider`**: rendering uses **`PaletteRedirect`** plus **`palette.GetRenderer()`**.

### Public members (shared tooltip configuration)

| Member | Type | Description |
| -------- | ------ | ----------- |
| **`ToolTipValues`** | `ToolTipValues` | **Content serialization object** expanded in the designer. Holds delays, **`EnableToolTips`**, shadow, **`ToolTipStyle`**, **`ToolTipPosition`**, heading/description/image inherited from **`HeaderValues`** (see below). **`EnableToolTips` is forced `true`** in **`KryptonToolTip`’s constructor** because the component’s purpose is to show tooltips. |
| **`ResetToolTipValues()`** | `void` | Resets **`ToolTipValues`** to defaults (serialization helper). |
| **`UseLegacyCursorAnchoredPlacement`** | `bool` | **`false` (default)**: obey **`ToolTipValues.ToolTipPosition`** with the **hovered control** as fallback bounds. **`true`**: use **`VisualPopupToolTip.ShowCalculatingSize`** (cursor-hotspot anchoring compatible with older `KryptonToolTip` previews). |
| **`ContainerControl`** | `ContainerControl?` | **Browsable false**. Secondary DPI/context anchor when **`GetDpiFactorFromContext`** falls back from **`_hoverControl`**. Rarely needed if tooltips originate from DPI-aware controls. |

### Programmatic API

- **`SetToolTip(Control?, string title, string description, Image? image = null, Color imageTransparentColor = default)`**: Registers or replaces association for **`control`**; unsubscribes and removes hooks when content is empty.
- **`ClearToolTip(Control?)`**: Removes association and event hooks for **`control`**.

### Extender provider API (`IExtenderProvider`)

These pairs are surfaced in the **`Properties`** window when **`CanExtend(control)` is true`:

```text

string GetKryptonToolTipTitle(Control control)

void   SetKryptonToolTipTitle(Control control, string value)



string GetKryptonToolTipDescription(Control control)

void   SetKryptonToolTipDescription(Control control, string value)



Image? GetKryptonToolTipImage(Control control)

void   SetKryptonToolTipImage(Control control, Image? value)

```

**`ProvideProperty`** names (first argument) are **`"KryptonToolTipTitle"`**, **`"KryptonToolTipDescription"`**, **`"KryptonToolTipImage"`**.

### Disposal

`Dispose(bool disposing)` unsubscribes from **`GlobalPaletteChanged`**, hides active pop-ups, clears timers, **unhooks every tracked control**, disposes **`Redirector`**, and nulls **`Renderer`** / **`PaletteInternal`**.  

Controls that are **`Dispose`**d unregister via **`Disposed`** independently.

---

## Per-control content

### Rendering contract (`IContentValues`)

The popup **`ViewDrawContent`** reads:

| Tooltip field | **`IContentValues` mapping** |
| --------------- | --------------------------- |
| **Title** (extender / `SetToolTip` **title**) | **`GetShortText()`** |
| **Description** (extender / `SetToolTip` **description**) | **`GetLongText()`** |
| **Image** | **`GetImage`**, **`GetImageTransparentColor`** |
| Overlays | Not used for **`PerControlToolTipContent`** (returns **`null`** / sensible defaults mirroring **`HeaderValuesBase`** conventions). |

### “Has content?” rule

Hooks are attached only when at least one of **title**, **description**, or **image** is considered present (`HasRenderableTextOrImage`). Whitespace-only strings are **not** treated specially beyond **`string.IsNullOrEmpty`**; prefer trimming in your own layer if you need stricter behaviour.

### SuperTip vs simple styles

Use **`ToolTipValues.ToolTipStyle`** (a **`LabelStyle`**, commonly **`SuperTip`** or **`ToolTip`**) to control layout/styling consistent with **`CommonHelper.ContentStyleFromLabelStyle`** applied when constructing **`VisualPopupToolTip`**.

### Image ownership

**`SetToolTip` / designer** assign **`Image`** references **owned by your application**. **`KryptonToolTip`** does **not** dispose assigned images.

---

## `ToolTipValues` and shared behaviour

**`ToolTipValues`** inherits **`HeaderValues`**, which in turn derives from **`HeaderValuesBase`** (**`IContentValues`**). On **`KryptonToolTip`**, **per-popup** content is **`PerControlToolTipContent`**, not the component’s **`ToolTipValues`** instance—but **timing, positioning, shadow, style, enable flag**, etc. come from **`KryptonToolTip.ToolTipValues`**.

Important members:

| Member | Typical use with **`KryptonToolTip`** |
| -------- | ------------------------------------- |
| **`EnableToolTips`** | Must stay **`true`** for tooltips to show (constructor sets **`true`**). **`false`** suppresses **`OnTargetMouseEnter`**. |
| **`ShowIntervalDelay`** | Milliseconds **before first show** after **`MouseEnter`**. (**Minimum effective interval is clamped internally**.) |
| **`CloseIntervalDelay`** | Milliseconds until **automatic hide after show**; **`0`** means stay until **`MouseLeave`**, **`MouseDown`**, dispose, etc. |
| **`ToolTipStyle`** | Maps to **`PaletteContentStyle`** via **`CommonHelper.ContentStyleFromLabelStyle`**. |
| **`ToolTipShadow`** | Passed through to **`VisualPopupToolTip`**. |
| **`ToolTipPosition`** | **`PopupPositionValues`** (placement mode, optional **`PlacementTarget`**, optional **`PlacementRectangle`**). Used when **`UseLegacyCursorAnchoredPlacement == false`**. |
| **`Heading`** / **`Description`** / **`Image`** (via **`HeaderValues`**) | **Shared defaults** inherited from **`ToolTipValues`** type—they are **not** the primary per-control pathway for **`KryptonToolTip`** (**extender fields** or **`SetToolTip`** populate **`PerControlToolTipContent`**). You can still use these for designer defaults if you extend the implementation later or for tooling consistency. |

---

## Placement

### Modes overview

When **`UseLegacyCursorAnchoredPlacement` is false** (default), the component calls:

```csharp

_visualPopup.ShowRelativeTo(hoveredControl, Cursor.Position, ToolTipValues.ToolTipPosition);

```

That overload applies the same **`ApplyPlacementAndShow`** logic as **`ShowRelativeTo(ViewBase, Point)`**, but uses:

- **`PlacementTarget`** (if **`ViewBase`**) plus its **`OwningControl`** / **`ClientRectangle`** when set on **`PopupPositionValues`**.

- Otherwise **fallback**: **`fallbackOwningControl`** = hovered control and **`fallbackPlacementRect`** = **`hoveredControl.ClientRectangle`** (converted to screen space as in the **`ViewBase`** path).

#### `PopupPositionValues` members

| Property | Role |
| ----------- | ------ |
| **`PlacementMode`** | **`PlacementMode`** enum (**WPF-aligned** semantics; see xmldocs on the enum). Default in **`PopupPositionValues`** ctor is **`Bottom`**. |
| **`PlacementTarget`** | Optional **`ViewBase`**. Rarely used from **`KryptonToolTip`** because arbitrary WinForms targets are not **`ViewBase`**; toolkit-internal views might set this in richer scenarios. |
| **`PlacementRectangle`** | Screen/world rectangle usage depends on **`PlacementMode`** branches inside **`ApplyPlacementAndShow`**; when **non-empty**, some modes use **`Screen.GetWorkingArea(controlMousePosition)`** or honour absolute placement semantics (see **`VisualPopupToolTip`** implementation). |

**`PlacementMode.Mouse`** / **`MousePoint`** use the **cursor** (and hotspot from **`CommonHelper.CaptureCursor()`)**, not control bounds—these are the modes closest to **`ShowCalculatingSize`** while still respecting the shared placement pipeline.

### `UseLegacyCursorAnchoredPlacement`

| Value | Behaviour |
| -------- | ----------- |
| **`false`** (**default**) | **`ShowRelativeTo(Control, Point, PopupPositionValues)`** with **`ToolTipValues.ToolTipPosition`**. |
| **`true`** | **`ShowCalculatingSize(Cursor.Position)`**: offset popup by cursor hotspot; **does not consult** **`ToolTipPosition`** for anchored placement geometry. Useful for migrating early prototypes or mimicking **`KryptonHelpProvider`**-style tooltip placement that used screen-point sizing. |

### Edge clip and “bounce”

Comments in **`VisualPopupToolTip`** note WPF-inspired placement; **screen-edge correction** beyond initial placement is delegated to **`Show`** / base **`VisualPopup`** behaviour as elsewhere in the toolkit. Expect similar limitations as **`ShowRelativeTo(ViewBase)`** for complex multi-monitor DPI mixes.

---

## Palette

- **`PaletteMode.Global`**: Tooltip colours track **`KryptonManager.CurrentGlobalPalette`**; **`GlobalPaletteChanged`** rebuilds **`PaletteRedirect`** and **`IRenderer`**.

- **`PaletteMode.Custom`** + **`Palette`**: Locks rendering to supplied **`PaletteBase`**.

- Other built-in modes: **`PaletteMode`** set to **`Office2007`** / **`Microsoft365`** / etc.; **`KryptonManager.GetPaletteForMode`** supplies the **`PaletteBase`**.

If **`PaletteInternal`** is unexpectedly **`null`**, **`OnShowTimerTick`** bails early and **no popup** appears.

---

## Runtime behaviour

### Event flow

1. **`MouseEnter`** on a registered control (**with** **`ToolTipValues.EnableToolTips`**): clear prior timers/popup; remember **`_hoverControl`**; start **show timer** (**`ShowIntervalDelay`**).

2. **`MouseLeave`**: tear down timers and popup; clear **`_hoverControl`**.

3. **`MouseDown`**: hides tooltip (parity with **`ToolTipManager.MouseDown`** interrupt).

4. **Show timer tick**:

   - Skips **design-mode** hierarchies (**`Site.DesignMode`** walk).

   - Skips when **`OwningForm` is null** or **`ContainsFocus == false`** (aligned with **`VisualControlBase`** “no unfocused form tooltips” policy).

   - Builds **`VisualPopupToolTip`** with current palette redirector/renderer and shows via **placement path** chosen by **`UseLegacyCursorAnchoredPlacement`**.

   - If **`CloseIntervalDelay > 0`**, starts **close timer** to **`HidePopupOnly`**.

5. **`OnCloseTimerTick`**: hides popup (**does not** remove control hooks).

### DPI

Construction uses **`GetDpiFactorFromContext`**: **`_hoverControl`**’s **`DeviceDpi / 96f`**, falling back to **`ContainerControl`**, otherwise **`1.0`**.

### Threading

All hooks are **Windows Forms UI thread**. Do not call **`SetToolTip`** from background threads **without marshalling** to the control’s thread.

### Multiple `KryptonToolTip` components

Avoid assigning **different extender namespaces** onto the **same** **`Control`** from **two** provider instances (ambiguous designer **property names**, duplicate **`MouseEnter`** hooks). Prefer **one** provider per **`Form`/user-control** subtree.

### Interaction with **`Krypton*` built-in tips**

A **`KryptonButton`** already has **`ToolTipValues`** and **`VisualControlBase`** tooltip handling. Showing **another** tooltip via **`KryptonToolTip`** on the same **`KryptonButton`** can mean **two** tooltip systems coexist; developers usually pick **either** embedded **`ToolTipValues`** **or** **`KryptonToolTip`**, unless intentionally layered (not recommended without testing).

---

## Comparison with alternatives

| Approach | Strengths | Trade-offs |
| ---------- | ----------- | ------------ |
| **`System.Windows.Forms.ToolTip`** | Native theming/lightweight designer story. | **Not** **`VisualPopupToolTip`**; cannot share Krypton **`PaletteBase`** styling trivially. |
| **`VisualControlBase.ToolTipValues`** | Integrated **`ToolTipManager`** + **`ViewBase`** hit testing. | Only on **Krypton** visual controls hierarchy. |
| **`KryptonErrorProvider`** (tooltip facet) | Themed **`VisualPopupToolTip`** beside error chrome. | Tied **error** workflow + icon hit regions, **not** general-purpose per-control rects. |
| **`KryptonHelpProvider`** | Help plumbing + contextual strings. | Help-centric; not a **`ToolTip` replacement** mapping. |
| **`KryptonToolTip`** | **General** **`Control`** surface; **`IExtenderProvider`** story; **`SetToolTip`**. | **Managed** **`Mouse*`** hooks vs native **`ToolTip`** window; **`PlacementTarget`** (**`ViewBase`**) rarely ergonomic from arbitrary WinForms. |

---

## Limitations and good practices

1. **Child hit testing**: Tooltips attach to **`Control`** instances chosen by you. Parent **`Panel`** **vs** **`Button`** child—hover **regions** correspond to **`Control`** **client rects** independently (standard WinForms event routing).

2. **Rapid nesting moves**: Leaving one control for a child inside the parent may **tear down** timers briefly (same class of flicker as classic WinForms **`ToolTip`**).

3. **Focus gate**: Tooltip **won’t display** while **`FindForm().ContainsFocus` is false**—by design symmetry with **`VisualControlBase`**.

4. **`ToolTip.AssociatedControl` analogue**: Not exposed; **`KryptonToolTip`** keeps an **internal dictionary** instead.

5. **Accessibility**: Narrator/other tools may classify these as **`VisualPopup`** top-level visuals; validate if you expose **critical** **`AccessibleName`** on targets alongside tooltips.

### Recommended practices

- Set **`ContainerControl`** on the **host form** when creating **`KryptonToolTip`** in code without a designer.

- Centralize **one** **`KryptonToolTip`** per **logical surface** (form / user control).

- Document **`ToolTipPosition`** decisions for support—users often expect **Bottom** under mouse-heavy UIs but **Right** for narrow columns.

- For **infinite** display, set **`CloseIntervalDelay = 0`** (see also **Tooltip timeout** discussions in the broader toolkit changelog).

---

## Extending or integrating

### `VisualPopupToolTip` overloads relevant to callers

| Method | Use |
| -------- | ----- |
| **`ShowRelativeTo(ViewBase, Point)`** | Existing **`VisualControlBase`** path (**unchanged externally** besides shared **`ApplyPlacementAndShow`** and **`OwningControl` null fallback** → **`ShowCalculatingSize`**). |
| **`ShowCalculatingSize(Point)`** | Simple screen-point anchored popup with **preferred size**. |
| **`ShowRelativeTo(Control, Point, PopupPositionValues)`** | Explicit **control fallback** rectangle + **`PopupPositionValues`** when **`IContentValues` is not `ToolTipValues`** ( **`KryptonToolTip`** scenario). |
| **`ApplyPlacementAndShow` (private)** | Single source for placement math (**do not duplicate** externally). |

Third-party wrappers can mimic **`KryptonToolTip`** by composing **`PaletteRedirect`** + **`ToolTipValues.ToolTipPosition`** + **`VisualPopupToolTip`** the same way, but **reuse** **`ShowRelativeTo(Control, Point, PopupPositionValues)`** rather than forks of placement maths.

### Implemented follow-ups

Recent follow-ups from community demand now implemented:

- **Keyboard/focus activation parity** via **`EnableKeyboardToolTips`** (`true` by default): focus entry (`GotFocus`) schedules tooltip display using the same delays and rendering path as mouse hover, and focus exit (`LostFocus`) cancels the popup for that control.

- **Control-bound placement-rectangle helpers**:
  - **`SetPlacementRectangle(Control, Rectangle, bool isScreenCoordinates = false)`**
  - **`GetPlacementRectangle(Control)`**
  - **`ClearPlacementRectangle(Control)`**
  These feed an effective **`PopupPositionValues`** instance so placement can be authored per control without manual rectangle conversion.

- **Control timer-flow deduplication**: mouse and keyboard activation now share a single `ScheduleShow(...)` path inside `KryptonToolTip`, reducing duplicated lifecycle logic and keeping behaviour aligned across input modes.

Contributions should continue to target **`VisualPopupToolTip`** once—**`ApplyPlacementAndShow`** remains canonical placement logic.
