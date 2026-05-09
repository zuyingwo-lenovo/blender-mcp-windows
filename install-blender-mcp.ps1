<#
.SYNOPSIS
    Blender MCP Windows 一键部署脚本
.DESCRIPTION
    此脚本用于在 Windows 环境下自动部署 Blender MCP (https://github.com/ahujasid/blender-mcp)。
    主要步骤包括：环境检测、安装 uv、下载插件、配置 Antigravity MCP 客户端。
#>

$ErrorActionPreference = "Stop"
$LogDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
$LogFile = Join-Path $LogDir "install_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    
    switch ($Level) {
        "INFO" { Write-Host "[信息] $Message" -ForegroundColor Cyan }
        "SUCCESS" { Write-Host "[成功] $Message" -ForegroundColor Green }
        "WARN" { Write-Host "[警告] $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "[错误] $Message" -ForegroundColor Red }
    }
}

function Get-BlenderPath {
    # 1. 尝试注册表
    $regPaths = @(
        "HKLM:\SOFTWARE\Blender Foundation\Blender",
        "HKCU:\SOFTWARE\Blender Foundation\Blender"
    )
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $installDir = (Get-ItemProperty $regPath -ErrorAction SilentlyContinue).InstallDir
            if ($installDir -and (Test-Path $installDir)) { return $installDir }
        }
    }
    
    # 2. 尝试常见安装位置
    $commonPaths = @(
        "C:\Program Files\Blender Foundation",
        "$env:ProgramFiles\Blender Foundation",
        "$env:ProgramFiles(x86)\Blender Foundation"
    )
    foreach ($basePath in $commonPaths) {
        if (Test-Path $basePath) {
            # 获取最新版本的文件夹 (例如 Blender 4.2)
            $latest = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -match "Blender" } | Sort-Object Name -Descending | Select-Object -First 1
            if ($latest) { return $latest.FullName }
        }
    }
    return $null
}

function Get-MCPConfigs {
    $configs = @()
    
    # Claude Desktop
    $claude = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"
    if (Test-Path $claude) { $configs += [PSCustomObject]@{ Name="Claude Desktop"; Path=$claude } }
    
    # Cursor
    $cursorPaths = @(
        Join-Path $env:APPDATA "Cursor\User\globalStorage\robbie.cursor-mcp\mcp.json",
        Join-Path $env:APPDATA "Cursor\User\globalStorage\mcp-servers.json"
    )
    foreach ($p in $cursorPaths) {
        if (Test-Path $p) { $configs += [PSCustomObject]@{ Name="Cursor"; Path=$p }; break }
    }
    
    # Windsurf
    $windsurf = Join-Path $env:USERPROFILE ".codeium\windsurf\mcp_config.json"
    if (Test-Path $windsurf) { $configs += [PSCustomObject]@{ Name="Windsurf"; Path=$windsurf } }

    return $configs
}

Write-Log "开始 Blender MCP 部署流程" "INFO"
Write-Log "=======================================" "INFO"

# 1. 检查 Python
Write-Log "正在检测 Python 环境..." "INFO"
try {
    $PythonVersion = & python --version 2>&1
    Write-Log "检测到 Python: $PythonVersion" "SUCCESS"
} catch {
    Write-Log "未检测到 Python。请先从 python.org 安装 Python 3.10 或以上版本。" "ERROR"
    Read-Host "按回车键退出"
    exit
}

# 2. 安装/检查 uv
Write-Log "正在检测 uv 包管理器..." "INFO"
$UvInstalled = $false
try {
    $UvVersion = & uv --version 2>&1
    Write-Log "检测到 uv: $UvVersion" "SUCCESS"
    $UvInstalled = $true
} catch {
    Write-Log "未检测到 uv，准备自动安装..." "INFO"
}

if (-not $UvInstalled) {
    try {
        Write-Log "正在下载并安装 uv..." "INFO"
        Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1" -OutFile "$env:TEMP\install_uv.ps1"
        & "$env:TEMP\install_uv.ps1"
        
        $localBin = "$env:USERPROFILE\.local\bin"
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notmatch [regex]::Escape($localBin)) {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$localBin", "User")
            $env:Path = "$env:Path;$localBin"
            Write-Log "已将 uv 添加到环境变量 PATH。" "SUCCESS"
        }
        Write-Log "uv 安装完成。" "SUCCESS"
    } catch {
        Write-Log "uv 安装失败: $_" "ERROR"
        Write-Log "请手动执行: powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`"" "WARN"
        Read-Host "按回车键退出"
        exit
    }
}

