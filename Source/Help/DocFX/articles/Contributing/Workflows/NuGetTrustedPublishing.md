# NuGet Trusted Publishing

Setup and operator guide for publishing Krypton packages to nuget.org from GitHub Actions without a long-lived API key. This is the implementation of [issue #4480](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4480).

Microsoft’s description of the feature is [Trusted Publishing](https://learn.microsoft.com/en-gb/nuget/nuget-org/trusted-publishing).

Local `publish.cmd`, ModernBuild, and `nuget.exe push` from a developer machine are unchanged. They still use a developer API key. See [Local publishing](#local-publishing).

## Overview

Trusted publishing exchanges a short-lived GitHub Actions OpenID Connect token for a temporary nuget.org API key. The key lasts about one hour. Nothing in the repository stores a nuget.org credential that can publish on its own.

The GitHub secret that remains is `NUGET_USER`. Its value is the nuget.org **profile name** of the account that owns the packages (the name in `https://www.nuget.org/profiles/<name>`), not an email address and not an API key.

## How a publish run authenticates

1. A publish job in this repository starts. The job must use the GitHub environment `production`.
2. Immediately before `dotnet nuget push`, the job runs `NuGet/login@v1`.
3. That action asks GitHub for an OIDC token. The workflow permission `id-token: write` is what allows that request. The token is signed by GitHub and names the repository owner, repository, workflow file, and environment.
4. nuget.org checks the token against a trusted publishing policy. The policy must match those claims.
5. nuget.org returns one temporary API key. Each OIDC token can be exchanged once. The resulting key can push every package in that job’s loop.
6. `dotnet nuget push` sends that key to `https://api.nuget.org/v3/index.json` with `--skip-duplicate`.

Request the key immediately before the push. The build can take longer than the key’s lifetime. Do not put `NuGet/login` at the start of the job.

A policy matches the **workflow file name**, not the git branch and not the job id. `release.yml` is one policy even though three jobs inside it push. Branch and kill-switch `if` conditions in the workflow are what stop the wrong job from publishing. The `production` environment on the policy is what stops a workflow file from publishing unless the job was admitted to that environment.

## Workflows that publish

Create one nuget.org policy for each of these files. Environment is `production` on every policy.

| Workflow file | Jobs that push | GitHub environment |
| --- | --- | --- |
| `release.yml` | `release-master`, `release-v105-lts`, `release-canary` | `production` |
| `canary.yml` | `canary` | `production` |
| `nightly.yml` | `nightly` | `production` |
| `release-candidate.yml` | `release-candidate` | `production` |
| `canary-lts-release.yml` | `canary-lts-release` | `production` |

`release-alpha` in `release.yml` does not push to nuget.org. It does not need its own policy. The `release.yml` policy already covers the file.

`build.yml` does not push to nuget.org and must not receive a policy.

Package ids are `Krypton.*`, including channel suffixes such as `Krypton.Toolkit.Canary`, `Krypton.Toolkit.Nightly`, `Krypton.Toolkit.Lite`, and `Krypton.Standard.Toolkit`.

## Prerequisites

- Access to the nuget.org account or organization that **owns** the `Krypton.*` packages. That is the same account the old API key belonged to. The policy owner must be that user or that organization. A policy owned by someone else cannot push those packages.
- Permission to create Actions secrets on `Krypton-Suite/Standard-Toolkit`.
- Permission to edit the `production` environment if its protection rules need to allow these workflows.
- The workflow changes already in this repository: `id-token: write`, `NuGet/login@v1` immediately before each push, and `environment: production` on every publish job, including Canary LTS.

Do this setup before the next publish. A run on `Krypton-Suite/Standard-Toolkit` fails the job when login does not produce a key.

## 1. Create the nuget.org policies

Sign in to nuget.org as a member of the package owner. Open your username menu and choose **Trusted Publishing**.

Create five policies. The match is case-insensitive. Enter the workflow **file name only**. Do not include `.github/workflows/`.

| Policy field | Value |
| --- | --- |
| Repository owner | `Krypton-Suite` |
| Repository | `Standard-Toolkit` |
| Workflow file | One of `release.yml`, `canary.yml`, `nightly.yml`, `release-candidate.yml`, `canary-lts-release.yml` |
| Environment | `production` |

Suggested policy names, so the list stays readable: `standard-toolkit-release`, `standard-toolkit-canary`, `standard-toolkit-nightly`, `standard-toolkit-release-candidate`, `standard-toolkit-canary-lts`.

### Package owner

Set the policy owner to the nuget.org user or organization that owns the packages. The policy applies to packages owned by that owner.

If the owner is an organization, the person who creates the policy must be an active member. If they later leave the organization, nuget.org marks the policy inactive until they are added back. A locked or deleted organization also inactivates its policies.

### Scopes

Limit each policy to package id glob `Krypton.*`.

Allow both of these actions:

- Push new versions of existing packages.
- Push new packages.

New package ids under `Krypton.*` (a new component, or a new channel suffix) then work without another policy. Ids outside that glob are rejected.

### Pending policies and repository identity

nuget.org locks a policy to the GitHub repository id and owner id after a successful publish. That stops someone from deleting this repository, creating another with the same name, and publishing as if it were the original.

This repository is public, so a successful publish from each workflow file supplies those ids and the policy becomes permanently active.

A policy created against a **private** repository starts temporarily active for seven days. If nothing publishes in that window, nuget.org deactivates it. Restarting the window is available from the Trusted Publishing page. That temporary window does not apply to this public repository, but it does apply if you copy the setup onto a private fork.

## 2. Add the `NUGET_USER` secret

Repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

| Field | Value |
| --- | --- |
| Name | `NUGET_USER` |
| Secret | nuget.org profile name |

The profile name is the last segment of the profile URL, for example `Krypton-Suite` in `https://www.nuget.org/profiles/Krypton-Suite`. It is not the sign-in email. `NuGet/login` rejects an email address.

The workflows pass it as:

```yaml
- name: NuGet login (OIDC)
  id: nuget_login
  uses: NuGet/login@v1
  with:
    user: ${{ secrets.NUGET_USER }}
```

The push step then uses the action output, not a stored key:

```yaml
env:
  NUGET_API_KEY: ${{ steps.nuget_login.outputs.NUGET_API_KEY }}
```

`NUGET_API_KEY` in that `env` block is only the name of the variable the existing PowerShell reads. It is filled from `steps.nuget_login.outputs.NUGET_API_KEY` for that job. It is not `secrets.NUGET_API_KEY`.

## 3. Confirm the `production` environment

Publish jobs set `environment: production`. The nuget.org policies require that same environment name. A job that omits `environment: production` will not satisfy those policies.

`production` is also the approval gate. If the environment requires reviewers, a scheduled nightly run waits for approval before it can publish. That is existing behavior, and trusted publishing depends on it: a policy does not check the git branch.

Environment protection rules live under **Settings** → **Environments** → **production**. Repository variables used as kill switches (`RELEASE_DISABLED`, `NIGHTLY_DISABLED`, and the others) stay on the repository **Variables** tab, not only on the environment, unless a workflow is changed to read environment variables.

## 4. What the workflows already enforce

Each publishing workflow sets:

```yaml
permissions:
  contents: read
  id-token: write
```

`id-token: write` is required. Without it, GitHub will not issue the OIDC token and `NuGet/login` fails. These workflows set permissions at workflow level, and the publish jobs inherit them. If a job later sets its own `permissions` block, that block replaces the workflow permissions. It must then include both `contents: read` and `id-token: write`, or checkout and login both break.

Login is skipped unless `github.repository` is `Krypton-Suite/Standard-Toolkit`, and it uses the same kill-switch `if` as the push step (nightly also requires `has_changes`).

On `Krypton-Suite/Standard-Toolkit`, a missing short-lived key fails the push step. The job does not continue as a successful run with nothing published.

On any other repository, including a fork, login is skipped and the push step logs a warning, sets `packages_published=false`, and exits 0. A fork’s OIDC token names the fork, so it cannot match these policies. Skipping avoids a red Actions run on forks that still contain the workflow file.

Individual package push failures inside the loop are still logged as warnings, matching the previous push script. A package that already exists is skipped because of `--skip-duplicate`, and `packages_published` stays false unless some other package was new. Discord runs only when `packages_published` is true.

## 5. First publish, then delete the old key

1. Create the five policies and the `NUGET_USER` secret.
2. Merge the workflow changes to the branch that will publish.
3. Run one real publish. A manual run of Canary or Nightly is enough if that channel is safe to publish. In the log, **NuGet login (OIDC)** should report that it exchanged the token for an API key. The package should appear on nuget.org, and the matching policy should show as fully active.
4. Delete the repository secret `NUGET_API_KEY`. If that secret was inherited from the organization, remove or stop exposing it to this repository as well.

Until step 4, a leaked copy of the old key could still push. The workflows no longer read `secrets.NUGET_API_KEY`.

Repeat a publish once per workflow file that has not yet published. Each policy stays pending until that file’s job exchanges a token successfully. Publishing from `canary.yml` does not activate the policy for `nightly.yml`.

## Adding another publish workflow

1. On nuget.org, add a policy whose workflow file is the new YAML file name and whose environment is `production`.
2. Set `permissions` so the publish job has `id-token: write` and `contents: read`.
3. Put the publish job on `environment: production`.
4. Insert `NuGet/login@v1` immediately before the push, with `user: ${{ secrets.NUGET_USER }}`, and pass `steps.nuget_login.outputs.NUGET_API_KEY` into the push. Keep the repository check so forks skip instead of failing login.
5. Update this document’s workflow table.

Dependabot already watches the `github-actions` ecosystem, so `NuGet/login` version updates are proposed with the other actions.

## Local publishing

Trusted publishing applies only to GitHub Actions (and other CI systems nuget.org supports, such as GitLab). A developer machine has no GitHub OIDC token for these policies.

`Scripts/**/publish.cmd` and ModernBuild still expect a developer API key configured with:

```cmd
nuget.exe setapikey <YOUR_API_KEY> -Source https://api.nuget.org/v3/index.json
```

Create that key on nuget.org under **API Keys**, scoped to `Krypton.*`, with push permission and a short expiration. Do not store it in the repository and do not put it back into the `NUGET_API_KEY` Actions secret. See [Build Scripts](../Build%20System/BuildScripts.md) and [ModernBuild](../Build%20System/ModernBuildTool.md).

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Login fails with 403, or GitHub reports the id token cannot be requested | Workflow or job is missing `id-token: write` | Add `id-token: write` without dropping `contents: read`. |
| nuget.org rejects the token, policy not found | Owner, repository, workflow file name, or environment does not match | Compare the policy with the table above. File name only, environment `production`. |
| Login fails and the log mentions the user | `NUGET_USER` is missing, is an email, or is not the package owner’s profile name | Set the secret to the profile name. Confirm that account owns the packages the policy is attached to. |
| Policy shows pending, then inactive | No successful publish from that workflow file within the activation window (typical for private repositories) | Publish from that workflow, or restart the window on nuget.org. |
| Policy shows an ownership warning | The creating user left the nuget.org organization, or the organization is locked | Restore membership or organization access. The policy becomes active again when ownership is valid. |
| Push step fails before any `dotnet nuget push`, saying trusted publishing did not provide a key | Login was skipped or did not set `NUGET_API_KEY` on this repository | Read the login step. Fix the secret or policy. This is a failed release, not a skip. |
| Push skipped with a warning about `Krypton-Suite/Standard-Toolkit` | The run is a fork or another repository | Expected. Policies match this repository only. |
| `dotnet nuget push` returns 409, or the log says the package already exists | That version is already on nuget.org | Expected with `--skip-duplicate`. Discord is not sent when nothing new was published. |
| `dotnet nuget push` returns 403 after login succeeded | Policy scope does not include that package id, or the temporary key expired | Confirm the glob is `Krypton.*` and that login is the step immediately before push. |
| Nightly or another scheduled run sits waiting | `production` requires a reviewer | Approve the environment, or adjust the environment protection rules. |
| Canary LTS push is rejected | Its job is not on `environment: production` | The job must set `environment: production` so the policy’s environment claim matches. |

## See also

- [Trusted Publishing](https://learn.microsoft.com/en-gb/nuget/nuget-org/trusted-publishing) (Microsoft Learn)
- [Release Workflow](ReleaseWorkflow.md)
- [Canary Workflow](CanaryWorkflow.md)
- [Nightly Workflow](NightlyWorkflow.md)
- [Canary LTS Release Workflow](CanaryLTSReleaseWorkflow.md)
- [GitHub Actions Workflows](../GitHubActionsWorkflows.md)
- [NuGet packaging](../Build%20System/NuGetPackaging.md)
