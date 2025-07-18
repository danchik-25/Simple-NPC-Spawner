-- Client UI Components
-- lua/npc_spawner/client/cl_ui_components.lua

NPCSpawner.Client.UI = NPCSpawner.Client.UI or {}

-- Create styled button with hover effects
function NPCSpawner.Client.UI:CreateStyledButton(parent, x, y, w, h, text, color, callback)
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(w, h)
    btn:SetText(text)
    btn:SetFont("Trebuchet18")
    btn:SetTextColor(NPCSpawner.Shared.Colors.Text)
    
    btn.Paint = function(self, width, height)
        local bgColor = color
        local alpha = 255
        
        if self:IsHovered() then
            bgColor = Color(color.r + 30, color.g + 30, color.b + 30, alpha)
            draw.RoundedBox(5, 0, 0, width, height, Color(255, 255, 255, 20))
        elseif self:IsDown() then
            bgColor = Color(color.r - 20, color.g - 20, color.b - 20, alpha)
        end
        
        draw.RoundedBox(5, 0, 0, width, height, bgColor)
        
        -- Subtle border
        surface.SetDrawColor(255, 255, 255, self:IsHovered() and 40 or 20)
        surface.DrawOutlinedRect(0, 0, width, height)
    end
    
    btn.DoClick = callback
    return btn
end

-- Create modern slider with custom styling
function NPCSpawner.Client.UI:CreateStyledSlider(parent, x, y, w, h, label, min, max, decimals, defaultValue)
    local slider = vgui.Create("DNumSlider", parent)
    slider:SetPos(x, y)
    slider:SetSize(w, h)
    slider:SetText(label)
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetDecimals(decimals or 0)
    slider:SetValue(defaultValue)
    
    -- Custom styling
    slider.Label:SetTextColor(NPCSpawner.Shared.Colors.Text)
    slider.TextArea:SetTextColor(NPCSpawner.Shared.Colors.Text)
    
    return slider
end

-- Create dropdown with categories
function NPCSpawner.Client.UI:CreateCategorizedDropdown(parent, x, y, w, h, npcCategories)
    local dropdown = vgui.Create("DComboBox", parent)
    dropdown:SetPos(x, y)
    dropdown:SetSize(w, h)
    
    -- Style the dropdown
    dropdown:SetTextColor(NPCSpawner.Shared.Colors.Text)
    dropdown.Paint = function(self, width, height)
        draw.RoundedBox(3, 0, 0, width, height, Color(60, 60, 60))
        surface.SetDrawColor(100, 100, 100)
        surface.DrawOutlinedRect(0, 0, width, height)
    end
    
    -- Add NPCs by category
    for categoryName, npcs in pairs(npcCategories) do
        if #npcs > 0 then
            local categoryLabel = NPCSpawner:GetText(categoryName:lower(), "npc_categories") or categoryName
            dropdown:AddSpacer() -- Visual separator
            
            for _, npc in ipairs(npcs) do
                local displayName = categoryLabel .. " - " .. npc
                dropdown:AddChoice(displayName, npc)
            end
        end
    end
    
    return dropdown
end

-- Create info panel with scrollable text
function NPCSpawner.Client.UI:CreateInfoPanel(parent, x, y, w, h, text)
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x, y)
    panel:SetSize(w, h)
    
    panel.Paint = function(self, width, height)
        draw.RoundedBox(3, 0, 0, width, height, Color(35, 35, 35, 200))
        surface.SetDrawColor(80, 80, 80)
        surface.DrawOutlinedRect(0, 0, width, height)
    end
    
    local label = vgui.Create("DLabel", panel)
    label:SetPos(5, 5)
    label:SetSize(w - 10, h - 10)
    label:SetText(text)
    label:SetTextColor(Color(200, 200, 200))
    label:SetWrap(true)
    label:SetContentAlignment(7) -- Top-left alignment
    
    return panel
end

