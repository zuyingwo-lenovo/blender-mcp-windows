@echo off
setlocal
chcp 65001 >nul

:: Run script directly (User-local install does not require Admin)
cd /d "%~dp0"
echo Starting installer...
powershell -NoProfile -ExecutionPolicy Bypass -File ".\install-blender-mcp.ps1"
if %errorLevel% neq 0 (
    echo.
    echo [Error] Installer exited with error. If you chose a system path (like C:\Program Files), please right-click this .bat and "Run as Administrator".
)
pause
exit /B
