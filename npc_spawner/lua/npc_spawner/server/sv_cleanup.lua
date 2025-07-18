-- Server Cleanup System
-- lua/npc_spawner/server/sv_cleanup.lua

NPCSpawner.Server.Cleanup = NPCSpawner.Server.Cleanup or {}

function NPCSpawner.Server.Cleanup:Initialize()
    self.cleanupStats = {
        totalCleaned = 0,
        lastCleanup = 0,
        invalidNPCs = 0,
        stuckNPCs = 0,
        oldNPCs = 0
    }
    
    -- Start cleanup timers
    self:StartCleanupTimers()
    
    -- Register cleanup hooks
    self:RegisterHooks()
    
    NPCSpawner.Shared.Util:Debug("Cleanup system initialized", "INFO")
end

-- Start various cleanup timers
function NPCSpawner.Server.Cleanup:StartCleanupTimers()
    -- Main periodic cleanup (every 5 minutes)
    timer.Create("NPCSpawner_PeriodicCleanup", 300, 0, function()
        self:PeriodicCleanup()
    end)
    
    -- Quick validation cleanup (every 30 seconds)
    timer.Create("NPCSpawner_QuickCleanup", 30, 0, function()
        self:QuickValidationCleanup()
    end)
    
    -- Stuck NPC detection (every 2 minutes)
    timer.Create("NPCSpawner_StuckDetection", 120, 0, function()
        self:DetectStuckNPCs()
    end)
    
    -- Old NPC cleanup (every 10 minutes)
    timer.Create("NPCSpawner_OldNPCCleanup", 600, 0, function()
        self:CleanupOldNPCs()
    end)
end

-- Register cleanup-related hooks
function NPCSpawner.Server.Cleanup:RegisterHooks()
    -- Player disconnect cleanup
    hook.Add("PlayerDisconnected", "NPCSpawner_PlayerDisconnectCleanup", function(ply)
        self:CleanupPlayerData(ply)
    end)
    
    -- Map cleanup on map change
    hook.Add("ShutDown", "NPCSpawner_MapCleanup", function()
        self:CleanupAll()
    end)
    
    -- NPC death tracking
    hook.Add("OnNPCKilled", "NPCSpawner_NPCDeathTracking", function(npc, attacker, inflictor)
        self:HandleNPCDeath(npc)
    end)
    
    -- Entity removal tracking
    hook.Add("EntityRemoved", "NPCSpawner_EntityRemovalTracking", function(ent)
        if IsValid(ent) and ent.NPCSpawnerOwner then
            self:HandleNPCRemoval(ent)
        end
    end)
end

-- Main periodic cleanup function
function NPCSpawner.Server.Cleanup:PeriodicCleanup()
    local startTime = SysTime()
    local cleaned = 0
    
    NPCSpawner.Shared.Util:Debug("Starting periodic cleanup", "INFO")
    
    -- Clean invalid NPC references
    cleaned = cleaned + self:CleanInvalidNPCReferences()
    
    -- Clean disconnected player data
    cleaned = cleaned + self:CleanDisconnectedPlayerData()
    
    -- Clean empty spawn sessions
    cleaned = cleaned + self:CleanEmptySpawnSessions()
    
    -- Update statistics
    self.cleanupStats.totalCleaned = self.cleanupStats.totalCleaned + cleaned
    self.cleanupStats.lastCleanup = os.time()
    
    local duration = SysTime() - startTime
    NPCSpawner.Shared.Util:Debug(
        string.format("Periodic cleanup completed: %d items cleaned in %.3fs", cleaned, duration), 
        "INFO"
    )
end

-- Quick validation cleanup for performance
function NPCSpawner.Server.Cleanup:QuickValidationCleanup()
    local cleaned = 0
    
    -- Clean invalid NPCs from player lists
    for ply, npcs in pairs(NPCSpawner.Server.Core.playerSpawnedNPCs or {}) do
        if IsValid(ply) then
            local validNPCs = {}
            for _, npc in pairs(npcs) do
                if IsValid(npc) then
                    table.insert(validNPCs, npc)
                else
                    cleaned = cleaned + 1
                end
            end
            NPCSpawner.Server.Core.playerSpawnedNPCs[ply] = validNPCs
        end
    end
    
    if cleaned > 0 then
        self.cleanupStats.invalidNPCs = self.cleanupStats.invalidNPCs + cleaned
        NPCSpawner.Shared.Util:Debug("Quick cleanup removed " .. cleaned .. " invalid NPC references", "INFO")
    end
