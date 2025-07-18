-- Server Core Functions
-- lua/npc_spawner/server/sv_core.lua

NPCSpawner.Server.Core = NPCSpawner.Server.Core or {}

-- Initialize server-side systems
function NPCSpawner.Server.Initialize()
    NPCSpawner.Server.Core:Initialize()
    NPCSpawner.Shared.Util:Debug("Server initialized", "INFO")
end

function NPCSpawner.Server.Core:Initialize()
    -- Initialize data structures
    self.spawnPositions = {}
    self.playerSpawnedNPCs = {}
    self.activeSpawning = {}
    self.playerStats = {}
    
    -- Register console commands
    self:RegisterCommands()
    
    -- Start cleanup timer
    self:StartCleanupTimer()
    
    NPCSpawner.Shared.Util:Debug("Core server systems initialized", "INFO")
end

-- Register server console commands
function NPCSpawner.Server.Core:RegisterCommands()
    concommand.Add("npc_spawner_reload", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then
            ply:ChatPrint("Access denied")
            return
        end
        
        -- Reload config
        include("npc_spawner/config.lua")
        include("npc_spawner/languages.lua")
        
        if IsValid(ply) then
            ply:ChatPrint("NPC Spawner config reloaded")
        else
            print("NPC Spawner config reloaded")
        end
    end)
    
    concommand.Add("npc_spawner_cleanup", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then
            ply:ChatPrint("Access denied")
            return
        end
        
        local count = self:CleanupAllNPCs()
        local message = "Cleaned up " .. count .. " NPCs"
        
        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)
    
    concommand.Add("npc_spawner_stats", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then
            ply:ChatPrint("Access denied")
            return
        end
        
        self:PrintStats(ply)
    end)
end

-- Get spawn position for player
function NPCSpawner.Server.Core:GetSpawnPosition(ply)
    return self.spawnPositions[ply]
end

-- Set spawn position for player
function NPCSpawner.Server.Core:SetSpawnPosition(ply, pos)
    local isValid, errors = NPCSpawner.Shared.Validation:ValidateSpawnPosition(pos)
    if not isValid then
        return false, errors
    end
    
    self.spawnPositions[ply] = pos
    self:UpdatePlayerStats(ply, "spawn_positions_set", 1)
    
    NPCSpawner.Shared.Util:Debug("Spawn position set for " .. ply:Name(), "INFO")
    return true
end

-- Get spawned NPCs for player
function NPCSpawner.Server.Core:GetPlayerNPCs(ply)
    return self.playerSpawnedNPCs[ply] or {}
end

-- Add NPC to player's list
function NPCSpawner.Server.Core:AddPlayerNPC(ply, npc)
    self.playerSpawnedNPCs[ply] = self.playerSpawnedNPCs[ply] or {}
    table.insert(self.playerSpawnedNPCs[ply], npc)
    
    self:UpdatePlayerStats(ply, "npcs_spawned", 1)
end

-- Remove all NPCs for player
function NPCSpawner.Server.Core:RemovePlayerNPCs(ply)
    local npcs = self:GetPlayerNPCs(ply)
    local count = 0
    
    for _, npc in pairs(npcs) do
        if IsValid(npc) then
            npc:Remove()
            count = count + 1
        end
    end
    
    self.playerSpawnedNPCs[ply] = {}
    self:UpdatePlayerStats(ply, "npcs_removed", count)
    
    return count
end

-- Update player statistics
function NPCSpawner.Server.Core:UpdatePlayerStats(ply, stat, value)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID()
    self.playerStats[steamID] = self.playerStats[steamID] or {}
    self.playerStats[steamID][stat] = (self.playerStats[steamID][stat] or 0) + value
    self.playerStats[steamID].last_activity = os.time()
end

-- Get player statistics
function NPCSpawner.Server.Core:GetPlayerStats(ply)
    if not IsValid(ply) then return {} end
    return self.playerStats[ply:SteamID()] or {}
end

-- Print statistics
function NPCSpawner.Server.Core:PrintStats(ply)
    local totalNPCs = 0
    local activePlayers = 0
    
    for steamID, stats in pairs(self.playerStats) do
        if stats.npcs_spawned then
            totalNPCs = totalNPCs + stats.npcs_spawned
        end
        if stats.last_activity and (os.time() - stats.last_activity) < 3600 then -- Active in last hour
            activePlayers = activePlayers + 1
        end
    end
    
    local message = string.format(
        "NPC Spawner Stats:\nTotal NPCs spawned: %d\nActive players (1h): %d\nCurrent spawned NPCs: %d",
        totalNPCs,
        activePlayers,
        #ents.FindByClass("npc_*")
    )
    
    if IsValid(ply) then
        ply:ChatPrint(message)
    else
        print(message)
    end
end

-- Cleanup all spawned NPCs
function NPCSpawner.Server.Core:CleanupAllNPCs()
    local count = 0
    
    for ply, npcs in pairs(self.playerSpawnedNPCs) do
        for _, npc in pairs(npcs) do
            if IsValid(npc) then
                npc:Remove()
                count = count + 1
            end
        end
    end
    
    self.playerSpawnedNPCs = {}
    return count
end

-- Start periodic cleanup timer
function NPCSpawner.Server.Core:StartCleanupTimer()
    timer.Create("NPCSpawner_PeriodicCleanup", 300, 0, function() -- Every 5 minutes
        self:PeriodicCleanup()
    end)
end

-- Periodic cleanup of invalid data
function NPCSpawner.Server.Core:PeriodicCleanup()
    local cleaned = 0
    
    -- Clean up invalid NPCs from player lists
    for ply, npcs in pairs(self.playerSpawnedNPCs) do
        local validNPCs = {}
        for _, npc in pairs(npcs) do
            if IsValid(npc) then
                table.insert(validNPCs, npc)
            else
                cleaned = cleaned + 1
            end
        end
        self.playerSpawnedNPCs[ply] = validNPCs
    end
    
    -- Clean up disconnected players
    for ply, _ in pairs(self.spawnPositions) do
        if not IsValid(ply) then
            self.spawnPositions[ply] = nil
            self.playerSpawnedNPCs[ply] = nil
            self.activeSpawning[ply] = nil
        end
    end
    
    if cleaned > 0 then
        NPCSpawner.Shared.Util:Debug("Periodic cleanup removed " .. cleaned .. " invalid references", "INFO")
    end
end

-- Player disconnection cleanup
hook.Add("PlayerDisconnected", "NPCSpawner_PlayerCleanup", function(ply)
    local core = NPCSpawner.Server.Core
    
    if NPCSpawner.Config.CleanupOnDisconnect then
        local count = core:RemovePlayerNPCs(ply)
        if count > 0 then
            NPCSpawner.Shared.Util:Debug("Cleaned up " .. count .. " NPCs for disconnected player " .. ply:Name(), "INFO")
        end
    end
    
    -- Clean up player data
    core.spawnPositions[ply] = nil
    core.playerSpawnedNPCs[ply] = nil
    core.activeSpawning[ply] = nil
end)