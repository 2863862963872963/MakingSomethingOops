

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- GodTierUI Class
local GodTierUI = {}
GodTierUI.__index = GodTierUI

function GodTierUI.new(options)
    local self = setmetatable({}, GodTierUI)
    self.Player = Players.LocalPlayer
    self.Config = {
        Name = options.Name or "GodTierUI",
        Size = options.Size or UDim2.new(0, 450, 0, 350),
        ToggleKey = options.ToggleKey or Enum.KeyCode.LeftControl,
        Theme = {
            Primary = Color3.fromRGB(28, 37, 38), -- CSGO black
            Secondary = Color3.fromRGB(46, 46, 46), -- Dark gray
            Accent = Color3.fromRGB(0, 255, 255), -- Neon cyan
            Highlight = Color3.fromRGB(179, 0, 255), -- Neon purple
            Text = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1 -- Acrylic blur
        },
        ConfigFile = "GodTierUI_" .. self.Player.Name .. ".json"
    }

    -- ScreenGui Setup
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "GodTierUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end

    -- Window
    self.Window = Instance.new("Frame")
    self.Window.Size = self.Config.Size
    self.Window.Position = UDim2.new(0.5, -self.Config.Size.X.Offset / 2, 0.5, -self.Config.Size.Y.Offset / 2)
    self.Window.BackgroundColor3 = self.Config.Theme.Primary
    self.Window.BackgroundTransparency = self.Config.Theme.Transparency
    self.Window.BorderSizePixel = 2
    self.Window.BorderColor3 = self.Config.Theme.Accent
    self.Window.Parent = self.ScreenGui
    self.Window.ClipsDescendants = true
    self.Window.Active = true
    self.Window.Draggable = true

    -- Header
    self.Header = Instance.new("TextLabel")
    self.Header.Size = UDim2.new(1, 0, 0, 40)
    self.Header.BackgroundColor3 = self.Config.Theme.Secondary
    self.Header.Text = self.Config.Name
    self.Header.TextColor3 = self.Config.Theme.Accent
    self.Header.Font = Enum.Font.Code
    self.Header.TextSize = 18
    self.Header.TextXAlignment = Enum.TextXAlignment.Left
    self.Header.TextYAlignment = Enum.TextYAlignment.Center
    self.Header.Parent = self.Window
    self.Header.BorderSizePixel = 0
    self.Header.Position = UDim2.new(0, 10, 0, 0)

    -- Tabs Frame
    self.TabsFrame = Instance.new("Frame")
    self.TabsFrame.Size = UDim2.new(1, 0, 0, 30)
    self.TabsFrame.Position = UDim2.new(0, 0, 0, 40)
    self.TabsFrame.BackgroundTransparency = 1
    self.TabsFrame.Parent = self.Window

    self.TabsLayout = Instance.new("UIListLayout")
    self.TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    self.TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.TabsLayout.Padding = UDim.new(0, 5)
    self.TabsLayout.Parent = self.TabsFrame

    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -80)
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 70)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ClipsDescendants = true
    self.ContentFrame.Parent = self.Window

    -- Notification Frame
    self.NotificationFrame = Instance.new("Frame")
    self.NotificationFrame.Size = UDim2.new(0, 200, 0, 100)
    self.NotificationFrame.Position = UDim2.new(1, -210, 1, -110)
    self.NotificationFrame.BackgroundTransparency = 1
    self.NotificationFrame.Parent = self.ScreenGui
    self.NotificationFrame.ClipsDescendants = true

    self.NotificationLayout = Instance.new("UIListLayout")
    self.NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self.NotificationLayout.Padding = UDim.new(0, 5)
    self.NotificationLayout.Parent = self.NotificationFrame

    -- Minimize Button
    self.MinimizeButton = Instance.new("ImageButton")
    self.MinimizeButton.Size = UDim2.new(0, 50, 0, 50)
    self.MinimizeButton.Position = UDim2.new(0.9, 0, 0.1, 0)
    self.MinimizeButton.BackgroundColor3 = self.Config.Theme.Secondary
    self.MinimizeButton.Image = "rbxassetid://90319448802378"
    self.MinimizeButton.ImageTransparency = 0.2
    self.MinimizeButton.BackgroundTransparency = 0.8
    self.MinimizeButton.Parent = self.ScreenGui
    self.MinimizeButton.Draggable = true
    self.MinimizeButton.Visible = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 200)
    corner.Parent = self.MinimizeButton

    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Config.ToggleKey then
            self:ToggleVisibility()
        end
    end)

    self.Tabs = {}
    self.Visible = true
    self.ConfigData = {}
    self:LoadConfig()
    return self
end

function GodTierUI:ToggleVisibility()
    self.Visible = not self.Visible
    self.Window.Visible = self.Visible
    self.MinimizeButton.Visible = not self.Visible
    self:Notify({
        Title = "UI Toggled",
        Content = self.Visible and "UI shown" or "UI hidden",
        Duration = 2
    })
end

