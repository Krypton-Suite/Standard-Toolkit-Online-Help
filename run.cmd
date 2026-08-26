@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Configuration
REM ============================================
set "REPO_ROOT=%~dp0"
set "DOCFX=%USERPROFILE%\.dotnet\tools\docfx.exe"
set "DOCFX_CONFIG=%REPO_ROOT%Source\Help\DocFX\docfx.json"
set "DOCFX_URL=http://localhost:8080"
set "SITE_ROOT=%REPO_ROOT%Source\Help\Output\site"
set "STANDARD_TOOLKIT_ROOT=%REPO_ROOT%..\Standard-Toolkit"
set "STANDARD_TOOLKIT_SRC=%STANDARD_TOOLKIT_ROOT%\Source\Krypton Components"
set "STANDARD_TOOLKIT_REPO=https://github.com/Krypton-Suite/Standard-Toolkit.git"
set "EXTENDED_TOOLKIT_ROOT=%REPO_ROOT%..\Extended-Toolkit"
set "EXTENDED_TOOLKIT_SRC=%EXTENDED_TOOLKIT_ROOT%\Source\Krypton Toolkit"
set "EXTENDED_TOOLKIT_REPO=https://github.com/Krypton-Suite/Extended-Toolkit.git"
set "MODE=%~1"
if "%MODE%"=="" set "MODE=serve"

echo ============================================
echo DocFX Build Script
echo ============================================

REM ============================================
REM Check if docfx exists
REM ============================================
if not exist "%DOCFX%" (
    echo [INFO] DocFX not found. Installing...
    dotnet tool install -g docfx
    if errorlevel 1 (
        echo [ERROR] Failed to install DocFX.
        exit /b 1
    )
) else (
    echo [INFO] DocFX found. Checking for updates...
    dotnet tool update -g docfx >nul 2>nul
)

REM ============================================
REM Validate config file
REM ============================================
if not exist "%DOCFX_CONFIG%" (
    echo [ERROR] %DOCFX_CONFIG% not found.
    exit /b 1
)

REM ============================================
REM Ensure sibling toolkit sources
REM DocFX metadata.src cannot use a Git URL, so clone
REM the sibling folder from GitHub when it is missing.
REM ============================================
call :EnsureSiblingToolkit "Standard-Toolkit" "%STANDARD_TOOLKIT_ROOT%" "%STANDARD_TOOLKIT_SRC%" "%STANDARD_TOOLKIT_REPO%"
if errorlevel 1 exit /b 1
call :EnsureSiblingToolkit "Extended-Toolkit" "%EXTENDED_TOOLKIT_ROOT%" "%EXTENDED_TOOLKIT_SRC%" "%EXTENDED_TOOLKIT_REPO%"
if errorlevel 1 exit /b 1

REM ============================================
REM Dev build into site/v/local-dev (does not touch docs-versions)
REM ============================================
if /I "%MODE%"=="build" (
    echo [INFO] Building current siblings into "%SITE_ROOT%\v\local-dev"
    powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_ROOT%Scripts\Build-VersionedDocs.ps1" -LocalDev -OutputRoot "%SITE_ROOT%" -UseSiblings -SkipClone
    if errorlevel 1 exit /b 1
    endlocal
    exit /b 0
)

if /I "%MODE%"=="all" (
    echo [INFO] "run.cmd all" is deprecated. Use Build-VersionedDocs.ps1 -Channel/-Version/-StandardRef for NuGet versions,
    echo [INFO] or "run.cmd build" for a local-dev tree. See articles\Versions.md
    endlocal
    exit /b 1
)

REM ============================================
REM Start DocFX (serve current siblings; classic Output path)
REM ============================================
echo [INFO] Starting DocFX server (current sibling toolkits)...
echo [INFO] Tip: use "run.cmd build" for v\local-dev under Output\site\

start "" "%DOCFX%" "%DOCFX_CONFIG%" --serve

timeout /t 2 >nul

echo [INFO] Opening browser at %DOCFX_URL%
start "" "%DOCFX_URL%"

echo [INFO] DocFX is running.
echo Press Ctrl+C in the DocFX window to stop.

endlocal
goto :eof

:EnsureSiblingToolkit
set "SIB_NAME=%~1"
set "SIB_ROOT=%~2"
set "SIB_SRC=%~3"
set "SIB_REPO=%~4"
if exist "%SIB_SRC%" (
    echo [INFO] Using local %SIB_NAME% at "%SIB_ROOT%"
    goto :eof
)
echo [INFO] Local %SIB_NAME% not found at "%SIB_ROOT%"
echo [INFO] Cloning %SIB_REPO% as a fallback...
where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is required to clone %SIB_NAME% as a fallback.
    echo         Clone %SIB_REPO% to "%SIB_ROOT%" and re-run.
    exit /b 1
)
git clone --depth 1 "%SIB_REPO%" "%SIB_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to clone %SIB_NAME%.
    exit /b 1
)
goto :eof
