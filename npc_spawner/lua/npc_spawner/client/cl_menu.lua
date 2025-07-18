-- Client Menu System
-- lua/npc_spawner/client/cl_menu.lua

NPCSpawner.Client.Menu = NPCSpawner.Client.Menu or {}

function NPCSpawner.Client.Menu:Initialize()
    self.isOpen = false
    self.frame = nil
    self.availableNPCs = {}
    self.npcCategories = {}
    self.progressBar = nil
    self.currentTab = "spawn"
    
    NPCSpawner.Shared.Util:Debug("Menu system initialized", "INFO")
end

-- Create main menu
function NPCSpawner.Client.Menu:CreateMenu()
    if IsValid(self.frame) then
        self.frame:Remove()
    end
    
    -- Request NPC list first
    self:RequestNPCList()
    
    self.frame = vgui.Create("DFrame")
    self.frame:SetTitle(NPCSpawner:GetText("title"))
    self.frame:SetSize(500, 600)
    self.frame:Center()
    self.frame:MakePopup()
    self.frame:SetDeleteOnClose(true)
    
    -- Modern frame styling
    self.frame.Paint = function(self, w, h)
        -- Main background
        draw.RoundedBox(8, 0, 0, w, h, NPCSpawner.Shared.Colors.Dark)
        
        -- Title bar
        draw.RoundedBoxEx(8, 0, 0, w, 30, Color(35, 35, 35), true, true, false, false)
        
        -- Subtle border
        surface.SetDrawColor(80, 80, 80, 150)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    self.frame.OnClose = function()
        self.isOpen = false
    end
    
    self.isOpen = true
    self:CreateMenuContent()
end

-- Create menu content with tabs
function NPCSpawner.Client.Menu:CreateMenuContent()
    local tabs = NPCSpawner.Client.UI:CreateTabbedPanel(self.frame, 10, 40, 480, 550)
    
    -- Main spawn tab
    local spawnTab = vgui.Create("DPanel")
    spawnTab.Paint = function() end
    tabs:AddSheet(NPCSpawner:GetText("spawn_npcs"), spawnTab, "icon16/add.png")
    
    self:CreateSpawnPanel(spawnTab)
    
    -- Settings tab
    local settingsTab = vgui.Create("DPanel")
    settingsTab.Paint = function() end
    tabs:AddSheet(NPCSpawner:GetText("settings"), settingsTab, "icon16/cog.png")
    
    self:CreateSettingsPanel(settingsTab)
    
    -- Statistics tab
    local statsTab = vgui.Create("DPanel")
    statsTab.Paint = function() end
    tabs:AddSheet(NPCSpawner:GetText("statistics"), statsTab, "icon16/chart_bar.png")
    
    self:CreateStatsPanel(statsTab)
end

-- Create spawn panel
function NPCSpawner.Client.Menu:CreateSpawnPanel(parent)
    -- NPC selection dropdown
    local npcLabel = vgui.Create("DLabel", parent)
    npcLabel:SetText(NPCSpawner:GetText("select_npc"))
    npcLabel:SetTextColor(NPCSpawner.Shared.Colors.Text)
    npcLabel:SetPos(10, 10)
    npcLabel:SizeToContents()
    
    self.npcDropdown = NPCSpawner.Client.UI:CreateCategorizedDropdown(
        parent, 10, 35, 460, 30, self.npcCategories
    )
    
    -- Spawn parameters
    local sliders = {
        {80, NPCSpawner:GetText("spawn_radius"), NPCSpawner.Config.MinSpawnRadius, NPCSpawner.Config.MaxSpawnRadius, 1000},
        {130, NPCSpawner:GetText("spawn_frequency"), NPCSpawner.Config.MinFrequency, NPCSpawner.Config.MaxFrequency, 1},
        {180, NPCSpawner:GetText("npc_amount"), NPCSpawner.Config.MinNPCAmount, NPCSpawner.Config.MaxNPCAmount, 10}
    }
    
    self.sliders = {}
    for _, data in ipairs(sliders) do
        local slider = NPCSpawner.Client.UI:CreateStyledSlider(
            parent, 10, data[1], 460, 40, data[2], data[3], data[4], 
            data[2]:find("Frequency") and 1 or 0, data[5]
        )
        self.sliders[data[2]] = slider
    end
    
    -- Progress bar
    self.progressBar = NPCSpawner.Client.UI:CreateProgressBar(parent, 10, 240, 460, 25)
    
    -- Action buttons
    local buttonY = 280
    
    NPCSpawner.Client.UI:CreateStyledButton(
        parent, 10, buttonY, 225, 40, 
        NPCSpawner:GetText("set_spawn_pos"), 
        NPCSpawner.Shared.Colors.Primary,
        function() self:SetSpawnPosition() end
    )
    
    NPCSpawner.Client.UI:CreateStyledButton(
        parent, 245, buttonY, 225, 40,
        NPCSpawner:GetText("spawn_npcs"),
        NPCSpawner.Shared.Colors.Success,
        function() self:StartSpawning() end
    )
    
    NPCSpawner.Client.UI:CreateStyledButton(
        parent, 10, buttonY + 50, 225, 40,
        NPCSpawner:GetText("undo_last_spawn"),
        NPCSpawner.Shared.Colors.Warning,
        function() self:UndoLastSpawn() end
    )
    
    NPCSpawner.Client.UI:CreateStyledButton(
        parent, 245, buttonY + 50, 225, 40,
        NPCSpawner:GetText("cancel_spawning"),
        NPCSpawner.Shared.Colors.Danger,
        function() self:CancelSpawning() end
    )
    
    -- Info panel
    local infoText = NPCSpawner:GetText("info_text")
    NPCSpawner.Client.UI:CreateInfoPanel(parent, 10, 390, 460, 80, infoText)
