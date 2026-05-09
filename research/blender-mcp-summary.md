# Blender-MCP Windows 本地部署总结报告

通过对 GitHub 仓库（ahujasid/blender-mcp）以及 YouTube 教程的深入分析，我为您整理了以下部署总结。

## 1. 这个 MCP 的作用
BlenderMCP 是一个通过 Model Context Protocol (MCP) 将 Blender 与 AI 助手（如 Claude、Cursor 等）连接的桥梁。它允许 AI 直接与 Blender 交互并控制它，从而实现提示词辅助的 3D 建模、场景创建、材质修改以及在 Blender 中执行任意 Python 代码等功能。

该系统由两个核心组件构成：
1. **Blender Addon (`addon.py`)**：在 Blender 内部运行，创建一个 Socket 服务器（默认监听 9876 端口）来接收和执行命令。
2. **MCP Server**：一个 Python 程序（通过 `uvx blender-mcp` 运行），实现 MCP 协议并连接到 Blender 插件的 Socket 服务器。

## 2. Windows 本地部署所需前置条件
- **操作系统**：Windows 10/11
- **网络**：能够访问 GitHub、Python 包索引（PyPI）以及可能的 3D 资产网站（如 Poly Haven）。

## 3. 需要安装的软件
- **Blender**：3.0 或更新版本。
- **Python**：3.10 或更新版本（虽然项目中提到了 `.python-version` 为 3.13.2，但 3.10+ 即可）。
- **uv 包管理器**：这是一个极其快速的 Python 包安装和解析工具，MCP Server 依赖它来运行。
- **Git**：可选，但推荐用于克隆仓库获取最新插件文件。
- **注意**：视频教程中提到了需要 Node.js，但根据最新的 GitHub 仓库内容，该项目是纯 Python 实现的，**不需要**安装 Node.js。

## 4. 需要下载或生成的文件
- **`addon.py`**：Blender 插件文件，需要从 GitHub 仓库下载并安装到 Blender 中。
- **MCP Client 配置文件**：如 Claude Desktop 的 `claude_desktop_config.json` 或 Cursor 的 `mcp.json`，需要生成或修改。

## 5. 需要修改的配置文件
主要涉及您所使用的 MCP Client 的配置。例如，如果使用 Claude Desktop，需要修改 `%APPDATA%\Claude\claude_desktop_config.json`，添加如下内容：

```json
{
  "mcpServers": {
    "blender": {
      "command": "uvx",
      "args": ["blender-mcp"]
    }
  }
}
```
*注：如果是 Cursor (Windows)，命令需要改为 `cmd`，参数为 `["/c", "uvx", "blender-mcp"]`。*

## 6. 部署步骤分析

### 手动操作步骤（建议用户手动完成）
1. **安装 Blender 和 Python**：这通常涉及系统级别的安装路径选择和环境变量配置，建议用户自行安装。
2. **在 Blender 中启用插件**：
   - 打开 Blender -> Edit -> Preferences -> Add-ons。
   - 点击 "Install..." 并选择下载好的 `addon.py`。
   - 勾选 "Interface: Blender MCP" 启用。
3. **启动连接**：
   - 必须遵循严格的启动顺序：先打开 MCP Client，再打开 Blender，最后在 Blender 的 3D View 侧边栏（按 N 键）点击 "Connect to Claude"（或视频中的 "Start MCP Server"）。

### 可自动化的步骤（脚本可以完成）
1. **环境检测**：检查 Python、Blender 是否已安装。
2. **安装 uv 包管理器**：通过 PowerShell 自动下载并安装 uv，并将其添加到用户环境变量。
3. **下载插件**：自动从 GitHub 仓库下载最新的 `addon.py` 到指定目录。
4. **配置 MCP Client**：自动检测 Claude Desktop、Cursor 等的配置文件路径，备份原文件，并注入 Blender MCP 的配置。
5. **创建快捷启动脚本**：生成一键启动的批处理或 PowerShell 脚本。

### 潜在风险和常见失败点
- **启动顺序错误**：如果不按照 "Client -> Blender -> 启动插件服务器" 的顺序，可能会导致 Socket 连接超时或失败。
- **uv 环境变量未生效**：安装 uv 后，如果终端或 MCP Client 没有重新加载环境变量，会导致找不到 `uvx` 命令。
- **端口冲突**：默认使用 9876 端口，如果被其他程序占用会启动失败。
- **JSON 格式错误**：手动或脚本修改 MCP Client 配置文件时，容易破坏原有的 JSON 结构。

---

## 等待您的确认

在为您生成最终的一键部署脚本之前，请确认以下偏好设置：

1. **脚本语言**：确认使用 **PowerShell** 作为主脚本（辅以 .bat 启动器）？
2. **Blender 安装路径**：脚本是否需要尝试自动检测 Blender 路径，还是您希望在脚本中手动指定？
3. **MCP Client**：您主要使用的是哪一个 MCP Client（Claude Desktop、Cursor、Windsurf、Cline 还是其他）？
4. **自动配置**：是否希望脚本自动为您写入该 MCP Client 的配置文件（脚本会自动备份原文件）？
5. **打包需求**：是否需要把所有部署文件（脚本、说明文档等）打包成一个 ZIP 文件提供给您？

请回复您的选择，我将立即为您生成并打包部署脚本。
