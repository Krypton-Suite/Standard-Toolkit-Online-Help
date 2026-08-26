<#
.SYNOPSIS
  Builds DocFX documentation for one or all toolkit branches (master, alpha, V105-LTS).

.DESCRIPTION
  Each version is an isolated DocFX output tree under <OutputRoot>/<slug>/ so API UIDs
  do not collide across branches.

  Do not pass DocFX --output together with build.dest — DocFX resolves {output}/{dest}.
  This script patches build.output per version and runs DocFX without -o so HTML lands
  in <OutputRoot>/<slug>/. Metadata YAML stays under DocFX/api and api-extended.

.PARAMETER Branch
  Toolkit git branch: master | alpha | V105-LTS

.PARAMETER All
  Build master, alpha, and V105-LTS into <OutputRoot>/<slug>/ and write a root redirect.

.PARAMETER OutputRoot
  Directory that receives version folders (default: Source/Help/Output/site).

.PARAMETER UseSiblings
  Use ../Standard-Toolkit and ../Extended-Toolkit as-is (CI / local current checkout).
  When omitted, clones are kept under .toolkit-src/.

.PARAMETER SkipClone
  Do not fetch/clone; require toolkit sources to already exist at the resolved paths.

.PARAMETER DocfxPath
  Path to docfx.exe (default: ~/.dotnet/tools/docfx.exe).
#>
[CmdletBinding(DefaultParameterSetName = 'Branch')]
param(
    [Parameter(ParameterSetName = 'Branch')]
    [ValidateSet('master', 'alpha', 'V105-LTS')]
    [string] $Branch = 'master',

    [Parameter(ParameterSetName = 'All')]
    [switch] $All,

    [string] $OutputRoot,

    [switch] $UseSiblings,

    [switch] $SkipClone,

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

function Get-VersionSlug {
    param([string] $GitBranch)
    switch ($GitBranch) {
        'master'   { 'master' }
        'alpha'    { 'alpha' }
        'V105-LTS' { 'v105-lts' }
        default    { throw "Unsupported branch: $GitBranch" }
    }
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

function Ensure-ToolkitClone {
    param(
        [string] $Name,
        [string] $RepoUrl,
        [string] $GitBranch,
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
        Write-Host "[INFO] Cloning $Name ($GitBranch) into $DestPath ..."
        New-Item -ItemType Directory -Force -Path (Split-Path $DestPath -Parent) | Out-Null
        git clone --branch $GitBranch --single-branch --depth 1 $RepoUrl $DestPath
        if ($LASTEXITCODE -ne 0) { throw "Failed to clone $Name." }
        return
    }

    Write-Host "[INFO] Updating $Name at $DestPath to $GitBranch ..."
    Push-Location $DestPath
    try {
        git fetch --depth 1 origin $GitBranch
        if ($LASTEXITCODE -ne 0) { throw "Failed to fetch $Name ($GitBranch)." }
        git checkout -B $GitBranch FETCH_HEAD
        if ($LASTEXITCODE -ne 0) { throw "Failed to checkout $Name ($GitBranch)." }
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
        [string] $GitBranch,
        [string] $Slug
    )

    Write-Host "============================================"
    Write-Host " Building documentation for $GitBranch -> $Slug"
    Write-Host "============================================"

    $patchSrc = $false
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
        $standardRoot = Join-Path $ToolkitSrcRoot "Standard-Toolkit-$Slug"
        $extendedRoot = Join-Path $ToolkitSrcRoot "Extended-Toolkit-$Slug"
        Ensure-ToolkitClone -Name 'Standard-Toolkit' `
            -RepoUrl 'https://github.com/Krypton-Suite/Standard-Toolkit.git' `
            -GitBranch $GitBranch `
            -DestPath $standardRoot `
            -MarkerRelativePath 'Source\Krypton Components'
        Ensure-ToolkitClone -Name 'Extended-Toolkit' `
            -RepoUrl 'https://github.com/Krypton-Suite/Extended-Toolkit.git' `
            -GitBranch $GitBranch `
            -DestPath $extendedRoot `
            -MarkerRelativePath 'Source\Krypton Toolkit'
        $patchSrc = $true
    }

    $versionOut = Join-Path $OutputRoot $Slug
    if (Test-Path $versionOut) {
        Remove-Item -Recurse -Force $versionOut
    }
    New-Item -ItemType Directory -Force -Path $versionOut | Out-Null

    $tempConfig = Join-Path $DocfxDir "docfx.$Slug.json"
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
            throw "DocFX failed for $GitBranch (exit $LASTEXITCODE)."
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

function Write-RootRedirect {
    param([string] $SiteRoot)

    $template = Join-Path $PSScriptRoot 'root-redirect.index.html'
    $indexPath = Join-Path $SiteRoot 'index.html'
    Copy-Item -Force -Path $template -Destination $indexPath
    Write-Host "[INFO] Wrote root redirect: $indexPath"
}

# --- main ---
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

if ($All) {
    foreach ($b in @('master', 'alpha', 'V105-LTS')) {
        Build-OneVersion -GitBranch $b -Slug (Get-VersionSlug $b)
    }
    Write-RootRedirect -SiteRoot $OutputRoot
}
else {
    Build-OneVersion -GitBranch $Branch -Slug (Get-VersionSlug $Branch)
    if (-not $UseSiblings) {
        Write-RootRedirect -SiteRoot $OutputRoot
    }
}

Write-Host "[INFO] Done. Output: $OutputRoot"
