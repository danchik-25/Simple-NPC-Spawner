-- Shared Utilities
-- lua/npc_spawner/shared/sh_util.lua

NPCSpawner.Shared.Util = NPCSpawner.Shared.Util or {}

-- Get localized text with improved fallback system
function NPCSpawner.Shared.Util:GetText(key, category)
    local lang = NPCSpawner.Config.Language or "en"
    
    if not NPCSpawner.Languages then
        return key -- Fallback if languages not loaded
    end
    
    local langData = NPCSpawner.Languages[lang]
    if not langData then
        langData = NPCSpawner.Languages["en"] -- Fallback to English
    end
    
    if category and langData[category] and langData[category][key] then
        return langData[category][key]
    elseif langData[key] then
        return langData[key]
    else
        -- Try English fallback
        local enData = NPCSpawner.Languages["en"]
        if category and enData[category] and enData[category][key] then
            return enData[category][key]
        elseif enData[key] then
            return enData[key]
        end
    end
    
    return key -- Ultimate fallback
end

-- Convenience function
function NPCSpawner:GetText(key, category)
    return NPCSpawner.Shared.Util:GetText(key, category)
end

-- Check if player has permission
function NPCSpawner.Shared.Util:HasPermission(ply)
    if not IsValid(ply) then return false end
    if not NPCSpawner.Config.AdminOnly then return true end
    
    return ply:IsAdmin() or ply:IsUserGroup(NPCSpawner.Config.RequiredUserGroup)
end

-- Get available NPCs based on installed addons
function NPCSpawner.Shared.Util:GetAvailableNPCs()
    local available = {}
    local categories = {}
    
    -- Always include standard NPCs
    categories["Standard"] = {}
    for _, npc in ipairs(NPCSpawner.Config.NPCTypes["Standard"]) do
        table.insert(available, npc)
        table.insert(categories["Standard"], npc)
    end
    
    -- Check for DRGBase
    if self:IsAddonInstalled("drgbase") then
        categories["DRGBase"] = {}
        for _, npc in ipairs(NPCSpawner.Config.NPCTypes["DRGBase"]) do
            if self:IsNPCValid(npc) then
                table.insert(available, npc)
                table.insert(categories["DRGBase"], npc)
            end
        end
    end
    
    -- Check for VJBase
    if self:IsAddonInstalled("vjbase") then
        categories["VJBase"] = {}
        for _, npc in ipairs(NPCSpawner.Config.NPCTypes["VJBase"]) do
            if self:IsNPCValid(npc) then
                table.insert(available, npc)
                table.insert(categories["VJBase"], npc)
            end
        end
    end
    
    return available, categories
end

-- Check if addon is installed
function NPCSpawner.Shared.Util:IsAddonInstalled(addonType)
    if addonType == "drgbase" then
        return file.Exists("lua/entities/drg_*", "GAME") or _G.DRG ~= nil
    elseif addonType == "vjbase" then
        return _G.VJ ~= nil or file.Exists("lua/autorun/vj_*", "GAME")
    end
    return false
end

-- Check if NPC entity exists
function NPCSpawner.Shared.Util:IsNPCValid(npcType)
    return scripted_ents.GetStored(npcType) ~= nil or list.Get("NPC")[npcType] ~= nil
end

-- Generate unique identifier for spawning sessions
function NPCSpawner.Shared.Util:GenerateSpawnID(ply)
    local steamID = IsValid(ply) and ply:SteamID() or "unknown"
    return "NPCSpawner_" .. steamID .. "_" .. os.time()
end

-- Clamp value with validation
function NPCSpawner.Shared.Util:ClampValue(value, min, max, default)
    if not isnumber(value) then return default or min end
    return math.Clamp(value, min, max)
end

-- Color utilities for UI
NPCSpawner.Shared.Colors = {
    Primary = Color(0, 120, 255),
    Success = Color(0, 200, 0),
    Warning = Color(255, 165, 0),
    Danger = Color(220, 53, 69),
    Dark = Color(45, 45, 45),
    Light = Color(248, 249, 250),
    Text = Color(255, 255, 255)
}

-- Debugging utilities
function NPCSpawner.Shared.Util:Debug(message, level)
    if not NPCSpawner.Config.Debug then return end
    
    level = level or "INFO"
    local prefix = "[NPC Spawner " .. level .. "] "
    
    if SERVER then
        print(prefix .. tostring(message))
    else
        print(prefix .. tostring(message))
    end
end

function NPCSpawner.Shared.Util:DebugTable(tbl, name)
    if not NPCSpawner.Config.Debug then return end
    
    name = name or "Table"
    print("[NPC Spawner DEBUG] " .. name .. ":")
    PrintTable(tbl)
end