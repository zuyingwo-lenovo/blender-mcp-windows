<#
.SYNOPSIS
    打包所有部署文件为 ZIP
#>

$ErrorActionPreference = "Stop"

$SourceDir = $PSScriptRoot
$DateStr = Get-Date -Format "yyyy-MM-dd"
$Version = "v0.9.1"
$DistDir = Join-Path $SourceDir "dist"
if (-not (Test-Path $DistDir)) { New-Item -ItemType Directory -Path $DistDir | Out-Null }

$ZipName = "blender-mcp-windows-installer-$Version-$DateStr.zip"
$ZipPath = Join-Path $DistDir $ZipName

Write-Host "开始打包部署文件 (版本: $Version)..." -ForegroundColor Cyan

# 必需文件清单 (P0)
$RequiredFiles = @(
    "install-blender-mcp.ps1",
    "install-blender-mcp.bat",
    "start-blender-mcp.ps1",
    "uninstall-blender-mcp.ps1",
    "config-example.json",
    "README.md",
    "README-部署说明.md",
    "LICENSE",
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
    
    Compress-Archive -Path $RequiredFiles -DestinationPath $ZipPath -Force
    
    # 生成校验和
    $Checksum = Get-FileHash -Path $ZipPath -Algorithm SHA256
    $ChecksumPath = "$ZipPath.sha256"
    $Checksum.Hash | Out-File -FilePath $ChecksumPath -Encoding ascii
    
    Write-Host "[成功] 打包完成！" -ForegroundColor Green
    Write-Host "ZIP 文件路径: $ZipPath" -ForegroundColor Cyan
    Write-Host "SHA256 校验和: $ChecksumPath" -ForegroundColor Cyan
} catch {
    Write-Host "[错误] 打包失败: $_" -ForegroundColor Red
}

Read-Host "按回车键退出"
