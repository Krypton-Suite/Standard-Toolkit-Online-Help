@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Configuration
REM ============================================
set "DOCFX=%USERPROFILE%\.dotnet\tools\docfx.exe"
set "DOCFX_CONFIG=Source\Help\DocFX\docfx.json"
set "DOCFX_URL=http://localhost:8080"

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
    echo [ERROR] %DOCFX_CONFIG% not found in current directory.
    exit /b 1
)

REM ============================================
REM Start DocFX
REM ============================================
echo [INFO] Starting DocFX server...

start "" "%DOCFX%" "%DOCFX_CONFIG%" --serve

REM Give server time to spin up
timeout /t 2 >nul

REM ============================================
REM Open browser
REM ============================================
echo [INFO] Opening browser at %DOCFX_URL%
start "" "%DOCFX_URL%"

echo [INFO] DocFX is running.
echo Press Ctrl+C in the DocFX window to stop.

endlocal