end

-- Detect and handle stuck NPCs
function NPCSpawner.Server.Cleanup:DetectStuckNPCs()
    local stuckCount = 0
    local maxStuckTime = 60 -- 60 seconds
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent.NPCSpawnerOwner then
            -- Check if NPC hasn't moved for too long
            if not ent.NPCSpawner_LastPos then
                ent.NPCSpawner_LastPos = ent:GetPos()
                ent.NPCSpawner_LastMoveTime = CurTime()
            else
                local currentPos = ent:GetPos()
                local distance = ent.NPCSpawner_LastPos:Distance(currentPos)
                
                if distance > 50 then -- NPC moved significantly
                    ent.NPCSpawner_LastPos = currentPos
                    ent.NPCSpawner_LastMoveTime = CurTime()
                elseif (CurTime() - ent.NPCSpawner_LastMoveTime) > maxStuckTime then
                    -- NPC is stuck, try to unstick or remove
                    if self:TryUnstickNPC(ent) then
                        ent.NPCSpawner_LastMoveTime = CurTime()
                    else
                        self:RemoveStuckNPC(ent)
                        stuckCount = stuckCount + 1
                    end
                end
            end
        end
    end
    
    if stuckCount > 0 then
        self.cleanupStats.stuckNPCs = self.cleanupStats.stuckNPCs + stuckCount
        NPCSpawner.Shared.Util:Debug("Removed " .. stuckCount .. " stuck NPCs", "INFO")
    end
end

