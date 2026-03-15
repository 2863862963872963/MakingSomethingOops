local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/uis-vault/refs/heads/main/Obsidian/Obsidian%20(10).lua"))()
local Window = Library:CreateWindow({
    Title = "Obsidian",
    Footer = "v2.0",
    Center = false,
    Size = UDim2.fromOffset(700, 500),
    AutoResizeMobile = false, -- use exact size on mobile, no auto-fit
    DisableToggle = true,     -- UI always visible, no keybind/button
    AutoShow = true,
})

Library:SetDPIScale(75)


local Tabs = {
    Main    = Window:AddTab({ Name = "Main",    Icon = "home" }),
    Combat  = Window:AddTab({ Name = "Combat",  Icon = "sword" }),
    Visual  = Window:AddTab({ Name = "Visual",  Icon = "eye" }),
    Player  = Window:AddTab({ Name = "Player",  Icon = "user" }),
    Misc    = Window:AddTab({ Name = "Misc",    Icon = "settings" }),
}

local Toggles = Library.Toggles
local Options = Library.Options

do
    local Left  = Tabs.Main:AddLeftGroupbox("General", { IconName = "layout-dashboard", Collapsible = true })
    local Right = Tabs.Main:AddRightGroupbox("Session", { IconName = "activity", Collapsible = true, DefaultCollapsed = false })

    Left:AddToggle("MainEnabled", {
        Text    = "Enable Script",
        Default = false,
        Icon    = "power",
        Callback = function(v) end,
    })

    Left:AddToggle("AutoFarm", {
        Text    = "Auto Farm",
        Default = false,
        Icon    = "refresh-cw",
    })

    Left:AddToggle("AntiAFK", {
        Text    = "Anti AFK",
        Default = true,
        Icon    = "clock",
    })

    Left:AddDivider()

    Left:AddSlider("WalkSpeed", {
        Text    = "Walk Speed",
        Default = 16,
        Min     = 1,
        Max     = 250,
        Icon    = "gauge",
    })

    Left:AddSlider("JumpPower", {
        Text    = "Jump Power",
        Default = 50,
        Min     = 1,
        Max     = 500,
        Icon    = "arrow-up",
    })

    Left:AddDivider()

    Left:AddInput("TargetPlayer", {
        Text        = "Target Player",
        Placeholder = "Username",
        Icon        = "user-search",
    })

    Left:AddDropdown("GameMode", {
        Text   = "Game Mode",
        Values = { "Normal", "Hardcore", "Sandbox" },
        Icon   = "gamepad-2",
    })

    Right:AddLabel({ Text = "Script loaded successfully.", Icon = "check-circle" })
    Right:AddLabel({ Text = "Server: " .. game.JobId:sub(1, 8), Icon = "server" })

    Right:AddDivider()

    Right:AddButton({
        Text = "Rejoin Server",
        Icon = "rotate-cw",
        Func = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end,
    })

    Right:AddButton({
        Text  = "Copy Job ID",
        Icon  = "clipboard",
        Func  = function()
            if setclipboard then setclipboard(game.JobId) end
        end,
    })
end

do
    local Left  = Tabs.Combat:AddLeftGroupbox("Aimbot", { IconName = "crosshair", Collapsible = true })
    local Right = Tabs.Combat:AddRightGroupbox("Prediction", { IconName = "move-3d", Collapsible = true })

    Left:AddToggle("AimbotEnabled", {
        Text    = "Aimbot",
        Default = false,
        Icon    = "crosshair",
        Risky   = true,
    })

    Left:AddToggle("AimbotVisible", {
        Text    = "Visible Check",
        Default = true,
        Icon    = "eye",
    })

    Left:AddSlider("AimbotFOV", {
        Text    = "FOV",
        Default = 90,
        Min     = 10,
        Max     = 360,
        Suffix  = "°",
        Icon    = "scan",
    })

    Left:AddSlider("AimbotSmooth", {
        Text    = "Smoothness",
        Default = 5,
        Min     = 1,
        Max     = 20,
        Icon    = "wind",
    })

    Left:AddDropdown("AimbotPart", {
        Text   = "Target Part",
        Values = { "Head", "HumanoidRootPart", "Torso" },
        Icon   = "aim",
    })

    Left:AddDivider()

    Left:AddToggle("SilentAim", {
        Text    = "Silent Aim",
        Default = false,
        Icon    = "ghost",
        Risky   = true,
    })

    Right:AddToggle("PredictionEnabled", {
        Text    = "Prediction",
        Default = false,
        Icon    = "activity",
    })

    Right:AddSlider("PredictionValue", {
        Text    = "Prediction Value",
        Default = 0,
        Min     = -1,
        Max     = 1,
        Rounding = 2,
        Icon    = "sliders-horizontal",
    })

    Right:AddDivider()

    Right:AddToggle("AutoShoot", {
        Text    = "Auto Shoot",
        Default = false,
        Icon    = "zap",
        Risky   = true,
    })

    Right:AddToggle("TriggerBot", {
        Text    = "Trigger Bot",
        Default = false,
        Icon    = "mouse-pointer-click",
    })

    Right:AddSlider("TriggerDelay", {
        Text    = "Trigger Delay (ms)",
        Default = 50,
        Min     = 0,
        Max     = 500,
        Icon    = "timer",
    })
end

