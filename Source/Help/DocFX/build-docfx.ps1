param(
    [switch]$Serve
)

$ErrorActionPreference = 'Stop'

$configPath = Join-Path $PSScriptRoot 'docfx.json'
$temporaryConfigPath = Join-Path $PSScriptRoot "docfx.build.$PID.json"
$footerYearPattern = '(?<=2017 - )\d{4}(?=\. All rights reserved\.)'
$failed = $false

# DocFX runs bare `dotnet restore` and does not pass metadata.properties to that
# restore (see DotnetApiCatalog.Compile.cs). Pin TFM via MSBuild response file.
$kryptonRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$standardRspPath = Join-Path $kryptonRoot 'Standard-Toolkit\Source\Krypton Components\Directory.Build.rsp'
$createdRspPaths = [System.Collections.Generic.List[string]]::new()

function Install-DocFxMsBuildResponseFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Contents
    )

    if (-not (Test-Path -LiteralPath (Split-Path -Parent $Path))) {
        Write-Host "WARNING: Skipping MSBuild response file; folder missing: $(Split-Path -Parent $Path)" -ForegroundColor Yellow
        return
    }

    if (Test-Path -LiteralPath $Path) {
        throw "Refusing to overwrite existing MSBuild response file: $Path"
    }

    [System.IO.File]::WriteAllText($Path, $Contents, [System.Text.UTF8Encoding]::new($false))
    $createdRspPaths.Add($Path) | Out-Null
    Write-Host "Installed DocFX MSBuild response file: $Path"
}

try {
    Install-DocFxMsBuildResponseFile -Path $standardRspPath -Contents @"
/p:TFMs=all
/p:TargetFramework=net10.0-windows
"@

    $config = [System.IO.File]::ReadAllText($configPath)
    $matches = [regex]::Matches($config, $footerYearPattern)

    if ($matches.Count -ne 1) {
        throw "Expected one footer year in '$configPath'; found $($matches.Count)."
    }

    $currentYear = (Get-Date).Year.ToString()
    $config = [regex]::Replace($config, $footerYearPattern, $currentYear, 1)
    [System.IO.File]::WriteAllText(
        $temporaryConfigPath,
        $config,
        [System.Text.UTF8Encoding]::new($false)
    )

    $docfxArguments = @($temporaryConfigPath)
    if ($Serve) {
        $docfxArguments += '--serve'
    }

    & docfx @docfxArguments
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw "DocFX exited with code $LASTEXITCODE."
    }
}
catch {
    $failed = $true
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    foreach ($rspPath in $createdRspPaths) {
        if (Test-Path -LiteralPath $rspPath) {
            Remove-Item -LiteralPath $rspPath -Force -ErrorAction SilentlyContinue
            Write-Host "Removed DocFX MSBuild response file: $rspPath"
        }
    }

    if (Test-Path -LiteralPath $temporaryConfigPath) {
        Remove-Item -LiteralPath $temporaryConfigPath -ErrorAction SilentlyContinue
    }
}

if ($failed) {
    if ($Host.Name -eq 'ConsoleHost' -and -not [Console]::IsInputRedirected) {
        Write-Host ""
        Read-Host 'Press Enter to close'
    }
    exit 1
}
