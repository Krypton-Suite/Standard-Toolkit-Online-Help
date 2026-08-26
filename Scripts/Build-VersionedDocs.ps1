<#
.SYNOPSIS
  Builds DocFX documentation for a NuGet package version into v/<version>/.

.DESCRIPTION
  Checks out Standard-Toolkit and Extended-Toolkit at the given refs (SHA/tag/branch),
  builds a full DocFX tree under <OutputRoot>/v/<Version>/, and optionally updates
  versions.json / root redirect when -UpdateCatalog is set.

  Do not pass DocFX --output together with build.dest — DocFX resolves {output}/{dest}.
  This script patches build.output per version and runs DocFX without -o.

.PARAMETER Channel
  stable | lts | canary | nightly

.PARAMETER Version
  Exact NuGet PackageVersion (e.g. 110.26.11.328 or 110.26.8.221-alpha).

.PARAMETER StandardRef
  Git SHA, tag, or branch of Standard-Toolkit for that package.

.PARAMETER ExtendedRef
  Matching Extended-Toolkit SHA/tag/branch (defaults to StandardRef).

.PARAMETER Line
  Optional LTS line name (e.g. V105-LTS) stored in versions.json.

.PARAMETER LocalDev
  Build current sibling checkouts into v/local-dev/ without cloning.

.PARAMETER OutputRoot
  Directory that receives v/<version>/ (default: Source/Help/Output/site).

.PARAMETER UseSiblings
  Use ../Standard-Toolkit and ../Extended-Toolkit as-is (CI / local).

.PARAMETER SkipClone
  Do not fetch/clone; require toolkit sources at the resolved paths.

.PARAMETER UpdateCatalog
  After a successful build, merge this version into versions.json and prune canary/nightly.

.PARAMETER DocfxPath
  Path to docfx.exe (default: ~/.dotnet/tools/docfx.exe).
#>
[CmdletBinding(DefaultParameterSetName = 'Publish')]
param(
    [Parameter(ParameterSetName = 'Publish', Mandatory = $true)]
    [ValidateSet('stable', 'lts', 'canary', 'nightly')]
    [string] $Channel,

    [Parameter(ParameterSetName = 'Publish', Mandatory = $true)]
    [string] $Version,

    [Parameter(ParameterSetName = 'Publish')]
    [string] $StandardRef,

    [Parameter(ParameterSetName = 'Publish')]
    [string] $ExtendedRef,

    [Parameter(ParameterSetName = 'Publish')]
    [string] $Line,

    [Parameter(ParameterSetName = 'LocalDev')]
    [switch] $LocalDev,

    [string] $OutputRoot,

    [switch] $UseSiblings,

    [switch] $SkipClone,

    [switch] $UpdateCatalog,

    [string] $DocfxPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$DocfxDir = Join-Path $RepoRoot 'Source\Help\DocFX'
$DocfxConfig = Join-Path $DocfxDir 'docfx.json'
$ToolkitSrcRoot = Join-Path $RepoRoot '.toolkit-src'

if (-not $OutputRoot) {
    $OutputRoot = Join-Path $RepoRoot 'Source\Help\Output\site'
}
if (-not [System.IO.Path]::IsPathRooted($OutputRoot)) {
    $OutputRoot = Join-Path (Get-Location) $OutputRoot
}
$OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)

if (-not $DocfxPath) {
    $DocfxPath = Join-Path $env:USERPROFILE '.dotnet\tools\docfx.exe'
}
if (-not (Test-Path $DocfxPath)) {
    Write-Host '[INFO] DocFX not found. Installing...'
    dotnet tool install -g docfx
    if ($LASTEXITCODE -ne 0) { throw 'Failed to install DocFX.' }
    $DocfxPath = Join-Path $env:USERPROFILE '.dotnet\tools\docfx.exe'
}

if ($LocalDev) {
    $Channel = 'stable'
    $Version = 'local-dev'
    $UseSiblings = $true
    $SkipClone = $true
    $UpdateCatalog = $false
}
else {
    if (-not $StandardRef) {
        throw 'StandardRef is required unless -LocalDev is set.'
    }
    if (-not $ExtendedRef) {
        $ExtendedRef = $StandardRef
    }
}

# Folder segment under v/ — keep NuGet version chars (letters, digits, ., -)
function Get-VersionFolderName {
    param([string] $PackageVersion)
    if ($PackageVersion -notmatch '^[A-Za-z0-9._-]+$') {
        throw "Version contains characters unsafe for a URL path segment: $PackageVersion"
    }
    return $PackageVersion
}