-- Create progress bar for spawning progress
function NPCSpawner.Client.UI:CreateProgressBar(parent, x, y, w, h)
    local progress = vgui.Create("DPanel", parent)
    progress:SetPos(x, y)
    progress:SetSize(w, h)
    progress:SetVisible(false)
    
    progress.Progress = 0
    progress.Text = ""
    
    progress.Paint = function(self, width, height)
        -- Background
        draw.RoundedBox(3, 0, 0, width, height, Color(40, 40, 40))
        
        -- Progress fill
        local fillWidth = (width - 4) * (self.Progress / 100)
        if fillWidth > 0 then
            draw.RoundedBox(2, 2, 2, fillWidth, height - 4, NPCSpawner.Shared.Colors.Success)
        end
        
        -- Border
        surface.SetDrawColor(100, 100, 100)
        surface.DrawOutlinedRect(0, 0, width, height)
        
        -- Text
        if self.Text != "" then
            draw.SimpleText(self.Text, "DermaDefault", width / 2, height / 2, 
                NPCSpawner.Shared.Colors.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    function progress:SetProgress(percent, text)
        self.Progress = math.Clamp(percent or 0, 0, 100)
        self.Text = text or ""
    end
    
    return progress
end

-- Create tabbed panel for organized UI
function NPCSpawner.Client.UI:CreateTabbedPanel(parent, x, y, w, h)
    local tabs = vgui.Create("DPropertySheet", parent)
    tabs:SetPos(x, y)
    tabs:SetSize(w, h)
    
    -- Style the tabs
    tabs.Paint = function(self, width, height)
        draw.RoundedBox(5, 0, 20, width, height - 20, Color(50, 50, 50))
    end
    
    return tabs
end

-- Create notification system
NPCSpawner.Client.UI.Notifications = NPCSpawner.Client.UI.Notifications or {}

function NPCSpawner.Client.UI:ShowNotification(message, type, duration)
    type = type or "info"
    duration = duration or 3
    
    local colors = {
        info = NPCSpawner.Shared.Colors.Primary,
        success = NPCSpawner.Shared.Colors.Success,
        warning = NPCSpawner.Shared.Colors.Warning,
        error = NPCSpawner.Shared.Colors.Danger
    }
    
    local color = colors[type] or colors.info
    
    -- Create notification panel
    local notification = vgui.Create("DPanel")
    notification:SetSize(300, 60)
    notification:SetPos(ScrW() - 320, 20 + (#self.Notifications * 70))
    
    notification.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(color.r, color.g, color.b, 230))
        draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    
    local label = vgui.Create("DLabel", notification)
    label:SetPos(10, 10)
    label:SetSize(280, 40)
    label:SetText(message)
    label:SetTextColor(Color(255, 255, 255))
    label:SetWrap(true)
    
    table.insert(self.Notifications, notification)
    
    -- Auto-remove after duration
    timer.Simple(duration, function()
        if IsValid(notification) then
            notification:Remove()
            table.RemoveByValue(self.Notifications, notification)
            self:RepositionNotifications()
        end
    end)
end

function NPCSpawner.Client.UI:RepositionNotifications()
    for i, notif in ipairs(self.Notifications) do
        if IsValid(notif) then
            notif:SetPos(ScrW() - 320, 20 + ((i - 1) * 70))
        end
    end
end

-- Create context menu for NPCs
function NPCSpawner.Client.UI:CreateNPCContextMenu(npc, x, y)
    local menu = DermaMenu()
    
    menu:AddOption(NPCSpawner:GetText("inspect"), function()
        -- Show NPC info
        self:ShowNPCInfo(npc)
    end):SetIcon("icon16/zoom.png")
    
    menu:AddOption(NPCSpawner:GetText("remove"), function()
        -- Remove specific NPC
        net.Start("NPCSpawner_RemoveSpecific")
        net.WriteEntity(npc)
        net.SendToServer()
    end):SetIcon("icon16/delete.png")
    
    menu:AddSeparator()
    
    menu:AddOption(NPCSpawner:GetText("remove_all"), function()
        -- Remove all player NPCs
        net.Start("NPCSpawner_UndoLastSpawn")
        net.SendToServer()
    end):SetIcon("icon16/bin.png")
    
    menu:Open(x, y)
    return menu
end

-- Show NPC information window
function NPCSpawner.Client.UI:ShowNPCInfo(npc)
    if not IsValid(npc) then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle(NPCSpawner:GetText("npc_info"))
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()
    
    local info = vgui.Create("DScrollPanel", frame)
    info:Dock(FILL)
    
    local infoText = string.format([[
Class: %s
Health: %d/%d
Position: %.1f, %.1f, %.1f
Model: %s
Material: %s
    ]], 
    npc:GetClass(),
    npc:Health(), npc:GetMaxHealth(),
    npc:GetPos().x, npc:GetPos().y, npc:GetPos().z,
    npc:GetModel(),
    npc:GetMaterial()
    )
    
    local label = vgui.Create("DLabel", info)
    label:SetText(infoText)
    label:SetTextColor(Color(255, 255, 255))
    label:SizeToContents()
    label:Dock(TOP)
end

-- Create settings panel
function NPCSpawner.Client.UI:CreateSettingsPanel(parent)
    local panel = vgui.Create("DScrollPanel", parent)
    
    -- Language selection
    local langLabel = vgui.Create("DLabel", panel)
    langLabel:SetText(NPCSpawner:GetText("language"))
    langLabel:SetTextColor(NPCSpawner.Shared.Colors.Text)
    langLabel:Dock(TOP)
    langLabel:DockMargin(5, 5, 5, 0)
    
    local langCombo = vgui.Create("DComboBox", panel)
    langCombo:Dock(TOP)
    langCombo:DockMargin(5, 5, 5, 10)
    
    for langCode, langData in pairs(NPCSpawner.Languages) do
        langCombo:AddChoice(langData.language_name or langCode, langCode)
    end
    langCombo:SetValue(NPCSpawner.Config.Language)
    
    -- Info text
    local infoLabel = vgui.Create("DLabel", panel)
    infoLabel:SetText("Note: Language changes require a restart to take full effect.\nAdmins can modify limits and permissions in the config file.")
    infoLabel:SetTextColor(Color(200, 200, 200))
    infoLabel:SetWrap(true)
    infoLabel:Dock(TOP)
    infoLabel:DockMargin(5, 10, 5, 10)
    
    return panel
end