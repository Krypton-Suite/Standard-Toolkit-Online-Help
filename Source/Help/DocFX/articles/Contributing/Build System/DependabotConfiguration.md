# Dependabot Configuration

This document explains how `.github/dependabot.yml` keeps the Krypton Standard Toolkit workflows up to date, and how to extend it safely.

## File Purpose and Scope

- **Update focus:** GitHub Actions only (`package-ecosystem: "github-actions"`). Application/package dependencies are not managed here.
- **Coverage:** Entire repository (`directory: "/"`), so every workflow under `.github` is scanned.
- **Frequency:** Weekly checks (`schedule.interval: weekly`) are typically triggered Monday in UTC—GitHub may adjust slightly.
- **Target branch:** Pull requests land on `alpha`, matching the branch where workflows are authored.
- **Routing:** PRs auto-request the `Krypton-Suite/reviewers` team and carry the `workflow:dependancies` label for triage automation.

## Field-by-Field Reference

| Field | Meaning | When to change |
| --- | --- | --- |
| `version: 2` | Dependabot manifest format. | Only change if GitHub introduces v3 in future. |
| `updates` | Array of ecosystems Dependabot manages. Currently single entry. | Add more entries for other ecosystems (NuGet, npm, etc.). |
| `package-ecosystem` | Specifies dependency source. `"github-actions"` instructs Dependabot to inspect workflow actions and composite actions. | Switch/add ecosystems to monitor other dependency types. |
| `directory` | Path relative to repo root to scan. `/` means scan entire repo. | Set to subfolders when scoping updates per solution or project. |
| `schedule.interval` | Update cadence. Options: `daily`, `weekly`, `monthly`. | Increase frequency for critical dependencies; decrease if reviewing PRs is burdensome. |
| `target-branch` | Branch where Dependabot raises PRs. | Update when default development branch changes. |
| `reviewers` | GitHub users/teams auto-requested. | Align with team responsible for workflows. |
| `labels` | Labels attached to the PR. | Keep consistent with label taxonomy for automation/search. |

## Typical Change Workflow

1. **Decide the scope:** For new dependency types (e.g., NuGet), add another item under `updates` with the appropriate `package-ecosystem`, `directory`, and schedule.
2. **Pick schedule + limits:** If noise is a concern, start with `monthly` and later increase.
3. **Route reviews:** Add `reviewers` and `labels` so triage and routing match owner teams.
4. **Validate:** Commit the change, open a PR, and ensure Dependabot runs successfully (check the `Dependabot` tab in GitHub).

## Gotchas

- Dependabot only updates actions referenced via semantic versions or SHAs. Ensure workflows pin actions to versions (e.g., `actions/checkout@v4`) for Dependabot to detect updates.
- When adding ecosystems like `nuget`, Dependabot needs direct access to each project’s manifest (`*.csproj`, `packages.config`). Validate paths carefully when the repository uses multiple solutions.
- The `workflow:dependancies` label is spelled intentionally; match existing automation that may rely on it.

## Troubleshooting

- **Dependabot PRs missing:** Confirm the `Dependabot` GitHub app is enabled for the repo and that scheduled runs are not disabled under repository settings.
- **Wrong target branch:** Dependabot does not automatically follow default-branch changes. Update `target-branch` manually when branching strategy changes.
- **Noise from flaky updates:** Use Dependabot’s `ignore` rules (not currently present) to suppress specific versions or packages that should not be updated automatically.

Keeping this configuration current ensures workflow dependencies stay secure without manual chasing of GitHub Action releases. Update this document whenever `.github/dependabot.yml` changes.

