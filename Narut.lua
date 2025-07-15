-- DebugLib.lua  •  lightweight in‑game debug console
-- API:
--   local DebugLib = require(...) or loadstring(...)
--   local Debug = DebugLib:MakeWindow(cfg)
--   Debug:Print / :Warn / :Error
--   Debug:Button{ Name, Callback }      -- max 5
--   Debug:Visible(true|false)
--   Debug:Clear()
--   Debug:Destroy()

--------------------------------------------------------------------
-- ░█▀▀░█▀▄░█▀▀░█▀▀░█░█░█░░░█▀█
-- ░█▀▀░█░█░█▀▀░█░░░█░█░█░░░█░█
-- ░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀
--------------------------------------------------------------------
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local DEFAULT_CONFIG = {
	Font            = Enum.Font.SourceSans,
	Size            = 14,
	Draggable       = true,
	ButtonForMobile = true,
	MaxLogs         = 50,
	WidthScale      = 0.4,
	HeightScale     = 0.3
}

--------------------------------------------------------------------
local DebugLib = {}

-- helper to create a text label + setters
local function makeLabel(text, color, font, size)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size          = UDim2.new(1, 0, 0, size)
	lbl.TextColor3    = color
	lbl.Font          = font
	lbl.TextSize      = size
	lbl.Text          = text
	lbl.TextXAlignment= Enum.TextXAlignment.Left
	lbl.RichText      = true

	function lbl:SetText(t)   self.Text = t end
	function lbl:SetColor(c)  self.TextColor3 = c end
	function lbl:Remove()     self:Destroy() end

	return lbl
end

--------------------------------------------------------------------
function DebugLib:MakeWindow(cfg)
	cfg = table.clone(cfg or {})
	for k,v in pairs(DEFAULT_CONFIG) do
		if cfg[k] == nil then cfg[k] = v end
	end

	-------------------------------------------------- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "DebugUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	-------------------------------------------------- Main frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	frame.BorderSizePixel  = 0
	frame.Size             = UDim2.new(cfg.WidthScale, 0, cfg.HeightScale, 0)
	frame.Position         = UDim2.new((1-cfg.WidthScale)/2, 0, 1-cfg.HeightScale-0.05, 0)
	frame.ClipsDescendants = true
	frame.Parent           = gui

	if cfg.Draggable then
		frame.Active   = true
		frame.Draggable= true
	end

	-------------------------------------------------- Button row
	local buttonRow  = Instance.new("Frame")
	buttonRow.Size   = UDim2.new(1,0,0,cfg.Size+6)
	buttonRow.BackgroundTransparency = 1
	buttonRow.Parent = frame

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0,5)
	buttonLayout.Parent = buttonRow

	-------------------------------------------------- Clear button
	local clearBtn = Instance.new("TextButton")
	clearBtn.Text            = "🧹 Clear Logs"
	clearBtn.Font            = cfg.Font
	clearBtn.TextSize        = cfg.Size
	clearBtn.Size            = UDim2.new(0,100,1,0)
	clearBtn.BackgroundColor3= Color3.fromRGB(40,40,40)
	clearBtn.TextColor3      = Color3.new(1,1,1)
	clearBtn.AutoButtonColor = true
	clearBtn.Parent          = buttonRow

	-------------------------------------------------- Log list frame
	local listFrame = Instance.new("Frame")
	listFrame.BackgroundTransparency = 1
	listFrame.Position = UDim2.new(0,0,0,buttonRow.Size.Y.Offset)
	listFrame.Size     = UDim2.new(1,0,1,-buttonRow.Size.Y.Offset)
	listFrame.Parent   = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding   = UDim.new(0,2)
	listLayout.Parent    = listFrame

	-------------------------------------------------- Mobile toggle button
	local mobileBtn
	if cfg.ButtonForMobile then
		mobileBtn = Instance.new("TextButton")
		mobileBtn.Size            = UDim2.new(0,110,0,30)
		mobileBtn.Position        = UDim2.new(1,-120,1,-40)
		mobileBtn.AnchorPoint     = Vector2.new(0,1)
		mobileBtn.Text            = "👁 Hide Debug"
		mobileBtn.Font            = cfg.Font
		mobileBtn.TextSize        = cfg.Size
		mobileBtn.BackgroundColor3= Color3.fromRGB(40,40,40)
		mobileBtn.TextColor3      = Color3.new(1,1,1)
		mobileBtn.Parent          = gui
	end

	-------------------------------------------------- Internal state
	local logs = {}
	local buttonCount = 0

	-------------------------------------------------- Clear handler
	local function clearLogs()
		for _,v in ipairs(logs) do v:Destroy() end
		table.clear(logs)
	end
	clearBtn.MouseButton1Click:Connect(clearLogs)

	-------------------------------------------------- Public API
	local Debug = {}

	local function addLog(lbl)
		lbl.Parent = listFrame
		table.insert(logs,lbl)
		if #logs > cfg.MaxLogs then
			logs[1]:Destroy()
			table.remove(logs,1)
		end
		return lbl
	end

	function Debug:Print(txt)
		return addLog(makeLabel("🟢 "..tostring(txt), Color3.fromRGB(180,255,180), cfg.Font, cfg.Size))
	end
	function Debug:Warn(txt)
		return addLog(makeLabel("🟡 "..tostring(txt), Color3.fromRGB(255,255,0), cfg.Font, cfg.Size))
	end
	function Debug:Error(txt)
		return addLog(makeLabel("🔴 "..tostring(txt), Color3.fromRGB(255,100,100), cfg.Font, cfg.Size))
	end

	function Debug:Clear() clearLogs() end

	-- Visibility toggle
	function Debug:Visible(state:boolean)
		frame.Visible = state
		if mobileBtn then
			mobileBtn.Text = state and "👁 Hide Debug" or "👁 Show Debug"
		end
	end

	-- Extra buttons (max 5)
	function Debug:Button(opts)
		if buttonCount >= 5 then return nil end
		opts = opts or {}
		local btn = Instance.new("TextButton")
		btn.Text            = opts.Name or ("Button "..tostring(buttonCount+1))
		btn.Font            = cfg.Font
		btn.TextSize        = cfg.Size
		btn.Size            = UDim2.new(0,100,1,0)
		btn.BackgroundColor3= Color3.fromRGB(40,40,40)
		btn.TextColor3      = Color3.new(1,1,1)
		btn.AutoButtonColor = true
		btn.Parent          = buttonRow
		buttonCount += 1
		if opts.Callback then btn.MouseButton1Click:Connect(opts.Callback) end
		return btn
	end

	function Debug:Destroy()
		gui:Destroy()
		if mobileBtn then mobileBtn:Destroy() end
	end

	-- Wire mobile toggle button
	if mobileBtn then
		mobileBtn.MouseButton1Click:Connect(function()
			Debug:Visible(not frame.Visible)
		end)
	end

	return Debug
end

return DebugLib
