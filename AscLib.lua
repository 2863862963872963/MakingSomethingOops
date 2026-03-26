local AscLib = {}
AscLib.__index = AscLib

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
	Background  = Color3.fromRGB(15,  15,  19),
	Surface     = Color3.fromRGB(22,  22,  29),
	Surface2    = Color3.fromRGB(29,  29,  39),
	Surface3    = Color3.fromRGB(37,  37,  51),
	Surface4    = Color3.fromRGB(46,  46,  64),
	Accent      = Color3.fromRGB(124, 92,  252),
	AccentLight = Color3.fromRGB(157, 130, 255),
	AccentDark  = Color3.fromRGB(90,  63,  212),
	Text        = Color3.fromRGB(240, 238, 255),
	TextMuted   = Color3.fromRGB(155, 150, 188),
	TextDim     = Color3.fromRGB(94,  90,  122),
	Success     = Color3.fromRGB(61,  214, 140),
	Warning     = Color3.fromRGB(245, 166, 35),
	Danger      = Color3.fromRGB(255, 82,  82),
	Info        = Color3.fromRGB(94,  184, 255),
	Border      = Color3.fromRGB(255, 255, 255),
	BorderAlpha = 0.09,
}

local function Tween(obj, props, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props):Play()
end

local function Corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = r or UDim.new(0, 10)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, alpha, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Border
	s.Transparency = alpha or (1 - Theme.BorderAlpha)
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function Padding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 8)
	p.PaddingBottom = UDim.new(0, bottom or 8)
	p.PaddingLeft   = UDim.new(0, left   or 10)
	p.PaddingRight  = UDim.new(0, right  or 10)
	p.Parent = parent
	return p
end

local function ListLayout(parent, dir, pad, halign, valign)
	local l = Instance.new("UIListLayout")
	l.FillDirection   = dir    or Enum.FillDirection.Vertical
	l.Padding         = UDim.new(0, pad or 4)
	l.SortOrder       = Enum.SortOrder.LayoutOrder
	if halign then l.HorizontalAlignment = halign end
	if valign  then l.VerticalAlignment  = valign  end
	l.Parent = parent
	return l
end

local function GridLayout(parent, cellSize, cellPad)
	local g = Instance.new("UIGridLayout")
	g.CellSize    = cellSize or UDim2.new(0, 72, 0, 72)
	g.CellPadding = UDim2.new(0, cellPad or 5, 0, cellPad or 5)
	g.SortOrder   = Enum.SortOrder.LayoutOrder
	g.Parent      = parent
	return g
end

local function MkFrame(parent, props)
	local f = Instance.new("Frame")
	f.Name                = props.Name         or "Frame"
	f.BackgroundColor3    = props.Color        or Theme.Surface
	f.BackgroundTransparency = props.Alpha     or 0
	f.BorderSizePixel     = 0
	f.Size                = props.Size         or UDim2.new(1,0,0,30)
	f.Position            = props.Position     or UDim2.new(0,0,0,0)
	f.AnchorPoint         = props.Anchor       or Vector2.new(0,0)
	f.ClipsDescendants    = props.Clip         or false
	f.ZIndex              = props.ZIndex       or 1
	if props.AutoY then f.AutomaticSize = Enum.AutomaticSize.Y end
	if props.AutoX then f.AutomaticSize = Enum.AutomaticSize.X end
	if props.AutoXY then f.AutomaticSize = Enum.AutomaticSize.XY end
	f.Parent = parent
	return f
end

local function MkLabel(parent, props)
	local l = Instance.new("TextLabel")
	l.Name                = props.Name    or "Label"
	l.BackgroundTransparency = 1
	l.Size                = props.Size    or UDim2.new(1,0,0,20)
	l.Position            = props.Pos     or UDim2.new(0,0,0,0)
	l.AnchorPoint         = props.Anchor  or Vector2.new(0,0)
	l.Text                = props.Text    or ""
	l.TextColor3          = props.Color   or Theme.Text
	l.TextSize            = props.Size2   or 14
	l.Font                = props.Font    or Enum.Font.GothamMedium
	l.TextXAlignment      = props.AlignX  or Enum.TextXAlignment.Left
	l.TextYAlignment      = props.AlignY  or Enum.TextYAlignment.Center
	l.TextWrapped         = props.Wrap    ~= false
	l.RichText            = props.Rich    ~= false
	l.ZIndex              = props.ZIndex  or 2
	if props.AutoY  then l.AutomaticSize = Enum.AutomaticSize.Y  end
	if props.AutoX  then l.AutomaticSize = Enum.AutomaticSize.X  end
	if props.AutoXY then l.AutomaticSize = Enum.AutomaticSize.XY end
	l.Parent = parent
	return l
end

local function MkBtn(parent, props)
	local b = Instance.new("TextButton")
	b.Name                = props.Name    or "Btn"
	b.BackgroundColor3    = props.Color   or Theme.Surface3
	b.BackgroundTransparency = props.Alpha or 0
	b.BorderSizePixel     = 0
	b.Size                = props.Size    or UDim2.new(1,0,0,36)
	b.Position            = props.Pos     or UDim2.new(0,0,0,0)
	b.AnchorPoint         = props.Anchor  or Vector2.new(0,0)
	b.Text                = ""
	b.AutoButtonColor     = false
	b.ZIndex              = props.ZIndex  or 2
	if props.AutoX  then b.AutomaticSize = Enum.AutomaticSize.X  end
	if props.AutoXY then b.AutomaticSize = Enum.AutomaticSize.XY end
	b.Parent = parent
	return b
end

local function BtnFX(btn, normal, hover)
	btn.MouseEnter:Connect(function()
		Tween(btn, {BackgroundColor3 = hover}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		Tween(btn, {BackgroundColor3 = normal}, 0.12)
	end)
	btn.MouseButton1Down:Connect(function()
		Tween(btn, {BackgroundColor3 = normal:Lerp(Color3.new(0,0,0), 0.15)}, 0.08)
	end)
	btn.MouseButton1Up:Connect(function()
		Tween(btn, {BackgroundColor3 = hover}, 0.1)
	end)
end

local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local _gradConns = {}
local function AnimGrad(gradient, c1, c2, speed)
	speed = speed or 1.2
	local t = math.random() * 10
	local conn = RunService.Heartbeat:Connect(function(dt)
		if not gradient or not gradient.Parent then return end
		t = t + dt * speed
		local pct = (math.sin(t) + 1) * 0.5
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, c1:Lerp(c2, pct)),
			ColorSequenceKeypoint.new(1, c2:Lerp(c1, pct)),
		}
		gradient.Rotation = 135 + math.sin(t * 0.4) * 40
	end)
	table.insert(_gradConns, conn)
	return conn
