@echo off
chcp 65001 >nul
:: Blender MCP 一键部署启动器
:: 作用：以管理员权限调用 PowerShell 脚本

echo ===================================================
echo       Blender MCP Windows 一键部署程序
echo ===================================================
echo.
echo 正在请求管理员权限...

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [成功] 已获取管理员权限。
    goto :RunScript
) else (
    echo [提示] 正在尝试提升权限...
    goto :UACPrompt
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^)>"%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:RunScript
    echo.
    echo 正在启动部署脚本...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-blender-mcp.ps1"
    
    echo.
    pause
