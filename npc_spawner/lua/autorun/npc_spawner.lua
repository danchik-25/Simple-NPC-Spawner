-- NPC Spawner Main Loader
-- lua/autorun/npc_spawner.lua

NPCSpawner = NPCSpawner or {}
NPCSpawner.Version = "2.0.0"
NPCSpawner.Loaded = NPCSpawner.Loaded or {}

-- Initialize namespace
NPCSpawner.Server = NPCSpawner.Server or {}
NPCSpawner.Client = NPCSpawner.Client or {}
NPCSpawner.Shared = NPCSpawner.Shared or {}

-- File loading helper
local function LoadFile(path, realm)
    realm = realm or "shared"
    local fullPath = "npc_spawner/" .. path
    
    if realm == "shared" then
        include(fullPath)
        if SERVER then
            AddCSLuaFile(fullPath)
        end
    elseif realm == "server" and SERVER then
        include(fullPath)
    elseif realm == "client" then
        if SERVER then
            AddCSLuaFile(fullPath)
        else
            include(fullPath)
        end
    end
    
    if NPCSpawner.Config and NPCSpawner.Config.Debug then
        print("[NPC Spawner] Loaded: " .. fullPath)
    end
end

-- Load order is important!
local loadOrder = {
    -- Core files first
    {"config.lua", "shared"},
    {"languages.lua", "shared"},
    
    -- Shared utilities
    {"shared/sh_util.lua", "shared"},
    {"shared/sh_validation.lua", "shared"},
    
    -- Server files
    {"server/sv_core.lua", "server"},
    {"server/sv_networking.lua", "server"},
    {"server/sv_spawning.lua", "server"},
    {"server/sv_cleanup.lua", "server"},
    
    -- Client files
    {"client/cl_core.lua", "client"},
    {"client/cl_networking.lua", "client"},
    {"client/cl_ui_components.lua", "client"},
    {"client/cl_menu.lua", "client"}
}

-- Load all files
for _, fileData in ipairs(loadOrder) do
    local success, err = pcall(LoadFile, fileData[1], fileData[2])
    if not success then
        print("[NPC Spawner ERROR] Failed to load " .. fileData[1] .. ": " .. tostring(err))
    else
        NPCSpawner.Loaded[fileData[1]] = true
    end
end

-- Initialize after all files are loaded
hook.Add("Initialize", "NPCSpawner_Init", function()
    if SERVER and NPCSpawner.Server.Initialize then
        NPCSpawner.Server.Initialize()
    elseif CLIENT and NPCSpawner.Client.Initialize then
        NPCSpawner.Client.Initialize()
    end
    
    if NPCSpawner.Config and NPCSpawner.Config.Debug then
        print("[NPC Spawner] Version " .. NPCSpawner.Version .. " initialized successfully!")
    end
end)

-- Network string registration (must be done early)
if SERVER then
    local networkStrings = {
        "NPCSpawner_OpenMenu",
        "NPCSpawner_StartSpawning",
        "NPCSpawner_SetSpawnPosition",
        "NPCSpawner_RequestNPCList",
        "NPCSpawner_SendNPCList",
        "NPCSpawner_UndoLastSpawn",
        "NPCSpawner_GetStats",
        "NPCSpawner_SendStats"
    }
    
    for _, str in ipairs(networkStrings) do
        util.AddNetworkString(str)
    end
end