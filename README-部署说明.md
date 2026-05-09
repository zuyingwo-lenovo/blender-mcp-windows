# Blender MCP Windows 一键部署包说明

## 1. 概述
本部署包用于在 Windows 环境下快速配置 Blender MCP。它会自动检测 **Python**、**Blender**（通过注册表和路径搜索）、**MCP 客户端配置**（如 Claude Desktop, Cursor, Windsurf），安装依赖的 `uv` 包管理器，下载最新的 Blender 插件，并协助完成配置。

## 2. 部署前提条件
- Windows 10/11 操作系统
- 已安装 **Python 3.10+** (必须)
- 已安装 **Blender 3.0+** (脚本会自动尝试定位安装路径)
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
1. 将文件夹放在您的工作目录。
2. **双击 `install-blender-mcp.bat`**。
3. 脚本会自动申请管理员权限。
4. 按照屏幕上的中文提示进行操作：
   - 脚本会自动寻找 Blender。
   - 脚本会扫描已安装的 MCP 客户端（Claude, Cursor, Windsurf），您可以选择其中一个进行自动配置。
   - 如果没有检测到，您可以手动输入配置文件的绝对路径。

## 5. 手动配置与验证
脚本执行完成后，请按照以下步骤完成最后设置：

### 5.1 在 Blender 中启用插件
1. 打开 Blender。
2. 进入 `Edit` -> `Preferences` -> `Add-ons`。
3. 点击右上角的 `Install...` 按钮。
4. 导航到 `C:\MCP\blender-mcp` 目录，选择 `addon.py` 并安装。
5. 在插件列表中勾选 `Interface: Blender MCP` 启用它。

### 5.2 验证与连接
**严格的启动顺序：**
1. **先打开** 您的 MCP 客户端 (Claude Desktop/Cursor 等)。
2. **再打开** Blender。
3. 在 Blender 3D 视图中，按 `N` 键打开右侧面板。
4. 找到底部的 `Blender MCP` 标签。
5. 点击 `Connect to Claude` (或 `Start MCP Server`) 按钮。

## 6. 常见错误排查
- **找不到 uvx 命令**：安装脚本已将 uv 添加到环境变量。如果客户端报错找不到命令，请尝试重启电脑或客户端。
- **连接超时/失败**：请确保严格按照上述 5.2 的顺序启动。
- **权限问题**：请确保是以管理员身份运行 `.bat` 文件。

## 7. 卸载方法
1. 在 Blender 中禁用并删除该插件。
2. 在 MCP 客户端配置中删除 `blender` 节点。
3. 右键运行 `uninstall-blender-mcp.ps1` 删除部署目录。

## 8. 注意事项
- 本脚本会默认禁用 Blender MCP 的遥测功能（`DISABLE_TELEMETRY=true`）。
- 脚本在修改您的配置文件前，会自动在同目录下创建一个 `.bak` 备份文件。