end

-- Create settings panel
function NPCSpawner.Client.Menu:CreateSettingsPanel(parent)
    local settingsPanel = NPCSpawner.Client.UI:CreateSettingsPanel(parent)
    settingsPanel:Dock(FILL)
end

-- Create statistics panel
function NPCSpawner.Client.Menu:CreateStatsPanel(parent)
    -- Request stats from server
    net.Start("NPCSpawner_GetStats")
    net.SendToServer()
    
    self.statsPanel = vgui.Create("DScrollPanel", parent)
    self.statsPanel:Dock(FILL)
    
    local label = vgui.Create("DLabel", self.statsPanel)
    label:SetText(NPCSpawner:GetText("loading_stats"))
    label:SetTextColor(NPCSpawner.Shared.Colors.Text)
    label:Dock(TOP)
    label:DockMargin(10, 10, 10, 10)
end

-- Request NPC list from server
function NPCSpawner.Client.Menu:RequestNPCList()
    net.Start("NPCSpawner_RequestNPCList")
    net.SendToServer()
end

-- Set spawn position
function NPCSpawner.Client.Menu:SetSpawnPosition()
    if not NPCSpawner.Shared.Validation:CheckRateLimit(LocalPlayer(), "spawn") then
        NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("rate_limit"), "warning")
        return
    end
    
    net.Start("NPCSpawner_SetSpawnPosition")
    net.SendToServer()
    
    NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("spawn_set"), "success")
end

-- Start spawning process
function NPCSpawner.Client.Menu:StartSpawning()
    if not NPCSpawner.Shared.Validation:CheckRateLimit(LocalPlayer(), "spawn") then
        NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("rate_limit"), "warning")
        return
    end
    
    local selectedNPC = self.npcDropdown:GetSelected()
    if not selectedNPC then
        NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("no_npc_selected"), "error")
        return
    end
    
    -- Get actual NPC class name if it's a categorized selection
    local npcClass = selectedNPC
    if self.npcDropdown:GetSelectedID() then
        npcClass = self.npcDropdown:GetOptionData(self.npcDropdown:GetSelectedID()) or selectedNPC
    end
    
    local spawnData = {
        npcType = npcClass,
        radius = self.sliders[NPCSpawner:GetText("spawn_radius")]:GetValue(),
        frequency = self.sliders[NPCSpawner:GetText("spawn_frequency")]:GetValue(),
        amount = self.sliders[NPCSpawner:GetText("npc_amount")]:GetValue()
    }
    
    net.Start("NPCSpawner_StartSpawning")
    net.WriteTable(spawnData)
    net.SendToServer()
    
    self.progressBar:SetVisible(true)
    self.progressBar:SetProgress(0, NPCSpawner:GetText("spawning_started"))
    
    NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("spawning_started"), "info")
end

-- Undo last spawn
function NPCSpawner.Client.Menu:UndoLastSpawn()
    if not NPCSpawner.Shared.Validation:CheckRateLimit(LocalPlayer(), "undo") then
        NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("rate_limit"), "warning")
        return
    end
    
    net.Start("NPCSpawner_UndoLastSpawn")
    net.SendToServer()
end

-- Cancel current spawning
function NPCSpawner.Client.Menu:CancelSpawning()
    net.Start("NPCSpawner_CancelSpawning")
    net.SendToServer()
    
    if IsValid(self.progressBar) then
        self.progressBar:SetVisible(false)
    end
    
    NPCSpawner.Client.UI:ShowNotification(NPCSpawner:GetText("spawning_cancelled"), "info")
end

-- Update spawning progress
function NPCSpawner.Client.Menu:UpdateProgress(percent, text)
    if IsValid(self.progressBar) then
        self.progressBar:SetProgress(percent, text)
        
        if percent >= 100 then
            timer.Simple(2, function()
                if IsValid(self.progressBar) then
                    self.progressBar:SetVisible(false)
                end
            end)
        end
    end
