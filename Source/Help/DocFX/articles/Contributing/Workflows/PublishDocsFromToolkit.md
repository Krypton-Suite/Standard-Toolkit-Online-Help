# Publishing docs from toolkit releases

Online Help trees are aligned to **NuGet `PackageVersion`**, not live branch tips. After a successful package push in [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit), that repo should notify this repository so a matching DocFX tree is built and kept under `/v/<version>/`.

## Online-Help workflow

Workflow: `.github/workflows/publish-docs-version.yml` in this repository.

| Trigger | When |
|---------|------|
| `repository_dispatch` type `docs-publish` | Automated from Standard-Toolkit after NuGet push |
| `workflow_dispatch` | Manual backfill / until the dispatch hook lands |

### Payload / inputs

| Field | Required | Description |
|-------|----------|-------------|
| `channel` | yes | `stable` \| `lts` \| `canary` \| `nightly` |
| `version` | yes | Exact NuGet `PackageVersion` (e.g. `110.26.11.328`, `110.26.8.221-alpha`) |
| `standard_ref` | yes | Git SHA or tag of Standard-Toolkit used for that package |
| `extended_ref` | no | Matching Extended-Toolkit SHA/tag (defaults to `standard_ref`) |
| `line` | no | LTS line name when `channel=lts` (e.g. `V105-LTS`) |

Example `client_payload` for `repository_dispatch`:

```json
{
  "channel": "stable",
  "version": "110.26.11.328",
  "standard_ref": "abc123def456...",
  "extended_ref": "fed654cba321...",
  "line": ""
}
```

Retention: every **Stable** and **LTS** tree is kept; **Canary** and **Nightly** keep only the latest tree of that channel. Persistence uses the `docs-versions` branch in this repo.

## Companion change in Standard-Toolkit (required for automation)

Implement in Standard-Toolkit `release.yml` / `nightly.yml` (and Canary/LTS release workflows) **after** a successful NuGet push:

1. Resolve `PackageVersion`, commit SHA used for the pack, and channel.
2. Resolve the matching Extended-Toolkit ref at publish time.
3. Call GitHub API `repository_dispatch` against `Krypton-Suite/Standard-Toolkit-Online-Help` with `event_type: docs-publish` and the payload above.

### Secret

Create a fine-grained PAT (or classic PAT) with **`actions: write`** (and contents read if needed) on **Standard-Toolkit-Online-Help**, and store it in Standard-Toolkit as e.g. `DOCS_DISPATCH_TOKEN` (or `ONLINE_HELP_DISPATCH_TOKEN`).

Example step (illustrative — adapt to existing workflows):

```yaml
- name: Trigger Online-Help docs publish
  env:
    GH_TOKEN: ${{ secrets.DOCS_DISPATCH_TOKEN }}
  run: |
    gh api repos/Krypton-Suite/Standard-Toolkit-Online-Help/dispatches \
      -f event_type='docs-publish' \
      -f 'client_payload[channel]=stable' \
      -f "client_payload[version]=${{ env.PACKAGE_VERSION }}" \
      -f "client_payload[standard_ref]=${{ github.sha }}" \
      -f "client_payload[extended_ref]=${{ env.EXTENDED_REF }}"
```

Until that PR lands, use this repo’s **Publish Docs Version** workflow manually after each NuGet publish.

## Local reproduction

```powershell
.\Scripts\Build-VersionedDocs.ps1 `
  -Channel stable `
  -Version 110.26.11.328 `
  -StandardRef <sha-or-tag> `
  -ExtendedRef <sha-or-tag> `
  -UpdateCatalog `
  -OutputRoot Source\Help\Output\site
```

Dev-only siblings (does not update the published catalog):

```cmd
run.cmd build
```

Builds into `Source\Help\Output\site\v\local-dev\`.
