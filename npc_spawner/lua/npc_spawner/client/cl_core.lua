-- Client Core Functions
-- lua/npc_spawner/client/cl_core.lua

NPCSpawner.Client.Core = NPCSpawner.Client.Core or {}

-- Initialize client-side systems
function NPCSpawner.Client.Initialize()
    NPCSpawner.Client.Core:Initialize()
    NPCSpawner.Shared.Util:Debug("Client initialized", "INFO")
end

function NPCSpawner.Client.Core:Initialize()
    -- Initialize client data
    self.isMenuOpen = false
    self.lastMenuToggle = 0
    self.playerStats = {}
    self.spawningSessions = {}
    
    -- Register client commands
    self:RegisterCommands()
    
    -- Setup hooks
    self:SetupHooks()
    
    -- Initialize UI theme
    self:InitializeTheme()
    
    NPCSpawner.Shared.Util:Debug("Core client systems initialized", "INFO")
end

-- Register client console commands
function NPCSpawner.Client.Core:RegisterCommands()
    concommand.Add("npc_spawner_toggle", function()
        NPCSpawner.Client.Menu:Toggle()
    end, nil, "Toggle the NPC Spawner menu")
    
    concommand.Add("npc_spawner_close", function()
        NPCSpawner.Client.Menu:Close()
    end, nil, "Close the NPC Spawner menu")
    
    concommand.Add("npc_spawner_help", function()
        self:ShowHelp()
    end, nil, "Show NPC Spawner help information")
    
    concommand.Add("npc_spawner_version", function()
        chat.AddText(Color(100, 200, 255), "[NPC Spawner] ", Color(255, 255, 255), "Version: " .. NPCSpawner.Version)
    end, nil, "Show NPC Spawner version")
end

-- Setup client hooks
function NPCSpawner.Client.Core:SetupHooks()
    -- HUD Paint for debug info
    hook.Add("HUDPaint", "NPCSpawner_DebugHUD", function()
        if NPCSpawner.Config.Debug and self:ShouldShowDebugHUD() then
            self:DrawDebugHUD()
        end
    end)
    
    -- Think hook for updates
    hook.Add("Think", "NPCSpawner_ClientThink", function()
        self:Think()
    end)
    
    -- Disconnect cleanup
    hook.Add("ShutDown", "NPCSpawner_ClientShutdown", function()
        self:Cleanup()
    end)
    
    -- Chat commands
    hook.Add("OnPlayerChat", "NPCSpawner_ChatCommands", function(ply, text, team, dead)
        if ply == LocalPlayer() then
            return self:HandleChatCommand(text)
        end
    end)
end

