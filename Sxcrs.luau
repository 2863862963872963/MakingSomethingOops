-- Ascent Library - Window Module
-- Supports advanced config-based window creation with dynamic sizing, blur, draggable UI, and tab/button support

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AscentWindow = {}
AscentWindow.Version = "v1.0.0"

local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Enabled = false
blur.Name = "AscentBlur"
blur.Parent = game:GetService("Lighting")

function AscentWindow:CreateWindow(config)
    -- Remove previous UI
    local existing = PlayerGui:FindFirstChild("AscentUI")
    if existing then
        existing:Destroy()
        blur.Enabled = false
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AscentUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui

    -- Handle resizing for mobile or varying resolutions
    local baseSize = config.Size or UDim2.fromOffset(500, 400)
    if config.Resize and typeof(baseSize) == "UDim2" then
        local screenSize = workspace.CurrentCamera.ViewportSize
        local scaledX = math.clamp(baseSize.X.Offset / 1920, 0.3, 1)
        local scaledY = math.clamp(baseSize.Y.Offset / 1080, 0.3, 1)
        baseSize = UDim2.new(0, screenSize.X * scaledX, 0, screenSize.Y * scaledY)
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window"
    mainFrame.Size = baseSize
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 12)
    uicorner.Parent = mainFrame

    local uistroke = Instance.new("UIStroke")
    uistroke.Thickness = 2
    uistroke.Color = config.StrokeColor or Color3.fromRGB(80, 80, 80)
    uistroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uistroke.Parent = mainFrame

    if config.BlurBackground then
        blur.Enabled = true
    end

    -- Topbar
    local topbar = Instance.new("TextLabel")
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundTransparency = 1
    topbar.Text = config.Title or ("Ascent " .. AscentWindow.Version)
    topbar.TextSize = 20
    topbar.Font = Enum.Font.GothamBold
    topbar.TextColor3 = Color3.fromRGB(255, 255, 255)
    topbar.TextXAlignment = Enum.TextXAlignment.Center
    topbar.Parent = mainFrame

    -- Draggable logic (mobile + pc)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Close ("×") button
    local close = Instance.new("TextButton")
    close.Name = "CloseButton"
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.AnchorPoint = Vector2.new(0, 0)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.ZIndex = 2
    close.Parent = mainFrame

    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        blur.Enabled = false
    end)

    -- Tab Holder
    local tabWidth = config.TabWidth or 160

    local tabHolder = Instance.new("Frame")
    tabHolder.Name = "TabHolder"
    tabHolder.Size = UDim2.new(0, tabWidth, 1, -40)
    tabHolder.Position = UDim2.new(0, 0, 0, 40)
    tabHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    tabHolder.BorderSizePixel = 0
    tabHolder.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabHolder

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "TabContent"
    contentFrame.Size = UDim2.new(1, -tabWidth, 1, -40)
    contentFrame.Position = UDim2.new(0, tabWidth, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame

    local tabs = {}

    local window = {
        Gui = screenGui,
        Main = mainFrame,
        Topbar = topbar,
        TabHolder = tabHolder,
        ContentFrame = contentFrame,
        Tabs = tabs,
        Config = config
    }

    function window:AddTab(tabConfig)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 32)
        button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        button.Text = tabConfig.Name or "Tab"
        button.TextColor3 = Color3.fromRGB(240, 240, 240)
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 16
        button.AutoButtonColor = true
        button.BorderSizePixel = 0
        button.Parent = tabHolder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. (tabConfig.Name or "Tab")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundTransparency = 1
        page.Visible = tabConfig.Visible or false
        page.ScrollBarThickness = 4
        page.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        button.MouseButton1Click:Connect(function()
            for _, tab in pairs(tabs) do
                tab.Page.Visible = false
            end
            page.Visible = true
        end)

        local tabData = {
            Name = tabConfig.Name,
            Desc = tabConfig.Desc,
            Icon = tabConfig.Icon,
            Page = page,
            Button = button,
        }

        function tabData:AddButton(buttonConfig)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = buttonConfig.Text or "Button"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.AutoButtonColor = true
            btn.BorderSizePixel = 0
            btn.Parent = page

            local uic = Instance.new("UICorner")
            uic.CornerRadius = UDim.new(0, 6)
            uic.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if buttonConfig.Callback then
                    pcall(buttonConfig.Callback)
                end
            end)

            return btn
        end

        table.insert(tabs, tabData)
        return tabData
    end

    return window
end

function AscentWindow:Destroy()
    local gui = PlayerGui:FindFirstChild("AscentUI")
    if gui then gui:Destroy() end
    blur.Enabled = false
end

return AscentWindow