do
    local Left  = Tabs.Visual:AddLeftGroupbox("ESP", { IconName = "scan-eye", Collapsible = true })
    local Right = Tabs.Visual:AddRightGroupbox("World", { IconName = "globe", Collapsible = true, DefaultCollapsed = true })

    Left:AddToggle("ESPEnabled", {
        Text    = "Player ESP",
        Default = false,
        Icon    = "users",
    })

    Left:AddToggle("ESPBoxes", {
        Text    = "Boxes",
        Default = true,
        Icon    = "square",
    })

    Left:AddToggle("ESPNames", {
        Text    = "Names",
        Default = true,
        Icon    = "tag",
    })

    Left:AddToggle("ESPDistance", {
        Text    = "Distance",
        Default = false,
        Icon    = "ruler",
    })

    Left:AddToggle("ESPHealth", {
        Text    = "Health Bar",
        Default = true,
        Icon    = "heart",
    })

    Left:AddDivider()

    Left:AddSlider("ESPMaxDistance", {
        Text    = "Max Distance",
        Default = 1000,
        Min     = 100,
        Max     = 5000,
        Suffix  = " studs",
        Icon    = "maximize",
    })

    Right:AddToggle("Fullbright", {
        Text    = "Fullbright",
        Default = false,
        Icon    = "sun",
    })

    Right:AddToggle("NoFog", {
        Text    = "No Fog",
        Default = false,
        Icon    = "cloud-off",
    })

    Right:AddSlider("Brightness", {
        Text    = "Brightness",
        Default = 1,
        Min     = 0,
        Max     = 10,
        Rounding = 1,
        Icon    = "lamp",
    })

    Right:AddDropdown("SkyBox", {
        Text   = "Sky Theme",
        Values = { "Default", "Night", "Sunset", "Storm" },
        Icon   = "cloud",
    })
end

do
    local Left  = Tabs.Player:AddLeftGroupbox("Character", { IconName = "person-standing", Collapsible = true })
    local Right = Tabs.Player:AddRightGroupbox("Movement", { IconName = "footprints", Collapsible = true })

    Left:AddToggle("Godmode", {
        Text    = "Godmode",
        Default = false,
        Icon    = "shield",
        Risky   = true,
    })

    Left:AddToggle("InfStamina", {
        Text    = "Inf Stamina",
        Default = false,
        Icon    = "battery-charging",
    })

    Left:AddToggle("AutoHeal", {
        Text    = "Auto Heal",
        Default = false,
        Icon    = "heart-pulse",
    })

    Left:AddDivider()

    Left:AddButton({
        Text = "Reset Character",
        Icon = "refresh-ccw",
        Risky = true,
        Func  = function()
            game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
        end,
    })

    Right:AddToggle("Noclip", {
        Text    = "Noclip",
        Default = false,
        Icon    = "layers",
        Risky   = true,
    })

    Right:AddToggle("Flight", {
        Text    = "Fly",
        Default = false,
        Icon    = "plane",
    })

    Right:AddSlider("FlySpeed", {
        Text    = "Fly Speed",
        Default = 50,
        Min     = 5,
        Max     = 500,
        Icon    = "wind",
    })

    Right:AddDivider()

    Right:AddToggle("InfJump", {
        Text    = "Infinite Jump",
        Default = false,
        Icon    = "chevrons-up",
    })

    Right:AddSlider("Gravity", {
        Text    = "Gravity",
        Default = 196,
        Min     = 0,
        Max     = 500,
        Icon    = "arrow-down-to-line",
    })
end

do
    local Left  = Tabs.Misc:AddLeftGroupbox("Interface", { IconName = "layout", Collapsible = true })
    local Right = Tabs.Misc:AddRightGroupbox("Danger Zone", { IconName = "triangle-alert", Collapsible = true, DefaultCollapsed = true })

    Left:AddToggle("ShowCursor", {
        Text    = "Custom Cursor",
        Default = true,
        Icon    = "mouse-pointer",
        Callback = function(v)
            Library.ShowCustomCursor = v
        end,
    })

    Left:AddDropdown("NotifySide", {
        Text   = "Notification Side",
        Values = { "Right", "Left" },
        Icon   = "bell",
        Callback = function(v)
            Library:SetNotifySide(v)
        end,
    })

    Left:AddDropdown("UITheme", {
        Text   = "Theme",
        Values = Library:GetThemeNames(),
        Default = "Obsidian",
        Icon   = "palette",
        Callback = function(v)
            Library:SetTheme(v)
        end,
    })

    Left:AddSlider("UITransparency", {
        Text     = "UI Transparency",
        Default  = 0,
        Min      = 0,
        Max      = 90,
        Rounding = 0,
        Suffix   = "%",
        Icon     = "blend",
        Callback = function(v)
            Library:SetUITransparency(v / 100)
        end,
    })

    Left:AddDivider()

    Left:AddButton({
        Text = "Test Notification",
        Icon = "bell-ring",
        Func = function()
            Library:Notify({
                Title       = "Obsidian",
                Description = "This is a test notification.",
                Icon        = "info",
                Time        = 4,
            })
        end,
    })

    Right:AddLabel({ Text = "These actions are irreversible.", Icon = "triangle-alert" })
    Right:AddDivider()

    Right:AddButton({
        Text      = "Unload Script",
        Icon      = "log-out",
        Risky     = true,
        DoubleClick = true,
        Func      = function()
            Library:Unload()
        end,
    })
end
