# YouTube 教程分析笔记

## 视频信息
- URL: https://www.youtube.com/watch?v=lCyQ717DuzQ
- 标题: Blender MCP Full Tutorial

## 视频中的安装步骤

### 前置条件
- Blender (从 blender.org 下载)
- Node.js (从 nodejs.org 下载) — 注意：README 中未提及需要 Node.js
- Python (从 python.org 下载)
- uv 包管理器 (Windows 用户从 uv 官网安装)

### Blender 插件安装
1. 从 GitHub 仓库下载 ZIP（Code > Download ZIP）
2. 解压找到 addon.py 文件
3. Blender > Edit > Preferences > Add-ons
4. 点击 "Install from Disk..." 选择 addon.py
5. 勾选 "Interface: Blender MCP" 启用

### 启动 MCP 服务器
1. Blender 视口中按 N 键打开侧边栏
2. 点击 "Blender MCP" 标签
3. 点击 "Start MCP Server" 按钮
4. 默认端口: 9876

### Claude Desktop 配置
1. 安装 Claude Desktop
2. Settings > Developer > Edit Config
3. Windows 配置文件路径: %APPDATA%\Claude\claude_desktop_config.json
4. 添加 JSON 配置:
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
5. 保存文件
6. 完全退出 Claude Desktop 并重新打开
7. 验证：查看 Claude 聊天框中的锤子图标

## 视频与 README 的差异

### 差异 1: Node.js 需求
- **视频**: 列出 Node.js 为前置条件
- **README**: 未提及 Node.js
- **判断**: 当前版本(1.5.5)不需要 Node.js。项目是纯 Python 的，使用 uvx 运行。视频可能是早期版本的信息。

### 差异 2: 启动顺序
- **视频**: 强调严格的启动顺序（Claude Desktop → Blender → Start MCP Server）
- **README**: 未明确说明启动顺序
- **判断**: 视频的建议更实用，应遵循

### 差异 3: 不要在终端运行命令
- **视频**: 明确指出不需要在终端运行 `uvx blender-mcp`，只需在 Blender 中点击按钮
- **README**: 说明配置 MCP Client 后，uvx 命令由 Client 自动调用
- **判断**: 两者不矛盾。uvx blender-mcp 是 MCP Client（如 Claude Desktop）自动调用的，用户不需要手动在终端执行。Blender 中的 "Start MCP Server" 按钮启动的是 Blender 端的 socket 服务器（addon），不是 MCP Server。

### 差异 4: Blender 中的按钮名称
- **视频**: "Start MCP Server"
- **README**: "Connect to Claude"
- **判断**: 可能是版本更新导致的 UI 变化，功能相同

## 关键理解
实际上系统有两个组件：
1. **Blender 端 (addon.py)**: 在 Blender 内运行 socket 服务器，监听端口 9876
2. **MCP Server (uvx blender-mcp)**: 由 MCP Client（如 Claude Desktop）自动启动，连接到 Blender 的 socket 服务器

用户需要做的：
1. 安装 uv
2. 配置 MCP Client 的 JSON 配置文件
3. 在 Blender 中安装并启用 addon.py
4. 在 Blender 中点击连接按钮
5. MCP Client 会自动通过 uvx 启动 MCP Server
