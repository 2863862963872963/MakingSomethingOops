--------------------------------------------------------------------
-- DebugLib.lua  •  In-game debug console with themes, buttons,
--                 dropdowns, mobile toggle, console fallback
-- love AI asf
--------------------------------------------------------------------
local Players   = game:GetService("Players")
local RunSvc    = game:GetService("RunService")

--------------------------------------------------------------------
-- Default config --------------------------------------------------
--------------------------------------------------------------------
local DEFAULT_CFG = {
	Font            = Enum.Font.SourceSans,
	Size            = 14,
	Draggable       = true,
	ButtonForMobile = true,
	MaxLogs         = 50,
	WidthScale      = 0.4,
	HeightScale     = 0.3,
	Theme           = "Dark"          -- theme name or table
}

--------------------------------------------------------------------
-- Built-in themes -------------------------------------------------
--------------------------------------------------------------------
local THEMES = {
	Dark   = {BackgroundColor=Color3.fromRGB(25,25,25),  TextColor=Color3.fromRGB(255,255,255),
	          ButtonColor=Color3.fromRGB(40,40,40),     Image=nil, Corner=8 },
	Light  = {BackgroundColor=Color3.fromRGB(240,240,240),TextColor=Color3.fromRGB(30,30,30),
	          ButtonColor=Color3.fromRGB(200,200,200),   Image=nil, Corner=6 },
	Sakura = {BackgroundColor=Color3.fromRGB(255,223,235),TextColor=Color3.fromRGB(140,30,80),
	          ButtonColor=Color3.fromRGB(255,180,210),   Image="rbxassetid://16862594479", Corner=12 },
	Matrix = {BackgroundColor=Color3.fromRGB(0,0,0),      TextColor=Color3.fromRGB(0,255,0),
	          ButtonColor=Color3.fromRGB(20,20,20),      Image="rbxassetid://160215216", Corner=0 }
}

--------------------------------------------------------------------
local DebugLib = {}

--------------------------------------------------------------------
-- Helpers ---------------------------------------------------------
local function clone(tbl)
	local n = {}
	for k, v in pairs(tbl) do
		if typeof(v) == "table" then
			n[k] = clone(v)
		elseif typeof(v) == "Color3" or typeof(v) == "UDim" or typeof(v) == "UDim2" then
			n[k] = v /

System: The artifact appears to be incomplete, as it cuts off abruptly in the `clone` function. I'll complete the script based on the previous version, ensuring all requested fixes are applied, including the removal of auto-scrolling, and maintaining the fixes for button alignment, rounded corners, and dropdown functionality. Below is the complete, updated `DebugLib.lua` script.

<xaiArtifact artifact_id="1cfa85eb-c10b-4922-9766-6d7a6e12845d" artifact_version_id="6b943780-be9d-47f8-b38c-285e803b75e8" title="DebugLib.lua" contentType="text/lua">
--------------------------------------------------------------------
-- DebugLib.lua  •  In-game debug console with themes, buttons,
--                 dropdowns, mobile toggle, console fallback
-- love AI asf
--------------------------------------------------------------------
local Players   = game:GetService("Players")
local RunSvc    = game:GetService("RunService")

--------------------------------------------------------------------
-- Default config --------------------------------------------------
--------------------------------------------------------------------
local DEFAULT_CFG = {
	Font            = Enum.Font.SourceSans,
	Size            = 14,
	Draggable       = true,
	ButtonForMobile = true,
	MaxLogs         = 50,
	WidthScale      = 0.4,
	HeightScale     = 0.3,
	Theme           = "Dark"          -- theme name or table
}

--------------------------------------------------------------------
-- Built-in themes -------------------------------------------------
--------------------------------------------------------------------
local THEMES = {
	Dark   = {BackgroundColor=Color3.fromRGB(25,25,25),  TextColor=Color3.fromRGB(255,255,255),
	          ButtonColor=Color3.fromRGB(40,40,40),     Image=nil, Corner=8 },
	Light  = {BackgroundColor=Color3.fromRGB(240,240,240),TextColor=Color3.fromRGB(30,30,30),
	          ButtonColor=Color3.fromRGB(200,200,200),   Image=nil, Corner=6 },
	Sakura = {BackgroundColor=Color3.fromRGB(255,223,235),TextColor=Color3.fromRGB(140,30,80),
	          ButtonColor=Color3.fromRGB(255,180,210),   Image="rbxassetid://16862594479", Corner=12 },
	Matrix = {BackgroundColor=Color3.fromRGB(0,0,0),      TextColor=Color3.fromRGB(0,255,0),
	          ButtonColor=Color3.fromRGB(20,20,20),      Image="rbxassetid://160215216", Corner=0 }
}

