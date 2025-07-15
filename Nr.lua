local DebugLib = {}
DebugLib.__index = DebugLib

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Destroy old instance
if CoreGui:FindFirstChild("DebugWindow") then
	CoreGui.DebugWindow:Destroy()
end

-- Themes
local ThemeColors = {
	Dark = {
		Background = Color3.fromRGB(20, 20, 20),
		TextColor = Color3.fromRGB(255, 255, 255),
		BorderColor = Color3.fromRGB(80, 80, 80),
		InfoColor = Color3.fromRGB(120, 200, 255),
		WarnColor = Color3.fromRGB(255, 100, 100),
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 240),
		TextColor = Color3.fromRGB(0, 0, 0),
		BorderColor = Color3.fromRGB(180, 180, 180),
		InfoColor = Color3.fromRGB(0, 120, 255),
		WarnColor = Color3.fromRGB(200, 0, 0),
	},
	Matrix = {
		Background = Color3.fromRGB(10, 10, 10),
		TextColor = Color3.fromRGB(0, 255, 0),
		BorderColor = Color3.fromRGB(0, 80, 0),
		InfoColor = Color3.fromRGB(0, 255, 100),
		WarnColor = Color3.fromRGB(255, 0, 0),
	},
	Sakura = {
		Background = Color3.fromRGB(255, 240, 245),
		TextColor = Color3.fromRGB(70, 20, 40),
		BorderColor = Color3.fromRGB(200, 160, 180),
		InfoColor = Color3.fromRGB(140, 40, 80),
		WarnColor = Color3.fromRGB(200, 50, 50),
	}
}

function DebugLib:MakeWindow(config)
	local self = setmetatable({}, DebugLib)
	config = config or {}

	self.Theme = ThemeColors[config.Theme] or ThemeColors.Dark
	self.Font = config.Font or Enum.Font.Code
	self.Size = config.Size or 14

	self.Gui = Instance.new("ScreenGui", CoreGui)
	self.Gui.Name = "DebugWindow"
	self.Gui.IgnoreGuiInset = true
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame
	self.Frame = Instance.new("Frame", self.Gui)
	self.Frame.Size = UDim2.new(0, 500, 0, 300)
	self.Frame.Position = UDim2.new(0, 50, 0, 100)
	self.Frame.BackgroundColor3 = self.Theme.Background
	self.Frame.BorderColor3 = self.Theme.BorderColor
	self.Frame.Name = "Window"
	self.Frame.Active = true
	self.Frame.Draggable = true

	local UIList = Instance.new("UIListLayout", self.Frame)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 4)

	self.Logs = {}

	-- Clear Button
	local clearBtn = Instance.new("TextButton", self.Frame)
	clearBtn.Size = UDim2.new(1, 0, 0, 20)
	clearBtn.Text = "❌ Clear Log"
	clearBtn.TextColor3 = self.Theme.WarnColor
	clearBtn.BackgroundColor3 = self.Theme.BorderColor
	clearBtn.Font = self.Font
	clearBtn.TextSize = self.Size
	clearBtn.LayoutOrder = 999

	clearBtn.MouseButton1Click:Connect(function()
		for _, v in ipairs(self.Logs) do v:Destroy() end
		self.Logs = {}
	end)

	return self
end

function DebugLib:Print(text)
	local label = self:_makeLabel(text, self.Theme.InfoColor or Color3.fromRGB(255,255,255))
	label.Text = os.date("%X") .. " -- [INFO] " .. text
end

function DebugLib:Warn(text)
	local label = self:_makeLabel(text, self.Theme.WarnColor or Color3.fromRGB(255, 100, 100))
	label.Text = os.date("%X") .. " -- " .. text
end

function DebugLib:_makeLabel(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Text = text
	label.Font = self.Font
	label.TextSize = self.Size
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = self.Frame
	table.insert(self.Logs, label)
	return label
end

function DebugLib:Button(opt)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 20)
	button.BackgroundColor3 = self.Theme.BorderColor
	button.TextColor3 = self.Theme.TextColor or Color3.fromRGB(255,255,255)
	button.Text = opt.Name or "Button"
	button.Font = self.Font
	button.TextSize = self.Size
	button.Parent = self.Frame
	button.MouseButton1Click:Connect(opt.Callback or function() end)
	return button
end

function DebugLib:Dropdown(opt)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = self.Theme.TextColor
	label.Text = opt.Name or "Dropdown"
	label.Font = self.Font
	label.TextSize = self.Size
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = self.Frame

	local drop = Instance.new("TextButton")
	drop.Size = UDim2.new(1, 0, 0, 20)
	drop.BackgroundColor3 = self.Theme.BorderColor
	drop.TextColor3 = self.Theme.TextColor
	drop.Text = opt.Default or "Select"
	drop.Font = self.Font
	drop.TextSize = self.Size
	drop.Parent = self.Frame

	drop.MouseButton1Click:Connect(function()
		local next = table.find(opt.Options, drop.Text) or 0
		local sel = opt.Options[next % #opt.Options + 1]
		drop.Text = sel
		if opt.Callback then opt.Callback(sel) end
	end)
end

function DebugLib:SetTheme(themeName)
	local theme = ThemeColors[themeName]
	if theme then
		self.Theme = theme
		self.Frame.BackgroundColor3 = theme.Background
		self.Frame.BorderColor3 = theme.BorderColor
		self:Print("Theme updated.")
	else
		self:Warn("Theme '"..themeName.."' not found.")
	end
end

function DebugLib:Visible(bool)
	self.Gui.Enabled = bool
end

return DebugLib
