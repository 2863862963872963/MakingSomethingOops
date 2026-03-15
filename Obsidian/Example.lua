local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title   = "Example",
    Footer  = "v3.0",
    Icon    = "layers",
    Center  = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,

    -- Custom toggle button (variant 2 = icon button, always visible)
    ToggleUiVariant = 2,
    ToggleUiButton = {
        Shape       = "Circle",
        Size        = UDim2.fromOffset(44, 44),
        Position    = UDim2.fromOffset(8, 8),
        Side        = "Left",
        OpenIcon    = "x",
        ClosedIcon  = "menu",
        ShowLock    = true,
    },
})

Library:SetTheme("Midnight")

Library:SetStyle({
    AccentStrip          = true,
    HeaderGradient       = true,
    CollapseAnimation    = true,
    AnimationSpeed       = 0.12,
    ElementIconSize      = 16,
    WindowTransparency   = 0,
    GroupboxTransparency = 0,
})

local Tabs = {
    Main     = Window:AddTab("Main",     "home"),
    Combat   = Window:AddTab("Combat",   "sword"),
    Visual   = Window:AddTab("Visual",   "eye"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- Built-in settings page with config profiles baked in
Tabs.Settings:AddSettingPage()

-- MAIN TAB
do
    local Left  = Tabs.Main:AddLeftGroupbox("Movement", "footprints")
    local Right = Tabs.Main:AddRightGroupbox("World", "globe", { Collapsed = true })

    Left:AddToggle("SpeedEnabled", {
        Text = "Speed Hack", Icon = "zap", Default = false,
        Callback = function(v)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and Toggles.WalkSpeed.Value or 16
        end,
    })
    Left:AddSlider("WalkSpeed", {
        Text = "Walk Speed", Icon = "gauge",
        Default = 16, Min = 16, Max = 250, Rounding = 0,
    })
    Left:AddSlider("JumpPower", {
        Text = "Jump Power", Icon = "chevrons-up",
        Default = 50, Min = 50, Max = 300, Rounding = 0,
    })

    Left:AddFadeDivider()
    Left:AddToggle("NoclipEnabled", { Text = "Noclip", Icon = "ghost", Default = false })
    Left:AddToggle("FlyEnabled",    { Text = "Fly",    Icon = "wind",  Default = false })

    Left:AddFadeDivider("Actions")
    Left:AddButton({
        Text = "Reset Position", Icon = "rotate-ccw",
        Func = function()
            local char = game.Players.LocalPlayer.Character
            if char then char:MoveTo(Vector3.new(0, 5, 0)) end
        end,
    })

    Right:AddToggle("Fullbright", {
        Text = "Fullbright", Icon = "sun", Default = false,
        Callback = function(v) game.Lighting.Brightness = v and 10 or 1 end,
    })
    Right:AddSlider("TimeOfDay", {
        Text = "Time of Day", Icon = "clock",
        Default = 14, Min = 0, Max = 24, Rounding = 1,
        Callback = function(v) game.Lighting.ClockTime = v end,
    })
end

-- COMBAT TAB
do
    local Left  = Tabs.Combat:AddLeftGroupbox("Aimbot", "crosshair")
    local Right = Tabs.Combat:AddRightGroupbox("Misc", "shield", { Collapsed = true })

    Left:AddToggle("AimbotEnabled", { Text = "Aimbot",     Icon = "target",      Default = false })
    Left:AddSlider("AimbotFOV",     { Text = "FOV",        Icon = "maximize-2",  Default = 90,  Min = 10, Max = 360, Suffix = "°" })
    Left:AddSlider("AimbotSmooth",  { Text = "Smoothness", Icon = "activity",    Default = 5,   Min = 1,  Max = 20,  Rounding = 1 })
    Left:AddDropdown("AimbotPart",  { Text = "Target Part", Values = { "Head", "HumanoidRootPart", "Torso" }, Default = "Head" })
    Left:AddFadeDivider("Risky")
    Left:AddToggle("SilentAim", { Text = "Silent Aim", Icon = "eye-off", Default = false, Risky = true })

    Right:AddToggle("InfiniteAmmo", { Text = "Infinite Ammo", Icon = "package",      Default = false })
    Right:AddToggle("AutoReload",   { Text = "Auto Reload",   Icon = "refresh-cw",   Default = false })
    Right:AddSlider("Recoil",       { Text = "Recoil Reduction", Icon = "trending-down", Default = 0, Min = 0, Max = 100, Suffix = "%" })
end

-- VISUAL TAB
do
    local Left  = Tabs.Visual:AddLeftGroupbox("ESP",   "scan")
    local Right = Tabs.Visual:AddRightGroupbox("Misc", "sparkles")

    Left:AddToggle("ESPEnabled",   { Text = "ESP",       Icon = "scan-eye", Default = false })
    Left:AddToggle("ESPBoxes",     { Text = "Boxes",     Icon = "box",      Default = true  })
    Left:AddToggle("ESPNames",     { Text = "Names",     Icon = "type",     Default = true  })
    Left:AddToggle("ESPHealthbar", { Text = "Healthbar", Icon = "heart",    Default = true  })
    Left:AddFadeDivider("Colors")
    Left:AddColorPicker("ESPColor", { Text = "ESP Color", Default = Color3.fromRGB(255, 50, 50) })

    Right:AddToggle("ChamsEnabled",   { Text = "Chams",         Icon = "sparkles", Default = false })
    Right:AddToggle("ChamsWallcheck", { Text = "Through Walls", Icon = "layers",   Default = false })
    Right:AddColorPicker("ChamsColor", { Text = "Chams Color",  Default = Color3.fromRGB(100, 180, 255) })
end

-- Demo notifications on load
task.delay(1, function()
    -- Normal timed notification (click to dismiss)
    Library:Notify({
        Title       = "Welcome",
        Description = "Click anywhere on this to dismiss early.",
        Icon        = "check-circle",
        Time        = 6,
        ClickDismiss = true,
    })
end)

task.delay(2.5, function()
    -- Progress bar notification (manually driven)
    local N = Library:Notify({
        Title       = "Loading Assets",
        Description = "Downloading resources...",
        Icon        = "download",
        Style       = "Progress",
    })

    task.spawn(function()
        for i = 1, 10 do
            task.wait(0.3)
            N:SetProgress(i / 10)
            if i == 10 then
                N:ChangeDescription("Done!")
            end
        end
    end)
end)

-- Auto-load default config on start if it exists
task.defer(function()
    Library:LoadConfig("default")
end)