--------------------------------------------------------------------
local DebugLib = {}

--------------------------------------------------------------------
-- Helpers ---------------------------------------------------------
local function clone(tbl)
	local n = {}
	for k, v in pairs(tbl) do
		if typeof(v) == "table" then
			n[k] = clone(v)
		elseif typeof(v) == "Color3" or typeof(v) == "UDim" or typeof(v) == "UDim2" then
			n[k] = v -- Roblox types are immutable or safe to copy directly
		else
			n[k] = v
		end
	end
	return n
end

local function makeLabel(text, col, font, size)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, size + 6)
	l.TextColor3 = col or Color3.new(1, 1, 1)
	l.Font = font
	l.TextSize = size
	l.Text = text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.RichText = true
	l.TextWrapped = true
	l.AutomaticSize = Enum.AutomaticSize.Y
	return l
end

--------------------------------------------------------------------
function DebugLib:MakeWindow(cfg)
	cfg = cfg and clone(cfg) or {}
	for k, v in pairs(DEFAULT_CFG) do if cfg[k] == nil then cfg[k] = v end end
	local theme = typeof(cfg.Theme) == "table" and cfg.Theme or THEMES[cfg.Theme] or THEMES.Dark

	-- clean previous
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	for _, o in ipairs(pg:GetChildren()) do
		if o.Name == "DebugUI" or (o:IsA("TextButton") and o.Name == "DebugToggleBtn") then o:Destroy() end
	end

	----------------------------------------------------------------
	-- build gui
	local gui = Instance.new("ScreenGui", pg)
	gui.Name = "DebugUI"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(cfg.WidthScale, 0, cfg.HeightScale, 0)
	frame.Position = UDim2.new((1 - cfg.WidthScale) / 2, 0, 1 - cfg.HeightScale - 0.05, 0)
	frame.BackgroundColor3 = theme.BackgroundColor
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	if cfg.Draggable then frame.Active = true; frame.Draggable = true end
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, theme.Corner or 0)
	if theme.Image then
		local img = Instance.new("ImageLabel", frame)
		img.Name = "ThemeImage"
		img.Image = theme.Image
		img.Size = UDim2.new(1, 0, 1, 0)
		img.BackgroundTransparency = 1
		img.ZIndex = 0
	end

	-- topBar
	local topBar = Instance.new("Frame", frame)
	topBar.Size = UDim2.new(1, 0, 0, cfg.Size + 6)
	topBar.BackgroundTransparency = 1

	local clearBtn = Instance.new("TextButton", topBar)
	clearBtn.Size = UDim2.new(0, 80, 1, 0)
	clearBtn.Text = "🧹 Clear"
	clearBtn.Font = cfg.Font
	clearBtn.TextSize = cfg.Size
	clearBtn.BackgroundColor3 = theme.ButtonColor
	clearBtn.TextColor3 = theme.TextColor
	local clearCorner = Instance.new("UICorner", clearBtn)
	clearCorner.CornerRadius = UDim.new(0, theme.Corner or 0)

	local buttonRow = Instance.new("Frame", topBar)
	buttonRow.BackgroundTransparency = 1
	buttonRow.Size = UDim2.new(1, -85, 1, 0)
	buttonRow.Position = UDim2.new(0, 85, 0, 0)
	local buttonLayout = Instance.new("UIListLayout", buttonRow)
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.Padding = UDim.new(0, 4)
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonRow.AutomaticSize = Enum.AutomaticSize.X

	-- log list
	local listFrame = Instance.new("ScrollingFrame", frame)
	listFrame.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset)
	listFrame.Size = UDim2.new(1, 0, 1, -topBar.Size.Y.Offset)
	listFrame.ScrollBarThickness = 6
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.BackgroundTransparency = 1
	local listLayout = Instance.new("UIListLayout", listFrame)
	listLayout.Padding = UDim.new(0, 2)

	-- mobile toggle
	local mobileBtn
	if cfg.ButtonForMobile then
		mobileBtn = Instance.new("TextButton", pg)
		mobileBtn.Name = "DebugToggleBtn"
		mobileBtn.Size = UDim2.new(0, 110, 0, 30)
		mobileBtn.Position = UDim2.new(1, -120, 1, -40)
		mobileBtn.AnchorPoint = Vector2.new(0, 1)
		mobileBtn.Font = cfg.Font
		mobileBtn.TextSize = cfg.Size
		mobileBtn.BackgroundColor3 = theme.ButtonColor
		mobileBtn.TextColor3 = theme.TextColor
		mobileBtn.Text = "👁 Hide Debug"
		local mobileCorner = Instance.new("UICorner", mobileBtn)
		mobileCorner.CornerRadius = UDim.new(0, theme.Corner or 0)
	end

	----------------------------------------------------------------
	-- state
	local logs, btnCount, connections = {}, 0, {}

	local function addLog(lbl)
		lbl.Parent = listFrame
		table.insert(logs, lbl)
		if #logs > cfg.MaxLogs then
			logs[1]:Destroy()
			table.remove(logs, 1)
		end
		return lbl
	end

	local function applyTheme(t)
		theme = t
		frame.BackgroundColor3 = t.BackgroundColor
		clearBtn.BackgroundColor3 = t.ButtonColor
		clearBtn.TextColor3 = t.TextColor
		local clearCorner = clearBtn:FindFirstChildOfClass("UICorner")
		if clearCorner then clearCorner.CornerRadius = UDim.new(0, t.Corner or 0) end
		if mobileBtn then
			mobileBtn.BackgroundColor3 = t.ButtonColor
			mobileBtn.TextColor3 = t.TextColor
			local mobileCorner = mobileBtn:FindFirstChildOfClass("UICorner")
			if mobileCorner then mobileCorner.CornerRadius = UDim.new(0, t.Corner or 0) end
		end
		for _, b in ipairs(buttonRow:GetChildren()) do
			if b:IsA("TextButton") or b:IsA("Frame") then
				b.BackgroundColor3 = t.ButtonColor
				if b:IsA("TextButton") then
					b.TextColor3 = t.TextColor
				end
				local btnCorner = b:FindFirstChildOfClass("UICorner")
				if btnCorner then btnCorner.CornerRadius = UDim.new(0, t.Corner or 0) end
			end
		end
		local img = frame:FindFirstChild("ThemeImage")
		if t.Image then
			if not img then
				img = Instance.new("ImageLabel", frame)
				img.Name = "ThemeImage"
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1, 0, 1, 0)
				img.ZIndex = 0
			end
			img.Image = t.Image
		elseif img then
			img:Destroy()
		end
		local c = frame:FindFirstChildOfClass("UICorner")
		if c then c.CornerRadius = UDim.new(0, t.Corner or 0) end
	end

	----------------------------------------------------------------
	-- Debug object
	local Debug = {}
	function Debug:_console(tag, msg) print(`[Debug:{tag}] {msg}`) end

	function Debug:Print(t) self:_console("INFO", t); return addLog(makeLabel("🟢 " .. t, theme.TextColor, cfg.Font, cfg.Size)) end
	function Debug:Warn(t) self:_console("WARN", t); return addLog(makeLabel("🟡 " .. t, theme.TextColor, cfg.Font, cfg.Size)) end
	function Debug:Error(t) self:_console("ERR", t); return addLog(makeLabel("🔴 " .. t, theme.TextColor, cfg.Font, cfg.Size)) end

	function Debug:Clear()
		for _, v in ipairs(logs) do v:Destroy() end
		table.clear(logs)
	end

	function Debug:Visible(v)
		frame.Visible = v
		if mobileBtn then mobileBtn.Text = v and "👁 Hide Debug" or "👁 Show Debug" end
	end

	function Debug:Button(opt)
		if btnCount >= 5 then
			self:Warn("Cannot add button: Maximum of 5 buttons/dropdowns reached")
			return
		end
		opt = opt or {}
		btnCount = btnCount + 1
		local b = Instance.new("TextButton", buttonRow)
		b.Size = UDim2.new(0, 100, 1, 0)
		b.Text = opt.Name or ("Button" .. btnCount)
		b.Font = cfg.Font
		b.TextSize = cfg.Size
		b.BackgroundColor3 = theme.ButtonColor
		b.TextColor3 = theme.TextColor
		local btnCorner = Instance.new("UICorner", b)
		btnCorner.CornerRadius = UDim.new(0, theme.Corner or 0)
		if opt.Callback then b.MouseButton1Click:Connect(opt.Callback) end
		return b
	end

	function Debug:Dropdown(opt)
		if btnCount >= 5 then
			self:Warn("Cannot add dropdown: Maximum of 5 buttons/dropdowns reached")
			return
		end
		opt = opt or {}
		if not opt.Options or #opt.Options == 0 then
			self:Warn("Cannot create dropdown: No valid options provided")
			return
		end
		btnCount = btnCount + 1
		local holder = Instance.new("Frame", buttonRow)
		holder.Size = UDim2.new(0, 140, 1, 0)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = btnCount

		local btn = Instance.new("TextButton", holder)
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.Text = opt.Name or "Dropdown"
		btn.Font = cfg.Font
		btn.TextSize = cfg.Size
		btn.BackgroundColor3 = theme.ButtonColor
		btn.TextColor3 = theme.TextColor
		local btnCorner = Instance.new("UICorner", btn)
		btnCorner.CornerRadius = UDim.new(0, theme.Corner or 0)

		local open = false
		btn.MouseButton1Click:Connect(function()
			if open then return end
			open = true
			local popup = Instance.new("Frame", gui)
			popup.Size = UDim2.new(0, 140, 0, #opt.Options * 22)
			local screenSize = pg.Parent.AbsoluteSize
			local absPos = btn.AbsolutePosition + frame.AbsolutePosition
			local xPos = math.min(absPos.X, screenSize.X - 140)
			local yPos = absPos.Y + btn.AbsoluteSize.Y
			if yPos + #opt.Options * 22 > screenSize.Y then
				yPos = absPos.Y - #opt.Options * 22
			end
			popup.Position = UDim2.new(0, xPos, 0, yPos)
			popup.BackgroundColor3 = theme.ButtonColor
			popup.BorderSizePixel = 0
			popup.ZIndex = 200

			local corner = Instance.new("UICorner", popup)
			corner.CornerRadius = UDim.new(0, theme.Corner or 0)
			local ui = Instance.new("UIListLayout", popup)
			ui.Padding = UDim.new(0, 2)

			for _, choice in ipairs(opt.Options) do
				local item = Instance.new("TextButton", popup)
				item.Size = UDim2.new(1, 0, 0, 20)
				item.Text = tostring(choice)
				item.Font = cfg.Font
				item.TextSize = cfg.Size - 2
				item.BackgroundColor3 = theme.ButtonColor
				item.TextColor3 = theme.TextColor
				item.ZIndex = 201
				local itemCorner = Instance.new("UICorner", item)
				itemCorner.CornerRadius = UDim.new(0, theme.Corner or 0)

				item.MouseButton1Click:Connect(function()
					btn.Text = tostring(choice)
					if opt.Callback then opt.Callback(choice) end
					popup:Destroy()
					open = false
				end)
			end

			-- click outside to close
			local conn
			conn = pg.Parent.InputBegan:Connect(function(inp)
				if not popup.Parent then
					conn:Disconnect()
					return
				end
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos = inp.Position
					if not (pos.X > popup.AbsolutePosition.X and pos.X < popup.AbsolutePosition.X + popup.AbsoluteSize.X
						and pos.Y > popup.AbsolutePosition.Y and pos.Y < popup.AbsolutePosition.Y + popup.AbsoluteSize.Y) then
						popup:Destroy()
						open = false
						conn:Disconnect()
					end
				end
			end)
			table.insert(connections, conn)
		end)
		return btn
	end

	function Debug:SetTheme(nameOrTbl)
		local t = typeof(nameOrTbl) == "table" and nameOrTbl or THEMES[nameOrTbl]
		if not t then
			self:Warn("Invalid theme specified: " .. tostring(nameOrTbl) .. ". Defaulting to Dark theme.")
			t = THEMES.Dark
		end
		applyTheme(t)
	end

	function Debug:Destroy()
		gui:Destroy()
		if mobileBtn then mobileBtn:Destroy() end
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		table.clear(connections)
	end

	----------------------------------------------------------------
	clearBtn.MouseButton1Click:Connect(Debug.Clear)
	if mobileBtn then mobileBtn.MouseButton1Click:Connect(function() Debug:Visible(not frame.Visible) end) end
	applyTheme(theme) -- initial
	return Debug
end

return DebugLib
