<#
.SYNOPSIS
    这是一个帮助脚本，用于提示用户正确的启动顺序。
#>

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "      Blender MCP 启动指南" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "请严格按照以下顺序启动，以确保连接成功：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 启动您的 MCP 客户端 (Claude Desktop / Cursor / Windsurf / Claude Code 等)" -ForegroundColor White
Write-Host "   (客户端会自动在后台启动 MCP Server)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 启动 Blender" -ForegroundColor White
Write-Host "   (打开您的工程文件)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 在 Blender 中启动 Socket 服务器" -ForegroundColor White
Write-Host "   - 在 3D 视图按 N 键打开侧边栏" -ForegroundColor Gray
Write-Host "   - 切换到 'Blender MCP' 标签" -ForegroundColor Gray
Write-Host "   - 点击 'Connect' 或 'Start MCP Server' 按钮" -ForegroundColor Gray
Write-Host ""
Write-Host "注意：请勿同时运行多个 MCP 客户端实例连接同一个 Blender！" -ForegroundColor Red
Write-Host "注意：不要在终端中手动运行 uvx blender-mcp，除非您知道自己在做什么。" -ForegroundColor Yellow
Write-Host ""
Read-Host "按回车键退出"
