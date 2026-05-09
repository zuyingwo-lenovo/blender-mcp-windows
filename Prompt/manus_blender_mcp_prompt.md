# Manus 提示词：Windows 本地部署 blender-mcp

你是一名资深 Windows 自动化部署工程师，请帮我在本地 Windows 环境从零部署以下 MCP：

GitHub 项目：
https://github.com/ahujasid/blender-mcp

参考教程：
https://www.youtube.com/watch?v=lCyQ717DuzQ

你的目标是：先完整学习 GitHub README、项目结构、依赖说明、安装方式，以及 YouTube Full tutorial 的关键步骤；然后总结确认；最后为我生成一个从零开始、一键即用的 Windows 部署脚本，可以是 batch 脚本，也可以是 PowerShell 脚本，优先使用 PowerShell。

请严格按照以下流程执行：

## 第 1 阶段：资料学习与总结

1. 打开并阅读 GitHub 仓库：
   - README
   - 安装说明
   - 依赖项
   - 启动方式
   - MCP 配置方式
   - Blender 插件或脚本相关文件
   - Claude Desktop / Cursor / Windsurf / 其他 MCP Client 的配置方式，如仓库中有说明请一并总结

2. 打开并学习 YouTube 教程：
   - 提取教程中的完整安装流程
   - 记录所有命令
   - 记录所有手动操作步骤
   - 记录视频中涉及的路径、配置文件、端口、环境变量、Blender 设置等
   - 如果视频内容与 GitHub README 有差异，请指出差异，并判断哪个更适合当前最新版本

3. 输出一份中文总结，包含：
   - 这个 MCP 的作用
   - Windows 本地部署所需前置条件
   - 需要安装的软件，例如 Python、Git、Blender、uv、Node.js 等，如果需要的话
   - 需要下载或生成的文件
   - 需要修改的配置文件
   - 手动操作步骤
   - 可自动化的步骤
   - 不建议自动化、需要用户确认的步骤
   - 潜在风险和常见失败点

4. 在输出总结之后，暂停并向我确认：
   - 是否使用 PowerShell 作为主脚本
   - 我的 Blender 安装路径是否需要指定
   - 我的 MCP Client 是 Claude Desktop、Cursor、Windsurf、Cline，还是其他
   - 是否希望脚本自动写入 MCP Client 配置
   - 是否需要把所有部署文件打包成 zip

在我确认之前，不要生成最终脚本。

## 第 2 阶段：生成一键部署脚本

在我确认之后，请生成一个从零开始可执行的 Windows 一键部署方案。

要求：

1. 优先提供 PowerShell 脚本，例如：
   - `install-blender-mcp.ps1`

2. 如有必要，再提供 batch 启动器，例如：
   - `install-blender-mcp.bat`
   - 用于以合适权限调用 PowerShell 脚本

3. 脚本必须尽可能自动完成：
   - 检测 Windows 系统
   - 检测是否已安装 Git
   - 检测是否已安装 Python
   - 检测是否已安装 Blender
   - 检测是否已安装 uv / pip / Node.js，如项目需要
   - 自动创建部署目录，例如：
     `C:\MCP\blender-mcp`
   - 自动 clone GitHub 仓库
   - 自动安装 Python 依赖
   - 自动创建虚拟环境，如有需要
   - 自动配置 Blender MCP 所需文件
   - 自动生成 MCP Client 配置片段
   - 可选：自动写入 Claude Desktop / Cursor / Windsurf / Cline 的 MCP 配置文件
   - 自动创建启动脚本
   - 自动创建卸载脚本
   - 自动创建日志目录
   - 自动记录安装日志
   - 自动检查安装是否成功

4. 脚本需要具备健壮性：
   - 每一步都输出清晰中文提示
   - 每一步都做错误检查
   - 出错时给出具体原因和解决建议
   - 不要静默失败
   - 对已有目录、已有配置、已有依赖要做兼容处理
   - 修改配置文件前必须自动备份
   - 配置文件写入前需要验证 JSON 格式
   - 路径中包含空格时也要正常工作

5. 最终请提供以下文件内容：
   - `install-blender-mcp.ps1`
   - `install-blender-mcp.bat`，如需要
   - `start-blender-mcp.ps1`
   - `uninstall-blender-mcp.ps1`
   - `README-部署说明.md`
   - `config-example.json`
   - `package-files.ps1`

6. 请同时提供文件夹结构，例如：

   ```text
   blender-mcp-windows-installer/
   ├─ install-blender-mcp.ps1
   ├─ install-blender-mcp.bat
   ├─ start-blender-mcp.ps1
   ├─ uninstall-blender-mcp.ps1
   ├─ package-files.ps1
   ├─ config-example.json
   ├─ README-部署说明.md
   └─ logs/
   ```

## 第 3 阶段：中间过程与文件打包

请提供完整中间过程，不要只给最终脚本。

需要包含：

1. 每个阶段执行了什么
2. 为什么这么做
3. 生成了哪些文件
4. 每个文件的用途
5. 用户需要手动确认或修改的地方
6. 如何运行安装脚本
7. 如何验证 MCP 是否连接成功
8. 如何在 Blender 中测试
9. 如何在 MCP Client 中测试
10. 如何回滚
11. 如何卸载
12. 如何重新安装

请额外生成一个打包脚本：

`package-files.ps1`

要求：
- 自动创建发布目录
- 自动复制所有安装相关文件
- 自动生成 zip 文件
- zip 文件名包含版本号和日期，例如：
  `blender-mcp-windows-installer-v1.0-2026-05-09.zip`
- 打包前检查文件是否齐全
- 打包完成后输出 zip 文件路径

## 第 4 阶段：交付格式

请最终按照以下格式交付：

1. 中文总结
2. 部署前提条件
3. 推荐安装路径
4. 自动化脚本说明
5. 文件结构
6. 每个文件的完整代码
7. 运行方法
8. 验证方法
9. 常见错误排查
10. 打包方法
11. 卸载方法
12. 注意事项

## 重要约束

- 所有脚本必须适用于 Windows。
- 不要假设用户已经配置好开发环境。
- 不要跳过依赖检测。
- 不要直接覆盖用户已有配置。
- 涉及 MCP Client 配置文件时，必须先备份。
- 涉及 JSON 配置时，必须校验格式。
- 所有命令和说明使用中文。
- 脚本中的路径要尽量可配置。
- 如果某一步无法完全自动化，请明确说明原因，并给出手动操作步骤。
- 如果 GitHub README 或 YouTube 教程中的信息过时，请基于最新仓库内容修正。
- 如果需要管理员权限，请说明原因，并尽量避免不必要的管理员权限。
- 最终脚本应达到“普通 Windows 用户复制文件后双击或右键运行即可完成部署”的程度。

请先执行第 1 阶段，不要直接生成最终脚本。总结完成后等待我确认。
