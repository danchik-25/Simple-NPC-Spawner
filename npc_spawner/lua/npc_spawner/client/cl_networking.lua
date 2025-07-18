-- Client Networking
-- lua/npc_spawner/client/cl_networking.lua

NPCSpawner.Client.Networking = NPCSpawner.Client.Networking or {}

function NPCSpawner.Client.Networking:Initialize()
    self:RegisterNetworkHandlers()
    NPCSpawner.Shared.Util:Debug("Client networking initialized", "INFO")
end

-- Register all network message handlers
function NPCSpawner.Client.Networking:RegisterNetworkHandlers()
    
    -- Receive NPC list from server
    net.Receive("NPCSpawner_SendNPCList", function()
        local npcs = net.ReadTable()
        local categories = net.ReadTable()
        
        NPCSpawner.Client.Menu:UpdateNPCList(npcs, categories)
        NPCSpawner.Shared.Util:Debug("Received NPC list with " .. #npcs .. " NPCs", "INFO")
    end)
    
    -- Receive notifications from server
    net.Receive("NPCSpawner_Notification", function()
        local type = net.ReadString()
        local messageKey = net.ReadString()
        local data = net.ReadString()
        
        local message = NPCSpawner:GetText(messageKey)
        if data and data ~= "" then
            message = message .. " (" .. data .. ")"
        end
        
        NPCSpawner.Client.UI:ShowNotification(message, type)
    end)
    
    -- Receive spawn progress updates
    net.Receive("NPCSpawner_SpawnProgress", function()
        local percent = net.ReadFloat()
        local current = net.ReadInt(16)
        local total = net.ReadInt(16)
        
        local progressText = current .. "/" .. total .. " " .. NPCSpawner:GetText("npcs")
        NPCSpawner.Client.Menu:UpdateProgress(percent, progressText)
    end)
    
    -- Receive spawn completion notification
    net.Receive("NPCSpawner_SpawnComplete", function()
        local totalSpawned = net.ReadInt(16)
        
        NPCSpawner.Client.Menu:UpdateProgress(100, NPCSpawner:GetText("complete"))
        
        local message = NPCSpawner:GetText("spawning_complete") .. " (" .. totalSpawned .. ")"
        NPCSpawner.Client.UI:ShowNotification(message, "success")
    end)
    
    -- Receive undo result
    net.Receive("NPCSpawner_UndoResult", function()
        local count = net.ReadInt(16)
        
        if count > 0 then
            local message = NPCSpawner:GetText("npcs_removed") .. ": " .. count
            NPCSpawner.Client.UI:ShowNotification(message, "success")
        else
            NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("no_npcs_to_remove"), "warning")
        end
    end)
    
    -- Receive cancel result
    net.Receive("NPCSpawner_CancelResult", function()
        local cancelled = net.ReadBool()
        
        if cancelled then
            NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("spawning_cancelled"), "info")
        end
    end)
    
    -- Receive statistics from server
    net.Receive("NPCSpawner_SendStats", function()
        local stats = net.ReadTable()
        NPCSpawner.Client.Menu:UpdateStats(stats)
    end)
end

-- Send request for NPC list
function NPCSpawner.Client.Networking:RequestNPCList()
    net.Start("NPCSpawner_RequestNPCList")
    net.SendToServer()
end

-- Send spawn position to server
function NPCSpawner.Client.Networking:SetSpawnPosition()
    net.Start("NPCSpawner_SetSpawnPosition")
    net.SendToServer()
end

-- Send spawning request to server
function NPCSpawner.Client.Networking:StartSpawning(spawnData)
    net.Start("NPCSpawner_StartSpawning")
    net.WriteTable(spawnData)
    net.SendToServer()
end

-- Send undo request to server
function NPCSpawner.Client.Networking:UndoLastSpawn()
    net.Start("NPCSpawner_UndoLastSpawn")
    net.SendToServer()
end

-- Send cancel spawning request to server
function NPCSpawner.Client.Networking:CancelSpawning()
    net.Start("NPCSpawner_CancelSpawning")
    net.SendToServer()
end

-- Send statistics request to server
function NPCSpawner.Client.Networking:RequestStats()
    net.Start("NPCSpawner_GetStats")
    net.SendToServer()
end

-- Send specific NPC removal request
function NPCSpawner.Client.Networking:RemoveSpecificNPC(npc)
    if not IsValid(npc) then return end
    
    net.Start("NPCSpawner_RemoveSpecific")
    net.WriteEntity(npc)
    net.SendToServer()
end

-- Initialize networking when ready
hook.Add("InitPostEntity", "NPCSpawner_InitClientNetworking", function()
    NPCSpawner.Client.Networking:Initialize()
end)