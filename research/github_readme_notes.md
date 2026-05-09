# Blender-MCP GitHub 仓库研究笔记

## 项目概述
- **名称**: BlenderMCP - Blender Model Context Protocol Integration
- **版本**: 1.5.5
- **Stars**: 21.5k
- **许可**: MIT
- **作者**: Siddharth (ahujasid)

## 项目作用
BlenderMCP 通过 Model Context Protocol (MCP) 将 Blender 连接到 Claude AI，允许 Claude 直接与 Blender 交互和控制。实现 prompt 辅助的 3D 建模、场景创建和操作。

## 项目结构
```
blender-mcp/
├── assets/
├── src/blender_mcp/
│   └── server.py          # MCP Server
├── addon.py               # Blender 插件
├── main.py
├── pyproject.toml
├── uv.lock
├── .python-version
├── LICENSE
├── README.md
└── TERMS_AND_CONDITIONS.md
```

## 两个核心组件
1. **Blender Addon (addon.py)**: Blender 插件，在 Blender 内创建 socket 服务器来接收和执行命令
2. **MCP Server (src/blender_mcp/server.py)**: Python 服务器，实现 Model Context Protocol 并连接到 Blender 插件

## 前置条件
- Blender 3.0 或更新版本
- Python 3.10 或更新版本
- uv 包管理器

## Windows 安装 uv 的方法
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

然后添加 uv 到用户 PATH：
```powershell
$localBin = "$env:USERPROFILE\.local\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$userPath;$localBin", "User")
```

## 环境变量
- `BLENDER_HOST`: Blender socket 服务器地址 (默认: "localhost")
- `BLENDER_PORT`: Blender socket 服务器端口 (默认: 9876)

## Claude Desktop 配置
文件路径: Claude > Settings > Developer > Edit Config > claude_desktop_config.json
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

## Cursor 配置 (Windows)
Settings > MCP > Add Server:
```json
{
    "mcpServers": {
        "blender": {
            "command": "cmd",
            "args": ["/c", "uvx", "blender-mcp"]
        }
    }
}
```

## VS Code 配置
有一键安装按钮

## Blender 插件安装步骤
1. 下载 addon.py 文件
2. 打开 Blender
3. Edit > Preferences > Add-ons
4. 点击 "Install..." 选择 addon.py 文件
5. 勾选 "Interface: Blender MCP" 启用插件

## 使用方法
1. 在 Blender 中，打开 3D View 侧边栏 (按 N 键)
2. 找到 "BlenderMCP" 标签
3. 可选：开启 Poly Haven 复选框
4. 点击 "Connect to Claude"
5. 确保 MCP 服务器正在运行

## 功能特性
- 获取场景和对象信息
- 创建、删除和修改形状
- 应用或创建材质
- 在 Blender 中执行任意 Python 代码
- 通过 Poly Haven 下载模型、资产和 HDRI
- 通过 Hyper3D Rodin 生成 AI 3D 模型
- 查看 Blender 视口截图
- 搜索和下载 Sketchfab 模型
- 远程运行 Blender MCP

## 遥测控制
可通过环境变量 DISABLE_TELEMETRY=true 完全禁用遥测：
```json
{
    "mcpServers": {
        "blender": {
            "command": "uvx",
            "args": ["blender-mcp"],
            "env": {
                "DISABLE_TELEMETRY": "true"
            }
        }
    }
}
```

## 故障排除
- 连接问题：确保 Blender 插件服务器正在运行，MCP 服务器已在 Claude 中配置，不要在终端中运行 uvx 命令
- 超时错误：简化请求或分解为更小的步骤
- 重启 Claude 和 Blender 服务器

## 关键发现
- 安装方式非常简单：通过 uvx 直接运行 blender-mcp（无需 clone 仓库）
- 只需要安装 uv 包管理器，然后配置 MCP Client
- Blender 端只需要安装 addon.py 插件
- 不需要 Node.js
- 不需要手动 clone 仓库（uvx 会自动处理）
- 通信协议：JSON over TCP sockets，默认端口 9876
