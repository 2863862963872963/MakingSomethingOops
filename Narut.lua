
--// Ui, Modules, etc \\
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Compilerr.inc"))();
local Class, translate, Configs, Funcs, Default = unpack(Module)
local WebhookModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/2863862963872963/dawnggggggggx/refs/heads/main/Discord.luau"))();

--/// Services \\\--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Game = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local HttpService = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = Player.Backpack

--/// Settings \\\--
getgenv().Settings = {
  Automation = {
    ["Auto M1"] = false,
    ["M1 Delay"] = 0.1
  },
  DashTech = {
    ["Instaint Twisted"] = {
      Toggle = false,
      FirstDelay = 0.25,
      SecDelay = 0.25,
			ThirdDelay = 0.6,
    },
  },
  Visual = {
    ["Aiming At"] = nil,
    ["Locked Player"] = false,
  }
}

local aimlockConn

--/// Mini Funcs (utils) \\\--
local function isMobile()
    return userInput.TouchEnabled and not userInput.KeyboardEnabled
end

local function FrontDash()
	local Communicate = Players.LocalPlayer.Character.Communicate  
	Communicate:FireServer(
		{
			Dash = Enum.KeyCode.W,
			Key = Enum.KeyCode.Q,
			Goal = "KeyPress"
		}
	)
end

local function GetPlayerCombo()
  return Character:GetAttribute("Combo")
end

local function LookAt(deg, cframeTarget)
    local newCF = (cframeTarget or workspace.CurrentCamera.CFrame) * CFrame.Angles(0, math.rad(deg), 0)
    if not cframeTarget then
        workspace.CurrentCamera.CFrame = newCF
    end
    return newCF
end



function FocusCam(state)
	if state and not aimlockConn then
		local cam = workspace.CurrentCamera
		local plr = Players.LocalPlayer

		aimlockConn = RunService.RenderStepped:Connect(function()
			local myChar = plr.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			local closest, d2 = nil, math.huge
			for _, model in ipairs(workspace.Live:GetChildren()) do
				if model ~= myChar then
					local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
					if root then
						local dist2 = (root.Position - myRoot.Position).Magnitude^2
						if dist2 < d2 then
							closest, d2 = root, dist2
						end
					end
				end
			end

			if closest then
				cam.CFrame = CFrame.lookAt(cam.CFrame.Position, closest.Position, Vector3.new(0,1,0))
			end
		end)

	elseif not state and aimlockConn then
		aimlockConn:Disconnect()
		aimlockConn = nil
	end
end

--/// Big Funcs \\\--
local function InstaintTwisted()
  local combo = GetPlayerCombo()
	local cfg   = getgenv().Settings.DashTech["Instaint Twisted"]
  if combo and combo >= 5 then
    FrontDash()
    LookAt(90)
    task.wait(cfg.SecDelay)
    FocusCam(true)
    task.wait(cfg.ThirdDelay)
    FocusCam(false)
  end
end
    
--/// Windows \\\--
local Window = Compkiller.new({
	Name = "Ascent Hub",
	Keybind = "LeftAlt",
	Logo = "rbxassetid://120245531583106",
	TextSize = 15,
});

local DashTechTab = Window:DrawTab({Name = "Dash Techs", Icon = "apple", EnableScrolling = true});

local DashSection = DashTechTab:DrawSection({ Name = "Dash", Position = 'left'	});
--// Main \\

local InstTwistedToggle = DashSection:AddToggle({
	Name = "Instaint Twisted",
	Default = false,
	Callback = function(state)                 
		getgenv().Settings.DashTech["Instaint Twisted"].Toggle = state

		if state then
			task.spawn(function()
				local cfg   = getgenv().Settings.DashTech["Instaint Twisted"]
				while cfg.Toggle do               
					local combo = GetPlayerCombo()
					if combo and combo >= 5 then
						InstaintTwisted()
						task.wait(cfg.FirstDelay)          
					else
						task.wait(0.1)               
					end
				end
			end)
		end
	end
});

InstTwistedToggle.Link:AddOption():AddSlider({
	Name = "First Delay",
	Min = 0,
	Max = 1,
	Default = getgenv().Settings.DashTech["Instaint Twisted"].FirstDelay,
	Round = 1,
	Callback = function(Num)
			getgenv().Settings.DashTech["Instaint Twisted"].FirstDelay = Num 
	end,
});

InstTwistedToggle.Link:AddOption():AddSlider({
	Name = "Second Delay",
	Min = 0,
	Max = 1,
	Default = getgenv().Settings.DashTech["Instaint Twisted"].SecDelay,
	Round = 1,
	Callback = function(Num)
			getgenv().Settings.DashTech["Instaint Twisted"].SecDelay = Num 
	end,
});

InstTwistedToggle.Link:AddOption():AddSlider({
	Name = "Third Delay",
	Min = 0,
	Max = 1,
	Default = getgenv().Settings.DashTech["Instaint Twisted"].ThirdDelay,
	Round = 1,
	Callback = function(Num)
			getgenv().Settings.DashTech["Instaint Twisted"].ThirdDelay = Num 
	end,
});
