@echo off
setlocal enabledelayedexpansion

echo Starting Gokul's Portfolio...
echo.

REM Kill any existing portfolio servers on port 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    tasklist /fi "pid eq %%a" | findstr python >nul
    if !errorlevel! equ 0 (
        echo Stopping existing portfolio server...
        taskkill /pid %%a /f >nul 2>&1
    )
)

REM Try port 3000 first
echo Trying port 3000...
start /min python -m http.server 3000 2>nul
timeout /t 2 /nobreak >nul

netstat -ano | findstr :3000 | findstr LISTENING >nul
if !errorlevel! equ 0 (
    echo ✅ Portfolio running at http://localhost:3000
    start http://localhost:3000
    goto :end
)

REM If 3000 fails, try other ports
for %%p in (3001 8080 8000 5000 4000) do (
    echo Trying port %%p...
    start /min python -m http.server %%p 2>nul
    timeout /t 2 /nobreak >nul
    
    netstat -ano | findstr :%%p | findstr LISTENING >nul
    if !errorlevel! equ 0 (
        echo ✅ Portfolio running at http://localhost:%%p
        start http://localhost:%%p
        goto :end
    )
)

echo ❌ Could not start server on any port

:end
echo.
echo Press any key to stop the server...
pause >nul