function GodTierUI:AddTab(options)
    local tab = {}
    tab.Name = options.Title
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(0, 100, 0, 30)
    tab.Button.BackgroundColor3 = self.Config.Theme.Secondary
    tab.Button.Text = options.Title
    tab.Button.TextColor3 = self.Config.Theme.Text
    tab.Button.Font = Enum.Font.Code
    tab.Button.TextSize = 14
    tab.Button.Parent = self.TabsFrame
    tab.Button.BorderSizePixel = 1
    tab.Button.BorderColor3 = self.Config.Theme.Accent

    tab.Content = Instance.new("Frame")
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Parent = self.ContentFrame
    tab.Content.Visible = false
    tab.Layout = Instance.new("UIListLayout")
    tab.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    tab.Layout.Padding = UDim.new(0, 5)
    tab.Layout.Parent = tab.Content

    tab.Button.MouseEnter:Connect(function()
        TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Config.Theme.Accent}):Play()
    end)
    tab.Button.MouseLeave:Connect(function()
        if not tab.Content.Visible then
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Config.Theme.Secondary}):Play()
        end
    end)
    tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = self.Config.Theme.Secondary
        end
        tab.Content.Visible = true
        TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Config.Theme.Accent}):Play()
        self:Notify({
            Title = "Tab Switched",
            Content = "Switched to " .. options.Title,
            Duration = 2
        })
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab.Button:MouseButton1Click()
    end
    return tab
end

function GodTierUI:AddSection(tab, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = tab.Content
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = self.Config.Theme.Highlight
    label.Font = Enum.Font.Code
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    return section
end

function GodTierUI:AddToggle(section, options)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 30)
    toggle.BackgroundTransparency = 1
    toggle.Parent = section
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Title
    label.TextColor3 = self.Config.Theme.Text
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(0.9, 0, 0, 5)
    button.BackgroundColor3 = options.Default and self.Config.Theme.Accent or self.Config.Theme.Secondary
    button.Text = ""
    button.Parent = toggle
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    button.MouseButton1Click:Connect(function()
        options.Default = not options.Default
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = options.Default and self.Config.Theme.Accent or self.Config.Theme.Secondary}):Play()
        self:SaveConfig(options.Flag, options.Default)
        if options.Callback then
            options.Callback(options.Default)
        end
        self:Notify({
            Title = options.Title,
            Content = options.Default and "Enabled" or "Disabled",
            Duration = 2
        })
    end)
    self.ConfigData[options.Flag] = options.Default
    return toggle
end

function GodTierUI:AddSlider(section, options)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 50)
    slider.BackgroundTransparency = 1
    slider.Parent = section
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = options.Title
    label.TextColor3 = self.Config.Theme.Text
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = self.Config.Theme.Secondary
    bar.Parent = slider
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0)
    fill.BackgroundColor3 = self.Config.Theme.Accent
    fill.Parent = bar
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = bar
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, 0, 0, -20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(options.Default) .. (options.Suffix or "")
    valueLabel.TextColor3 = self.Config.Theme.Text
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 12
    valueLabel.Parent = slider
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = bar
    button.MouseButton1Down:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        local startX = bar.AbsolutePosition.X
        local maxWidth = bar.AbsoluteSize.X
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local relativeX = math.clamp((mouseX - startX) / maxWidth, 0, 1)
            local value = options.Min + (options.Max - options.Min) * relativeX
            value = math.floor(value / (options.Increment or 1)) * (options.Increment or 1)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            valueLabel.Text = tostring(value) .. (options.Suffix or "")
            self.ConfigData[options.Flag] = value
            if options.Callback then
                options.Callback(value)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                self:SaveConfig(options.Flag, self.ConfigData[options.Flag])
                self:Notify({
                    Title = options.Title,
                    Content = "Set to " .. valueLabel.Text,
                    Duration = 2
                })
            end
        end)
    end)
    self.ConfigData[options.Flag] = options.Default
    return slider
end

function GodTierUI:AddDropdown(section, options)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 30)
    dropdown.BackgroundTransparency = 1
    dropdown.Parent = section
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Title
    label.TextColor3 = self.Config.Theme.Text
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.8, 0, 0, 0)
    button.BackgroundColor3 = self.Config.Theme.Secondary
    button.Text = options.Default or options.Values[1]
    button.TextColor3 = self.Config.Theme.Text
    button.Font = Enum.Font.Code
    button.TextSize = 12
    button.Parent = dropdown
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0.2, 0, 0, #options.Values * 30)
    menu.Position = UDim2.new(0.8, 0, 0, 30)
    menu.BackgroundColor3 = self.Config.Theme.Secondary
    menu.BackgroundTransparency = self.Config.Theme.Transparency
    menu.Parent = dropdown
    menu.Visible = false
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Parent = menu
    for _, value in ipairs(options.Values) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, 0, 0, 30)
        option.BackgroundColor3 = self.Config.Theme.Secondary
        option.Text = value
        option.TextColor3 = self.Config.Theme.Text
        option.Font = Enum.Font.Code
        option.TextSize = 12
        option.Parent = menu
        option.MouseButton1Click:Connect(function()
            button.Text = value
            menu.Visible = false
            self.ConfigData[options.Flag] = value
            if options.Callback then
                options.Callback(value)
            end
            self:SaveConfig(options.Flag, value)
            self:Notify({
                Title = options.Title,
                Content = "Selected " .. value,
                Duration = 2
            })
        end)
    end
    button.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        TweenService:Create(menu, TweenInfo.new(0.2), {BackgroundTransparency = menu.Visible and self.Config.Theme.Transparency or 1}):Play()
    end)
    self.ConfigData[options.Flag] = options.Default or options.Values[1]
    return dropdown