# 3. 检查 Blender
Write-Log "正在搜索 Blender 安装路径..." "INFO"
$BlenderPath = Get-BlenderPath

if ($null -eq $BlenderPath) {
    Write-Log "未能自动检测到 Blender。请确保已安装 Blender (推荐 4.0+)。" "WARN"
} else {
    Write-Log "检测到 Blender: $BlenderPath" "SUCCESS"
}

$InstallDir = "C:\MCP\blender-mcp"
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Log "创建部署目录: $InstallDir" "SUCCESS"
}

$AddonUrl = "https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py"
$AddonDest = Join-Path $InstallDir "addon.py"

try {
    Write-Log "正在从 GitHub 下载 Blender 插件 (addon.py)..." "INFO"
    Invoke-WebRequest -Uri $AddonUrl -OutFile $AddonDest
    Write-Log "插件下载成功，保存至: $AddonDest" "SUCCESS"
} catch {
    Write-Log "下载插件失败: $_" "ERROR"
    Write-Log "请手动从 GitHub 下载 addon.py 并放入 $InstallDir" "WARN"
}

# 4. 配置 MCP 客户端
Write-Log "正在配置 MCP 客户端..." "INFO"
$DetectedConfigs = Get-MCPConfigs

$ConfigPath = ""
if ($DetectedConfigs.Count -gt 0) {
    Write-Host "`n检测到以下 MCP 客户端配置：" -ForegroundColor Yellow
    for ($i = 0; $i -lt $DetectedConfigs.Count; $i++) {
        Write-Host "  [$($i+1)] $($DetectedConfigs[$i].Name): $($DetectedConfigs[$i].Path)"
    }
    Write-Host "  [0] 手动输入路径 / 跳过"
    
    $choice = Read-Host "`n请选择要配置的客户端编号"
    if ($choice -match "^\d+$" -and [int]$choice -gt 0 -and [int]$choice -le $DetectedConfigs.Count) {
        $ConfigPath = $DetectedConfigs[[int]$choice - 1].Path
    }
}

if ([string]::IsNullOrWhiteSpace($ConfigPath) -and $choice -ne "0") {
    $ConfigPath = Read-Host "请输入 MCP 配置文件路径 (留空跳过)"
}

if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
    if (Test-Path $ConfigPath) {
        try {
            # 备份
            $BackupPath = "$ConfigPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item -Path $ConfigPath -Destination $BackupPath
            Write-Log "已备份配置文件: $BackupPath" "SUCCESS"

            # 解析并注入
            $JsonRaw = Get-Content -Path $ConfigPath -Raw
            if ([string]::IsNullOrWhiteSpace($JsonRaw)) { $JsonRaw = "{}" }
            $JsonContent = $JsonRaw | ConvertFrom-Json -AsHashtable
            
            if (-not $JsonContent.ContainsKey("mcpServers")) {
                $JsonContent.Add("mcpServers", @{})
            }

            $BlenderConfig = @{
                command = "cmd"
                args = @("/c", "uvx", "blender-mcp")
                env = @{
                    BLENDER_HOST = "localhost"
                    BLENDER_PORT = "9876"
                    DISABLE_TELEMETRY = "true"
                }
            }

            $JsonContent["mcpServers"]["blender"] = $BlenderConfig

            $NewJson = $JsonContent | ConvertTo-Json -Depth 10
            Set-Content -Path $ConfigPath -Value $NewJson -Encoding UTF8
            Write-Log "已成功更新配置: $ConfigPath" "SUCCESS"
        } catch {
            Write-Log "更新配置失败: $_" "ERROR"
        }
    } else {
        Write-Log "路径不存在: $ConfigPath" "WARN"
    }
}

Write-Log "=======================================" "INFO"
Write-Log "部署流程完成！" "SUCCESS"
Write-Log "" "INFO"
Write-Log "下一步操作：" "INFO"
Write-Log "1. 打开 Blender，进入 Preferences -> Add-ons。" "INFO"
Write-Log "2. 点击 Install，选择 $AddonDest。" "INFO"
Write-Log "3. 启用 'Interface: Blender MCP' 插件。" "INFO"
Write-Log "4. 在 Blender 3D View 侧栏 (N 键) 点击 'Connect to Claude'。" "INFO"
Write-Log "5. 重启您的 MCP 客户端 (Claude/Cursor 等)。" "INFO"
Read-Host "按回车键退出"