end

local _tooltipFrame, _tooltipLabel
local function EnsureTooltip(gui)
	if _tooltipFrame then return end
	_tooltipFrame = MkFrame(gui, {
		Name = "Tooltip", Color = Theme.Background,
		Size = UDim2.new(0,160,0,28), Clip = true, ZIndex = 120,
	})
	_tooltipFrame.Visible = false
	Corner(_tooltipFrame, UDim.new(0,7))
	Stroke(_tooltipFrame, Theme.Border, 0.72)
	Padding(_tooltipFrame, 4,4,10,10)
	_tooltipLabel = MkLabel(_tooltipFrame, {
		Text = "", Color = Theme.TextMuted,
		Size2 = 12, Font = Enum.Font.Code,
		Size = UDim2.new(1,0,1,0), ZIndex = 121,
	})
end

local function ShowTooltip(text, gui)
	EnsureTooltip(gui)
	if not text or text == "" then return end
	_tooltipLabel.Text = text
	local w = TextService:GetTextSize(text, 12, Enum.Font.Code, Vector2.new(400,28)).X
	_tooltipFrame.Size = UDim2.new(0, w+22, 0, 28)
	_tooltipFrame.Visible = true
end

local function HideTooltip()
	if _tooltipFrame then _tooltipFrame.Visible = false end
end

local function TrackTooltip(btn, text, gui)
	if IsMobile() then
		btn.MouseButton1Click:Connect(function()
			ShowTooltip(text, gui)
			task.delay(1.5, HideTooltip)
		end)
	else
		btn.MouseEnter:Connect(function() ShowTooltip(text, gui) end)
		btn.MouseMoved:Connect(function(x, y)
			if _tooltipFrame then
				_tooltipFrame.Position = UDim2.new(0, x+14, 0, y-36)
			end
		end)
		btn.MouseLeave:Connect(function() HideTooltip() end)
	end
end

local function MakeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = inp.Position
			startPos  = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local d = inp.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
end

