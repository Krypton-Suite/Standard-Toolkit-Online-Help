# Krypton Logger

Native logging for applications that use `Krypton.Toolkit.Utilities` without taking a dependency on NLog, Serilog, or `Microsoft.Extensions.Logging`.

Related: [issue #4223](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4223). Builds on the thin toolkit hook from [#3856](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3856) (`IKryptonLogger` / `KryptonLogger`) and splash logging from [#4180](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4180).

## Overview

| Piece | Assembly | Role |
| --- | --- | --- |
| `IKryptonLogger` / `KryptonLogger` | `Krypton.Toolkit` | `Write(string)` diagnostic hook used by `CommonHelper.LogOutput` and theme-swap WM tracing. Unchanged. |
| `KryptonLog` | `Krypton.Toolkit.Utilities` | Opt-in pipeline: levels, named loggers, filters, sinks, viewer. |

Until `KryptonLog.Configure` is called, `ForContext` is a no-op and toolkit diagnostics keep using `DefaultKryptonLogger`. Utilities never replaces the toolkit logger unless the app calls `InstallAsToolkitLogger()`.

Package: `Krypton.Standard.Toolkit` (`Krypton.Toolkit.Utilities` assembly). Compatible with `net472` and later Windows TFMs. JSON configuration is `net8.0-windows` and later only.

## Architecture

```
App / splash / exception dialog
        |
        v
IKryptonContextualLogger (named category)
        |
        v
KryptonLogFilter (global min level + prefix overrides)
        |
        +--> sync sinks: Debug, Trace, Memory, Callback
        +--> async queue --> File, EventLog
```

Disabled writes return before message templates are rendered. File and Event Log default to a bounded background queue (drop Trace/Debug when full; block Error/Fatal). The memory ring buffer is written on the calling thread so the viewer stays current.

## Public API

- `KryptonLog` — `Configure`, `ConfigureFromXml`, `ConfigureFromJson` (net8+), `ConfigureFromEnvironment`, `ForContext`, `CloseAndFlush`, `InstallAsToolkitLogger`, `AsKryptonLogger`
- `KryptonLogLevel` — Trace, Debug, Information, Warning, Error, Fatal
- `IKryptonContextualLogger` — also implements `IKryptonLogger.Write` as Information
- `IKryptonLogSink` / `KryptonLogEvent` / `KryptonLogLayout`
- `KryptonLogConfiguration` — fluent `MinimumLevel`, `Override`, `WriteTo.*`, `Enrich`, `Async` / `Sync`
- `KryptonLogViewer` — themed viewer over the memory sink
- `KryptonLogMicrosoftExtensions` — delegate bridges; no MEL package reference

### Usage

```csharp
KryptonLog.Configure(cfg => cfg
    .MinimumLevel(KryptonLogLevel.Debug)
    .Override("Krypton.Toolkit", KryptonLogLevel.Warning)
    .WriteTo.Debug()
    .WriteTo.File(path: null, rollOnSizeBytes: 5_000_000, retainedFileCount: 7)
    .WriteTo.Memory(capacity: 2000)
    .Enrich.WithThreadId()
    .Async());

KryptonLog.InstallAsToolkitLogger();

var log = KryptonLog.ForContext("MyApp.Startup");
log.Information("Starting {Step}", "load-theme");
log.Error(ex, "Failed {Step}", "load-theme");

KryptonLogViewer.Show();
```

Call `KryptonLog.CloseAndFlush()` during shutdown.

Default file path when none is supplied: `%LOCALAPPDATA%\Krypton-Suite\Toolkit\Krypton.log` (UAC-safe, same idea as #3856).

### Message templates

Named `{UserId}` and positional `{0}` holes are supported, with optional format (`{Value:N2}`). Arguments bind in order; hole names become `KryptonLogEvent.Properties`. There is no Serilog `{@obj}` destructuring.

## Configuration files

### XML (all TFMs)

```xml
<kryptonLog minimumLevel="Debug" async="true" queueCapacity="4096">
  <overrides>
    <override category="Krypton.Toolkit" level="Warning" />
  </overrides>
  <enrich threadId="true" machineName="false" />
  <writeTo>
    <debug />
    <file path="" rollOnSizeBytes="5000000" retainedFileCount="7" rollOnDate="true" />
    <memory capacity="2000" />
  </writeTo>
</kryptonLog>
```

`KryptonLog.ConfigureFromXml(path)` / `SaveToXml(path, configuration)`.

### JSON (`net8.0-windows`+)

```json
{
  "minimumLevel": "Debug",
  "async": true,
  "writeTo": [
    { "name": "debug" },
    { "name": "file", "rollOnSizeBytes": 5000000, "retainedFileCount": 7 },
    { "name": "memory", "capacity": 2000 }
  ]
}
```

### Environment

`KryptonLog.ConfigureFromEnvironment()` is explicit (not run on first `ForContext`):

| Variable | Meaning |
| --- | --- |
| `KRYPTON_LOG_CONFIG` | Path to XML, or JSON on net8+ |
| `KRYPTON_LOG` | When truthy (`1`/`true`/`yes`/`on`) and no config file, enable Debug + rolling file |
| `KRYPTON_LOG_PATH` | File path override |
| `KRYPTON_LOG_WM` | Legacy toolkit WM file path; used if `KRYPTON_LOG_PATH` is unset |

After `InstallAsToolkitLogger()`, lines starting with `[WM] ` use category `Krypton.Toolkit.WM` at Debug; other toolkit lines use `Krypton.Toolkit` at Information.

## Microsoft.Extensions.Logging (optional)

Utilities does not reference MEL. Bridge with delegates:

```csharp
// MEL -> Krypton splash / SetLogger
KryptonLogger.SetLogger(KryptonLogMicrosoftExtensions.CreateLogger(
    message => melLogger.LogInformation(message)));

// Krypton -> MEL
cfg.WriteTo.Sink(KryptonLogMicrosoftExtensions.CreateSink(
    (level, message, ex) => melLogger.Log(Map(level), ex, message),
    level => melLogger.IsEnabled(Map(level))));
```

Map `KryptonLogLevel` onto `Microsoft.Extensions.Logging.LogLevel` in application code (Trace→Trace, Debug→Debug, Information→Information, Warning→Warning, Error→Error, Fatal→Critical).

## Dialog wiring

- **Splash:** `KryptonSplashScreenManagerData.UseKryptonLog`. When true and `Logger` is null, status lines go to `KryptonLog.AsKryptonLogger()`. Existing `Logger` / `LogCallback` are unchanged.
- **Exception dialog:** `KryptonExceptionDialog.Show(exception, new KryptonExceptionDialogOptions { IncludeRecentLog = true, ShowViewLogButton = true })`. Existing `Show` overloads are unchanged.
- **Bug report:** `KryptonBugReportingDialog.Show(exception, emailConfig, includeApplicationLog: true)` adds an “Include application log” checkbox and attaches a memory-sink excerpt (or the active file).
