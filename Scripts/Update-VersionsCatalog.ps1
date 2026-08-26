<#
.SYNOPSIS
  Updates versions.json and root index.html after a docs version is published.

.PARAMETER SiteRoot
  Root of the assembled docs site (contains versions.json and v/).

.PARAMETER Channel
  stable | lts | canary | nightly

.PARAMETER Version
  Exact NuGet PackageVersion string.

.PARAMETER Line
  Optional LTS line name (e.g. V105-LTS).

.PARAMETER PackageId
  Optional override for packageId in the catalog entry.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SiteRoot,

    [Parameter(Mandatory = $true)]
    [ValidateSet('stable', 'lts', 'canary', 'nightly')]
    [string] $Channel,

    [Parameter(Mandatory = $true)]
    [string] $Version,

    [string] $Line,

    [string] $PackageId
)

$ErrorActionPreference = 'Stop'

$SiteRoot = [System.IO.Path]::GetFullPath($SiteRoot)
$catalogPath = Join-Path $SiteRoot 'versions.json'
$templateCatalog = Join-Path $PSScriptRoot 'site-templates\versions.json'

if (-not (Test-Path $catalogPath)) {
    if (Test-Path $templateCatalog) {
        Copy-Item -Force $templateCatalog $catalogPath
    }
    else {
        throw "Missing versions.json at $catalogPath"
    }
}

$packageIds = @{
    stable  = 'Krypton.Standard.Toolkit'
    lts     = 'Krypton.Standard.Toolkit'
    canary  = 'Krypton.Standard.Toolkit.Canary'
    nightly = 'Krypton.Standard.Toolkit.Nightly'
}

if (-not $PackageId) {
    $PackageId = $packageIds[$Channel]
}

$path = ('v/{0}/' -f $Version)
$entry = [pscustomobject]@{
    version   = $Version
    path      = $path
    packageId = $PackageId
}
if ($Line) {
    $entry | Add-Member -NotePropertyName line -NotePropertyValue $Line
}

$catalog = Get-Content -Raw -Path $catalogPath | ConvertFrom-Json

# Normalize channel lists (ConvertFrom-Json turns [] into $null on Windows PowerShell)
$channelMap = @{
    stable  = @()
    lts     = @()
    canary  = @()
    nightly = @()
}
foreach ($name in @('stable', 'lts', 'canary', 'nightly')) {
    $raw = $catalog.channels.$name
    if ($null -ne $raw) {
        $channelMap[$name] = @($raw)
    }
}

$existing = @($channelMap[$Channel])

# Prune canary/nightly: remove other version trees and catalog entries
if ($Channel -in @('canary', 'nightly')) {
    foreach ($old in $existing) {
        if ($old.version -eq $Version) { continue }
        $rel = [string]$old.path
        $oldDir = Join-Path $SiteRoot ($rel.TrimEnd('/').Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (Test-Path $oldDir) {
            Write-Host "[INFO] Pruning previous $Channel docs: $oldDir"
            Remove-Item -Recurse -Force $oldDir
        }
    }
    $existing = @()
}

# Upsert current version at front of channel list
$filtered = @($existing | Where-Object { $_.version -ne $Version })
$channelMap[$Channel] = @($entry) + $filtered

# Rebuild channels object for JSON
$catalog.channels = [pscustomobject]@{
    stable  = @($channelMap['stable'])
    lts     = @($channelMap['lts'])
    canary  = @($channelMap['canary'])
    nightly = @($channelMap['nightly'])
}

# Default = newest stable if any; else keep existing / current version
$stableList = @($channelMap['stable'])
if ($stableList.Length -gt 0) {
    $catalog.default = $stableList[0].version
}
elseif ([string]::IsNullOrWhiteSpace([string]$catalog.default)) {
    $catalog.default = $Version
}

$json = $catalog | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($catalogPath, $json)
Write-Host "[INFO] Updated catalog: $catalogPath (default=$($catalog.default))"

$target = 'v/' + $catalog.default + '/'
$indexPath = Join-Path $SiteRoot 'index.html'
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="refresh" content="0; url=$target" />
  <title>Krypton Toolkit Documentation</title>
  <link rel="canonical" href="$target" />
  <script>location.replace("$target");</script>
</head>
<body>
  <p>Redirecting to <a href="$target">$($catalog.default)</a> documentation…</p>
</body>
</html>
"@
[System.IO.File]::WriteAllText($indexPath, $html)
Write-Host "[INFO] Wrote root redirect -> $target"
