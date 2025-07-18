-- Server Networking
-- lua/npc_spawner/server/sv_networking.lua

NPCSpawner.Server.Networking = NPCSpawner.Server.Networking or {}

function NPCSpawner.Server.Networking:Initialize()
    self:RegisterNetworkHandlers()
    NPCSpawner.Shared.Util:Debug("Server networking initialized", "INFO")
end

-- Register all network message handlers
function NPCSpawner.Server.Networking:RegisterNetworkHandlers()
    
    -- Handle NPC list requests
    net.Receive("NPCSpawner_RequestNPCList", function(len, ply)
        if not NPCSpawner.Shared.Util:HasPermission(ply) then
            return
        end
        
        if not NPCSpawner.Shared.Validation:CheckRateLimit(ply, "menu") then
            return
        end
        
        local npcs, categories = NPCSpawner.Shared.Util:GetAvailableNPCs()
        
        net.Start("NPCSpawner_SendNPCList")
        net.WriteTable(npcs)
        net.WriteTable(categories)
        net.Send(ply)
        
        NPCSpawner.Shared.Util:Debug("Sent NPC list to " .. ply:Name(), "INFO")
    end)
    
    -- Handle spawn position setting
    net.Receive("NPCSpawner_SetSpawnPosition", function(len, ply)
        local isValid, errors = NPCSpawner.Shared.Validation:ValidatePlayer(ply)
        if not isValid then
            self:SendError(ply, errors[1])
            return
        end
        
        if not NPCSpawner.Shared.Validation:CheckRateLimit(ply, "spawn") then
            self:SendError(ply, "rate_limit")
            return
        end
        
        local success, err = NPCSpawner.Server.Core:SetSpawnPosition(ply, ply:GetPos())
        if success then
            self:SendSuccess(ply, "spawn_set")
        else
            self:SendError(ply, err[1] or "unknown_error")
        end
    end)
    
    -- Handle spawning requests
    net.Receive("NPCSpawner_StartSpawning", function(len, ply)
        local isValid, errors = NPCSpawner.Shared.Validation:ValidatePlayer(ply)
        if not isValid then
            self:SendError(ply, errors[1])
            return
        end
        
        if not NPCSpawner.Shared.Validation:CheckRateLimit(ply, "spawn") then
            self:SendError(ply, "rate_limit")
            return
        end
        
        local spawnData = net.ReadTable()
        spawnData = NPCSpawner.Shared.Validation:SanitizeNetworkData(spawnData)
        
        local success, err = NPCSpawner.Server.Spawning:StartSpawning(ply, spawnData)
        if success then
            self:SendSuccess(ply, "spawning_started")
        else
            self:SendError(ply, err[1] or "unknown_error")
        end
    end)
    
    -- Handle undo requests
    net.Receive("NPCSpawner_UndoLastSpawn", function(len, ply)
        local isValid, errors = NPCSpawner.Shared.Validation:ValidatePlayer(ply)
        if not isValid then
            self:SendError(ply, errors[1])
            return
        end
        
        if not NPCSpawner.Shared.Validation:CheckRateLimit(ply, "undo") then
            self:SendError(ply, "rate_limit")
            return
        end
        
        local count = NPCSpawner.Server.Core:RemovePlayerNPCs(ply)
        
        net.Start("NPCSpawner_UndoResult")
        net.WriteInt(count, 16)
        net.Send(ply)
        
        if count > 0 then
            self:SendSuccess(ply, "npcs_removed", count)
        else
            self:SendError(ply, "no_npcs_to_remove")
        end
    end)
    
    -- Handle cancel spawning requests
    net.Receive("NPCSpawner_CancelSpawning", function(len, ply)
        if not NPCSpawner.Shared.Util:HasPermission(ply) then
            return
        end
        
        local cancelled = NPCSpawner.Server.Spawning:CancelSpawning(ply)
        
        net.Start("NPCSpawner_CancelResult")
        net.WriteBool(cancelled)
        net.Send(ply)
        
        if cancelled then
            self:SendSuccess(ply, "spawning_cancelled")
        end
    end)
    
    -- Handle statistics requests
    net.Receive("NPCSpawner_GetStats", function(len, ply)
        if not NPCSpawner.Shared.Util:HasPermission(ply) then
            return
        end
        
        local playerStats = NPCSpawner.Server.Core:GetPlayerStats(ply)
        local serverStats = self:GetServerStats()
        
        local statsData = {
            player = playerStats,
            server = serverStats
        }
        
        net.Start("NPCSpawner_SendStats")
        net.WriteTable(statsData)
        net.Send(ply)
    end)
    
    -- Handle specific NPC removal
    net.Receive("NPCSpawner_RemoveSpecific", function(len, ply)
        if not NPCSpawner.Shared.Util:HasPermission(ply) then
            return
        end
        
        local npc = net.ReadEntity()
        if IsValid(npc) and npc.NPCSpawnerOwner == ply then
            npc:Remove()
            self:SendSuccess(ply, "npc_removed")
        else
            self:SendError(ply, "invalid_npc")
        end
    end)
