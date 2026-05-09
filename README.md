# Blender MCP Windows Deployment Toolkit

## 1. Overview
This toolkit provides a **semi-automated** deployment solution for [Blender MCP](https://github.com/ahujasid/blender-mcp) on Windows. It automates environment checks, installs the `uv` package manager, downloads the `addon.py`, and safely updates your MCP client configurations.

> **Note:** "One-click" refers to the automation of dependency setup and configuration writing. Enabling the Add-on within Blender's UI still requires manual user interaction.

## 2. Prerequisites
- **Windows 10/11**
- **Python 3.10+** (Added to PATH)
- **Blender 3.0+**
- Internet connection

## 3. Support Matrix

| Client | Auto-Detect | Auto-Write | Config Path Reliability | Status |
| :--- | :---: | :---: | :---: | :--- |
| Claude Desktop | Yes | Yes | High | Supported |
| Cursor | Yes | Yes | Medium | Supported |
| Windsurf | Yes | Yes | Medium | Supported |
| Claude Code | No | No | High | Planned (v1.1) |
| VS Code / Cline| No | No | Medium | Planned (v1.2) |

## 4. How to Install
1. **Double-click `install-blender-mcp.bat`**.
2. The script will install the toolkit to `%LOCALAPPDATA%\blender-mcp-windows` (No Administrator privileges required by default).
3. Follow the on-screen prompts to choose which MCP client to configure.
4. **Safety First:** A `.bak` backup of your config is created automatically before any modification.

## 5. Final Setup & Verification

### 5.1 Enable the Addon in Blender
1. Open Blender.
2. Go to `Edit` -> `Preferences` -> `Add-ons`.
3. Click `Install...` and select `addon.py` from your installation directory (default: `%LOCALAPPDATA%\blender-mcp-windows\addon.py`).
4. Enable `Interface: Blender MCP`.

### 5.2 Connection Sequence
1. **Launch** your MCP Client (Claude Desktop, Cursor, etc.).
2. **Launch** Blender.
3. In Blender's 3D View, press `N` for the sidebar -> `Blender MCP` -> `Connect`.

## 6. Security Considerations
- **Code Execution:** The `execute_blender_code` tool allows the AI to run arbitrary Python code within Blender. Only connect to trusted MCP clients.
- **Save Work:** Always save your `.blend` files before running AI operations.
- **External Assets:** Tools like PolyHaven, Sketchfab, and Hyper3D will access external servers to download 3D assets.
- **Telemetry:** Disabled by default (`DISABLE_TELEMETRY=true`).

## 7. Attribution & License
- **Upstream Project:** [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) (MIT License).
- **This Toolkit:** Licensed under the [MIT License](LICENSE). 
- *Note: This installer is not affiliated with the upstream BlenderMCP project.*

## 8. Troubleshooting
- **`uvx` not found:** Restart your MCP client after installation to refresh environment variables.
- **First Run Delay:** The very first time you use the tool in your MCP client, `uvx` will download the required packages. This may take 1-2 minutes.
- **Multiple Instances:** Do not run multiple MCP clients (e.g., Cursor and Claude Desktop) simultaneously with the Blender server.
