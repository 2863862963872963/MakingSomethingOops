    local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
    local ConfigManager = Compkiller:ConfigManager({ Directory = "Compkiller-UI", Config = "Example-Configs" });
    local Window = Compkiller.new({
        Name = "Ascent Hub",
        Keybind = "LeftAlt",
        Logo = "rbxassetid://120245531583106",
        TextSize = 15,
    });


    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local StartUi = Player.PlayerGui.HUD.InGame.VotePlaying


    local RestartMatch = ReplicatedStorage.Remote.Server.OnGame.RestartMatch
    local VotePlaying = ReplicatedStorage.Remote.Server.OnGame.Voting.VotePlaying
    local Deployment = ReplicatedStorage.Remote.Server.Units.Deployment
    local Upgrade = ReplicatedStorage.Remote.Server.Units.Upgrade
    local VoteRetry = ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry
    local VoteNext = ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext



    local config = {
        ["Game"] = {
            AutoRetry = {
                Active = false,
                Delay = 1
            },
            AutoNext = {
                Active = false,
                Delay = 1
            },
            AutoRestart = {
                Active = false,
                Method = "OnBoss", -- OnBoss/OnBoss Health Cap
                HealthCap = 100000000
            },
            AutoStart = {
                Active = false
            }
        },

        ["Auto Play"] = {
            
            AutoPlay = {
                Active = false,
                Priority = {}
            },
            AutoUpgrade = {
                Active = false,
                Priority = {}
            }

        }
    }

    local Debounce = {
        Retry = false,
        Next = false
    }



    local function isFinished()
        return Player.PlayerGui.RewardsUI.Enabled
    end


    local function Retry()
        if isFinished() and config["Game"].AutoRetry.Active and not Debounce.Retry then
            Debounce.Retry = true
            task.delay(config["Game"].AutoRetry.Delay, function()
                if isFinished() then
                    VoteRetry:FireServer()
                end
                Debounce.Retry = false
            end)
        end
    end


    local function Next()
        if isFinished() and config["Game"].AutoNext.Active and not Debounce.Next then
            Debounce.Next = true
            task.delay(config["Game"].AutoNext.Delay, function()
                if isFinished() then
                    VoteNext:FireServer()
                end
                Debounce.Next = false
            end)
        end
    end

    local function VoteStart()
        if StartUi.Visible == true and config["Game"].AutoStart.Active == true then
            VotePlaying:FireServer()
        end
    end



    local function UpgradeUnit(unit)
        Upgrade:FireServer(unpack(game:GetService("Players").LocalPlayer:WaitForChild("UnitsFolder"):WaitForChild(unit)))  
    end

    local function DeploymentUnit(unit)
        Deployment:FireServer(unpack(game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(Player.Name):WaitForChild("Collection"):WaitForChild(unit)))
    end


    local function GetUnits()
        local Units = {}
        local UnitFolder = Player.PlayerGui.UnitsLoadout.Main

        for i = 1, 6 do
            local unitLoadout = UnitFolder:FindFirstChild("UnitLoadout"..i)
            if unitLoadout and unitLoadout:FindFirstChild("UnitFrame") then
                local info = unitLoadout.UnitFrame:FindFirstChild("Info")
                if info and info:FindFirstChild("Folder") and info.Folder:FindFirstChild("Value") then
                    table.insert(Units, info.Folder.Value)
                end
            end
        end

        return Units
    end


    local GameTab = Window:DrawTab({Name = "Game", Icon = "gamepad-2", Type = "Single" });
    local MainGameSection = GameTab:DrawSection({Name = "", Position = 'left'});
    local AutoRestartSection = GameTab:DrawSection({Name = "Auto Restart", Position = 'left'});

    local AutoPlayTab = Window:DrawTab({Name = "Auto Play", Icon = "play", Type = "Single" });
    local AutoPlayFirstSection = AutoPlayTab:DrawSection({Name = "", Position = 'left'});



    MainGameSection:AddParagraph({
        Title = "oi oi oi",
        Content = "nothing"
    })


    local AutoNextToggle = MainGameSection:AddToggle({
        Name = "Auto Next ",
        Flag = "Auto Next Flag",
        Default = false,
        Callback = function(state)
            config["Game"].AutoNext.Active = state
        end,
    });


    MainGameSection:AddSlider({
        Name = "Next Delay(s)",
        Min = 0,
        Max = 100,
        Default = 1,
        Round = 1,
        Flag = "Auto Next Delay Flag",
        Callback = function(num)
            config["Game"].AutoNext.Delay = tonumber(num)
        end,
    });

    local AutoRetryToggle = MainGameSection:AddToggle({
        Name = "Auto Retry ",
        Flag = "Auto Retry Flag",
        Default = false,
        Callback = function(state)
            config["Game"].AutoRetry.Active = state
        end,
    });


    MainGameSection:AddSlider({
        Name = "Retry Delay(s)",
        Min = 0,
        Max = 100,
        Default = 1,
        Round = 1,
        Flag = "Auto Retry Delay Flag",
        Callback = function(num)
            config["Game"].AutoRetry.Delay = tonumber(num)
        end,
    });

    --// auto play tabs

    local AutoPlayToggle = AutoPlayFirstSection:AddToggle({
        Name = "Auto Play",
        Flag = "Auto Play Flag",
        Default = false,
        Callback = function(State)
            config["Auto Play"].AutoPlay.Active = State
        end,
    });

    AutoPlayToggle.Link:AddHelper({
        Text = "Will auto summon unit follow the priority >"
    })

    local SummonPriority = AutoPlayFirstSection:AddParagraph({
        Title = "Priority - Summon",
        Content = "[1] : \n[2] : \n[3] :\n[4] :\n[5] : \n[6] :"
    })

    local UnitsToPriority = AutoPlayFirstSection:AddDropdown({
        Name = "Units Summon Priority",
        Default = {"Select Unit"},
        Multi = true,
        Flag = "Units Summon Priority",
        Values = GetUnits(),
        Callback = function(Opt)
            config["Auto Play"].AutoPlay.Priority = Opt

            local content = ""
            for i = 1, 6 do
                local unitName = Opt[i] or ""
                content = content .. "[" .. i .. "] : " .. unitName .. "\n"
            end

            SummonPriority:SetContent(content)
        end
    })

