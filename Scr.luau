-- Ascent Library - Window Module
-- Supports advanced config-based window creation with dynamic sizing and future extensions

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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

    -- Topbar label
    local topbar = Instance.new("TextLabel")
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundTransparency = 1
    topbar.Text = config.Title or ("Ascent " .. AscentWindow.Version)
    topbar.TextSize = 20
    topbar.Font = Enum.Font.GothamBold
    topbar.TextColor3 = Color3.fromRGB(255, 255, 255)
    topbar.TextXAlignment = Enum.TextXAlignment.Center
    topbar.Parent = mainFrame

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
