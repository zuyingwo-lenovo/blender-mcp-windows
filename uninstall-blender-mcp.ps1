<#
.SYNOPSIS
    Blender MCP 卸载脚本
.PARAMETER InstallDir
    要卸载的安装目录。
#>

param(
    [string]$InstallDir = ""
)

$ErrorActionPreference = "Continue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "      Blender MCP 卸载脚本" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# 默认路径优先级：1. 参数传入, 2. 局部 AppData 默认路径, 3. 旧版硬编码路径 (仅作检查)
if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    $DefaultLocal = Join-Path $env:LOCALAPPDATA "blender-mcp-windows"
    $LegacyPath = "C:\MCP\blender-mcp"
    
    if (Test-Path $DefaultLocal) {
        $InstallDir = $DefaultLocal
    } elseif (Test-Path $LegacyPath) {
        $InstallDir = $LegacyPath
    } else {
        $InstallDir = $DefaultLocal
    }
}

# 尝试从 manifest.json 读取 (如果以后支持)
$ManifestPath = Join-Path $InstallDir "manifest.json"
if (Test-Path $ManifestPath) {
    try {
        $Manifest = Get-Content $ManifestPath | ConvertFrom-Json
        if ($Manifest.InstallPath) { $InstallDir = $Manifest.InstallPath }
    } catch {}
}

$Confirm = Read-Host "此操作将删除 $InstallDir 目录。是否继续？(Y/N)"
if ($Confirm -notmatch "^[Yy]$") {
    Write-Host "已取消卸载。" -ForegroundColor Yellow
    exit
}

if (Test-Path $InstallDir) {
    try {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-Host "[成功] 已删除目录: $InstallDir" -ForegroundColor Green
    } catch {
        Write-Host "[错误] 无法删除目录，可能文件正在被占用: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[信息] 目录不存在: $InstallDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "请注意，您还需要手动执行以下操作：" -ForegroundColor Cyan
Write-Host "1. 在 Blender 中禁用并删除 'Interface: Blender MCP' 插件" -ForegroundColor Cyan
Write-Host "2. 从您的 MCP 客户端 (Claude/Cursor/Windsurf) 配置文件中删除 'blender' 节点" -ForegroundColor Cyan
Write-Host ""
Read-Host "按回车键退出"
