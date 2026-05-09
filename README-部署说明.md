# Blender MCP Windows 一键部署包说明

## 1. 概述
本部署包用于在 Windows 环境下快速配置 Blender MCP。它会自动检测环境、安装依赖的 `uv` 包管理器、下载 Blender 插件，并协助配置您的 Antigravity MCP 客户端。

## 2. 部署前提条件
- Windows 10/11 操作系统
- 已安装 **Python 3.10+** (必须)
- 已安装 **Blender 5.1** (位于 `C:\Program Files\Blender Foundation\Blender 5.1`)
- 稳定的网络连接（需访问 GitHub 和包镜像）

## 3. 文件结构说明
```text
blender-mcp-windows-installer/
├─ install-blender-mcp.bat    # 启动器，双击运行，会自动请求管理员权限
├─ install-blender-mcp.ps1    # 核心部署脚本，由 bat 启动器调用
├─ start-blender-mcp.ps1      # 启动顺序指南
├─ uninstall-blender-mcp.ps1  # 卸载脚本
├─ config-example.json        # MCP 客户端配置示例
├─ README-部署说明.md         # 本文档
└─ logs/                      # 安装日志目录
```

## 4. 运行方法 (如何安装)
1. 将解压后的文件夹放在任意位置。
2. **右键点击 `install-blender-mcp.bat`**，选择 **"以管理员身份运行"**（或直接双击，会弹出 UAC 提示）。
3. 按照屏幕上的中文提示进行操作。
4. 当提示输入 Antigravity 配置文件路径时，请输入绝对路径（例如 `C:\Users\用户名\.antigravity\mcp.json`）。如果不确定，可以直接按回车跳过，稍后手动配置。

## 5. 手动配置与验证
脚本执行完成后，请按照以下步骤完成最后设置：

### 5.1 在 Blender 中启用插件
1. 打开 Blender 5.1。
2. 进入 `Edit` -> `Preferences` -> `Add-ons`。
3. 点击右上角的 `Install...` 按钮。
4. 导航到 `C:\MCP\blender-mcp` 目录，选择 `addon.py` 并安装。
5. 在插件列表中勾选 `Interface: Blender MCP` 启用它。

### 5.2 验证与连接
**严格的启动顺序：**
1. **先打开** Antigravity 客户端。
2. **再打开** Blender。
3. 在 Blender 3D 视图中，按 `N` 键打开右侧面板。
4. 找到底部的 `Blender MCP` 标签。
5. 点击 `Start MCP Server` (或 `Connect to Claude`) 按钮。

## 6. 常见错误排查
- **找不到 uvx 命令**：安装脚本已将 uv 添加到环境变量。如果 Antigravity 报错找不到命令，请完全退出并重启 Antigravity，或重启电脑以使环境变量生效。
- **连接超时/失败**：请确保严格按照上述 5.2 的顺序启动。不要在终端中手动运行 `uvx blender-mcp`，它应该由 Antigravity 自动启动。
- **JSON 格式错误**：如果脚本修改配置失败，请参考 `config-example.json` 手动将配置添加到 Antigravity 的配置中，注意逗号和括号的闭合。

## 7. 卸载方法
1. 在 Blender 中禁用并删除该插件。
2. 在 Antigravity 配置中删除 `blender` 节点。
3. 右键运行 `uninstall-blender-mcp.ps1` (选择"使用 PowerShell 运行") 删除 `C:\MCP\blender-mcp` 目录。

## 8. 注意事项
- 本脚本会默认禁用 Blender MCP 的遥测功能（`DISABLE_TELEMETRY=true`）。
- 脚本在修改您的 MCP 配置文件前，会自动在同目录下创建一个带有时间戳的 `.bak` 备份文件，如果配置损坏，可以通过重命名恢复。