function AscLib:Window(cfg)
	cfg = cfg or {}
	local title      = cfg.Title      or "AscLib"
	local fullScreen = cfg.FullScreen or false

	local winSize = fullScreen
		and UDim2.new(1, 0, 1, 0)
		or (cfg.Size or (IsMobile()
			and UDim2.new(1, -24, 0, 440)
			or  UDim2.new(0, 580, 0, 460)))

	local winPos = fullScreen
		and UDim2.new(0.5, 0, 0.5, 0)
		or (cfg.Position or UDim2.new(0.5, 0, 0.5, 0))

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name           = "AscLib_" .. title
	ScreenGui.ResetOnSpawn   = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder   = 999
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent         = PlayerGui

	local Shadow = Instance.new("ImageLabel")
	Shadow.Name               = "Shadow"
	Shadow.AnchorPoint        = Vector2.new(0.5, 0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Size               = UDim2.new(winSize.X.Scale, winSize.X.Offset+50, winSize.Y.Scale, winSize.Y.Offset+50)
	Shadow.Position           = UDim2.new(winPos.X.Scale, winPos.X.Offset, winPos.Y.Scale, winPos.Y.Offset+6)
	Shadow.Image              = "rbxassetid://6014261993"
	Shadow.ImageColor3        = Color3.new(0,0,0)
	Shadow.ImageTransparency  = 0.55
	Shadow.ScaleType          = Enum.ScaleType.Slice
	Shadow.SliceCenter        = Rect.new(49,49,450,450)
	Shadow.ZIndex             = 0
	Shadow.Parent             = ScreenGui

	local Root = MkFrame(ScreenGui, {
		Name = "Root", Color = Theme.Background,
		Size = winSize, Position = winPos, Clip = true, ZIndex = 1,
	})
	Root.AnchorPoint = Vector2.new(0.5, 0.5)
	Corner(Root, fullScreen and UDim.new(0,0) or UDim.new(0,14))
	Stroke(Root, Theme.Border, 0.80)

	Root:GetPropertyChangedSignal("Position"):Connect(function()
		Shadow.Position = UDim2.new(
			Root.Position.X.Scale, Root.Position.X.Offset,
			Root.Position.Y.Scale, Root.Position.Y.Offset + 6
		)
	end)

	local TopBar = MkFrame(Root, {
		Name = "TopBar", Color = Theme.Surface,
		Size = UDim2.new(1,0,0,50), ZIndex = 2,
	})

	local BrandFrame = MkFrame(TopBar, {
		Name = "Brand", Color = Color3.new(0,0,0), Alpha = 1,
		Size = UDim2.new(0, 140, 1, 0), ZIndex = 3,
	})
	Padding(BrandFrame, 0, 0, 12, 8)
	ListLayout(BrandFrame, Enum.FillDirection.Horizontal, 8, nil, Enum.VerticalAlignment.Center)

	local LogoFrame = MkFrame(BrandFrame, {
		Name = "Logo", Color = Theme.AccentDark,
		Size = UDim2.new(0,26,0,26), ZIndex = 4,
	})
	Corner(LogoFrame, UDim.new(0,7))
	local logoGrad = Instance.new("UIGradient")
	logoGrad.Parent = LogoFrame
	AnimGrad(logoGrad, Theme.AccentDark, Theme.AccentLight, 1.2)

	MkLabel(LogoFrame, {
		Text = "A", Size2 = 15, Font = Enum.Font.GothamBold,
		Color = Color3.new(1,1,1), Size = UDim2.new(1,0,1,0),
		AlignX = Enum.TextXAlignment.Center, ZIndex = 5,
	})

	local WinTitle = MkLabel(BrandFrame, {
		Name = "WinTitle", Text = title,
		Size2 = 14, Font = Enum.Font.GothamBold,
		Color = Theme.Text, Size = UDim2.new(0,90,0,26), ZIndex = 4,
	})

	MkFrame(TopBar, {
		Name = "Div1", Color = Theme.Border,
		Alpha = 1 - Theme.BorderAlpha,
		Size = UDim2.new(0,1,1,-20),
		Position = UDim2.new(0,142,0,10), ZIndex = 3,
	})

	local TabStrip = MkFrame(TopBar, {
		Name = "TabStrip", Color = Color3.new(0,0,0), Alpha = 1,
		Size = UDim2.new(1,-222,1,0),
		Position = UDim2.new(0,148,0,0), ZIndex = 3,
	})
	TabStrip.ClipsDescendants = false
	ListLayout(TabStrip, Enum.FillDirection.Horizontal, 0, nil, Enum.VerticalAlignment.Center)

	local CtrlFrame = MkFrame(TopBar, {
		Name = "Controls", Color = Color3.new(0,0,0), Alpha = 1,
		Size = UDim2.new(0,80,1,0),
		Position = UDim2.new(1,0,0,0),
		Anchor = Vector2.new(1,0), ZIndex = 3,
	})
	Padding(CtrlFrame, 0, 0, 0, 10)
	ListLayout(CtrlFrame, Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

	local function MakeCtrlBtn(name, text, lo, dangerHover)
		local b = MkBtn(CtrlFrame, {
			Name = name, Color = Theme.Surface3,
			Size = UDim2.new(0,28,0,28), ZIndex = 4,
		})
		b.LayoutOrder = lo
		Corner(b, UDim.new(0,7))
		Stroke(b, Theme.Border, 0.75)
		MkLabel(b, {
			Text = text, Size2 = 13, Font = Enum.Font.GothamBold,
			Color = Theme.TextMuted, Size = UDim2.new(1,0,1,0),
			AlignX = Enum.TextXAlignment.Center, ZIndex = 5,
		})
		if dangerHover then
			b.MouseEnter:Connect(function()
				Tween(b, {BackgroundColor3 = Color3.fromRGB(80,20,20)}, 0.12)
			end)
			b.MouseLeave:Connect(function()
				Tween(b, {BackgroundColor3 = Theme.Surface3}, 0.12)
			end)
		else
			BtnFX(b, Theme.Surface3, Theme.Surface4)
		end
		return b
	end

	local MinBtn  = MakeCtrlBtn("MinBtn",  "─", 1, false)
	local HideBtn = MakeCtrlBtn("HideBtn", "✕", 2, true)

	MkFrame(TopBar, {
		Name = "BottomBorder", Color = Theme.Border,
		Alpha = 1 - Theme.BorderAlpha,
		Size = UDim2.new(1,0,0,1),
		Position = UDim2.new(0,0,1,-1), ZIndex = 3,
	})

	local CanvasHolder = MkFrame(Root, {
		Name = "CanvasHolder", Color = Color3.new(0,0,0), Alpha = 1,
		Size = UDim2.new(1,0,1,-80),
		Position = UDim2.new(0,0,0,50), ZIndex = 2,
	})

	local StatusBar = MkFrame(Root, {
		Name = "StatusBar", Color = Theme.Surface,
		Size = UDim2.new(1,0,0,30),
		Position = UDim2.new(0,0,1,-30), ZIndex = 2,
	})

	local sbStrip = MkFrame(StatusBar, {
		Name = "AccentStrip", Color = Theme.Accent,
		Size = UDim2.new(1,0,0,1), ZIndex = 3,
	})
	local sbGrad = Instance.new("UIGradient")
	sbGrad.Parent = sbStrip
	AnimGrad(sbGrad, Theme.AccentDark, Theme.AccentLight, 0.7)

	Padding(StatusBar, 0, 0, 14, 0)
	ListLayout(StatusBar, Enum.FillDirection.Horizontal, 16, nil, Enum.VerticalAlignment.Center)

	local function AddPill(dotColor, text)
		local pill = MkFrame(StatusBar, {
			Name = "Pill", Color = Color3.new(0,0,0), Alpha = 1,
			Size = UDim2.new(0,0,0,20), AutoX = true, ZIndex = 3,
		})
		ListLayout(pill, Enum.FillDirection.Horizontal, 5, nil, Enum.VerticalAlignment.Center)
		local dot = MkFrame(pill, {
			Name = "Dot", Color = dotColor,
			Size = UDim2.new(0,5,0,5), ZIndex = 4,
		})
		Corner(dot, UDim.new(1,0))
		local lbl = MkLabel(pill, {
			Text = text, Size2 = 11, Font = Enum.Font.Code,
			Color = Theme.TextMuted, Size = UDim2.new(0,0,0,20),
			AutoX = true, ZIndex = 4,
		})
		return pill, lbl
	end

	AddPill(Theme.Success, "Connected")
	local _, countLbl = AddPill(Theme.Info,    "0 items")
	local _, newLbl   = AddPill(Theme.Warning, "0 new")

	if not fullScreen then
		MakeDraggable(Root, TopBar)
	end

	local ShowPill = MkBtn(ScreenGui, {
		Name = "ShowPill", Color = Theme.Surface2,
		Size = UDim2.new(0,110,0,36),
		Pos = UDim2.new(0.5,-55,1,-54),
		ZIndex = 200,
	})
	Corner(ShowPill, UDim.new(0,18))
	Stroke(ShowPill, Theme.Accent, 0.35)
	MkLabel(ShowPill, {
		Text = "◈  Show UI", Size2 = 13, Font = Enum.Font.GothamBold,
		Color = Theme.AccentLight, Size = UDim2.new(1,0,1,0),
		AlignX = Enum.TextXAlignment.Center, ZIndex = 201,
	})
	local spGrad = Instance.new("UIGradient")
	spGrad.Parent = ShowPill
	AnimGrad(spGrad, Theme.AccentDark:Lerp(Theme.Surface2,0.65), Theme.AccentLight:Lerp(Theme.Surface2,0.65), 0.9)
	ShowPill.Visible = false

	local minimized = false
	local hidden    = false
	local fullSize  = winSize

	MinBtn.MouseButton1Click:Connect(function()
		if hidden then return end
		minimized = not minimized
		if minimized then
			Tween(Root, {Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 50)}, 0.22)
			Shadow.Visible = false
		else
			Tween(Root, {Size = fullSize}, 0.22)
			Shadow.Visible = true
		end
	end)

	local function DoHide()
		hidden = true
		Root.Visible = false
		Shadow.Visible = false
		ShowPill.Visible = true
	end

	local function DoShow()
		hidden = false
		Root.Visible = true
		Shadow.Visible = true
		ShowPill.Visible = false
	end

	HideBtn.MouseButton1Click:Connect(DoHide)
	ShowPill.MouseButton1Click:Connect(DoShow)

	local Window = {}
	Window._gui          = ScreenGui
	Window._root         = Root
	Window._tabs         = {}
	Window._active       = nil
	Window._statusCount  = countLbl
	Window._statusNew    = newLbl

	function Window:SetTitle(t)
		WinTitle.Text = t
	end

	function Window:SetStatus(count, newCount)
		if count    then countLbl.Text = tostring(count)    .. " items" end
		if newCount then newLbl.Text   = tostring(newCount) .. " new"   end
	end

	function Window:Tab(tabCfg)
		tabCfg = tabCfg or {}
		local icon   = tabCfg.Icon   or "📋"
		local label  = tabCfg.Label  or "Tab"
		local single = tabCfg.Single ~= false
		local order  = #self._tabs + 1

		local TabBtn = MkBtn(TabStrip, {
			Name = "TabBtn_" .. label,
			Color = Color3.new(0,0,0), Alpha = 1,
			Size = UDim2.new(0,0,1,0), AutoX = true, ZIndex = 4,
		})
		TabBtn.LayoutOrder = order
		Padding(TabBtn, 0, 2, 12, 12)
		ListLayout(TabBtn, Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

		local iconLbl = MkLabel(TabBtn, {
			Text = icon, Size2 = 16, Rich = false,
			Color = Theme.TextMuted,
			Size = UDim2.new(0,20,0,20),
			AlignX = Enum.TextXAlignment.Center, ZIndex = 5,
		})
		iconLbl.LayoutOrder = 0

		local labelLbl = MkLabel(TabBtn, {
			Text = label, Size2 = 13,
			Font = Enum.Font.GothamMedium, Color = Theme.TextMuted,
			Size = UDim2.new(0,0,0,20), AutoX = true, ZIndex = 5,
		})
		labelLbl.LayoutOrder = 1
		if IsMobile() then labelLbl.Visible = false end

		local Underline = MkFrame(TabBtn, {
			Name = "Underline", Color = Theme.Accent, Alpha = 1,
			Size = UDim2.new(1,-24,0,2),
			Position = UDim2.new(0,12,1,-2), ZIndex = 6,
		})
		Corner(Underline, UDim.new(1,0))
		local ulGrad = Instance.new("UIGradient")
		ulGrad.Parent = Underline
		AnimGrad(ulGrad, Theme.AccentDark, Theme.AccentLight, 1.4)

		if not single then
			local badge = MkLabel(TabBtn, {
				Text = "2P", Size2 = 9, Font = Enum.Font.Code,
				Color = Color3.new(1,1,1),
				Size = UDim2.new(0,18,0,14),
				Pos = UDim2.new(1,-6,0,4),
				AlignX = Enum.TextXAlignment.Center, ZIndex = 7,
			})
			badge.BackgroundColor3   = Theme.AccentDark
			badge.BackgroundTransparency = 0
			Corner(badge, UDim.new(0,3))
		end

		local Canvas = MkFrame(CanvasHolder, {
			Name = "Canvas_" .. label,
			Color = Color3.new(0,0,0), Alpha = 1,
			Size = UDim2.new(1,0,1,0), ZIndex = 2,
		})
		Canvas.Visible = false

		local function MakeScrollPane(parent)
			local scroll = Instance.new("ScrollingFrame")
			scroll.Name                 = "Scroll"
			scroll.Size                 = UDim2.new(1,0,1,0)
			scroll.BackgroundTransparency = 1
			scroll.BorderSizePixel      = 0
			scroll.ScrollBarThickness   = 3
			scroll.ScrollBarImageColor3 = Theme.Accent
			scroll.CanvasSize           = UDim2.new(0,0,0,0)
			scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
			scroll.Parent               = parent

			local content = MkFrame(scroll, {
				Name = "Content", Color = Color3.new(0,0,0), Alpha = 1,
				Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 2,
			})
			Padding(content, 10, 10, 10, 10)
			ListLayout(content, Enum.FillDirection.Vertical, 8)
			return scroll, content
		end

		local Tab = {}
		Tab._canvas = Canvas
		Tab._btn    = TabBtn
		Tab._icon   = iconLbl
		Tab._label  = labelLbl
		Tab._line   = Underline
		Tab._single = single

		if single then
			local sc, ct = MakeScrollPane(Canvas)
			Tab._content = ct
		else
			local PaneL = MkFrame(Canvas, {
				Name = "PaneLeft", Color = Color3.new(0,0,0), Alpha = 1,
				Size = UDim2.new(0.5,-1,1,0), ZIndex = 2,
			})
			MkFrame(Canvas, {
				Name = "Divider", Color = Theme.Border,
				Alpha = 1 - Theme.BorderAlpha,
				Size = UDim2.new(0,1,1,0),
				Position = UDim2.new(0.5,0,0,0), ZIndex = 3,
			})
			local PaneR = MkFrame(Canvas, {
				Name = "PaneRight", Color = Color3.new(0,0,0), Alpha = 1,
				Size = UDim2.new(0.5,-1,1,0),
				Position = UDim2.new(0.5,1,0,0), ZIndex = 2,
			})
			local _, ctL = MakeScrollPane(PaneL)
			local _, ctR = MakeScrollPane(PaneR)
			Tab._contentL = ctL
			Tab._contentR = ctR
		end

		function Tab:Section(sCfg)
			sCfg = sCfg or {}
			local stitle   = sCfg.Title    or "Section"
			local collapse = sCfg.Collapse or false
			local page     = sCfg.Page     or 1

			local parent = self._single and self._content
				or (page == 1 and self._contentL or self._contentR)

			local SecFrame = MkFrame(parent, {
				Name = "Section_" .. stitle,
				Color = Theme.Surface2,
				Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 2,
			})
			Corner(SecFrame, UDim.new(0,10))
			Stroke(SecFrame, Theme.Border, 0.82)

			local SecHdr = MkBtn(SecFrame, {
				Name = "Header", Color = Theme.Surface3,
				Size = UDim2.new(1,0,0,36), ZIndex = 3,
			})
			Corner(SecHdr, UDim.new(0,10))
			Padding(SecHdr, 0, 0, 13, 12)

			local hdrLayout = ListLayout(SecHdr, Enum.FillDirection.Horizontal, 7, nil, Enum.VerticalAlignment.Center)

			MkLabel(SecHdr, {
				Name = "Arrow", Text = "›",
				Size2 = 14, Font = Enum.Font.GothamBold,
				Color = Theme.TextDim,
				Size = UDim2.new(0,20,1,0),
				Pos = UDim2.new(1,-24,0,0),
				AlignX = Enum.TextXAlignment.Center, ZIndex = 5,
			})

			local SecIcon = MkLabel(SecHdr, {
				Text = sCfg.Icon or "▸", Size2 = 14,
				Color = Theme.Accent,
				Size = UDim2.new(0,16,0,20),
				AlignX = Enum.TextXAlignment.Center,
				Rich = false, ZIndex = 4,
			})
			SecIcon.LayoutOrder = 0

			local SecTitle = MkLabel(SecHdr, {
				Text = stitle, Size2 = 13,
				Font = Enum.Font.GothamBold, Color = Theme.Text,
				Size = UDim2.new(0,0,0,20), AutoX = true, ZIndex = 4,
			})
			SecTitle.LayoutOrder = 1

			local HdrFill = MkFrame(SecFrame, {
				Name = "HdrFill", Color = Theme.Surface3,
				Size = UDim2.new(1,0,0,10),
				Position = UDim2.new(0,0,0,26), ZIndex = 2,
			})

			local HdrBorder = MkFrame(SecFrame, {
				Name = "HdrBorder", Color = Theme.Border,
				Alpha = 1 - Theme.BorderAlpha,
				Size = UDim2.new(1,0,0,1),
				Position = UDim2.new(0,0,0,36), ZIndex = 3,
			})

			local Body = MkFrame(SecFrame, {
				Name = "Body", Color = Color3.new(0,0,0), Alpha = 1,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,37),
				AutoY = true, ZIndex = 2,
			})
			Padding(Body, 8, 10, 10, 10)
			ListLayout(Body, Enum.FillDirection.Vertical, 6)

			local Arrow = SecHdr:FindFirstChild("Arrow")
			local isOpen = true
			local function setOpen(v)
				isOpen = v
				Body.Visible    = v
				HdrFill.Visible = v
				HdrBorder.Visible = v
				if Arrow then Tween(Arrow, {Rotation = v and 90 or 0}, 0.18) end
			end
			setOpen(not collapse)

			SecHdr.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
			BtnFX(SecHdr, Theme.Surface3, Theme.Surface4)

			local Section = {}
			Section._body = Body

			function Section:AddLabel(content, color)
				local lf = MkFrame(Body, {
					Name = "LabelRow",
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 3,
				})
				Padding(lf, 2, 2, 4, 4)
				local ll = MkLabel(lf, {
					Text = content or "", Size2 = 13,
					Font = Enum.Font.Gotham, Color = color or Theme.TextMuted,
					Size = UDim2.new(1,0,0,0), AutoY = true,
					Wrap = true, Rich = true, ZIndex = 4,
				})
				local obj = {}
				function obj:Set(text, col)
					ll.Text = text or ll.Text
					if col then ll.TextColor3 = col end
				end
				return obj
			end

			function Section:AddButton(bCfg)
				bCfg = bCfg or {}
				local btn = MkBtn(Body, {
					Name = "Btn_" .. (bCfg.Label or "Button"),
					Color = Theme.Surface3,
					Size = UDim2.new(1,0,0,36), ZIndex = 3,
				})
				Corner(btn, UDim.new(0,8))
				Stroke(btn, Theme.Border, 0.78)
				Padding(btn, 0, 0, 12, 12)
				BtnFX(btn, Theme.Surface3, Theme.Surface4)

				ListLayout(btn, Enum.FillDirection.Horizontal, 8, nil, Enum.VerticalAlignment.Center)

				local lo = 0
				if bCfg.Icon then
					local il = MkLabel(btn, {
						Text = bCfg.Icon, Size2 = 15, Color = Theme.Accent,
						Size = UDim2.new(0,18,0,20),
						AlignX = Enum.TextXAlignment.Center, ZIndex = 4,
					})
					il.LayoutOrder = lo; lo = lo + 1
				end

				local lbl = MkLabel(btn, {
					Text = bCfg.Label or "Button", Size2 = 13,
					Font = Enum.Font.GothamMedium, Color = Theme.Text,
					Size = UDim2.new(1,0,0,20), ZIndex = 4,
				})
				lbl.LayoutOrder = lo; lo = lo + 1

				local arr = MkLabel(btn, {
					Text = "›", Size2 = 16, Font = Enum.Font.GothamBold,
					Color = Theme.TextDim,
					Size = UDim2.new(0,14,0,20),
					AlignX = Enum.TextXAlignment.Right, ZIndex = 4,
				})
				arr.LayoutOrder = lo

				btn.MouseButton1Click:Connect(function()
					if bCfg.Callback then bCfg.Callback() end
				end)

				local obj = {}
				function obj:SetLabel(t) lbl.Text = t end
				return obj
			end

			function Section:AddToggle(tCfg)
				tCfg = tCfg or {}
				local value = tCfg.Default or false

				local row = MkFrame(Body, {
					Name = "Toggle_" .. (tCfg.Label or "Toggle"),
					Color = Theme.Surface3,
					Size = UDim2.new(1,0,0,38), ZIndex = 3,
				})
				Corner(row, UDim.new(0,8))
				Stroke(row, Theme.Border, 0.78)
				Padding(row, 0, 0, 13, 13)

				MkLabel(row, {
					Text = tCfg.Label or "Toggle", Size2 = 13,
					Font = Enum.Font.GothamMedium, Color = Theme.Text,
					Size = UDim2.new(1,-54,1,0), ZIndex = 4,
				})

				local Track = MkFrame(row, {
					Name = "Track",
					Color = value and Theme.Accent or Theme.Surface4,
					Size = UDim2.new(0,38,0,20),
					Position = UDim2.new(1,-38,0.5,-10), ZIndex = 4,
				})
				Corner(Track, UDim.new(1,0))

				local Knob = MkFrame(Track, {
					Name = "Knob", Color = Color3.new(1,1,1),
					Size = UDim2.new(0,16,0,16),
					Position = value and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
					ZIndex = 5,
				})
				Corner(Knob, UDim.new(1,0))

				local hit = MkBtn(row, {
					Name = "HitArea", Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,1,0), ZIndex = 6,
				})

				local function setVal(v)
					value = v
					Tween(Track, {BackgroundColor3 = v and Theme.Accent or Theme.Surface4}, 0.16)
					Tween(Knob,  {Position = v and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}, 0.16)
					if tCfg.Callback then tCfg.Callback(v) end
				end

				hit.MouseButton1Click:Connect(function() setVal(not value) end)

				local obj = {}
				function obj:Set(v) setVal(v) end
				function obj:Get() return value end
				return obj
			end

			function Section:AddSlider(sCfg2)
				sCfg2 = sCfg2 or {}
				local smin   = sCfg2.Min     or 0
				local smax   = sCfg2.Max     or 100
				local val    = sCfg2.Default or smin
				local suffix = sCfg2.Suffix  or ""

				local wrap = MkFrame(Body, {
					Name = "Slider_" .. (sCfg2.Label or "Slider"),
					Color = Theme.Surface3,
					Size = UDim2.new(1,0,0,58), ZIndex = 3,
				})
				Corner(wrap, UDim.new(0,8))
				Stroke(wrap, Theme.Border, 0.78)
				Padding(wrap, 8, 8, 13, 13)

				local topRow = MkFrame(wrap, {
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,18), ZIndex = 4,
				})
				MkLabel(topRow, {
					Text = sCfg2.Label or "Slider", Size2 = 13,
					Font = Enum.Font.GothamMedium, Color = Theme.Text,
					Size = UDim2.new(1,-50,1,0), ZIndex = 5,
				})
				local valLbl = MkLabel(topRow, {
					Text = tostring(val) .. suffix,
					Size2 = 12, Font = Enum.Font.Code,
					Color = Theme.AccentLight,
					Size = UDim2.new(0,44,1,0),
					Pos = UDim2.new(1,-44,0,0),
					AlignX = Enum.TextXAlignment.Right, ZIndex = 5,
				})

				local TrackBg = MkFrame(wrap, {
					Color = Theme.Surface4,
					Size = UDim2.new(1,0,0,5),
					Position = UDim2.new(0,0,0,32), ZIndex = 4,
				})
				Corner(TrackBg, UDim.new(1,0))

				local TrackFill = MkFrame(TrackBg, {
					Color = Theme.Accent,
					Size = UDim2.new((val-smin)/(smax-smin),0,1,0),
					ZIndex = 5,
				})
				Corner(TrackFill, UDim.new(1,0))
				local fillGrad = Instance.new("UIGradient")
				fillGrad.Parent = TrackFill
				AnimGrad(fillGrad, Theme.AccentDark, Theme.AccentLight, 1.0)

				local Knob = MkFrame(TrackBg, {
					Color = Color3.new(1,1,1),
					Size = UDim2.new(0,15,0,15),
					Position = UDim2.new((val-smin)/(smax-smin),0,0.5,-7),
					ZIndex = 6,
				})
				Corner(Knob, UDim.new(1,0))

				local hit = MkBtn(wrap, {
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,30),
					Pos = UDim2.new(0,0,0,22), ZIndex = 7,
				})

				local dragging = false
				local function updateSlider(absX)
					local rel = math.clamp((absX - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
					val = math.round(smin + (smax - smin) * rel)
					local pct = (val - smin) / (smax - smin)
					Tween(TrackFill, {Size = UDim2.new(pct,0,1,0)}, 0.05)
					Tween(Knob,      {Position = UDim2.new(pct,0,0.5,-7)}, 0.05)
					valLbl.Text = tostring(val) .. suffix
					if sCfg2.Callback then sCfg2.Callback(val) end
				end

				hit.MouseButton1Down:Connect(function(x) dragging = true; updateSlider(x) end)
				hit.MouseButton1Up:Connect(function() dragging = false end)
				hit.MouseMoved:Connect(function(x) if dragging then updateSlider(x) end end)
				hit.TouchPan:Connect(function(t, _, _, state)
					if state == Enum.UserInputState.Change or state == Enum.UserInputState.Begin then
						if #t > 0 then updateSlider(t[1].Position.X) end
					end
				end)

				local obj = {}
				function obj:Set(v)
					val = math.clamp(v, smin, smax)
					local pct = (val-smin)/(smax-smin)
					TrackFill.Size = UDim2.new(pct,0,1,0)
					Knob.Position  = UDim2.new(pct,0,0.5,-7)
					valLbl.Text    = tostring(val) .. suffix
				end
				function obj:Get() return val end
				return obj
			end

			function Section:AddDropdown(dCfg)
				dCfg = dCfg or {}
				local options  = dCfg.Options or {}
				local selected = dCfg.Default or options[1] or "Select..."
				local open     = false

				local wrap = MkFrame(Body, {
					Name = "DD_" .. (dCfg.Label or "DD"),
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 3,
				})

				MkLabel(wrap, {
					Text = dCfg.Label or "Dropdown", Size2 = 12,
					Font = Enum.Font.GothamMedium, Color = Theme.TextMuted,
					Size = UDim2.new(1,0,0,18), ZIndex = 4,
				})

				local DDBtn = MkBtn(wrap, {
					Name = "DDBtn", Color = Theme.Surface3,
					Size = UDim2.new(1,0,0,36),
					Pos = UDim2.new(0,0,0,20), ZIndex = 4,
				})
				Corner(DDBtn, UDim.new(0,8))
				Stroke(DDBtn, Theme.Border, 0.78)
				Padding(DDBtn, 0, 0, 12, 12)
				BtnFX(DDBtn, Theme.Surface3, Theme.Surface4)
				ListLayout(DDBtn, Enum.FillDirection.Horizontal, 6, nil, Enum.VerticalAlignment.Center)

				local selLbl = MkLabel(DDBtn, {
					Text = selected, Size2 = 13,
					Font = Enum.Font.GothamMedium, Color = Theme.Text,
					Size = UDim2.new(1,-22,0,20), ZIndex = 5,
				})
				selLbl.LayoutOrder = 0

				local arrow = MkLabel(DDBtn, {
					Text = "▾", Size2 = 14, Color = Theme.TextDim,
					Size = UDim2.new(0,16,0,20),
					AlignX = Enum.TextXAlignment.Right, ZIndex = 5,
				})
				arrow.LayoutOrder = 1

				local OptionList = MkFrame(wrap, {
					Name = "Options", Color = Theme.Surface2,
					Size = UDim2.new(1,0,0,0),
					Position = UDim2.new(0,0,0,58),
					AutoY = true, ZIndex = 30,
				})
				OptionList.Visible = false
				Corner(OptionList, UDim.new(0,8))
				Stroke(OptionList, Theme.Accent, 0.5)
				Padding(OptionList, 4, 4, 4, 4)
				ListLayout(OptionList, Enum.FillDirection.Vertical, 2)

				for _, opt in ipairs(options) do
					local ob = MkBtn(OptionList, {
						Name = "Opt_" .. opt,
						Color = Color3.new(0,0,0), Alpha = 1,
						Size = UDim2.new(1,0,0,32), ZIndex = 31,
					})
					Corner(ob, UDim.new(0,6))
					Padding(ob, 0, 0, 10, 10)
					BtnFX(ob, Color3.new(0,0,0), Theme.Surface3)
					MkLabel(ob, {
						Text = opt, Size2 = 13,
						Font = Enum.Font.GothamMedium, Color = Theme.TextMuted,
						Size = UDim2.new(1,0,1,0), ZIndex = 32,
					})
					ob.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = opt
						open = false
						OptionList.Visible = false
						Tween(arrow, {Rotation = 0}, 0.15)
						if dCfg.Callback then dCfg.Callback(opt) end
					end)
				end

				DDBtn.MouseButton1Click:Connect(function()
					open = not open
					OptionList.Visible = open
					Tween(arrow, {Rotation = open and 180 or 0}, 0.15)
				end)

				local obj = {}
				function obj:Set(v) selLbl.Text = v; selected = v end
				function obj:Get() return selected end
				return obj
			end

			function Section:AddInput(iCfg)
				iCfg = iCfg or {}
				local wrap = MkFrame(Body, {
					Name = "Input_" .. (iCfg.Label or "Input"),
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 3,
				})

				MkLabel(wrap, {
					Text = iCfg.Label or "Input", Size2 = 12,
					Font = Enum.Font.GothamMedium, Color = Theme.TextMuted,
					Size = UDim2.new(1,0,0,18), ZIndex = 4,
				})

				local box = Instance.new("TextBox")
				box.Name                = "InputBox"
				box.Size                = UDim2.new(1,0,0,36)
				box.Position            = UDim2.new(0,0,0,20)
				box.BackgroundColor3    = Theme.Surface3
				box.BorderSizePixel     = 0
				box.TextColor3          = Theme.Text
				box.PlaceholderColor3   = Theme.TextDim
				box.PlaceholderText     = iCfg.Placeholder or "Type here..."
				box.Text                = iCfg.Default or ""
				box.TextSize            = 13
				box.Font                = Enum.Font.GothamMedium
				box.ClearTextOnFocus    = iCfg.Clear ~= false
				box.TextXAlignment      = Enum.TextXAlignment.Left
				box.ZIndex              = 4
				box.Parent              = wrap
				Corner(box, UDim.new(0,8))
				Stroke(box, Theme.Border, 0.78)
				Padding(box, 0, 0, 12, 12)

				box.Focused:Connect(function()
					Tween(box, {BackgroundColor3 = Theme.Surface4}, 0.12)
				end)
				box.FocusLost:Connect(function(enter)
					Tween(box, {BackgroundColor3 = Theme.Surface3}, 0.12)
					if iCfg.Callback then iCfg.Callback(box.Text, enter) end
				end)

				local obj = {}
				function obj:Get() return box.Text end
				function obj:Set(v) box.Text = v end
				return obj
			end

			function Section:AddTable(tblCfg)
				tblCfg = tblCfg or {}
				local tblFrame = MkFrame(Body, {
					Name = "Table_" .. (tblCfg.Title or "Table"),
					Color = Theme.Surface4,
					Size = UDim2.new(1,0,0,0), AutoY = true, ZIndex = 3,
				})
				Corner(tblFrame, UDim.new(0,9))
				Stroke(tblFrame, Theme.Border, 0.82)

				local TblHdr = MkFrame(tblFrame, {
					Name = "TblHdr", Color = Theme.Background,
					Size = UDim2.new(1,0,0,32), ZIndex = 4,
				})
				Corner(TblHdr, UDim.new(0,9))
				Padding(TblHdr, 0, 0, 12, 10)
				ListLayout(TblHdr, Enum.FillDirection.Horizontal, 0, nil, Enum.VerticalAlignment.Center)

				local titleLbl = MkLabel(TblHdr, {
					Text = (tblCfg.Title or "TABLE"):upper(),
					Size2 = 10, Font = Enum.Font.Code,
					Color = Theme.TextDim,
					Size = UDim2.new(1,-80,0,20), ZIndex = 5,
				})
				titleLbl.LayoutOrder = 0

				local ActFrame = MkFrame(TblHdr, {
					Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(0,76,0,24), ZIndex = 5,
				})
				ActFrame.LayoutOrder = 1
				ListLayout(ActFrame, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

				local function MakeTblAct(lbl, lo)
					local b = MkBtn(ActFrame, {
						Name = "Act_" .. lbl, Color = Theme.Surface3,
						Size = UDim2.new(0,34,0,22), ZIndex = 6,
					})
					b.LayoutOrder = lo
					Corner(b, UDim.new(0,5))
					Stroke(b, Theme.Border, 0.78)
					BtnFX(b, Theme.Surface3, Theme.Surface4)
					MkLabel(b, {
						Text = lbl, Size2 = 11,
						Font = Enum.Font.GothamMedium, Color = Theme.TextMuted,
						Size = UDim2.new(1,0,1,0),
						AlignX = Enum.TextXAlignment.Center, ZIndex = 7,
					})
					return b
				end

				local SortBtn  = MakeTblAct("Sort",  0)
				local ClearBtn = MakeTblAct("Clear", 1)

				MkFrame(tblFrame, {
					Color = Theme.Border, Alpha = 1 - Theme.BorderAlpha,
					Size = UDim2.new(1,0,0,1),
					Position = UDim2.new(0,0,0,32), ZIndex = 4,
				})

				local Grid = MkFrame(tblFrame, {
					Name = "Grid", Color = Color3.new(0,0,0), Alpha = 1,
					Size = UDim2.new(1,0,0,0),
					Position = UDim2.new(0,0,0,33),
					AutoY = true, ZIndex = 4,
				})
				Padding(Grid, 7, 7, 7, 7)
				local gridLayout = GridLayout(Grid, UDim2.new(0,70,0,78), 5)

				local items       = {}
				local selectedCell = nil

				local function RenderItems(list)
					for _, ch in ipairs(Grid:GetChildren()) do
						if not ch:IsA("UIGridLayout") and not ch:IsA("UIPadding") then
							ch:Destroy()
						end
					end
					for _, item in ipairs(list) do
						local cell = MkBtn(Grid, {
							Name = "Cell", Color = Theme.Surface3,
							Size = UDim2.new(0,70,0,78), ZIndex = 5,
						})
						Corner(cell, UDim.new(0,9))
						Stroke(cell, Theme.Border, 0.82)
						ListLayout(cell, Enum.FillDirection.Vertical, 3, Enum.HorizontalAlignment.Center)
						Padding(cell, 8, 6, 4, 4)

						local ico = MkLabel(cell, {
							Text = item.Icon or "📦", Size2 = 22,
							Size = UDim2.new(1,0,0,28),
							AlignX = Enum.TextXAlignment.Center,
							Rich = false, ZIndex = 6,
						})
						ico.LayoutOrder = 0

						local amtF = MkFrame(cell, {
							Color = Color3.fromRGB(30,20,60),
							Size = UDim2.new(1,0,0,16), ZIndex = 6,
						})
						amtF.LayoutOrder = 1
						Corner(amtF, UDim.new(0,4))
						MkLabel(amtF, {
							Text = tostring(item.Amount or ""),
							Size2 = 10, Font = Enum.Font.Code,
							Color = Theme.AccentLight,
							Size = UDim2.new(1,0,1,0),
							AlignX = Enum.TextXAlignment.Center, ZIndex = 7,
						})

						local nameL = MkLabel(cell, {
							Text = item.Name or "", Size2 = 10,
							Color = Theme.TextMuted,
							Size = UDim2.new(1,0,0,14),
							AlignX = Enum.TextXAlignment.Center,
							Wrap = true, ZIndex = 6,
						})
						nameL.LayoutOrder = 2

						if item.Tooltip then
							TrackTooltip(cell, item.Tooltip, ScreenGui)
						end

						cell.MouseButton1Click:Connect(function()
							if selectedCell then
								Tween(selectedCell, {BackgroundColor3 = Theme.Surface3}, 0.1)
							end
							selectedCell = cell
							Tween(cell, {BackgroundColor3 = Theme.AccentDark:Lerp(Theme.Surface3, 0.55)}, 0.1)
							if item.Callback then item.Callback(item) end
						end)
						BtnFX(cell, Theme.Surface3, Theme.Surface4)
					end
				end

				local Table = {}

				function Table:AddItem(cfg2)
					cfg2 = cfg2 or {}
					table.insert(items, cfg2)
					RenderItems(items)
					local iobj = {}
					function iobj:SetAmount(v)
						cfg2.Amount = v; RenderItems(items)
					end
					function iobj:Remove()
						for i, it in ipairs(items) do
							if it == cfg2 then table.remove(items, i); break end
						end
						RenderItems(items)
					end
					return iobj
				end

				function Table:Set(newItems)
					items = newItems or {}
					RenderItems(items)
				end

				function Table:Clear()
					items = {}
					RenderItems(items)
				end

				SortBtn.MouseButton1Click:Connect(function()
					table.sort(items, function(a, b) return (a.Name or "") < (b.Name or "") end)
					RenderItems(items)
				end)
				ClearBtn.MouseButton1Click:Connect(function() Table:Clear() end)

				return Table
			end

			return Section
		end

		TabBtn.MouseButton1Click:Connect(function()
			Window:_SwitchTab(Tab)
		end)

		table.insert(self._tabs, Tab)

		if #self._tabs == 1 then
			task.defer(function() Window:_SwitchTab(Tab) end)
		end

		return Tab
	end

	function Window:_SwitchTab(target)
		for _, t in ipairs(self._tabs) do
			t._canvas.Visible = false
			Tween(t._icon,  {TextColor3 = Theme.TextMuted}, 0.15)
			Tween(t._label, {TextColor3 = Theme.TextMuted}, 0.15)
			Tween(t._line,  {BackgroundTransparency = 1},   0.15)
		end
		target._canvas.Visible = true
		Tween(target._icon,  {TextColor3 = Theme.AccentLight}, 0.15)
		Tween(target._label, {TextColor3 = Theme.AccentLight}, 0.15)
		Tween(target._line,  {BackgroundTransparency = 0},     0.15)
		self._active = target
	end

	function Window:Destroy()
		for _, c in ipairs(_gradConns) do
			if c then pcall(function() c:Disconnect() end) end
		end
		ScreenGui:Destroy()
	end

	return Window
end

return AscLib
