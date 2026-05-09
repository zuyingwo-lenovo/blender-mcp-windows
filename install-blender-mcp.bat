@echo off
setlocal
chcp 65001 >nul

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RunScript
)

echo Requesting Administrator privileges...
powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
exit /B

:RunScript
cd /d "%~dp0"
echo Starting installer...
powershell -NoProfile -ExecutionPolicy Bypass -File ".\install-blender-mcp.ps1"
pause