end

-- Update NPC list
function NPCSpawner.Client.Menu:UpdateNPCList(npcs, categories)
    self.availableNPCs = npcs
    self.npcCategories = categories
    
    if IsValid(self.npcDropdown) then
        self.npcDropdown:Clear()
        
        -- Re-populate dropdown
        for categoryName, npcList in pairs(categories) do
            if #npcList > 0 then
                local categoryLabel = NPCSpawner:GetText(categoryName:lower(), "npc_categories") or categoryName
                
                for _, npc in ipairs(npcList) do
                    local displayName = categoryLabel .. " - " .. npc
                    self.npcDropdown:AddChoice(displayName, npc)
                end
            end
        end
        
        -- Set default selection
        if #self.availableNPCs > 0 then
            self.npcDropdown:ChooseOptionID(1)
        end
    end
end

-- Update statistics display
function NPCSpawner.Client.Menu:UpdateStats(stats)
    if not IsValid(self.statsPanel) then return end
    
    self.statsPanel:Clear()
    
    -- Personal stats
    local personalPanel = vgui.Create("DCollapsibleCategory", self.statsPanel)
    personalPanel:SetLabel(NPCSpawner:GetText("personal_stats"))
    personalPanel:Dock(TOP)
    personalPanel:DockMargin(5, 5, 5, 5)
    personalPanel:SetExpanded(true)
    
    local personalList = vgui.Create("DListLayout", personalPanel)
    personalList:Dock(FILL)
    
    local personalStats = {
        {"npcs_spawned", stats.player and stats.player.npcs_spawned or 0},
        {"npcs_removed_stat", stats.player and stats.player.npcs_removed or 0},
        {"spawn_positions_set", stats.player and stats.player.spawn_positions_set or 0},
        {"last_activity", stats.player and stats.player.last_activity and os.date("%Y-%m-%d %H:%M:%S", stats.player.last_activity) or "Never"}
    }
    
    for _, stat in ipairs(personalStats) do
        local statLabel = vgui.Create("DLabel", personalList)
        statLabel:SetText(NPCSpawner:GetText(stat[1]) .. ": " .. tostring(stat[2]))
        statLabel:SetTextColor(NPCSpawner.Shared.Colors.Text)
        statLabel:Dock(TOP)
        statLabel:DockMargin(10, 2, 10, 2)
    end
    
    -- Server stats
    if stats.server then
        local serverPanel = vgui.Create("DCollapsibleCategory", self.statsPanel)
        serverPanel:SetLabel(NPCSpawner:GetText("server_stats"))
        serverPanel:Dock(TOP)
        serverPanel:DockMargin(5, 5, 5, 5)
        serverPanel:SetExpanded(false)
        
        local serverList = vgui.Create("DListLayout", serverPanel)
        serverList:Dock(FILL)
        
        local serverStats = {
            {"total_npcs_spawned", stats.server.total_npcs_spawned or 0},
            {"active_players", stats.server.active_players or 0},
            {"current_npcs", stats.server.current_npcs or 0}
        }
        
        for _, stat in ipairs(serverStats) do
            local statLabel = vgui.Create("DLabel", serverList)
            statLabel:SetText(NPCSpawner:GetText(stat[1]) .. ": " .. tostring(stat[2]))
            statLabel:SetTextColor(NPCSpawner.Shared.Colors.Text)
            statLabel:Dock(TOP)
            statLabel:DockMargin(10, 2, 10, 2)
        end
    end
end

-- Toggle menu visibility
function NPCSpawner.Client.Menu:Toggle()
    if self.isOpen then
        self:Close()
    else
        self:Open()
    end
end

-- Open menu
function NPCSpawner.Client.Menu:Open()
    if not NPCSpawner.Shared.Validation:CheckRateLimit(LocalPlayer(), "menu") then
        return
    end
    
    self:CreateMenu()
end

-- Close menu
function NPCSpawner.Client.Menu:Close()
    if IsValid(self.frame) then
        self.frame:Close()
    end
    self.isOpen = false
end

-- Console command to open menu
concommand.Add("npc_spawner_menu", function()
    NPCSpawner.Client.Menu:Toggle()
end)

-- Right-click context menu for NPCs
hook.Add("OnPlayerChat", "NPCSpawner_NPCContext", function(ply, text)
    if text == "!npcmenu" and ply == LocalPlayer() then
        local trace = LocalPlayer():GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:IsNPC() then
            local x, y = gui.MousePos()
            NPCSpawner.Client.UI:CreateNPCContextMenu(trace.Entity, x, y)
        end
        return true
    end
end)

-- Initialize menu system
hook.Add("InitPostEntity", "NPCSpawner_InitMenu", function()
    NPCSpawner.Client.Menu:Initialize()
end)