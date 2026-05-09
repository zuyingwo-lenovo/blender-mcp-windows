<#
.SYNOPSIS
    Blender MCP 卸载脚本
#>

$ErrorActionPreference = "Continue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "      Blender MCP 卸载脚本" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$Confirm = Read-Host "此操作将删除 C:\MCP\blender-mcp 目录。是否继续？(Y/N)"
if ($Confirm -notmatch "^[Yy]$") {
    Write-Host "已取消卸载。" -ForegroundColor Yellow
    exit
}

$InstallDir = "C:\MCP\blender-mcp"
if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force
    Write-Host "[成功] 已删除目录: $InstallDir" -ForegroundColor Green
} else {
    Write-Host "[信息] 目录不存在: $InstallDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "请注意，您还需要手动执行以下操作：" -ForegroundColor Cyan
Write-Host "1. 在 Blender 中禁用并删除 'Interface: Blender MCP' 插件" -ForegroundColor Cyan
Write-Host "2. 从 Antigravity 配置文件中删除 blender mcpServers 节点" -ForegroundColor Cyan
Write-Host ""
Read-Host "按回车键退出"
