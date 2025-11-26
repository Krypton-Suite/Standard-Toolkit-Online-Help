# Release Workflow Kill Switches

## Purpose
Kill switches give maintainers an emergency brake for every automated release channel without having to edit `.github/workflows/release.yml`. Setting the appropriate repository variable forces the corresponding job to short-circuit before any tooling runs, which is safer than letting a known-bad build progress and fail later in the pipeline.

## How the guard works

### 1. Each job starts with a PowerShell probe
Every release job begins with a `Kill Switch Check` step that reads a repository variable, writes a warning when the switch is active, and emits an `enabled` output. When the switch is off (`false` or undefined), the step prints a pass message and sets `enabled=true` so the remainder of the job can execute.

```21:36:.github/workflows/release.yml
- name: Release Kill Switch Check
  id: release_kill_switch
  shell: pwsh
  run: |
    $disabled = '${{ vars.RELEASE_DISABLED }}'
    if ($disabled -eq 'true') {
      Write-Host "::warning:: Release workflow is currently DISABLED via kill switch (RELEASE_DISABLED=true)"
      echo "enabled=false" >> $env:GITHUB_OUTPUT
    } else {
      echo "enabled=true" >> $env:GITHUB_OUTPUT
    }
```

### 2. All downstream steps are gated
Every subsequent action in the job checks the `enabled` output. If the switch is active the expression evaluates to `false`, GitHub skips the step, and the build/page/publish stages never start.

```38:115:.github/workflows/release.yml
- name: Build Release
  if: steps.release_kill_switch.outputs.enabled == 'true'
  run: msbuild "Scripts/build.proj" /t:Build /p:Configuration=Release /p:Platform="Any CPU"
- name: Push NuGet Packages to nuget.org
  if: steps.release_kill_switch.outputs.enabled == 'true'
  id: push_nuget
  shell: pwsh
```

## Configuration

| Branch / Job Id | Variable name | Protected artifacts |
| --- | --- | --- |
| `master` (`release-master`) | `RELEASE_DISABLED` | Stable builds, packages, Discord master announcement |
| `V105-LTS` (`release-v105-lts`) | `RELEASE_DISABLED` | Latest LTS stream (shares the same switch to avoid drift) |
| `V85-LTS` (`release-v85-lts`) | `LTS_DISABLED` | Legacy LTS channel |
| `canary` (`release-canary`) | `CANARY_DISABLED` | Canary builds and related Discord/webhook posts |
| `alpha` (`release-alpha`) | `NIGHTLY_DISABLED` | Nightly/alpha drops and notifications |

> Why two LTS jobs share `RELEASE_DISABLED`: the V105 branch follows the same release cadence as `master`, so maintainers typically want to freeze both at once. If you need V105 to keep running while master is frozen, temporarily duplicate the kill-switch step under a new variable before toggling.

### Setting or clearing a switch
1. Open the repository in GitHub and navigate to **Settings → Secrets and variables → Actions → Variables**.
2. Select the variable listed above or create it if it does not exist.
3. Set the value to the string `true` to disable that job. Leave it empty or set to `false` to allow runs. Please note that these values are case sensitive and **must** always be in lowercase.
4. Save. The next workflow run on the matching branch will respect the new state without requiring a commit.

### Verifying the state during a run
* When disabled, the job log shows the warning emitted by the PowerShell step and the job exits with a green “Skipped” badge because all guarded steps evaluate to false.
* When enabled, the log includes “kill switch check has passed” and normal build/pack/publish steps begin immediately afterward.

## Operational playbook

**Freezing a channel before a risky commit**
1. Flip the relevant variable to `true`.
2. Push your work—CI will run but the guarded job will skip, preventing packages and notifications.
3. Once the branch is healthy again, set the variable back to `false` and rerun the latest workflow from the Actions tab if you need artifacts.

**Recovering after an accidental freeze**
1. Confirm the variable value in Settings.
2. Re-enable (`false`), then re-run the failed workflow from Actions → select the skipped run → “Re-run all jobs”. Because kill switches act at runtime, no workflow edits are required.

**Auditing who changed a switch**
Repository variables track the last editor in the activity log (**Settings → Audit log**). Filter for `repo.variable.update` events to see when and by whom a kill switch was toggled.

## Extending the pattern
To add a new kill switch (e.g., for a future `beta` branch), copy the existing pattern:
1. Add a `Kill Switch Check` step with a unique `id` and variable name.
2. Gate every subsequent step with `if: steps.<id>.outputs.enabled == 'true'`.
3. Document the variable under Configuration so on-call engineers know which switch to flip.

Keeping the guard self-contained inside the workflow ensures you can pause or resume publishing safely even while other infrastructure (NuGet, Discord, etc.) stays configured.