end

-- Send success message to client
function NPCSpawner.Server.Networking:SendSuccess(ply, messageKey, data)
    net.Start("NPCSpawner_Notification")
    net.WriteString("success")
    net.WriteString(messageKey)
    net.WriteString(tostring(data or ""))
    net.Send(ply)
end

-- Send error message to client
function NPCSpawner.Server.Networking:SendError(ply, messageKey, data)
    net.Start("NPCSpawner_Notification")
    net.WriteString("error")
    net.WriteString(messageKey)
    net.WriteString(tostring(data or ""))
    net.Send(ply)
end

-- Send spawning progress update
function NPCSpawner.Server.Networking:SendSpawnProgress(ply, percent, current, total)
    net.Start("NPCSpawner_SpawnProgress")
    net.WriteFloat(percent)
    net.WriteInt(current, 16)
    net.WriteInt(total, 16)
    net.Send(ply)
end

-- Send spawning completion notification
function NPCSpawner.Server.Networking:SendSpawnComplete(ply, totalSpawned)
    net.Start("NPCSpawner_SpawnComplete")
    net.WriteInt(totalSpawned, 16)
    net.Send(ply)
end

-- Get server-wide statistics
function NPCSpawner.Server.Networking:GetServerStats()
    local totalNPCs = 0
    local activePlayers = 0
    local currentNPCs = 0
    
    -- Count total spawned NPCs from all players
    for steamID, stats in pairs(NPCSpawner.Server.Core.playerStats or {}) do
        if stats.npcs_spawned then
            totalNPCs = totalNPCs + stats.npcs_spawned
        end
        
        if stats.last_activity and (os.time() - stats.last_activity) < 3600 then
            activePlayers = activePlayers + 1
        end
    end
    
    -- Count current NPCs on server
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) and ent.NPCSpawnerOwner then
            currentNPCs = currentNPCs + 1
        end
    end
    
    return {
        total_npcs_spawned = totalNPCs,
        active_players = activePlayers,
        current_npcs = currentNPCs,
        server_uptime = math.floor(CurTime()),
        addon_version = NPCSpawner.Version
    }
end

-- Broadcast message to all players with permission
function NPCSpawner.Server.Networking:BroadcastToAuthorized(messageType, messageKey, data)
    for _, ply in pairs(player.GetAll()) do
        if NPCSpawner.Shared.Util:HasPermission(ply) then
            if messageType == "success" then
                self:SendSuccess(ply, messageKey, data)
            else
                self:SendError(ply, messageKey, data)
            end
        end
    end
end

-- Send periodic updates to connected clients
function NPCSpawner.Server.Networking:StartPeriodicUpdates()
    timer.Create("NPCSpawner_PeriodicUpdates", 30, 0, function()
        for _, ply in pairs(player.GetAll()) do
            if NPCSpawner.Shared.Util:HasPermission(ply) then
                -- Send spawn progress if player is currently spawning
                local progress, current, total = NPCSpawner.Server.Spawning:GetSpawningProgress(ply)
                if progress > 0 and progress < 100 then
                    self:SendSpawnProgress(ply, progress, current, total)
                end
            end
        end
    end)
end

-- Initialize networking when core is ready
hook.Add("Initialize", "NPCSpawner_InitNetworking", function()
    NPCSpawner.Server.Networking:Initialize()
    NPCSpawner.Server.Networking:StartPeriodicUpdates()
end)

-- Additional network strings for new features
if SERVER then
    util.AddNetworkString("NPCSpawner_Notification")
    util.AddNetworkString("NPCSpawner_SpawnProgress")
    util.AddNetworkString("NPCSpawner_SpawnComplete")
    util.AddNetworkString("NPCSpawner_UndoResult")
    util.AddNetworkString("NPCSpawner_CancelResult")
    util.AddNetworkString("NPCSpawner_CancelSpawning")
    util.AddNetworkString("NPCSpawner_RemoveSpecific")
end