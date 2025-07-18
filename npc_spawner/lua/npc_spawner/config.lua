-- NPC Spawner Configuration
NPCSpawner = NPCSpawner or {}
NPCSpawner.Config = {
    -- Language Settings
    Language = "en", -- Available: "en", "ru", "tr", "es", "fr", "de"
    
    -- General Settings
    MaxSpawnRadius = 5000,
    MinSpawnRadius = 50,
    MaxNPCAmount = 200,
    MinNPCAmount = 1,
    MaxFrequency = 10,
    MinFrequency = 0.1,
    
    -- Performance Settings
    MaxSpawnAttempts = 20,
    CleanupOnDisconnect = true,
    Debug = false, -- Enable debug messages
    
    -- Admin Settings (Admins can override these as needed)
    AdminOnly = false, -- Set to true if you want admin-only access
    RequiredUserGroup = "user", -- Default to "user" so everyone can access
    
    -- Supported NPC Types
    NPCTypes = {
        -- Standard Source NPCs
        ["Standard"] = {
            "npc_zombie", "npc_fastzombie", "npc_poisonzombie", "npc_zombine",
            "npc_antlion", "npc_combine_s", "npc_citizen", "npc_headcrab",
            "npc_metropolice", "npc_strider", "npc_manhack", "npc_scanner"
        },
        
        -- DRGBase NextBots (if available)
        ["DRGBase"] = {
            "drg_zombie", "drg_skeleton", "drg_crawler"
        },
        
        -- VJBase NPCs (if available)
        ["VJBase"] = {
            "npc_vj_example", "npc_vj_zombie"
        }
    }
}

-- Function to get localized text
function NPCSpawner:GetText(key)
    local lang = self.Config.Language or "en"
    
    -- Load languages if not already loaded
    if not self.Languages then
        include("npc_spawner/languages.lua")
    end
    
    if self.Languages[lang] and self.Languages[lang][key] then
        return self.Languages[lang][key]
    elseif self.Languages["en"] and self.Languages["en"][key] then
        -- Fallback to English if key not found in selected language
        return self.Languages["en"][key]
    else
        -- Fallback to key itself if not found anywhere
        return key
    end
end

-- Function to check if player has permission
function NPCSpawner:HasPermission(ply)
    if not self.Config.AdminOnly then return true end
    return ply:IsAdmin() or ply:IsUserGroup(self.Config.RequiredUserGroup)
end

-- Function to get available NPCs based on installed addons
function NPCSpawner:GetAvailableNPCs()
    local available = {}
    
    -- Always include standard NPCs
    for _, npc in ipairs(self.Config.NPCTypes["Standard"]) do
        table.insert(available, npc)
    end
    
    -- Check for DRGBase
    if file.Exists("lua/entities/drg_*", "GAME") then
        for _, npc in ipairs(self.Config.NPCTypes["DRGBase"]) do
            if scripted_ents.GetStored(npc) then
                table.insert(available, npc)
            end
        end
    end
    
    -- Check for VJBase
    if VJ then
        for _, npc in ipairs(self.Config.NPCTypes["VJBase"]) do
            if scripted_ents.GetStored(npc) then
                table.insert(available, npc)
            end
        end
    end
    
    return available
end