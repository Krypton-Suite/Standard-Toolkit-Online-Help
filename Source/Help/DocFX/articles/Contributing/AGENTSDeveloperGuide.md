# AGENTS.md Developer Guide

This document explains the **AGENTS.md** feature in the Krypton Standard Toolkit repository: what it is, how AI-assisted development tools use it, how its content is organized, and how maintainers should evolve it over time.

For the live rules file itself, see [AGENTS.md](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/AGENTS.md) at the repository root. To view the `nightly` version, see [AGENTS.md](https://github.com/Krypton-Suite/Standard-Toolkit/blob/alpha/AGENTS.md) on the `alpha` branch.

---

## Table of contents

1. [Overview](#overview)
2. [Industry context and adoption](#industry-context-and-adoption)
3. [How tools consume AGENTS.md](#how-tools-consume-agentsmd)
4. [Relationship to other documentation](#relationship-to-other-documentation)
5. [Content architecture](#content-architecture)
6. [Section reference (in depth)](#section-reference-in-depth)
7. [Maintenance workflow](#maintenance-workflow)
8. [Verification and troubleshooting](#verification-and-troubleshooting)
9. [Evolution and changelog](#evolution-and-changelog)
10. [FAQ](#faq)

---

## Overview

**AGENTS.md** is a repository-root Markdown file that gives **persistent, machine-readable project instructions** to AI coding assistants (Cursor, GitHub Copilot, Codex, Windsurf, and similar tools).

Its purpose in this repository is to:

- Put humans and AI agents on the **same page** about build commands, folder layout, coding conventions, and contribution norms.
- Reduce repeated explanations in every chat session (“use PowerShell, not Bash”, “don’t parallel-build all Krypton.* projects”, “C# 7.3 compatibility”, and so on).
- Capture **lessons learned from real agent sessions**—especially shell and tooling pitfalls—in one durable place.

AGENTS.md is **not** application runtime code. It does not ship in NuGet packages. It is **contributor and automation infrastructure**, similar in spirit to `.editorconfig` or `CONTRIBUTING.md`, but optimized for LLM context injection.

### Key facts

| Property | Value |
|----------|-------|
| **Location** | Repository root: `AGENTS.md` |
| **Format** | Markdown (UTF-8) |
| **Audience** | AI agents first; human contributors second |
| **Introduced** | [#2444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2444) (V100, August 2025) |
| **Maintainers** | Any contributor; changes via normal PR review |

---

## Industry context and adoption

### The agents.md convention

The [agents.md](https://agents.md) initiative standardizes the **filename** `AGENTS.md` at a repository root. Before that agreement, tools used inconsistent names (`AGENT.md`, `.cursorrules`, tool-specific config files, etc.).

Important nuance from the original feature discussion ([#2444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2444)):

- The **standard is the naming**, not a mandated schema for file contents.
- Tools pass the file’s text into the **start of an agent conversation** (or equivalent system context), not to “bots” as standalone executables.
- Repositories may put **whatever instructions they need** inside the file.

Krypton Suite adopted `AGENTS.md` so that all major AI tools can discover the same file without per-tool duplication.

### Why this repository needs it

The Standard Toolkit is unusually demanding for automated assistants:

- **Windows-only** build scripts (`.cmd`), MSBuild orchestration, and Visual Studio version profiles.
- **Multi-target** builds (`net472` through `net11.0-windows`) with environment-dependent TFM sets.
- **Shared output directories** that forbid naive parallel project builds.
- **WinForms** designer constraints, global usings, BSD license headers, and **C# 7.3** compatibility on older TFMs.
- **No formal unit test suite**—validation flows through `TestForm` and harnesses.

Without AGENTS.md, agents repeatedly rediscover these constraints through failed builds and bad shell commands. The file front-loads that knowledge.

---

## How tools consume AGENTS.md

Different tools load repository instructions through slightly different mechanisms. The effect is the same: the model sees AGENTS.md text **before or during** reasoning about the repo.

### Cursor

In Cursor, `AGENTS.md` is typically surfaced as **always-applied workspace rules** (alongside user rules and optional `.cursor/rules`). The full file content is injected into the agent’s context for sessions opened in this workspace.

Implications for authors:

- Keep sections **scannable** (headings, bullets, short imperative lines).
- Prefer **actionable** statements (“Use PowerShell”) over narrative prose.
- Put the highest-impact guardrails **early** (see [Recent Tooling Mistakes To Avoid](#recent-tooling-mistakes-to-avoid)).

### Other tools

Tools that follow the agents.md convention (or allow a root instructions file) generally:

1. Detect `AGENTS.md` at clone/open time.
2. Prepend or merge its contents into the system prompt or project context.
3. May also honor explicit `@AGENTS.md` references in user messages.

There is **no guarantee** every tool loads the file automatically. When in doubt, `@AGENTS.md` in the prompt or linking from README (already done) improves discoverability for humans.

### What AGENTS.md is *not*

| Mechanism | Role |
|-----------|------|
| **AGENTS.md** | Repo-wide defaults for all agent work in this project |
| **`.cursor/rules/*.mdc`** | Cursor-specific, path-scoped, or conditional rules |
| **User rules** | Personal preferences in the IDE (apply across repos) |
| **Agent Skills** | Reusable task playbooks the agent reads when relevant |
| **`README.md`** | Human-facing project overview and marketing |
| **Online Help** | Long-form contributing and architecture articles |

Avoid duplicating large bodies of text across these layers. AGENTS.md should **summarize and point**; deep dives belong in Online Help or component READMEs.

---

## Relationship to other documentation

Use this split when deciding where new information belongs:

| Topic | Primary home | AGENTS.md role |
|-------|----------------|----------------|
| Quick build/run commands | AGENTS.md | Canonical short form |
| Interactive `run.cmd` menu | AGENTS.md + `run.cmd` | Entry points and paths |
| ModernBuild TUI | [Scripts/ModernBuild/README.md](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Scripts/ModernBuild/README.md) | One-line pointer |
| Branch policy / release workflow | [Online Help](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/articles/Contributing/BranchPolicyandWorkflowHardening.html) | Not duplicated |
| General contributing ethics | [Online Help Contributing](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/Source/Help/Output/articles/Contributing.html) | PR/commit summary only |
| Analyzer severities, header template | `Source/.editorconfig` | “Follow .editorconfig” |
| Palette / component internals | Component READMEs | Not in AGENTS.md |
| Long path setup | README + Online Help | One-line reminder |

Cross-links from README and sub-project READMEs (e.g. `TestForm/PaletteViewer/README.md`) intentionally send readers to AGENTS.md for **standard command invocations**.

---

## Content architecture

AGENTS.md is organized as a single “Repository Guidelines” document with fixed top-level sections. Order matters: **tooling pitfalls and environment** come before structure and build commands, because agent failures often happen before any code is touched.

```
AGENTS.md
├── Recent Tooling Mistakes To Avoid    ← agent-specific guardrails (added after field experience)
├── Environment                         ← OS, shell, VS/SDK expectations
├── Project Structure & Module Organization
├── Build, Test, and Development Commands
├── Coding Style & Naming Conventions
├── C# Rules
├── Testing Guidelines
├── Commit & Pull Request Guidelines
└── Security & Configuration Tips
```

Design principles used when editing:

1. **Imperative mood** — “Do not run build scripts unless instructed.”
2. **One fact per bullet** — easier for models to retrieve.
3. **Correct examples** — especially for shell commands; show the pattern that works on Windows.
4. **Stable paths** — use repo-relative paths consistent with README.
5. **No stale duplication** — if MSBuild discovery changes, update AGENTS.md in the same PR as `find-msbuild.cmd`.

---

## Section reference (in depth)

### Recent Tooling Mistakes To Avoid

Added after repeated failures in AI-driven sessions (notably around [#3493](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3493) build-script work). Each bullet documents:

- **What went wrong** — the failure mode.
- **Why** — brief mechanism (e.g. `cmd.exe` expands `%VAR%` before `set`).
- **Correct example** — copy-pasteable fix.

Current topics:

| Mistake | Root cause | Correct approach |
|---------|------------|------------------|
| Stash name `"%STASH_MSG%"` | `cmd.exe` one-liner `set` + use | Separate commands or PowerShell |
| PowerShell `$var` eaten by `cmd` | Nested shell quoting | Run PowerShell directly |
| `git commit -m` with `--check` in body | Git parses body as options | `git commit -F message-file` |
| `gh` quoting failures | Wrapper mishandles spaces | JSON `--input` or argument arrays |
| `git stash store -m` rename | Stash display name from original commit | Re-stash with new message |
| Over-escaped `rg` patterns | Wrong literal match | Single-quoted PowerShell pattern |
| `findstr` path experiments | Fragile on Windows | `Select-String -LiteralPath` |

**When to add a new bullet:** after an agent (or human) hits the same footgun twice, and the fix is non-obvious. Do **not** use this section for general coding style—that belongs lower in the file.

### Environment

Establishes hard constraints:

- **OS:** Windows (WinForms, `.cmd` scripts, `-windows` TFMs).
- **Shell for agents:** PowerShell for agentic terminal use; `cmd.exe` only when reproducing batch behavior.
- **IDE:** Visual Studio 2022+ and .NET SDKs from `net472` upward.
- **Build scripts:** exist under `Scripts/` but agents must **not** run them unless the user explicitly asks—full solution builds are expensive and may require local VS profiles.

This section prevents the most common cross-platform agent mistake: running Bash idioms or `dotnet` commands that ignore the repo’s MSBuild orchestration.

### Project Structure & Module Organization

Maps the monorepo layout:

| Path | Purpose |
|------|---------|
| `Source/Krypton Components/` | Core libraries + main `.sln` |
| `Source/Krypton Components/TestForm/` | Sample app for manual validation |
| `Source/TestHarnesses/` | Focused repro projects |
| `Scripts/` | Build/packaging; `VS2022`, `Current`, `Build` subfolders |
| `Bin/` | Default build output (`<Configuration>/<TFM>/`) |
| `Documents/`, `Assets/`, `Logs/` | Docs, images, build logs |

Agents use this to place new files correctly and to find the solution file name verbatim:

`Krypton Toolkit Suite 2022 - VS2022.sln`

### Build, Test, and Development Commands

The most frequently consulted section. It encodes three **tiers** of build workflow:

#### Tier 1 — Everyday developer (`dotnet`)

```powershell
dotnet build ".\Source\Krypton Components\Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
dotnet run --project ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug
```

Appropriate when the user wants a quick compile or to launch TestForm. SDK MSBuild respects `Directory.Build.props` TFM filtering.

#### Tier 2 — Channel scripts (explicit user request only)

| Entry | Toolset | Profile |
|-------|---------|---------|
| `.\run.cmd` | Interactive menu | Chooses VS2022 vs Current |
| `Scripts\VS2022\build-*.cmd` | Visual Studio 2022 | `2022` |
| `Scripts\Current\build-*.cmd` | VS 2026 / major 18+ | `current` |

Scripts call `Scripts\Common\find-msbuild.cmd` with the profile, then MSBuild on `build.proj`.

**MSBuild override:** set `MSBUILDPATH` or `MSBUILD_PATH` to the folder containing `MSBuild.exe` (typically `...\MSBuild\Current\Bin`).

#### Tier 3 — Phased orchestration (CI and scripts)

`Scripts/Build/Krypton.Orchestration.targets` defines **phased** builds:

1. `Krypton.Toolkit` (sequential—foundation)
2. `Krypton.Ribbon` + `Krypton.Navigator` (parallel with each other)
3. `Krypton.Workspace`, then `Krypton.Docking`
4. Satellite utility projects and packaging targets

**Critical rule for agents:** do **not** build all `Krypton.*` projects in one parallel MSBuild batch. Projects share `Bin/<Configuration>/<tfm>/` outputs; parallel races corrupt outputs. Scripts use `/m` **within** a project for multi-TFM parallelism, not across the whole component set at once.

#### Target frameworks

TFMs are selected in `Source/Krypton Components/Directory.Build.props` based on:

| Condition | Typical TFMs |
|-----------|----------------|
| VS 2019 / `ExcludeModernTargetFrameworks` | `net472`, `net48`, `net481` |
| VS 2022 / `ExcludeVs2022UnsupportedTargetFrameworks` | Above + `net8.0-windows`, `net9.0-windows` |
| Full VS 2026, `ExcludeNet11` not set | Adds `net10.0-windows`, `net11.0-windows` |
| `TFMs=all` on script builds | Widest set supported by toolset |

CI and SDK builds may see more TFMs than a local VS2022 full MSBuild session.

#### Output paths

- Default: `Bin\<Configuration>\<TargetFramework>\`
- With `UseArtifactsOutput=true`: `artifacts\bin\<Configuration>\<TargetFramework>\`

#### License header note

New files use the **current Standard Toolkit BSD header** from `Source/.editorconfig` (`file_header_template`). Do not use the legacy ComponentFactory header unless the file is derived from original ComponentFactory source.

### Coding Style & Naming Conventions

Points agents at authoritative sources:

- **`.editorconfig`** under `Source/` — headers, analyzer severities, C# style.
- **UTF-8 with BOM**, **CRLF**, **4-space** indentation.
- **`global using`** in each project’s `GlobalDeclarations.cs` — agents must **not** add redundant `using` lines in ordinary source files.
- **No variable aliasing**; reuse existing variables when possible.

### C# Rules

Repository-specific C# contract beyond style:

| Rule | Rationale |
|------|-----------|
| Surgical edits | Avoid drive-by refactors in agent PRs |
| No empty `try/catch` | Noise without handling |
| Fix warnings in touched code | Keep analyzer debt from growing |
| Switch expressions vs statements | Expressions for pure dispatch only |
| **C# 7.3 / `net472`** | Language features must not break oldest TFM |
| WinForms designer patterns | Fields at bottom; init in `Designer.cs` |
| No `yield return` in `catch` | Compiler/runtime constraint |

### Testing Guidelines

No xUnit/NUnit suite. Validation path:

1. **TestForm** — interactive scenarios, menu-launched tools (e.g. PaletteViewer).
2. **TestHarnesses** — minimal repros for isolated bugs.

Bug-fix PRs should add or adjust a repro and describe **manual test steps** in the PR body.

### Commit & Pull Request Guidelines

Aligns with team practice:

- Imperative commit subjects with issue/PR references: `Fix autosizing (#2433)`.
- PRs: description, linked issues, UI screenshots, breaking-change notes.
- Avoid boilerplate “validation noise” in commits/PRs unless checks failed or context is essential.

### Security & Configuration Tips

- **Long paths** must be enabled on Windows for local builds (see README / Online Help).
- **`-windows` TFMs** require building on Windows.

---

## Maintenance workflow

### When to update AGENTS.md

Update in the **same PR** when you change:

- Build script paths, profiles, or orchestration
- Default shell expectations for automation
- TFM matrix or output directory layout
- Testing strategy (e.g. new harness location)
- License header policy
- Agent-observed tooling mistakes (new bullet under “Recent Tooling Mistakes”)

### When *not* to update

- Feature implementation details confined to one component
- Version release notes (use `Documents/Changelog/Changelog.md`)
- One-off user preferences (user rules)
- Lengthy tutorials (Online Help or `Scripts/ModernBuild/README.md`)

### Editing checklist

1. Read the changed area in the real script or props file—AGENTS.md must match reality.
2. Keep bullets **short**; link out for essays.
3. Prefer PowerShell examples for agent shell commands.
4. If removing obsolete guidance, grep the repo for references (`README.md`, sub-READMEs).
5. Note significant updates in `Documents/Changelog/Changelog.md` when the change is user-visible to contributors.

### Review criteria

Reviewers should ask:

- Would an agent follow this without extra context?
- Is there a **correct example** for every “do not”?
- Does this duplicate README without adding agent-specific value?
- Did we document **why** (one phrase), not just **what**?

---

## Verification and troubleshooting

There is no CI job that lints AGENTS.md compliance. Verification is **manual and observational**.

### Smoke tests with Cursor (recommended)

1. Open the repo in Cursor Agent mode.
2. Ask: *“Build the solution in Debug and run TestForm.”*
   - Expect: PowerShell, quoted paths, `dotnet build` / `dotnet run`—not `Scripts\build-stable.cmd` unless asked.
3. Ask: *“Add a new public method to a Toolkit control.”*
   - Expect: no new `using` lines; C# 7.3-safe syntax; BSD header on new files.
4. Ask: *“Stash my changes with message X.”*
   - Expect: no `cmd.exe` one-liner stash bugs from the mistakes section.

### Signs AGENTS.md is stale

- Agents propose deprecated paths (`Scripts/build-stable.cmd` at root without `VS2022/`).
- Agents use Bash (`ls`, `cat`, `export`).
- Agents parallel-build multiple `Krypton.*` csproj files.
- Agents add `using System;` to files in projects with `GlobalDeclarations.cs`.

If you observe drift, fix AGENTS.md **and** consider whether README or script comments also need alignment.

### Explicit invocation

Users can attach context in any tool that supports file references:

```
@AGENTS.md Please fix the build error in TestForm.
```

This is useful when workspace rules are disabled or when using tools that do not auto-load the file.

---

## Evolution and changelog

| Date / version | Change |
|----------------|--------|
| **V100 (Aug 2025)** | [#2444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2444) — initial `AGENTS.md`; `cmd.exe` shell guidance; basic build commands |
| **Subsequent** | Phased orchestration documented; `run.cmd` VS2022 vs Current split |
| **#3493** | Script/TFM fixes; expanded build/MSBuild instructions; **Recent Tooling Mistakes** section |
| **#3319** | `UseArtifactsOutput` / artifacts path note |
| **Ongoing** | PowerShell as primary agent shell; `find-msbuild.cmd` profiles; license header policy |

Initial file (V100) emphasized `cmd.exe` only. Current file intentionally prefers **PowerShell for agentic work** while retaining `cmd.exe` for batch fidelity—a deliberate shift after production agent sessions.

Git history for the file:

```powershell
git log --oneline --follow -- AGENTS.md
```

---

## FAQ

### Is the file content standardized by agents.md?

**No.** Only the **filename and location** are standardized. Content is repository-specific.

### Which tools automatically read AGENTS.md?

Any tool that implements the [agents.md](https://agents.md) convention or documents root-level agent instructions. The exact list changes as vendors ship updates; Cursor is known to apply it as workspace rules in this repo. When unsupported, reference the file manually.

### How is this different from CONTRIBUTING.md?

`CONTRIBUTING.md` is a GitHub convention for **human** contributors. This repo routes long-form human guidance to **Online Help**. AGENTS.md is optimized for **LLM context**—shorter, more imperative, and including automation pitfalls humans rarely document.

### Should we add `.cursor/rules` too?

Optional. Use `.cursor/rules` for **path-specific** or **conditional** Cursor-only rules. Keep universal truths in AGENTS.md so other tools benefit.

### Can we test agents “before they start reasoning”?

Not externally. Validation is indirect: open a fresh agent session and spot-check behavior (see [Verification](#verification-and-troubleshooting)). Some IDEs show which rules were loaded—use that to confirm AGENTS.md is present.

### Do agents run CI build scripts by default?

**They should not.** AGENTS.md explicitly forbids running `Scripts/` build presets unless the user instructs. This prevents accidental long builds and log churn on contributor machines.

### What about non-Windows contributors?

WinForms and `-windows` TFMs require Windows for meaningful builds. AGENTS.md states this plainly. Documentation edits and issue triage can happen on any OS; compile validation cannot.
