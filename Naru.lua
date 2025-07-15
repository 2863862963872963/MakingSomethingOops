-- DebugLib.lua – Full In-game Debug Console with Themes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DEFAULT_CFG = {
	Font = Enum.Font.SourceSans,
	Size = 14,
	Draggable = true,
	ButtonForMobile = true,
	MaxLogs = 50,
	WidthScale = 0.4,
	HeightScale = 0.3,
	Theme = "Dark"
}

local THEMES = {
	Dark = {
		BackgroundColor = Color3.fromRGB(25, 25, 25),
		TextColor = Color3.fromRGB(255, 255, 255),
		ButtonColor = Color3.fromRGB(40, 40, 40),
		Image = nil,
		Corner = 8
	},
	Light = {
		BackgroundColor = Color3.fromRGB(240, 240, 240),
		TextColor = Color3.fromRGB(30, 30, 30),
		ButtonColor = Color3.fromRGB(200, 200, 200),
		Image = nil,
		Corner = 6
	},
	Sakura = {
		BackgroundColor = Color3.fromRGB(255, 223, 235),
		TextColor = Color3.fromRGB(140, 30, 80),
		ButtonColor = Color3.fromRGB(255, 180, 210),
		Image = "rbxassetid://16862594479",
		Corner = 12
	},
	Matrix = {
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		TextColor = Color3.fromRGB(0, 255, 0),
		ButtonColor = Color3.fromRGB(20, 20, 20),
		Image = "rbxassetid://160215216",
		Corner = 0
	}
}

local function clone(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = typeof(v) == "table" and clone(v) or v
	end
	return copy
end

local function makeLabel(text, col, font, size)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, size + 6)
	lbl.TextColor3 = (typeof(col) == "Color3" and col) or Color3.new(1, 1, 1)
	lbl.Font = font or Enum.Font.SourceSans
	lbl.TextSize = size or 14
	lbl.Text = text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.RichText = true
	lbl.TextWrapped = true
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	return lbl
end

local DebugLib = {}

function DebugLib:MakeWindow(cfg)
	cfg = cfg or {}
	for k, v in pairs(DEFAULT_CFG) do
		if cfg[k] == nil then cfg[k] = v end
	end

	local theme = typeof(cfg.Theme) == "table" and cfg.Theme or THEMES[cfg.Theme] or THEMES.Dark
	for key, fallback in pairs(THEMES.Dark) do
		theme[key] = theme[key] or fallback
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "DebugUI"
	gui.ResetOnSpawn = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(cfg.WidthScale, 0, cfg.HeightScale, 0)
	frame.Position = UDim2.new((1 - cfg.WidthScale) / 2, 0, 0.1, 0)
	frame.BackgroundColor3 = theme.BackgroundColor
	frame.BorderSizePixel = 0
	if cfg.Draggable then frame.Active = true; frame.Draggable = true end

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, theme.Corner)

	local topBar = Instance.new("Frame", frame)
	topBar.Size = UDim2.new(1, 0, 0, cfg.Size + 6)
	topBar.BackgroundTransparency = 1

	local buttonRow = Instance.new("Frame", topBar)
	buttonRow.Size = UDim2.new(1, 0, 1, 0)
	buttonRow.BackgroundTransparency = 1

	local buttonLayout = Instance.new("UIListLayout", buttonRow)
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.Padding = UDim.new(0, 4)

	local listFrame = Instance.new("ScrollingFrame", frame)
	listFrame.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset)
	listFrame.Size = UDim2.new(1, 0, 1, -topBar.Size.Y.Offset)
	listFrame.ScrollBarThickness = 6
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.BackgroundTransparency = 1

	local listLayout = Instance.new("UIListLayout", listFrame)
	listLayout.Padding = UDim.new(0, 2)

	local logs = {}

	local Debug = {}

	function Debug:Print(t)
		return makeLabel("🟢 " .. t, theme.TextColor, cfg.Font, cfg.Size).Parent = listFrame
	end

	function Debug:Warn(t)
		return makeLabel("🟡 " .. t, theme.TextColor, cfg.Font, cfg.Size).Parent = listFrame
	end

	function Debug:Error(t)
		return makeLabel("🔴 " .. t, theme.TextColor, cfg.Font, cfg.Size).Parent = listFrame
	end

	function Debug:Clear()
		for _, v in ipairs(logs) do v:Destroy() end
		table.clear(logs)
	end

	function Debug:Visible(state)
		frame.Visible = state
	end

	function Debug:Button(opt)
		local b = Instance.new("TextButton", buttonRow)
		b.Size = UDim2.new(0, 100, 1, 0)
		b.Text = opt.Name or "Button"
		b.Font = cfg.Font
		b.TextSize = cfg.Size
		b.BackgroundColor3 = theme.ButtonColor
		b.TextColor3 = theme.TextColor
		if opt.Callback then b.MouseButton1Click:Connect(opt.Callback) end
		return b
	end

	function Debug:SetTheme(name)
		local newTheme = THEMES[name] or THEMES.Dark
		for k, v in pairs(THEMES.Dark) do
			newTheme[k] = newTheme[k] or v
		end
		frame.BackgroundColor3 = newTheme.BackgroundColor
	end

	return Debug
end

return DebugLib