end

function GodTierUI:AddButton(section, options)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = self.Config.Theme.Secondary
    button.Text = options.Title
    button.TextColor3 = self.Config.Theme.Text
    button.Font = Enum.Font.Code
    button.TextSize = 14
    button.Parent = section
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Config.Theme.Accent}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Config.Theme.Secondary}):Play()
        if options.Callback then
            options.Callback()
        end
        self:Notify({
            Title = options.Title,
            Content = "Clicked! [CSGO click sound]",
            Duration = 2
        })
    end)
    return button
end

function GodTierUI:AddParagraph(section, options)
    local paragraph = Instance.new("TextLabel")
    paragraph.Size = UDim2.new(1, 0, 0, 50)
    paragraph.BackgroundTransparency = 1
    paragraph.Text = options.Title .. "\n" .. options.Content
    paragraph.TextColor3 = self.Config.Theme.Text
    paragraph.Font = Enum.Font.Code
    paragraph.TextSize = 12
    paragraph.TextXAlignment = Enum.TextXAlignment.Left
    paragraph.TextYAlignment = Enum.TextYAlignment.Top
    paragraph.TextWrapped = true
    paragraph.Parent = section
    return paragraph
end

function GodTierUI:AddKeybind(section, options)
    local keybind = Instance.new("Frame")
    keybind.Size = UDim2.new(1, 0, 0, 30)
    keybind.BackgroundTransparency = 1
    keybind.Parent = section
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Title
    label.TextColor3 = self.Config.Theme.Text
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybind
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.8, 0, 0, 0)
    button.BackgroundColor3 = self.Config.Theme.Secondary
    button.Text = tostring(options.Default or "None")
    button.TextColor3 = self.Config.Theme.Text
    button.Font = Enum.Font.Code
    button.TextSize = 12
    button.Parent = keybind
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    local waiting = false
    button.MouseButton1Click:Connect(function()
        waiting = true
        button.Text = "Press a key..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard and waiting then
                waiting = false
                local key = input.KeyCode
                button.Text = tostring(key)
                self.ConfigData[options.Flag] = key
                if options.Callback then
                    options.Callback(key)
                end
                self:SaveConfig(options.Flag, key)
                self:Notify({
                    Title = options.Title,
                    Content = "Set to " .. tostring(key),
                    Duration = 2
                })
                connection:Disconnect()
            end
        end)
    end)
    self.ConfigData[options.Flag] = options.Default or Enum.KeyCode.Unknown
    return keybind
end

function GodTierUI:Notify(options)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 80)
    notification.BackgroundColor3 = self.Config.Theme.Primary
    notification.BackgroundTransparency = self.Config.Theme.Transparency
    notification.BorderSizePixel = 1
    notification.BorderColor3 = self.Config.Theme.Accent
    notification.Parent = self.NotificationFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = notification
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = options.Title
    title.TextColor3 = self.Config.Theme.Accent
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, 0, 0, 60)
    content.Position = UDim2.new(0, 0, 0, 20)
    content.BackgroundTransparency = 1
    content.Text = options.Content
    content.TextColor3 = self.Config.Theme.Text
    content.Font = Enum.Font.Code
    content.TextSize = 12
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.Parent = notification
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    spawn(function()
        wait(options.Duration or 3)
        TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0, 200, 0, 0)}):Play()
        wait(0.3)
        notification:Destroy()
    end)
end

function GodTierUI:SaveConfig(flag, value)
    self.ConfigData[flag] = value
    local success, err = pcall(function()
        writefile(self.Config.ConfigFile, HttpService:JSONEncode(self.ConfigData))
    end)
    if not success then
        self:Notify({
            Title = "Config Error",
            Content = "Failed to save config: " .. tostring(err),
            Duration = 3
        })
    end
end

function GodTierUI:LoadConfig()
    local success, content = pcall(function()
        if isfile(self.Config.ConfigFile) then
            return readfile(self.Config.ConfigFile)
        end
    end)
    if success and content then
        local success2, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success2 and data then
            self.ConfigData = data
            self:Notify({
                Title = "Config Loaded",
                Content = "Loaded saved settings",
                Duration = 2
            })
            return true
        end
    end
    self:Notify({
        Title = "Config Not Found",
        Content = "Using default settings",
        Duration = 2
    })
    return false
end

return GodTierUI
