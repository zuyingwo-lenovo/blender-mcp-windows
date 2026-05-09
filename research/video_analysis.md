Based on the video, here are the complete installation and setup steps for Blender MCP, specifically extracting the Windows-relevant information shown:

### Step 1: Prerequisites
*   **Blender:** Download and install from blender.org.
*   **Node.js:** Download and install from nodejs.org.
*   **Python:** Download and install from python.org.
*   **uv Package Manager:** The video notes that while Mac users use Homebrew (`brew install uv`), Windows users should follow the installation instructions directly on the `uv` website (as shown in the README on screen).

### Step 2: Install the Blender Add-on
1.  Go to the `blender-mcp` GitHub repository and click **Code > Download ZIP**.
2.  Extract the ZIP file and locate the **`addon.py`** file inside the folder.
3.  Open Blender and navigate to **`Edit > Preferences`**.
4.  Select the **`Add-ons`** tab on the left.
5.  Click **`Install from Disk...`** in the top right corner.
6.  Locate and select the **`addon.py`** file.
7.  Enable the add-on by checking the box next to **`Interface: Blender MCP`**.

### Step 3: Start the MCP Server
1.  In the main Blender viewport, press the **`N`** key to open the right-side vertical panel.
2.  Click on the **`Blender MCP`** tab at the bottom of that panel.
3.  Click the **`Start MCP Server`** button. 
    *   *Note: The default port shown running is **`9876`**.*

### Step 4: Configure Claude Desktop
1.  Download and install Claude for Desktop for Windows.
2.  Open Claude, click on your profile/menu, and go to **`Settings > Developer`**.
3.  Click **`Edit Config`**. This will create/open a configuration file.
    *   *Path shown for Windows:* **`%APPDATA%\Claude\claude_desktop_config.json`**
4.  Open the file in a text editor and add the following JSON configuration:
    ```json
    {
      "mcpServers": {
        "blender": {
          "command": "uvx",
          "args": [
            "blender-mcp"
          ]
        }
      }
    }
    ```
5.  Save the file.
6.  **Completely quit** Claude Desktop and reopen it.
7.  Verify the installation by looking for the small hammer icon in the Claude chat box. Clicking it should show available tools like `create_primitive`, `modify_object`, `execute_blender_code`, etc.

### Crucial Workflow Order & Differences from README
The video highlights a specific startup sequence and a common point of confusion regarding the GitHub documentation to avoid connection errors:

*   **Strict Startup Order:** To ensure a successful connection, you must follow this exact order:
    1.  Open Claude Desktop first.
    2.  Open Blender second.
    3.  Click "Start MCP Server" in Blender last.
*   **Do Not Run Terminal Commands:** The presenter explicitly notes a mistake users make when reading the README. While the documentation lists the command `uvx blender-mcp`, the presenter clarifies: *"you don't need to do that in a terminal, you just need to do that directly from blender."* You should rely on the UI button in Blender to start the server, not your command prompt.