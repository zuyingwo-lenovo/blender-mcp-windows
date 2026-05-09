# Blender MCP Windows Deployment Toolkit

## 1. Overview
This toolkit provides a "one-click" deployment solution for [Blender MCP](https://github.com/ahujasid/blender-mcp) on Windows. It automates environment checks, installs the `uv` package manager, downloads the latest Blender addon, and assists in configuring your favorite MCP client (Claude Desktop, Cursor, or Windsurf).

## 2. Prerequisites
- **Windows 10/11**
- **Python 3.10+** installed
- **Blender 3.0+** installed (the script will attempt to locate it automatically)
- Internet connection (to access GitHub and PyPI)

## 3. File Structure
```text
blender-mcp-windows-installer/
├─ install-blender-mcp.bat    # Launcher (Run this!)
├─ install-blender-mcp.ps1    # Core deployment logic
├─ start-blender-mcp.ps1      # Startup order guide
├─ uninstall-blender-mcp.ps1  # Cleanup script
├─ config-example.json        # Configuration reference
├─ README.md                  # This document
└─ logs/                      # Installation logs
```

## 4. How to Install
1. Place the folder in your desired workspace.
2. **Double-click `install-blender-mcp.bat`**.
3. The script will request Administrator privileges to perform environment setup.
4. Follow the on-screen prompts:
   - The script will search for your Blender installation.
   - It will scan for supported MCP clients (Claude, Cursor, Windsurf).
   - You can choose which client to configure automatically.
   - If no client is detected, you can skip or manually provide a path to your config file.

## 5. Final Setup & Verification

### 5.1 Enable the Addon in Blender
1. Open Blender.
2. Go to `Edit` -> `Preferences` -> `Add-ons`.
3. Click the `Install...` button in the top right.
4. Navigate to `C:\MCP\blender-mcp`, select `addon.py`, and click `Install Add-on`.
5. Check the box next to `Interface: Blender MCP` to enable it.

### 5.2 Connection Sequence
**Strict startup order is required:**
1. **Open** your MCP Client (Claude Desktop, Cursor, etc.) first.
2. **Open** Blender.
3. In Blender's 3D View, press `N` to open the sidebar.
4. Locate the `Blender MCP` tab at the bottom.
5. Click the `Connect to Claude` (or `Start MCP Server`) button.

## 6. Troubleshooting
- **`uvx` command not found**: The script adds `uv` to your PATH. If your client still can't find it, try restarting your computer or the client app.
- **Connection Failed/Timeout**: Ensure you follow the exact startup sequence in section 5.2.
- **Permissions**: Ensure you run the `.bat` file with enough privileges (it should prompt for UAC).

## 7. Uninstallation
1. Disable and remove the addon within Blender.
2. Remove the `blender` entry from your MCP client configuration.
3. Run `uninstall-blender-mcp.ps1` to delete the `C:\MCP\blender-mcp` directory.

## 8. Important Notes
- This script disables telemetry by default (`DISABLE_TELEMETRY=true`).
- A `.bak` backup file is automatically created before modifying any configuration files.
