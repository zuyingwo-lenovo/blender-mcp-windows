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

# 3. 检查 Blender 并下载插件
$BlenderPath = "C:\Program Files\Blender Foundation\Blender 5.1"
Write-Log "检查用户指定的 Blender 路径: $BlenderPath" "INFO"

if (-not (Test-Path $BlenderPath)) {
    Write-Log "未找到指定的 Blender 目录: $BlenderPath" "WARN"
    Write-Log "脚本将继续下载插件，您可能需要手动在 Blender 中安装。" "WARN"
} else {
    Write-Log "Blender 目录存在。" "SUCCESS"
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

# 4. 配置 Antigravity MCP
Write-Log "正在配置 Antigravity MCP 客户端..." "INFO"
Write-Log "由于 Antigravity 的配置文件路径可能因系统而异，请提供其配置文件的绝对路径。" "INFO"
Write-Log "通常是一个名为 mcp.json 或类似名称的文件。" "INFO"

$ConfigPath = Read-Host "请输入 Antigravity 配置文件的完整路径 (例如 C:\Users\YourName\.antigravity\mcp.json，留空跳过)"

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    Write-Log "用户跳过自动配置 MCP 客户端。" "WARN"
} elseif (-not (Test-Path $ConfigPath)) {
    Write-Log "未找到文件: $ConfigPath。请手动将 config-example.json 中的内容添加到您的配置中。" "WARN"
} else {
    try {
        # 备份原配置
        $BackupPath = "$ConfigPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -Path $ConfigPath -Destination $BackupPath
        Write-Log "已备份原配置文件至: $BackupPath" "SUCCESS"

        # 读取并解析 JSON
        $JsonContent = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json -AsHashtable
        
        if ($null -eq $JsonContent.mcpServers) {
            $JsonContent.Add("mcpServers", @{})
        }

        # 准备 Blender MCP 配置
        $BlenderConfig = @{
            command = "cmd"
            args = @("/c", "uvx", "blender-mcp")
            env = @{
                BLENDER_HOST = "localhost"
                BLENDER_PORT = "9876"
                DISABLE_TELEMETRY = "true"
            }
        }

        $JsonContent.mcpServers.blender = $BlenderConfig

        # 写回 JSON
        $NewJson = $JsonContent | ConvertTo-Json -Depth 10 -Compress:$false
        Set-Content -Path $ConfigPath -Value $NewJson -Encoding UTF8
        Write-Log "已成功将 Blender MCP 配置写入 Antigravity 配置文件。" "SUCCESS"
    } catch {
        Write-Log "修改配置文件时出错: $_" "ERROR"
        Write-Log "请手动将 config-example.json 中的内容添加到您的配置中。" "WARN"
    }
}

Write-Log "=======================================" "INFO"
Write-Log "部署脚本执行完毕！" "SUCCESS"
Write-Log "请按照以下步骤完成最终设置：" "INFO"
Write-Log "1. 打开 Blender 5.1" "INFO"
Write-Log "2. 进入 Edit -> Preferences -> Add-ons" "INFO"
Write-Log "3. 点击 'Install...'，选择 $AddonDest" "INFO"
Write-Log "4. 勾选 'Interface: Blender MCP' 启用插件" "INFO"
Write-Log "5. 重启 Antigravity 客户端" "INFO"
Write-Log "6. 在 Blender 3D View 侧边栏 (按 N) 点击 'Connect to Claude/Start MCP Server'" "INFO"
Write-Log "详细说明请参考 README-部署说明.md" "INFO"
