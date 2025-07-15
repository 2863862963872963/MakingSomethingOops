-- DebugLib.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local DEFAULT_CONFIG = {
	Font = Enum.Font.SourceSans,
	Size = 14,
	Draggable = true,
	ButtonForMobile = true,
	MaxLogs = 50,
	WidthScale = 0.4,
	HeightScale = 0.3
}

local DebugLib = {}

local function makeLabel(text, color, font, size)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, size + 6)
	lbl.TextColor3 = color
	lbl.Font = font
	lbl.TextSize = size
	lbl.Text = text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.RichText = true
	lbl.TextWrapped = true
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	return lbl
end

function DebugLib:MakeWindow(cfg)
	cfg = table.clone(cfg or {})
	for k, v in pairs(DEFAULT_CONFIG) do
		if cfg[k] == nil then cfg[k] = v end
	end

	-- Destroy old Debug UI
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("DebugUI")
	if old then old:Destroy() end

	for _, v in ipairs(playerGui:GetChildren()) do
		if v:IsA("TextButton") and v.Text:match("Debug") then
			v:Destroy()
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "DebugUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(cfg.WidthScale, 0, cfg.HeightScale, 0)
	frame.Position = UDim2.new((1 - cfg.WidthScale) / 2, 0, 1 - cfg.HeightScale - 0.05, 0)
	frame.ClipsDescendants = true
	frame.Parent = gui

	if cfg.Draggable then
		frame.Active = true
		frame.Draggable = true
	end

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, cfg.Size + 6)
	topBar.BackgroundTransparency = 1
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.Name = "TopBar"
	topBar.Parent = frame

	local clearBtn = Instance.new("TextButton")
	clearBtn.Text = "🧹 Clear Logs"
	clearBtn.Font = cfg.Font
	clearBtn.TextSize = cfg.Size
	clearBtn.Size = UDim2.new(0, 100, 1, 0)
	clearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	clearBtn.TextColor3 = Color3.new(1, 1, 1)
	clearBtn.AutoButtonColor = true
	clearBtn.Position = UDim2.new(0, 0, 0, 0)
	clearBtn.Parent = topBar

	local buttonRow = Instance.new("Frame")
	buttonRow.BackgroundTransparency = 1
	buttonRow.Size = UDim2.new(1, -105, 1, 0)
	buttonRow.Position = UDim2.new(0, 105, 0, 0)
	buttonRow.Parent = topBar

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 5)
	buttonLayout.Parent = buttonRow

	local listFrame = Instance.new("ScrollingFrame")
	listFrame.BackgroundTransparency = 1
	listFrame.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset)
	listFrame.Size = UDim2.new(1, 0, 1, -topBar.Size.Y.Offset)
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.ScrollBarThickness = 6
	listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = listFrame

	local mobileBtn
	if cfg.ButtonForMobile then
		mobileBtn = Instance.new("TextButton")
		mobileBtn.Size = UDim2.new(0, 110, 0, 30)
		mobileBtn.Position = UDim2.new(1, -120, 1, -40)
		mobileBtn.AnchorPoint = Vector2.new(0, 1)
		mobileBtn.Text = "👁 Hide Debug"
		mobileBtn.Font = cfg.Font
		mobileBtn.TextSize = cfg.Size
		mobileBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		mobileBtn.TextColor3 = Color3.new(1, 1, 1)
		mobileBtn.Parent = gui
	end

	local logs = {}
	local buttonCount = 0

	local function clearLogs()
		for _, v in ipairs(logs) do v:Destroy() end
		table.clear(logs)
	end

	clearBtn.MouseButton1Click:Connect(clearLogs)

	local Debug = {}

	local function addLog(lbl)
		lbl.Parent = listFrame
		table.insert(logs, lbl)
		if #logs > cfg.MaxLogs then
			logs[1]:Destroy()
			table.remove(logs, 1)
		end
		RunService.RenderStepped:Wait()
		listFrame.CanvasPosition = Vector2.new(0, listFrame.AbsoluteCanvasSize.Y)
		return lbl
	end

	-- Always log to console too
	function Debug:_console(tag, ...)
		local msg = string.format("[%s] %s", tag, table.concat({...}, " "))
		print(msg)
	end

	function Debug:Print(txt)
		self:_console("INFO", txt)
		return addLog(makeLabel("🟢 " .. tostring(txt), Color3.fromRGB(180, 255, 180), cfg.Font, cfg.Size))
	end

	function Debug:Warn(txt)
		self:_console("WARN", txt)
		return addLog(makeLabel("🟡 " .. tostring(txt), Color3.fromRGB(255, 255, 0), cfg.Font, cfg.Size))
	end

	function Debug:Error(txt)
		self:_console("ERR", txt)
		return addLog(makeLabel("🔴 " .. tostring(txt), Color3.fromRGB(255, 100, 100), cfg.Font, cfg.Size))
	end

	function Debug:Clear()
		clearLogs()
	end

	function Debug:Visible(state)
		frame.Visible = state
		if mobileBtn then
			mobileBtn.Text = state and "👁 Hide Debug" or "👁 Show Debug"
		end
	end

	function Debug:Button(opts)
		if buttonCount >= 5 then return nil end
		opts = opts or {}
		local btn = Instance.new("TextButton")
		btn.Text = opts.Name or ("Button " .. tostring(buttonCount + 1))
		btn.Font = cfg.Font
		btn.TextSize = cfg.Size
		btn.Size = UDim2.new(0, 100, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.AutoButtonColor = true
		btn.Parent = buttonRow
		buttonCount += 1
		if opts.Callback then
			btn.MouseButton1Click:Connect(opts.Callback)
		end
		return btn
	end

	function Debug:Destroy()
		gui:Destroy()
		if mobileBtn then mobileBtn:Destroy() end
	end

	if mobileBtn then
		mobileBtn.MouseButton1Click:Connect(function()
			Debug:Visible(not frame.Visible)
		end)
	end

	return Debug
end

return DebugLib
