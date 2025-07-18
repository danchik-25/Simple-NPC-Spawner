-- Server Spawning System
-- lua/npc_spawner/server/sv_spawning.lua

NPCSpawner.Server.Spawning = NPCSpawner.Server.Spawning or {}

-- Initialize spawning system
function NPCSpawner.Server.Spawning:Initialize()
    self.activeSpawning = NPCSpawner.Server.Core.activeSpawning or {}
    self.spawnQueue = {}
    
    -- Start spawn queue processor
    timer.Create("NPCSpawner_ProcessQueue", 0.1, 0, function()
        self:ProcessSpawnQueue()
    end)
    
    NPCSpawner.Shared.Util:Debug("Spawning system initialized", "INFO")
end

-- Advanced spawn position finding with multiple algorithms
function NPCSpawner.Server.Spawning:FindSpawnPosition(basePos, radius, attempt)
    attempt = attempt or 1
    local maxAttempts = NPCSpawner.Config.MaxSpawnAttempts
    
    -- Use different algorithms based on attempt number
    if attempt <= maxAttempts / 2 then
        return self:FindSpawnPositionRadial(basePos, radius)
    else
        return self:FindSpawnPositionGrid(basePos, radius)
    end
end

-- Radial spawn position finding
function NPCSpawner.Server.Spawning:FindSpawnPositionRadial(basePos, radius)
    for attempt = 1, NPCSpawner.Config.MaxSpawnAttempts do
        local angle = math.random() * math.pi * 2
        local distance = math.random(NPCSpawner.Config.MinSpawnRadius, radius)
        local height = math.random(50, 150) -- Variable height for better placement
        
        local pos = basePos + Vector(
            math.cos(angle) * distance, 
            math.sin(angle) * distance, 
            height
        )

        -- Comprehensive ground trace
        local trace = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0, 0, 300),
            mask = MASK_SOLID_BRUSHONLY,
            filter = function(ent) 
                return not ent:IsPlayer() and not ent:IsNPC() and not ent:IsNextBot()
            end
        })

        if trace.Hit then
            local spawnPos = trace.HitPos + Vector(0, 0, 10)
            
            -- Check if spawn position is clear with hull trace
            if self:IsSpawnPositionClear(spawnPos) then
                return spawnPos
            end
        end
    end
    
    return basePos -- Fallback
end

-- Grid-based spawn position finding for better distribution
function NPCSpawner.Server.Spawning:FindSpawnPositionGrid(basePos, radius)
    local gridSize = 64 -- 64 unit grid
    local maxDistance = radius
    
    for distance = gridSize, maxDistance, gridSize do
        local positions = self:GenerateGridPositions(basePos, distance, gridSize)
        
        for _, pos in ipairs(positions) do
            local groundPos = self:GetGroundPosition(pos)
            if groundPos and self:IsSpawnPositionClear(groundPos) then
                return groundPos
            end
        end
    end
    
    return basePos -- Fallback
end

-- Generate grid positions around base position
function NPCSpawner.Server.Spawning:GenerateGridPositions(basePos, radius, gridSize)
    local positions = {}
    local steps = math.floor(radius / gridSize)
    
    for x = -steps, steps do
        for y = -steps, steps do
            if x ~= 0 or y ~= 0 then -- Skip center position
                local pos = basePos + Vector(x * gridSize, y * gridSize, 100)
                table.insert(positions, pos)
            end
        end
    end
    
    -- Shuffle for randomness
    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end
    
    return positions
end

-- Get ground position with proper tracing
function NPCSpawner.Server.Spawning:GetGroundPosition(pos)
    local trace = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 500),
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if trace.Hit and not trace.HitSky then
        return trace.HitPos + Vector(0, 0, 10)
    end
    
    return nil
end

-- Check if spawn position is clear of obstacles
function NPCSpawner.Server.Spawning:IsSpawnPositionClear(pos)
    local hullTrace = util.TraceHull({
        start = pos,
        endpos = pos + Vector(0, 0, 72), -- NPC height
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 72),
        mask = MASK_SOLID,
        filter = function(ent)
            return not ent:IsPlayer() and ent:GetClass() ~= "worldspawn"
        end
    })
    
    return not hullTrace.Hit
end