-- Initialize UI theme and fonts
function NPCSpawner.Client.Core:InitializeTheme()
    -- Create custom fonts if they don't exist
    surface.CreateFont("NPCSpawner_Title", {
        font = "Roboto",
        extended = false,
        size = 24,
        weight = 600,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
    
    surface.CreateFont("NPCSpawner_Subtitle", {
        font = "Roboto",
        extended = false,
        size = 18,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
    
    surface.CreateFont("NPCSpawner_Button", {
        font = "Roboto",
        extended = false,
        size = 16,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
end

-- Client think function
function NPCSpawner.Client.Core:Think()
    -- Update spawning sessions
    self:UpdateSpawningSessions()
end

-- Update active spawning sessions
function NPCSpawner.Client.Core:UpdateSpawningSessions()
    local currentTime = CurTime()
    
    for sessionID, session in pairs(self.spawningSessions) do
        if session.endTime and currentTime > session.endTime then
            -- Session expired, clean up
            self.spawningSessions[sessionID] = nil
        end
    end
end

-- Handle chat commands
function NPCSpawner.Client.Core:HandleChatCommand(text)
    text = string.lower(string.Trim(text))
    
    if text == "!npcspawner" or text == "!npcs" then
        NPCSpawner.Client.Menu:Toggle()
        return true
    elseif text == "!npchelp" then
        self:ShowHelp()
        return true
    elseif text:StartWith("!npc ") then
        local command = string.sub(text, 6)
        return self:HandleNPCCommand(command)
    end
    
    return false
end

-- Handle NPC-specific commands
function NPCSpawner.Client.Core:HandleNPCCommand(command)
    if command == "menu" then
        NPCSpawner.Client.Menu:Toggle()
        return true
    elseif command == "undo" then
        NPCSpawner.Client.Networking:UndoLastSpawn()
        return true
    elseif command == "stats" then
        NPCSpawner.Client.Networking:RequestStats()
        return true
    elseif command == "help" then
        self:ShowHelp()
        return true
    end
    
    return false
end

-- Show help information
function NPCSpawner.Client.Core:ShowHelp()
    local helpText = NPCSpawner:GetText("help_text") or [[
NPC Spawner Help:

Chat Commands:
!npcspawner or !npcs - Open menu
!npc menu - Open menu
!npc undo - Undo last spawn
!npc stats - Show statistics
!npc help - Show this help

Console Commands:
npc_spawner_menu - Open menu

Usage:
1. Open menu with chat command or console
2. Select NPC type from dropdown
3. Adjust spawn settings
4. Set spawn position (where you're standing)
5. Click "Spawn NPCs"
    ]]
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle(NPCSpawner:GetText("help"))
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    
    local label = vgui.Create("DLabel", scroll)
    label:SetText(helpText)
    label:SetTextColor(Color(255, 255, 255))
    label:SetWrap(true)
    label:Dock(FILL)
    label:DockMargin(10, 10, 10, 10)
end

-- Should show debug HUD
function NPCSpawner.Client.Core:ShouldShowDebugHUD()
    return NPCSpawner.Config.Debug and NPCSpawner.Client.Menu.isOpen
end

-- Draw debug HUD information
function NPCSpawner.Client.Core:DrawDebugHUD()
    local x, y = 10, ScrH() - 150
    local lineHeight = 20
    
    -- Background
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(x - 5, y - 5, 300, 140)
    
    -- Title
    draw.SimpleText("NPC Spawner Debug", "DermaDefault", x, y, Color(255, 255, 255))
    y = y + lineHeight
    
    -- Version
    draw.SimpleText("Version: " .. NPCSpawner.Version, "DermaDefault", x, y, Color(200, 200, 200))
    y = y + lineHeight
    
    -- Active sessions
    local sessionCount = table.Count(self.spawningSessions)
    draw.SimpleText("Active Sessions: " .. sessionCount, "DermaDefault", x, y, Color(200, 200, 200))
    y = y + lineHeight
    
    -- Menu state
    local menuState = NPCSpawner.Client.Menu.isOpen and "Open" or "Closed"
    draw.SimpleText("Menu: " .. menuState, "DermaDefault", x, y, Color(200, 200, 200))
    y = y + lineHeight
    
    -- FPS
    draw.SimpleText("FPS: " .. math.floor(1 / FrameTime()), "DermaDefault", x, y, Color(200, 200, 200))
    y = y + lineHeight
    
    -- Memory usage (approximate)
    local memUsage = math.floor(collectgarbage("count"))
    draw.SimpleText("Lua Memory: " .. memUsage .. " KB", "DermaDefault", x, y, Color(200, 200, 200))
end

-- Start spawning session tracking
function NPCSpawner.Client.Core:StartSpawningSession(sessionData)
    local sessionID = NPCSpawner.Shared.Util:GenerateSpawnID(LocalPlayer())
    
    self.spawningSessions[sessionID] = {
        startTime = CurTime(),
        endTime = CurTime() + (sessionData.amount * sessionData.frequency) + 5,
        data = sessionData
    }
    
    return sessionID
end

-- Get player statistics
function NPCSpawner.Client.Core:GetPlayerStats()
    return self.playerStats
end

-- Update player statistics
function NPCSpawner.Client.Core:UpdatePlayerStats(newStats)
    self.playerStats = table.Copy(newStats)
end

-- Cleanup function
function NPCSpawner.Client.Core:Cleanup()
    -- Close menu if open
    if NPCSpawner.Client.Menu and NPCSpawner.Client.Menu.isOpen then
        NPCSpawner.Client.Menu:Close()
    end
    
    -- Clear sessions
    self.spawningSessions = {}
    
    NPCSpawner.Shared.Util:Debug("Client cleanup completed", "INFO")
end

-- Get client information for debugging
function NPCSpawner.Client.Core:GetClientInfo()
    return {
        version = NPCSpawner.Version,
        menuOpen = self.isMenuOpen,
        activeSessions = table.Count(self.spawningSessions),
        playerStats = self.playerStats
    }
end