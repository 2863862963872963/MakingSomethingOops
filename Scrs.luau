-- Ascent Library - Window Module
-- Supports advanced config-based window creation with dynamic sizing, blur, and draggable UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AscentWindow = {}
AscentWindow.Version = "v1.0.1"

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
    mainFrame.Position = UDim2.new(0.5, -baseSize.X.Offset / 2, 0.5, -baseSize.Y.Offset / 2)
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
    close.Text = "×" -- Replace with Lucide icon if needed
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.ZIndex = 2
    close.Parent = mainFrame

    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        blur.Enabled = false
    end)

    return {
        Gui = screenGui,
        Main = mainFrame,
        Topbar = topbar,
        Config = config,
    }
end

function AscentWindow:Destroy()
    local gui = PlayerGui:FindFirstChild("AscentUI")
    if gui then gui:Destroy() end
    blur.Enabled = false
end

return AscentWindow
