# Blender MCP Windows 部署包说明

## 1. 概述
本工具包用于在 Windows 环境下**半自动**配置 [Blender MCP](https://github.com/ahujasid/blender-mcp)。它会自动检测环境、安装 `uv` 包管理器、下载插件代码，并安全地更新 MCP 客户端配置。

> **注意：** “一键”是指自动化了环境依赖和配置文件写入。在 Blender 界面内安装并启用插件仍需用户手动操作。

## 2. 部署前提条件
- Windows 10/11
- 已安装 **Python 3.10+** (且已加入 PATH)
- 已安装 **Blender 3.0+**
- 稳定的网络连接

## 3. 支持矩阵 (Support Matrix)

| 客户端 | 自动检测 | 自动写入 | 配置路径可靠性 | 状态 |
| :--- | :---: | :---: | :---: | :--- |
| Claude Desktop | 是 | 是 | 高 | 已支持 |
| Cursor | 是 | 是 | 中 | 已支持 |
| Windsurf | 是 | 是 | 中 | 已支持 |
| Claude Code | 否 | 否 | 高 (可 CLI) | 计划 v1.1 |
| VS Code / Cline| 否 | 否 | 中 | 计划 v1.2 |

## 4. 运行方法 (如何安装)
1. **双击 `install-blender-mcp.bat`**。
2. 脚本默认安装至 `%LOCALAPPDATA%\blender-mcp-windows` (通常无需管理员权限)。
3. 按照屏幕提示选择要配置的客户端。
4. **安全保障：** 脚本在修改任何配置文件前，都会自动创建一个带有时间戳的 `.bak` 备份。

## 5. 手动配置与验证

### 5.1 在 Blender 中启用插件
1. 打开 Blender。
2. 进入 `Edit` -> `Preferences` -> `Add-ons`。
3. 点击 `Install...`，选择安装目录下的 `addon.py`。
4. 勾选 `Interface: Blender MCP` 启用。

### 5.2 验证与连接
1. **启动** 您的 MCP 客户端 (Claude Desktop/Cursor 等)。
2. **启动** Blender。
3. 在 Blender 3D 视图按 `N` 键打开侧边栏 -> `Blender MCP` -> 点击 `Connect`。

## 6. 安全说明
- **代码执行：** `execute_blender_code` 工具允许 AI 在 Blender 内运行任意 Python 代码。请仅连接至受信任的客户端。
- **保存工作：** 在运行 AI 操作前，请务必保存您的 `.blend` 工程。
- **外部资源：** PolyHaven、Sketchfab 等工具会访问外部服务器下载 3D 模型或贴图。
- **遥测：** 脚本默认禁用遥测 (`DISABLE_TELEMETRY=true`)。

## 7. 版权与许可
- **上游项目：** [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) (MIT License)。
- **本项目：** 采用 [MIT License](LICENSE) 开源。
- *声明：本安装工具与上游 BlenderMCP 项目无官方隶属关系。*

## 8. 常见错误排查
- **找不到 uvx 命令：** 安装后请重启 MCP 客户端以刷新环境变量。
- **首次运行延迟：** 首次在 MCP 客户端中使用时，`uvx` 会下载所需包，可能需要 1-2 分钟，请耐心等待。
- **多实例运行：** 请勿同时运行多个 MCP 客户端（如 Cursor 和 Claude）连接同一个 Blender 实例。
