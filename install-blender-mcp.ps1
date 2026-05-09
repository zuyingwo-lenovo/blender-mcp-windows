<#
.SYNOPSIS
    Blender MCP Windows 一键部署脚本 (兼容 PowerShell 5.1)
.DESCRIPTION
    此脚本用于在 Windows 环境下自动部署 Blender MCP。
#>

$ErrorActionPreference = "Stop"

# 尝试获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([string]::IsNullOrEmpty($ScriptDir)) { $ScriptDir = $PSScriptRoot }
if ([string]::IsNullOrEmpty($ScriptDir)) { $ScriptDir = Get-Location }

$LogDir = Join-Path $ScriptDir "logs"
$LogFile = ""

try {
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $LogFile = Join-Path $LogDir "install_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
} catch {
    Write-Host "[警告] 无法创建日志目录或文件: $_" -ForegroundColor Yellow
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    if ($LogFile) {
        try { Add-Content -Path $LogFile -Value $LogMessage -ErrorAction SilentlyContinue } catch {}
    }
    
    switch ($Level) {
        "INFO" { Write-Host "[信息] $Message" -ForegroundColor Cyan }
        "SUCCESS" { Write-Host "[成功] $Message" -ForegroundColor Green }
        "WARN" { Write-Host "[警告] $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "[错误] $Message" -ForegroundColor Red }
    }
}

# 兼容性助手：将 PSCustomObject 递归转换为 Hashtable (用于 PS 5.1)
function Convert-ObjectToHashtable {
    param($InputObject)
    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string] -and $InputObject -isnot [System.Collections.IDictionary]) {
        return @($InputObject | ForEach-Object { Convert-ObjectToHashtable $_ })
    } elseif ($InputObject -is [PSCustomObject] -or $InputObject -is [System.Management.Automation.PSObject]) {
        $hash = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $hash[$prop.Name] = Convert-ObjectToHashtable $prop.Value
        }
        return $hash
    } else {
        return $InputObject
    }
}

function Get-BlenderPath {
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
    
    $commonPaths = @(
        "C:\Program Files\Blender Foundation",
        "$env:ProgramFiles\Blender Foundation",
        "$env:ProgramFiles(x86)\Blender Foundation"
    )
    foreach ($basePath in $commonPaths) {
        if (Test-Path $basePath) {
            $latest = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -match "Blender" } | Sort-Object Name -Descending | Select-Object -First 1
            if ($latest) { return $latest.FullName }
        }
    }
    return $null
}

function Get-MCPConfigs {
    $configs = @()
    $claude = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"
    if (Test-Path $claude) { $configs += [PSCustomObject]@{ Name="Claude Desktop"; Path=$claude } }
    
    $cursorPaths = @(
        (Join-Path $env:APPDATA "Cursor\User\globalStorage\robbie.cursor-mcp\mcp.json"),
        (Join-Path $env:APPDATA "Cursor\User\globalStorage\mcp-servers.json")
    )
    foreach ($p in $cursorPaths) {
        if (Test-Path $p) { $configs += [PSCustomObject]@{ Name="Cursor"; Path=$p }; break }
    }
    
    $windsurf = Join-Path $env:USERPROFILE ".codeium\windsurf\mcp_config.json"
    if (Test-Path $windsurf) { $configs += [PSCustomObject]@{ Name="Windsurf"; Path=$windsurf } }
    return $configs
}

try {
    Write-Log "开始 Blender MCP 部署流程" "INFO"
    Write-Log "=======================================" "INFO"

    # 1. 检查 Python
    Write-Log "正在检测 Python 环境..." "INFO"
    try {
        $PythonVersion = & python --version 2>&1
        Write-Log "检测到 Python: $PythonVersion" "SUCCESS"
    } catch {
        Write-Log "未检测到 Python。请先安装 Python 3.10+ 并添加到 PATH。" "ERROR"
        Read-Host "按回车键退出"
        exit
    }

    # 2. 检查 uv
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
            Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1" -OutFile "$env:TEMP\install_uv.ps1" -UseBasicParsing
            & "$env:TEMP\install_uv.ps1"
            
            $localBin = "$env:USERPROFILE\.local\bin"
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notmatch [regex]::Escape($localBin)) {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$localBin", "User")
                $env:Path = "$env:Path;$localBin"
            }
            Write-Log "uv 安装完成。" "SUCCESS"
        } catch {
            Write-Log "uv 自动安装失败，请手动安装: https://astral.sh/uv" "WARN"
        }
    }

    # 3. 检查 Blender
    Write-Log "正在搜索 Blender 安装路径..." "INFO"
    $BlenderPath = Get-BlenderPath
    if ($null -eq $BlenderPath) {
        Write-Log "未能自动检测到 Blender。请确保已安装 Blender。" "WARN"
    } else {
        Write-Log "检测到 Blender: $BlenderPath" "SUCCESS"
    }

    $InstallDir = "C:\MCP\blender-mcp"
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $AddonUrl = "https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py"
    $AddonDest = Join-Path $InstallDir "addon.py"

    try {
        Write-Log "正在下载 Blender 插件..." "INFO"
        Invoke-WebRequest -Uri $AddonUrl -OutFile $AddonDest -UseBasicParsing
        Write-Log "插件已下载至: $AddonDest" "SUCCESS"
    } catch {
        Write-Log "下载插件失败，请检查网络。" "ERROR"
    }

    # 4. 配置 MCP 客户端
    Write-Log "正在配置 MCP 客户端..." "INFO"
    $DetectedConfigs = Get-MCPConfigs
    $ConfigPath = ""
    $choice = ""

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
            # 兼容性处理：ConvertFrom-Json 不带 -AsHashtable
            $JsonRaw = Get-Content -Path $ConfigPath -Raw
            if ([string]::IsNullOrWhiteSpace($JsonRaw)) { $JsonRaw = "{}" }
            
            $RawObj = $JsonRaw | ConvertFrom-Json
            $JsonContent = Convert-ObjectToHashtable $RawObj
            
            if ($null -eq $JsonContent) { $JsonContent = @{} }
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
        } else {
            Write-Log "找不到配置文件: $ConfigPath" "WARN"
        }
    }

    Write-Log "=======================================" "INFO"
    Write-Log "部署完成！" "SUCCESS"
    Write-Log "请按照 README 说明在 Blender 中安装插件并启用。" "INFO"
} catch {
    Write-Log "发生意外错误: $_" "ERROR"
    Write-Log $_.ScriptStackTrace "ERROR"
} finally {
    Write-Host "`n部署脚本执行结束。"
    Read-Host "按回车键退出"
}
