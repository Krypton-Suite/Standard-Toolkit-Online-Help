# Krypton Splash Screen Manager

## Overview

Issue [#4180](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4180) asked for a splash that stays alive while the rest of the application starts: fade in/out, live status and progress, logging, background image, semi-transparency, theming, and exception handling — without blocking the owner thread, and without `Microsoft.VisualBasic` or WPF `System.Windows.SplashScreen`.

`KryptonSplashScreenManager` in **Krypton.Toolkit.Utilities** is that implementation. It is **not** a replacement for the existing modal [`KryptonSplashScreen`](../../Source/Krypton%20Components/Krypton.Toolkit/Controls%20Toolkit/KryptonSplashScreen.cs) in `Krypton.Toolkit`.

| Type | Assembly | Behaviour |
|------|----------|-----------|
| `KryptonSplashScreen` | `Krypton.Toolkit` | Modal `ShowDialog` “about-like” splash (close/minimize, timeout progress). |
| `KryptonSplashScreenManager` | `Krypton.Toolkit.Utilities` | Non-blocking splash on a dedicated STA thread. |

To use the manager, consume the `Krypton.Standard.Toolkit` NuGet package (`Krypton.Toolkit.Utilities` assembly).

## Architecture

The manager starts a background STA thread, creates an internal `VisualSplashScreenManagerForm` (borderless `Form` hosting themed Krypton controls), and runs `Application.Run(form)` so fade timers and paints keep working while the caller does blocking startup work. The window is a `Form` rather than `KryptonForm` because KryptonForm custom chrome is not safe on a secondary splash thread; `KryptonPanel`, labels, and `KryptonProgressBar` still follow the captured palette.

```
Owner STA thread                         Splash STA thread
----------------                         -----------------
Show(data)  ---- start thread ---------> new form, apply theme
            <--- wait for Handle ------- Application.Run(form)
SetStatus / SetProgress  -- BeginInvoke --> labels / progress bar
Close()     -- Invoke RequestClose ----> fade out, form.Close()
            <--- join thread ----------- pump exits
```

User close is blocked (`ControlBox` / `CloseBox` / Alt+F4). Only `RequestClose` from the manager (or Windows shutdown / Task Manager / `Application.Exit`) can close the window.

## Public API

### `KryptonSplashScreenManagerData`

Content and behaviour bag (same pattern as `KryptonFoldableDialogData`):

- Identity: `Title`, `Status`, `Logo`, `Assembly`, `ShowApplicationName`, `ShowVersion`, `ShowCopyright`
- Look: `BackgroundImage`, `BackgroundImageLayout`, `Opacity` (default `1.0`; values below 1.0 are semi-transparent), `Size`, `StartPosition`, `TopMost`
- Motion: `FadeIn`, `FadeOut`, `FadeSpeed` (`FadeSpeedChoice`)
- Border: `BorderAnimation` (`None` default, `Pulse`, `Sweep`), optional `BorderAnimationColor`, `BorderAnimationThickness`, `BorderAnimationSpeed`
- Progress: `ShowProgressBar`, `ExpectedStepCount` (each `SetStatus` advances `100 / N`; omit for marquee until `SetProgress`)
- Theme: `PaletteMode?` — null uses `PaletteMode.Global` (current `KryptonManager` theme), captured on the **caller** thread before the splash thread starts
- Logging: `IKryptonLogger? Logger` and `Action<string>? LogCallback` (no `Microsoft.Extensions.Logging` / NLog package reference; wrap those sinks in an `IKryptonLogger` or callback)
- Exceptions: `ShowExceptionDialog` (default true) shows `KryptonExceptionDialog` on the **caller** thread after the splash has closed
- Timing: `MinimumDisplayMilliseconds` (default 750) so a fast startup does not flash the window

### `KryptonSplashScreenManager`

```csharp
public sealed class KryptonSplashScreenManager : IDisposable
{
    public static KryptonSplashScreenManager Show(KryptonSplashScreenManagerData data);
    public static void Run(KryptonSplashScreenManagerData data, IList<KryptonSplashStep> steps);
    public static void Run(KryptonSplashScreenManagerData data, params KryptonSplashStep[] steps);

    public void SetStatus(string status);
    public void SetProgress(int value, int? maximum = null);
    public void Close();
    public void ReportException(Exception exception);
}
```

### `KryptonSplashStep`

`Status` plus `Action`. `Action` runs on the **caller** thread. The splash stays on its own thread.

## Usage

Show the splash, do work, close it, then start the main message pump. Do **not** call `Application.Run(mainForm)` while still holding the splash unless you intend the splash to outlive the main form.

```csharp
[STAThread]
static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);

    var data = new KryptonSplashScreenManagerData
    {
        Title = "My Application",
        Status = "Starting…",
        FadeIn = true,
        FadeOut = true,
        ShowProgressBar = true,
        ExpectedStepCount = 3,
        PaletteMode = KryptonManager.CurrentGlobalPaletteMode,
        BorderAnimation = KryptonSplashBorderAnimation.Sweep,
        LogCallback = message => Debug.WriteLine(message)
    };

    using (var splash = KryptonSplashScreenManager.Show(data))
    {
        splash.SetStatus("Loading configuration…");
        LoadConfiguration();
        splash.SetStatus("Connecting…");
        Connect();
        splash.SetStatus("Opening main window…");
        var main = new MainForm();
        splash.Close();
        Application.Run(main);
    }
}
```

Step helper (auto-progress from `steps.Count`, exceptions reported):

```csharp
KryptonSplashScreenManager.Run(data,
    new KryptonSplashStep("Loading plugins…", LoadPlugins),
    new KryptonSplashStep("Opening main window…", () => { main = new MainForm(); }));
Application.Run(main);
```

Wrap `ILogger` / NLog without taking a package dependency in the toolkit:

```csharp
data.Logger = new CallbackLogger(message => nlog.Info(message));

sealed class CallbackLogger : IKryptonLogger
{
    private readonly Action<string> _write;
    public CallbackLogger(Action<string> write) => _write = write;
    public void Write(string message) => _write(message);
}
```

## Edge cases

- **Threading:** `Show` / `SetStatus` / `Close` are safe from the owner STA thread. The owner wait for splash-handle creation pumps messages (`Application.DoEvents`) so `SystemEvents` (used by `KryptonManager`) does not deadlock or overflow on a blocked STA thread. UI updates marshal with `BeginInvoke` / `Invoke`. `KryptonManager` is warmed on the owner thread before the splash thread starts.
- **Theme:** Do not set `KryptonManager.GlobalPaletteMode` from the splash thread. Pass `PaletteMode` on the data object (or leave it null for Global).
- **Exceptions:** `Run` catches step exceptions, logs, closes the splash, then shows `KryptonExceptionDialog` on the caller thread when `ShowExceptionDialog` is true. Handle-style callers can `try/catch` and call `ReportException`. The exception tree is built from `KryptonTreeNode` instances (`TreeNode.Clone` does not preserve that type).
- **Minimum display:** `Close` waits out `MinimumDisplayMilliseconds` on the caller thread, then fades out.
- **TFM:** Same as `Krypton.Toolkit.Utilities` (`net472` and later Windows TFMs). No Visual Basic or WPF splash types.
- **Not closeable / sizable:** `FormBorderStyle.None`, no control box. Alt+F4 is cancelled unless the manager requested close.
- **Animated border:** Drawn in form padding outside the content panel so it does not depend on `KryptonForm` chrome. Default `None` leaves the splash borderless.
