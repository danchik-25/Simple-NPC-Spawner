# Simple NPC Spawner

[![Steam Workshop](https://img.shields.io/badge/Steam%20Workshop-Download-blue?style=for-the-badge&logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=3431828120)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Compatible-orange?style=for-the-badge)](https://store.steampowered.com/app/4000/Garrys_Mod/)

Professional multi-language NPC spawning system for Garry's Mod with advanced algorithms, performance optimization, and extensive customization options.

**🎮 [Download from Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3431828120)**

---

## 🔧 Developer Information

This repository contains the complete source code and configuration files for the Simple NPC Spawner addon. Server administrators and developers can customize every aspect of the addon's behavior.

### 📁 File Structure

```
lua/
├── autorun/
│   └── npc_spawner.lua              # Main loader with dependency management
└── npc_spawner/
    ├── config.lua                   # Primary configuration file
    ├── languages.lua                # Multi-language translations
    ├── shared/
    │   ├── sh_util.lua             # Shared utilities and helpers
    │   └── sh_validation.lua       # Input validation and rate limiting
    ├── server/
    │   ├── sv_core.lua             # Core server systems and statistics
    │   ├── sv_networking.lua       # Network message handling
    │   ├── sv_spawning.lua         # Advanced spawning algorithms
    │   └── sv_cleanup.lua          # Memory and entity cleanup systems
    └── client/
        ├── cl_core.lua             # Client initialization and utilities
        ├── cl_networking.lua       # Client-side network handlers
        ├── cl_menu.lua             # Main UI system with tabbed interface
        └── cl_ui_components.lua    # Reusable UI components and styling
```

---

## ⚙️ Configuration Guide

### 🎯 Primary Configuration (`lua/npc_spawner/config.lua`)

```lua
NPCSpawner.Config = {
    -- Language Settings
    Language = "en", -- "en", "ru", "tr", "es", "fr", "de"
    
    -- Spawn Limits (Adjust for server performance)
    MaxSpawnRadius = 5000,     -- Maximum spawn radius in units
    MinSpawnRadius = 50,       -- Minimum spawn radius in units
    MaxNPCAmount = 200,        -- Maximum NPCs per spawn session
    MinNPCAmount = 1,          -- Minimum NPCs per spawn session
    MaxFrequency = 10,         -- Maximum seconds between spawns
    MinFrequency = 0.1,        -- Minimum seconds between spawns
    
    -- Performance Settings
    MaxSpawnAttempts = 20,     -- Position finding attempts before fallback
    CleanupOnDisconnect = true, -- Remove player NPCs on disconnect
    Debug = false,             -- Enable console debug messages
    
    -- Permission System
    AdminOnly = false,         -- Restrict to admins only
    RequiredUserGroup = "user", -- Required user group if AdminOnly is true
    
    -- NPC Type Configuration
    NPCTypes = {
        ["Standard"] = {
            -- Add/remove standard Source NPCs
            "npc_zombie", "npc_fastzombie", "npc_poisonzombie"
        },
        ["DRGBase"] = {
            -- Add your DRGBase NextBot classes
            "drg_zombie", "drg_skeleton"
        },
        ["VJBase"] = {
            -- Add your VJBase NPC classes
            "npc_vj_example"
        }
    }
}
```

### 🌍 Language Customization (`lua/npc_spawner/languages.lua`)

Add new languages or modify existing translations:

```lua
NPCSpawner.Languages["pt"] = {  -- Portuguese example
    language_name = "Português",
    title = "Gerador de NPCs",
    set_spawn_pos = "Definir Posição",
    spawn_npcs = "Gerar NPCs",
    -- ... add all required keys
}
```

**Required Translation Keys:**
- UI Elements: `title`, `set_spawn_pos`, `spawn_npcs`, `settings`, `statistics`
- Messages: `spawn_set`, `spawning_started`, `npcs_removed`, `no_permission`
- Categories: `npc_categories` (table with `standard`, `drgbase`, `vjbase`)
- Help: `info_text`, `help_text`

---

## 🔌 Advanced Customization

### 🎨 UI Theming (`lua/npc_spawner/client/cl_ui_components.lua`)

Customize colors and styling:

```lua
NPCSpawner.Shared.Colors = {
    Primary = Color(0, 120, 255),    -- Main buttons
    Success = Color(0, 200, 0),      -- Success actions
    Warning = Color(255, 165, 0),    -- Warning actions
    Danger = Color(220, 53, 69),     -- Dangerous actions
    Dark = Color(45, 45, 45),        -- Background
    Light = Color(248, 249, 250),    -- Light elements
    Text = Color(255, 255, 255)      -- Text color
}
```

### 🤖 NPC Type Detection (`lua/npc_spawner/shared/sh_util.lua`)

Add support for custom NPC addons:

```lua
function NPCSpawner.Shared.Util:IsAddonInstalled(addonType)
    if addonType == "your_custom_addon" then
        return _G.YourAddonGlobal ~= nil or file.Exists("lua/entities/your_prefix_*", "GAME")
    end
    -- ... existing detection code
end
```

### 📊 Statistics Tracking (`lua/npc_spawner/server/sv_core.lua`)

Add custom statistics:

```lua
function NPCSpawner.Server.Core:UpdatePlayerStats(ply, stat, value)
    -- Add custom stats like "favorite_npc", "total_playtime", etc.
    local steamID = ply:SteamID()
    self.playerStats[steamID] = self.playerStats[steamID] or {}
    self.playerStats[steamID][stat] = (self.playerStats[steamID][stat] or 0) + value
    
    -- Custom stat tracking
    if stat == "npcs_spawned" then
        self.playerStats[steamID].total_lifetime_spawns = 
            (self.playerStats[steamID].total_lifetime_spawns or 0) + value
    end
end
```

### 🎯 Spawning Algorithms (`lua/npc_spawner/server/sv_spawning.lua`)

Customize spawn position algorithms:

```lua
-- Add custom spawn patterns
function NPCSpawner.Server.Spawning:FindSpawnPositionCustom(basePos, radius)
    -- Implement your custom positioning logic
    -- Examples: circular patterns, line formations, etc.
end
```

---

## 🛠️ Development Setup

### 📋 Prerequisites

- **Garry's Mod Dedicated Server** or local installation
- **Text editor** with Lua syntax highlighting
- **Git** for version control

### 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/danchik-25/Simple-NPC-Spawner.git
   cd Simple-NPC-Spawner
   ```

2. **Install to Garry's Mod:**
   ```bash
   # Copy files to your GMod addons directory
   cp -r lua/ /path/to/garrysmod/addons/npc-spawner/
   ```

3. **Enable debug mode:**
   ```lua
   -- In config.lua
   Debug = true
   ```

4. **Restart server or reload Lua:**
   ```
   lua_run include("autorun/npc_spawner.lua")
   ```

### 🔍 Debugging

Enable debug mode to see detailed console output:

```lua
-- config.lua
Debug = true
```

Debug information includes:
- File loading status
- Network message handling
- Spawning algorithm performance
- Cleanup operation results
- Player action tracking

---

## 🧪 Testing

### 🎮 Singleplayer Testing

1. Enable debug mode
2. Use `!npcspawner` to open menu
3. Test different NPC types and configurations
4. Monitor console for errors

### 🌐 Server Testing

1. Configure appropriate limits for your server
2. Test with multiple players
3. Monitor server performance during mass spawning
4. Test permission system with different user groups

### 📊 Performance Testing

```lua
-- Add to sv_spawning.lua for performance monitoring
local startTime = SysTime()
-- ... spawning code ...
local duration = SysTime() - startTime
print("Spawn operation took: " .. duration .. " seconds")
```

---

## 🔌 API Reference

### 🌐 Shared Functions

```lua
-- Get localized text
NPCSpawner:GetText(key, category)

-- Check player permissions
NPCSpawner.Shared.Util:HasPermission(player)

-- Get available NPCs
NPCSpawner.Shared.Util:GetAvailableNPCs()
```

### 🖥️ Server Functions

```lua
-- Core system access
NPCSpawner.Server.Core:SetSpawnPosition(player, position)
NPCSpawner.Server.Core:GetPlayerNPCs(player)
NPCSpawner.Server.Core:RemovePlayerNPCs(player)

-- Spawning system
NPCSpawner.Server.Spawning:StartSpawning(player, spawnData)
NPCSpawner.Server.Spawning:CancelSpawning(player)

-- Cleanup system
NPCSpawner.Server.Cleanup:ManualCleanup(player)
```

### 💻 Client Functions

```lua
-- Menu system
NPCSpawner.Client.Menu:Toggle()
NPCSpawner.Client.Menu:UpdateNPCList(npcs, categories)

-- UI components
NPCSpawner.Client.UI:ShowNotification(message, type, duration)
NPCSpawner.Client.UI:CreateStyledButton(parent, x, y, w, h, text, color, callback)
```

---

## 🤝 Contributing

### 📝 Guidelines

1. **Follow the existing code style** and structure
2. **Test thoroughly** in both singleplayer and multiplayer
3. **Update language files** for any new text
4. **Document your changes** in pull request descriptions
5. **Keep performance in mind** - this addon is used on servers

### 🔄 Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### 🐛 Bug Reports

Please include:
- **Garry's Mod version**
- **Server or singleplayer**
- **Steps to reproduce**
- **Console errors** (with debug mode enabled)
- **Other installed addons** that might conflict

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### 🔓 What this means:

- ✅ **Commercial use** - Use on monetized servers
- ✅ **Modification** - Customize and extend freely
- ✅ **Distribution** - Share and redistribute
- ✅ **Private use** - Use for personal projects
- ✅ **Patent use** - No patent restrictions

**The only requirement is to include the original copyright notice.**

---

## 🙏 Acknowledgments

- **Garry's Mod Community** - For feedback and feature requests
- **DRGBase & VJBase Developers** - For creating amazing NPC frameworks
- **Translation Contributors** - For multi-language support
- **Beta Testers** - For finding bugs and suggesting improvements

---

## 📚 Additional Resources

- **[Steam Workshop Page](https://steamcommunity.com/sharedfiles/filedetails/?id=3431828120)** - Download and user guide
- **[Garry's Mod Wiki](https://wiki.facepunch.com/gmod/)** - GMod development documentation
- **[Lua Reference](https://www.lua.org/manual/5.1/)** - Lua programming language guide

---

**Made with ❤️ for the Garry's Mod community**