-- Try to unstick an NPC
function NPCSpawner.Server.Cleanup:TryUnstickNPC(npc)
    if not IsValid(npc) then return false end
    
    local currentPos = npc:GetPos()
    local attempts = 5
    
    for i = 1, attempts do
        local newPos = currentPos + Vector(
            math.random(-100, 100),
            math.random(-100, 100),
            math.random(0, 50)
        )
        
        -- Check if new position is valid
        local trace = util.TraceLine({
            start = newPos + Vector(0, 0, 50),
            endpos = newPos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if trace.Hit then
            local unstickPos = trace.HitPos + Vector(0, 0, 10)
            
            -- Check if position is clear
            local hullTrace = util.TraceHull({
                start = unstickPos,
                endpos = unstickPos + Vector(0, 0, 72),
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72),
                mask = MASK_SOLID
            })
            
            if not hullTrace.Hit then
                npc:SetPos(unstickPos)
                NPCSpawner.Shared.Util:Debug("Unstuck NPC " .. npc:GetClass(), "INFO")
                return true
            end
        end
    end
    
    return false
end

-- Remove stuck NPC
function NPCSpawner.Server.Cleanup:RemoveStuckNPC(npc)
    if not IsValid(npc) then return end
    
    local owner = npc.NPCSpawnerOwner
    NPCSpawner.Shared.Util:Debug("Removing stuck NPC: " .. npc:GetClass(), "INFO")
    
    npc:Remove()
    
    -- Notify owner if online
    if IsValid(owner) then
        owner:ChatPrint("Removed stuck NPC: " .. npc:GetClass())
    end
end

-- Cleanup old NPCs (configurable max age)
function NPCSpawner.Server.Cleanup:CleanupOldNPCs()
    local maxAge = NPCSpawner.Config.MaxNPCAge or 3600 -- 1 hour default
    local currentTime = CurTime()
    local removedCount = 0
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent.NPCSpawnerOwner and ent.NPCSpawnerSpawnTime then
            local age = currentTime - ent.NPCSpawnerSpawnTime
            
            if age > maxAge then
                local owner = ent.NPCSpawnerOwner
                ent:Remove()
                removedCount = removedCount + 1
                
                -- Notify owner if online
                if IsValid(owner) then
                    owner:ChatPrint("Removed old NPC: " .. ent:GetClass() .. " (Age: " .. math.floor(age/60) .. " minutes)")
                end
            end
        end
    end
    
    if removedCount > 0 then
        self.cleanupStats.oldNPCs = self.cleanupStats.oldNPCs + removedCount
        NPCSpawner.Shared.Util:Debug("Removed " .. removedCount .. " old NPCs", "INFO")
    end
end

-- Clean invalid NPC references from data structures
function NPCSpawner.Server.Cleanup:CleanInvalidNPCReferences()
    local cleaned = 0
    local core = NPCSpawner.Server.Core
    
    if not core then return 0 end
    
    -- Clean player spawned NPCs
    for ply, npcs in pairs(core.playerSpawnedNPCs or {}) do
        local validNPCs = {}
        for _, npc in pairs(npcs) do
            if IsValid(npc) then
                table.insert(validNPCs, npc)
            else
                cleaned = cleaned + 1
            end
        end
        core.playerSpawnedNPCs[ply] = validNPCs
    end
    
    return cleaned
end

-- Clean data for disconnected players
function NPCSpawner.Server.Cleanup:CleanDisconnectedPlayerData()
    local cleaned = 0
    local core = NPCSpawner.Server.Core
    
    if not core then return 0 end
    
    -- Clean spawn positions
    for ply, _ in pairs(core.spawnPositions or {}) do
        if not IsValid(ply) then
            core.spawnPositions[ply] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Clean active spawning
    for ply, _ in pairs(core.activeSpawning or {}) do
        if not IsValid(ply) then
            core.activeSpawning[ply] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- Clean empty spawn sessions
function NPCSpawner.Server.Cleanup:CleanEmptySpawnSessions()
    local cleaned = 0
    local spawning = NPCSpawner.Server.Spawning
    
    if not spawning then return 0 end
    
    -- Clean empty queue items
    for i = #(spawning.spawnQueue or {}), 1, -1 do
        local item = spawning.spawnQueue[i]
        if not item.session or not IsValid(item.session.player) then
            table.remove(spawning.spawnQueue, i)
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- Handle player disconnection cleanup
function NPCSpawner.Server.Cleanup:CleanupPlayerData(ply)
    local core = NPCSpawner.Server.Core
    local cleaned = 0
    
    if NPCSpawner.Config.CleanupOnDisconnect then
        -- Remove player's NPCs
        local npcs = core:GetPlayerNPCs(ply)
        for _, npc in pairs(npcs) do
            if IsValid(npc) then
                npc:Remove()
                cleaned = cleaned + 1
            end
        end
    end
    
    -- Clean player data
    if core then
        core.spawnPositions[ply] = nil
        core.playerSpawnedNPCs[ply] = nil
        core.activeSpawning[ply] = nil
    end
    
    NPCSpawner.Shared.Util:Debug("Cleaned up data for " .. ply:Name() .. " (" .. cleaned .. " NPCs removed)", "INFO")
end

-- Handle NPC death
function NPCSpawner.Server.Cleanup:HandleNPCDeath(npc)
    if IsValid(npc) and npc.NPCSpawnerOwner then
        -- Remove from player's NPC list
        local owner = npc.NPCSpawnerOwner
        local npcs = NPCSpawner.Server.Core:GetPlayerNPCs(owner)
        
        for i, playerNPC in pairs(npcs) do
            if playerNPC == npc then
                table.remove(npcs, i)
                break
            end
        end
    end
end

-- Handle NPC removal
function NPCSpawner.Server.Cleanup:HandleNPCRemoval(npc)
    if npc.NPCSpawnerOwner then
        -- Update statistics
        local core = NPCSpawner.Server.Core
        if core then
            core:UpdatePlayerStats(npc.NPCSpawnerOwner, "npcs_removed", 1)
        end
    end
end

-- Clean up all NPCSpawner data (for map change, etc.)
function NPCSpawner.Server.Cleanup:CleanupAll()
    local count = 0
    
    -- Remove all spawned NPCs
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and ent.NPCSpawnerOwner then
            ent:Remove()
            count = count + 1
        end
    end
    
    -- Clear all timers
    timer.Remove("NPCSpawner_PeriodicCleanup")
    timer.Remove("NPCSpawner_QuickCleanup")
    timer.Remove("NPCSpawner_StuckDetection")
    timer.Remove("NPCSpawner_OldNPCCleanup")
    
    NPCSpawner.Shared.Util:Debug("Complete cleanup: " .. count .. " NPCs removed", "INFO")
end

-- Get cleanup statistics
function NPCSpawner.Server.Cleanup:GetStats()
    return table.Copy(self.cleanupStats)
end

-- Manual cleanup command
function NPCSpawner.Server.Cleanup:ManualCleanup(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("Access denied")
        return
    end
    
    local startTime = SysTime()
    self:PeriodicCleanup()
    local duration = SysTime() - startTime
    
    local message = string.format("Manual cleanup completed in %.3fs", duration)
    
    if IsValid(ply) then
        ply:ChatPrint(message)
    else
        print(message)
    end
end

-- Initialize cleanup system
hook.Add("Initialize", "NPCSpawner_InitCleanup", function()
    NPCSpawner.Server.Cleanup:Initialize()
end)