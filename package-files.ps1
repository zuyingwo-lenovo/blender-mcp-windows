<#
.SYNOPSIS
    打包所有部署文件为 ZIP
#>

$ErrorActionPreference = "Stop"

$SourceDir = $PSScriptRoot
$DateStr = Get-Date -Format "yyyy-MM-dd"
$Version = "v1.0"
$ZipName = "blender-mcp-windows-installer-$Version-$DateStr.zip"
$ZipPath = Join-Path (Split-Path $SourceDir -Parent) $ZipName

Write-Host "开始打包部署文件..." -ForegroundColor Cyan

# 检查必需文件
$RequiredFiles = @(
    "install-blender-mcp.ps1",
    "install-blender-mcp.bat",
    "start-blender-mcp.ps1",
    "uninstall-blender-mcp.ps1",
    "config-example.json",
    "README-部署说明.md",
    "package-files.ps1"
)

$MissingFiles = @()
foreach ($File in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $SourceDir $File))) {
        $MissingFiles += $File
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host "打包失败！缺少以下必需文件：" -ForegroundColor Red
    $MissingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit
}

# 确保 logs 目录存在
$LogDir = Join-Path $SourceDir "logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

try {
    if (Test-Path $ZipPath) {
        Remove-Item $ZipPath -Force
    }
    
    Compress-Archive -Path "$SourceDir\*" -DestinationPath $ZipPath -Force
    Write-Host "[成功] 打包完成！" -ForegroundColor Green
    Write-Host "ZIP 文件路径: $ZipPath" -ForegroundColor Cyan
} catch {
    Write-Host "[错误] 打包失败: $_" -ForegroundColor Red
}

Read-Host "按回车键退出"