-- Start spawning process with queue system
function NPCSpawner.Server.Spawning:StartSpawning(ply, spawnData)
    local isValid, errors = NPCSpawner.Shared.Validation:ValidatePlayer(ply)
    if not isValid then
        return false, errors
    end
    
    isValid, errors = NPCSpawner.Shared.Validation:ValidateSpawnData(spawnData)
    if not isValid then
        return false, errors
    end
    
    -- Cancel previous spawning
    self:CancelSpawning(ply)
    
    local spawnPos = NPCSpawner.Server.Core:GetSpawnPosition(ply)
    if not spawnPos then
        return false, {"no_spawn_position"}
    end
    
    -- Create spawn session
    local sessionID = NPCSpawner.Shared.Util:GenerateSpawnID(ply)
    local session = {
        player = ply,
        sessionID = sessionID,
        npcType = spawnData.npcType,
        spawnPos = spawnPos,
        radius = spawnData.radius,
        frequency = spawnData.frequency,
        amount = spawnData.amount,
        spawned = 0,
        startTime = CurTime()
    }
    
    self.activeSpawning[ply] = session
    
    -- Add to spawn queue
    for i = 1, spawnData.amount do
        table.insert(self.spawnQueue, {
            session = session,
            index = i,
            spawnTime = CurTime() + (i * spawnData.frequency)
        })
    end
    
    NPCSpawner.Shared.Util:Debug("Started spawning session for " .. ply:Name() .. " (" .. spawnData.amount .. " " .. spawnData.npcType .. ")", "INFO")
    return true
end

-- Process spawn queue
function NPCSpawner.Server.Spawning:ProcessSpawnQueue()
    local currentTime = CurTime()
    
    for i = #self.spawnQueue, 1, -1 do
        local queueItem = self.spawnQueue[i]
        
        if currentTime >= queueItem.spawnTime then
            self:ProcessSpawnItem(queueItem)
            table.remove(self.spawnQueue, i)
        end
    end
end

-- Process individual spawn item
function NPCSpawner.Server.Spawning:ProcessSpawnItem(queueItem)
    local session = queueItem.session
    local ply = session.player
    
    if not IsValid(ply) then
        return
    end
    
    local spawnPos = self:FindSpawnPosition(session.spawnPos, session.radius, queueItem.index)
    local npc = self:SpawnNPC(session.npcType, spawnPos, ply)
    
    if IsValid(npc) then
        NPCSpawner.Server.Core:AddPlayerNPC(ply, npc)
        session.spawned = session.spawned + 1
        
        -- Send progress update to client
        net.Start("NPCSpawner_SpawnProgress")
        net.WriteFloat(session.spawned / session.amount * 100)
        net.WriteString(session.spawned .. "/" .. session.amount)
        net.Send(ply)
    end
    
    -- Check if session is complete
    if session.spawned >= session.amount then
        self.activeSpawning[ply] = nil
        
        net.Start("NPCSpawner_SpawnComplete")
        net.WriteInt(session.spawned, 16)
        net.Send(ply)
    end
end

-- Spawn individual NPC with type-specific handling
function NPCSpawner.Server.Spawning:SpawnNPC(npcType, pos, owner)
    local npc = ents.Create(npcType)
    if not IsValid(npc) then
        return nil
    end
    
    npc:SetPos(pos)
    npc:SetAngles(Angle(0, math.random(0, 360), 0))
    
    -- Set owner for tracking
    npc.NPCSpawnerOwner = owner
    npc.NPCSpawnerSpawnTime = CurTime()
    
    npc:Spawn()
    
    -- Type-specific setup
    timer.Simple(0.1, function()
        if IsValid(npc) then
            self:SetupNPCByType(npc, npcType)
        end
    end)
    
    return npc
end

-- Setup NPC based on its type
function NPCSpawner.Server.Spawning:SetupNPCByType(npc, npcType)
    npc:SetCollisionGroup(COLLISION_GROUP_NPC)
    
    if npcType:StartWith("drg_") then
        -- DRGBase NextBot setup
        if npc.SetAutomaticFrameAdvance then
            npc:SetAutomaticFrameAdvance(true)
        end
    elseif npcType:StartWith("npc_vj_") then
        -- VJBase NPC setup
        if npc.VJ_IsBeingControlled then
            npc.VJ_IsBeingControlled = false
        end
    elseif npcType:StartWith("npc_") then
        -- Standard Source NPC setup
        if npc:IsNPC() then
            npc:SetSchedule(SCHED_IDLE_WANDER)
        end
    end
    
    -- Common setup
    if npc.SetMaxHealth then
        npc:SetMaxHealth(npc:Health())
    end
end

-- Cancel spawning for player
function NPCSpawner.Server.Spawning:CancelSpawning(ply)
    if self.activeSpawning[ply] then
        local session = self.activeSpawning[ply]
        
        -- Remove from queue
        for i = #self.spawnQueue, 1, -1 do
            if self.spawnQueue[i].session == session then
                table.remove(self.spawnQueue, i)
            end
        end
        
        self.activeSpawning[ply] = nil
        NPCSpawner.Shared.Util:Debug("Cancelled spawning for " .. ply:Name(), "INFO")
        return true
    end
    
    return false
end

-- Get spawning progress for player
function NPCSpawner.Server.Spawning:GetSpawningProgress(ply)
    local session = self.activeSpawning[ply]
    if not session then
        return 0, 0, 0
    end
    
    local progress = session.spawned / session.amount * 100
    return progress, session.spawned, session.amount
end

-- Initialize spawning system when server core is ready
hook.Add("InitPostEntity", "NPCSpawner_InitSpawning", function()
    NPCSpawner.Server.Spawning:Initialize()
end)