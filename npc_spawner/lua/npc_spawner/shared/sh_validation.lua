-- Shared Validation
-- lua/npc_spawner/shared/sh_validation.lua

NPCSpawner.Shared.Validation = NPCSpawner.Shared.Validation or {}

-- Validate spawn parameters
function NPCSpawner.Shared.Validation:ValidateSpawnData(data)
    local errors = {}
    
    -- Validate NPC type
    if not data.npcType or data.npcType == "" then
        table.insert(errors, "invalid_npc_type")
    elseif not NPCSpawner.Shared.Util:IsNPCValid(data.npcType) then
        table.insert(errors, "npc_not_available")
    end
    
    -- Validate radius
    if not isnumber(data.radius) then
        table.insert(errors, "invalid_radius_type")
    elseif data.radius < NPCSpawner.Config.MinSpawnRadius or data.radius > NPCSpawner.Config.MaxSpawnRadius then
        table.insert(errors, "radius_out_of_range")
    end
    
    -- Validate frequency
    if not isnumber(data.frequency) then
        table.insert(errors, "invalid_frequency_type")
    elseif data.frequency < NPCSpawner.Config.MinFrequency or data.frequency > NPCSpawner.Config.MaxFrequency then
        table.insert(errors, "frequency_out_of_range")
    end
    
    -- Validate amount
    if not isnumber(data.amount) then
        table.insert(errors, "invalid_amount_type")
    elseif data.amount < NPCSpawner.Config.MinNPCAmount or data.amount > NPCSpawner.Config.MaxNPCAmount then
        table.insert(errors, "amount_out_of_range")
    end
    
    return #errors == 0, errors
end

-- Validate player permissions and state
function NPCSpawner.Shared.Validation:ValidatePlayer(ply)
    if not IsValid(ply) then
        return false, {"invalid_player"}
    end
    
    if not NPCSpawner.Shared.Util:HasPermission(ply) then
        return false, {"no_permission"}
    end
    
    if SERVER and not ply:Alive() then
        return false, {"player_not_alive"}
    end
    
    return true, {}
end

-- Validate spawn position
function NPCSpawner.Shared.Validation:ValidateSpawnPosition(pos)
    if not isvector(pos) then
        return false, {"invalid_position_type"}
    end
    
    if pos:Length() > 32000 then -- Source engine limit
        return false, {"position_too_far"}
    end
    
    return true, {}
end

-- Sanitize network data
function NPCSpawner.Shared.Validation:SanitizeNetworkData(data)
    local sanitized = {}
    
    -- Sanitize NPC type
    if isstring(data.npcType) then
        sanitized.npcType = string.gsub(data.npcType, "[^%w_]", "")
        sanitized.npcType = string.sub(sanitized.npcType, 1, 64) -- Limit length
    end
    
    -- Sanitize numeric values
    sanitized.radius = NPCSpawner.Shared.Util:ClampValue(
        data.radius, 
        NPCSpawner.Config.MinSpawnRadius, 
        NPCSpawner.Config.MaxSpawnRadius,
        1000
    )
    
    sanitized.frequency = NPCSpawner.Shared.Util:ClampValue(
        data.frequency,
        NPCSpawner.Config.MinFrequency,
        NPCSpawner.Config.MaxFrequency,
        1
    )
    
    sanitized.amount = NPCSpawner.Shared.Util:ClampValue(
        data.amount,
        NPCSpawner.Config.MinNPCAmount,
        NPCSpawner.Config.MaxNPCAmount,
        10
    )
    
    return sanitized
end

-- Rate limiting validation
NPCSpawner.Shared.RateLimit = NPCSpawner.Shared.RateLimit or {}

function NPCSpawner.Shared.Validation:CheckRateLimit(ply, action)
    if not IsValid(ply) then return false end
    
    local steamID = ply:SteamID()
    local currentTime = CurTime()
    
    NPCSpawner.Shared.RateLimit[steamID] = NPCSpawner.Shared.RateLimit[steamID] or {}
    local playerLimits = NPCSpawner.Shared.RateLimit[steamID]
    
    local limits = {
        spawn = 2, -- 2 seconds between spawn requests
        menu = 0.5, -- 0.5 seconds between menu opens
        undo = 1 -- 1 second between undo actions
    }
    
    local limit = limits[action] or 1
    
    if playerLimits[action] and (currentTime - playerLimits[action]) < limit then
        return false
    end
    
    playerLimits[action] = currentTime
    return true
end

-- Clean up rate limit data for disconnected players
if SERVER then
    hook.Add("PlayerDisconnected", "NPCSpawner_RateLimit_Cleanup", function(ply)
        if NPCSpawner.Shared.RateLimit[ply:SteamID()] then
            NPCSpawner.Shared.RateLimit[ply:SteamID()] = nil
        end
    end)
end