function Get-RelativeUnixPath {
    param(
        [string] $FromDir,
        [string] $ToDir
    )

    $fromUri = [Uri]((Resolve-Path $FromDir).Path.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar)
    $toUri = [Uri]((Resolve-Path $ToDir).Path.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar)
    $rel = [Uri]::UnescapeDataString($fromUri.MakeRelativeUri($toUri).ToString())
    return ($rel -replace '\\', '/').TrimEnd('/') + '/'
}

function Ensure-ToolkitAtRef {
    param(
        [string] $Name,
        [string] $RepoUrl,
        [string] $GitRef,
        [string] $DestPath,
        [string] $MarkerRelativePath
    )

    $marker = Join-Path $DestPath $MarkerRelativePath
    if ($SkipClone) {
        if (-not (Test-Path $marker)) {
            throw "SkipClone set but missing $Name at $DestPath (expected $MarkerRelativePath)."
        }
        return
    }

    if (-not (Test-Path (Join-Path $DestPath '.git'))) {
        Write-Host "[INFO] Cloning $Name into $DestPath ..."
        New-Item -ItemType Directory -Force -Path (Split-Path $DestPath -Parent) | Out-Null
        git clone --filter=blob:none --no-checkout $RepoUrl $DestPath
        if ($LASTEXITCODE -ne 0) { throw "Failed to clone $Name." }
    }

    Write-Host "[INFO] Checking out $Name @ $GitRef ..."
    Push-Location $DestPath
    try {
        git fetch --depth 1 origin $GitRef
        if ($LASTEXITCODE -ne 0) {
            # Full fetch for tags/SHAs that shallow fetch may miss
            git fetch --tags origin
            if ($LASTEXITCODE -ne 0) { throw "Failed to fetch $Name ($GitRef)." }
            git fetch origin $GitRef
            if ($LASTEXITCODE -ne 0) { throw "Failed to fetch $Name ($GitRef)." }
        }
        git checkout --force FETCH_HEAD
        if ($LASTEXITCODE -ne 0) {
            git checkout --force $GitRef
            if ($LASTEXITCODE -ne 0) { throw "Failed to checkout $Name ($GitRef)." }
        }
    }
    finally {
        Pop-Location
    }

    if (-not (Test-Path $marker)) {
        throw "Toolkit marker not found after checkout: $marker"
    }
}

function Write-VersionConfig {
    param(
        [string] $BuildOutput,
        [string] $DestConfigPath,
        [string] $StandardRoot,
        [string] $ExtendedRoot,
        [bool] $PatchSrcPaths
    )

    $text = [System.IO.File]::ReadAllText($DocfxConfig)

    if ($PatchSrcPaths) {
        $stdRel = Get-RelativeUnixPath -FromDir $DocfxDir -ToDir (Join-Path $StandardRoot 'Source\Krypton Components')
        $extRel = Get-RelativeUnixPath -FromDir $DocfxDir -ToDir (Join-Path $ExtendedRoot 'Source\Krypton Toolkit')
        $text = $text.Replace(
            '"src": "../../../../Standard-Toolkit/Source/Krypton Components/"',
            ('"src": "{0}"' -f $stdRel))
        $text = $text.Replace(
            '"src": "../../../../Extended-Toolkit/Source/Krypton Toolkit/"',
            ('"src": "{0}"' -f $extRel))
    }

    $buildOutJson = ($BuildOutput -replace '\\', '/')
    if ($text -notmatch '"output"\s*:') {
        throw 'docfx.json must use build.output (not build.dest) for versioned builds.'
    }
    $text = [regex]::Replace($text, '"output"\s*:\s*"[^"]*"', ('"output": "{0}"' -f $buildOutJson), 1)
    [System.IO.File]::WriteAllText($DestConfigPath, $text)
}

function Assert-VersionOutput {
    param([string] $VersionOut)

    $index = Join-Path $VersionOut 'index.html'
    if (-not (Test-Path $index)) {
        Write-Host "[ERROR] Expected DocFX output missing: $index"
        Write-Host '[ERROR] Version directory contents:'
        if (Test-Path $VersionOut) {
            Get-ChildItem -Force $VersionOut | ForEach-Object { Write-Host ("  " + $_.Name) }
        }
        else {
            Write-Host '  (directory does not exist)'
        }
        Write-Host '[ERROR] OutputRoot contents:'
        if (Test-Path $OutputRoot) {
            Get-ChildItem -Force $OutputRoot | ForEach-Object { Write-Host ("  " + $_.Name) }
        }
        throw "DocFX did not produce index.html under $VersionOut"
    }

    Write-Host "[INFO] Verified output: $index"
}

function Build-OneVersion {
    param(
        [string] $FolderName,
        [string] $StdRef,
        [string] $ExtRef
    )

    Write-Host "============================================"
    Write-Host " Building documentation -> v/$FolderName"
    Write-Host " Channel=$Channel Version=$Version"
    Write-Host "============================================"

    $patchSrc = $false
    $safeKey = ($FolderName -replace '[^A-Za-z0-9._-]', '_')
    if ($UseSiblings) {
        $parent = Split-Path $RepoRoot -Parent
        $standardRoot = Join-Path $parent 'Standard-Toolkit'
        $extendedRoot = Join-Path $parent 'Extended-Toolkit'
        if (-not (Test-Path (Join-Path $standardRoot 'Source\Krypton Components'))) {
            throw "UseSiblings requires $standardRoot\Source\Krypton Components"
        }
        if (-not (Test-Path (Join-Path $extendedRoot 'Source\Krypton Toolkit'))) {
            throw "UseSiblings requires $extendedRoot\Source\Krypton Toolkit"
        }
        Write-Host "[INFO] Using sibling Standard-Toolkit: $standardRoot"
        Write-Host "[INFO] Using sibling Extended-Toolkit: $extendedRoot"
    }
    else {
        $standardRoot = Join-Path $ToolkitSrcRoot "Standard-Toolkit-$safeKey"
        $extendedRoot = Join-Path $ToolkitSrcRoot "Extended-Toolkit-$safeKey"
        Ensure-ToolkitAtRef -Name 'Standard-Toolkit' `
            -RepoUrl 'https://github.com/Krypton-Suite/Standard-Toolkit.git' `
            -GitRef $StdRef `
            -DestPath $standardRoot `
            -MarkerRelativePath 'Source\Krypton Components'
        Ensure-ToolkitAtRef -Name 'Extended-Toolkit' `
            -RepoUrl 'https://github.com/Krypton-Suite/Extended-Toolkit.git' `
            -GitRef $ExtRef `
            -DestPath $extendedRoot `
            -MarkerRelativePath 'Source\Krypton Toolkit'
        $patchSrc = $true
    }

    $versionOut = Join-Path $OutputRoot "v\$FolderName"
    if (Test-Path $versionOut) {
        Remove-Item -Recurse -Force $versionOut
    }
    New-Item -ItemType Directory -Force -Path $versionOut | Out-Null

    $tempConfig = Join-Path $DocfxDir ("docfx.{0}.json" -f $safeKey)
    Write-VersionConfig `
        -BuildOutput $versionOut `
        -DestConfigPath $tempConfig `
        -StandardRoot $standardRoot `
        -ExtendedRoot $extendedRoot `
        -PatchSrcPaths $patchSrc

    Push-Location $DocfxDir
    try {
        Write-Host "[INFO] Running DocFX metadata+build -> $versionOut"
        Write-Host "[INFO] Config: $tempConfig"
        & $DocfxPath $tempConfig
        if ($LASTEXITCODE -ne 0) {
            throw "DocFX failed for $Version (exit $LASTEXITCODE)."
        }
    }
    finally {
        Pop-Location
        if (Test-Path $tempConfig) {
            Remove-Item -Force $tempConfig
        }
    }

    Assert-VersionOutput -VersionOut $versionOut
}

# --- main ---
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $OutputRoot 'v') | Out-Null

$folderName = Get-VersionFolderName -PackageVersion $Version
Build-OneVersion -FolderName $folderName -StdRef $StandardRef -ExtRef $ExtendedRef

if ($UpdateCatalog) {
    $catalogArgs = @{
        SiteRoot = $OutputRoot
        Channel  = $Channel
        Version  = $Version
    }
    if ($Line) { $catalogArgs['Line'] = $Line }
    & (Join-Path $PSScriptRoot 'Update-VersionsCatalog.ps1') @catalogArgs
}
else {
    $templateRedirect = Join-Path $PSScriptRoot 'root-redirect.index.html'
    $indexPath = Join-Path $OutputRoot 'index.html'
    if (-not (Test-Path $indexPath) -and (Test-Path $templateRedirect)) {
        Copy-Item -Force $templateRedirect $indexPath
    }
    $templateCatalog = Join-Path $PSScriptRoot 'site-templates\versions.json'
    $catalogPath = Join-Path $OutputRoot 'versions.json'
    if (-not (Test-Path $catalogPath) -and (Test-Path $templateCatalog)) {
        Copy-Item -Force $templateCatalog $catalogPath
    }
}

Write-Host "[INFO] Done. Output: $OutputRoot\v\$folderName"
