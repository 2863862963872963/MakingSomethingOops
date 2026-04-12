-- ============================================================
--  Uiv2 PRO  |  Roblox UI Library
--  Version   :  2.0.0
--  Engine    :  OOP / Luau Metatables
--  Renderer  :  CanvasGroup (glass / group transparency)
--  Animation :  TweenService  Quart·Out  0.3 s
-- ============================================================

-- USAGE EXAMPLE (paste at bottom or in a separate Script):
--[[
    local Library = loadstring(game:HttpGet("..."))()   -- or require(path)

    local Window = Library:CreateWindow({
        Name        = "My Cheat",
        ConfigName  = "my_cheat",
        AccentColor = Color3.fromRGB(100, 160, 255),
    })

    local Tab = Window:CreateTab({ Name = "Combat", Icon = "⚔" })

    local Section = Tab:CreateSection({ Name = "Aimbot", Side = "Left" })

    local toggle = Section:AddToggle({
        Name     = "Enable Aimbot",
        Default  = false,
        Callback = function(v) print("Aimbot:", v) end,
    })

    toggle:Set(true)

    Window:Notify({
        Title       = "Loaded!",
        Description = "Uiv2 PRO ready.",
        Type        = "Success",
    })
--]]

-- ──────────────────────────────────────────────────────────
--  SERVICES
-- ──────────────────────────────────────────────────────────
local TweenService         = game:GetService("TweenService")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local HttpService          = game:GetService("HttpService")
local Players              = game:GetService("Players")
local CoreGui              = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────────────────────────────────────────────
--  SIGNAL  (lightweight BindableEvent replacement)
-- ──────────────────────────────────────────────────────────
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(fn)
    local c = { _fn = fn, _on = true }
    c.Disconnect = function(self) self._on = false end
    table.insert(self._connections, c)
    return c
end

function Signal:Fire(...)
    for _, c in ipairs(self._connections) do
        if c._on then task.spawn(c._fn, ...) end
    end
end

function Signal:Destroy()
    self._connections = {}
end

-- ──────────────────────────────────────────────────────────
--  THEME  (centralised constants)
-- ──────────────────────────────────────────────────────────
local Theme = {
    -- Backgrounds
    Background          = Color3.fromRGB(13, 13, 18),
    BackgroundSecondary = Color3.fromRGB(18, 18, 24),
    BackgroundTertiary  = Color3.fromRGB(24, 24, 32),

    -- Surfaces
    Surface       = Color3.fromRGB(28, 28, 38),
    SurfaceHover  = Color3.fromRGB(36, 36, 48),
    SurfaceActive = Color3.fromRGB(44, 44, 58),

    -- Accent  (overridden per-window)
    Accent      = Color3.fromRGB(100, 130, 255),
    AccentDark  = Color3.fromRGB(70,  96,  200),
    AccentLight = Color3.fromRGB(140, 165, 255),

    -- Text
    TextPrimary   = Color3.fromRGB(238, 238, 248),
    TextSecondary = Color3.fromRGB(150, 150, 170),
    TextDisabled  = Color3.fromRGB(82,  82,  102),

    -- Status
    Success = Color3.fromRGB(72,  199, 116),
    Warning = Color3.fromRGB(255, 178, 46),
    Error   = Color3.fromRGB(255, 72,  72),
    Info    = Color3.fromRGB(72,  154, 255),

    -- Borders
    Border      = Color3.fromRGB(52, 52, 70),
    BorderLight = Color3.fromRGB(72, 72, 92),

    -- Misc
    ScrollBar = Color3.fromRGB(56, 56, 76),
    Shadow    = Color3.fromRGB(0,  0,  0),

    -- Transparency
    BgAlpha      = 0.12,
    SurfaceAlpha = 0.05,
    BorderAlpha  = 0.68,

    -- Sizing
    Corner        = UDim.new(0, 8),
    CornerLarge   = UDim.new(0, 12),
    ElementHeight = 36,

    -- Animation presets
    Tween     = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenSlow = TweenInfo.new(0.50, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- ──────────────────────────────────────────────────────────
--  UTILITY
-- ──────────────────────────────────────────────────────────
local U = {}

function U.Tween(inst, props, ti)
    local t = TweenService:Create(inst, ti or Theme.Tween, props)
    t:Play()
    return t
end

function U.New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

function U.Corner(parent, r)
    return U.New("UICorner", { CornerRadius = r or Theme.Corner, Parent = parent })
end

function U.Stroke(parent, color, alpha, thick)
    return U.New("UIStroke", {
        Color        = color or Theme.Border,
        Transparency = alpha or Theme.BorderAlpha,
        Thickness    = thick or 1,
        Parent       = parent,
    })
end

function U.Padding(parent, t, b, l, r)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
        PaddingRight  = UDim.new(0, r or 8),
        Parent        = parent,
    })
end

function U.List(parent, dir, pad, halign)
    return U.New("UIListLayout", {
        FillDirection       = dir    or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, pad or 6),
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = parent,
    })
end

function U.Draggable(frame, handle)
    handle = handle or frame
    local drag, start, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; start = i.Position; origin = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            frame.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + d.X,
                origin.Y.Scale, origin.Y.Offset + d.Y
            )
        end
    end)
end

function U.Color3toHex(c)
    return string.format("#%02X%02X%02X",
        math.clamp(math.floor(c.R * 255), 0, 255),
        math.clamp(math.floor(c.G * 255), 0, 255),
        math.clamp(math.floor(c.B * 255), 0, 255))
end

function U.HextoColor3(hex)
    hex = hex:gsub("#","")
    return Color3.new(
        tonumber(hex:sub(1,2),16)/255,
        tonumber(hex:sub(3,4),16)/255,
        tonumber(hex:sub(5,6),16)/255)
end

-- ──────────────────────────────────────────────────────────
--  REGISTRY  (state management)
-- ──────────────────────────────────────────────────────────
local Registry = { _data = {}, Changed = Signal.new() }

function Registry:Set(k, v) self._data[k] = v; self.Changed:Fire(k, v) end
function Registry:Get(k)    return self._data[k] end
function Registry:GetAll()  return self._data     end
function Registry:Clear()   self._data = {}       end

-- ──────────────────────────────────────────────────────────
--  NOTIFICATION SYSTEM
-- ──────────────────────────────────────────────────────────
local Notif = {}
Notif.__index = Notif

function Notif.new(gui)
    local self  = setmetatable({}, Notif)
    self._count = 0
    self._host  = U.New("Frame", {
        Name                = "NotifHost",
        BackgroundTransparency = 1,
        AnchorPoint         = Vector2.new(1, 1),
        Position            = UDim2.new(1, -16, 1, -16),
        Size                = UDim2.new(0, 300, 1, 0),
        ZIndex              = 200,
        Parent              = gui,
    })
    U.New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding           = UDim.new(0, 8),
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Parent            = self._host,
    })
    return self
end

function Notif:Send(opt)
    opt = opt or {}
    local typeColor = { Info=Theme.Info, Success=Theme.Success, Warning=Theme.Warning, Error=Theme.Error }
    local accent  = typeColor[opt.Type or "Info"] or Theme.Info
    local dur     = opt.Duration or 4
    self._count   = self._count + 1

    local card = U.New("Frame", {
        Name                   = "Notif"..self._count,
        BackgroundColor3       = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.08,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        ClipsDescendants       = true,
        ZIndex                 = 200,
        Parent                 = self._host,
    })
    U.Corner(card, UDim.new(0, 10))
    U.Stroke(card, accent, 0.55)

    -- coloured side-bar
    U.New("Frame", {
        BackgroundColor3 = accent,
        Size             = UDim2.new(0, 3, 1, 0),
        ZIndex           = 201,
        Parent           = card,
    }, { U.New("UICorner",{CornerRadius=UDim.new(0,6)}) })

    local body = U.New("Frame", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 10, 0, 0),
        Size                   = UDim2.new(1, -10, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        ZIndex                 = 201,
        Parent                 = card,
    })
    U.Padding(body, 10, 10, 8, 8)

    U.New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 18),
        Text                   = opt.Title or "Notice",
        TextColor3             = Theme.TextPrimary,
        TextSize               = 14,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 201,
        Parent                 = body,
    })

    if opt.Description and opt.Description ~= "" then
        U.New("TextLabel", {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 0, 0, 22),
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            Text                   = opt.Description,
            TextColor3             = Theme.TextSecondary,
            TextSize               = 12,
            Font                   = Enum.Font.Gotham,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            ZIndex                 = 201,
            Parent                 = body,
        })
    end

    -- progress bar
    local pbBg = U.New("Frame", {
        BackgroundColor3       = Theme.SurfaceActive,
        Size                   = UDim2.new(1, 0, 0, 3),
        ZIndex                 = 202,
        Parent                 = card,
    })
    U.Corner(pbBg, UDim.new(0,2))
    local pb = U.New("Frame", {
        BackgroundColor3 = accent,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 202,
        Parent           = pbBg,
    })
    U.Corner(pb, UDim.new(0,2))

    -- slide in
    card.Position = UDim2.new(1, 12, 0, 0)
    U.Tween(card, { Position = UDim2.new(0,0,0,0) }, Theme.Tween)
    U.Tween(pb,   { Size = UDim2.new(0,0,1,0) },     TweenInfo.new(dur, Enum.EasingStyle.Linear))

    local function dismiss()
        U.Tween(card, { Position = UDim2.new(1,12,0,0), BackgroundTransparency = 1 }, Theme.TweenFast)
        task.wait(0.18)
        card:Destroy()
    end
    task.delay(dur, dismiss)
    card.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dismiss() end
    end)
end

-- ──────────────────────────────────────────────────────────
--  TOOLTIP SYSTEM
-- ──────────────────────────────────────────────────────────
local Tooltip = {}
local _tip

function Tooltip.Setup(gui)
    _tip = U.New("Frame", {
        Name                   = "Tooltip",
        BackgroundColor3       = Theme.Surface,
        BackgroundTransparency = 0.05,
        AutomaticSize          = Enum.AutomaticSize.X,
        Size                   = UDim2.new(0, 0, 0, 26),
        Visible                = false,
        ZIndex                 = 300,
        Parent                 = gui,
    })
    U.Corner(_tip, UDim.new(0, 6))
    U.Stroke(_tip, Theme.BorderLight, 0.5)
    U.Padding(_tip, 5, 5, 10, 10)
    U.New("TextLabel", {
        Name                   = "Lbl",
        BackgroundTransparency = 1,
        AutomaticSize          = Enum.AutomaticSize.X,
        Size                   = UDim2.new(0, 0, 1, 0),
        Text                   = "",
        TextColor3             = Theme.TextSecondary,
        TextSize               = 12,
        Font                   = Enum.Font.Gotham,
        ZIndex                 = 300,
        Parent                 = _tip,
    })
    RunService.RenderStepped:Connect(function()
        if _tip and _tip.Visible then
            local m = UserInputService:GetMouseLocation()
            _tip.Position = UDim2.new(0, m.X + 14, 0, m.Y - 20)
        end
    end)
end

function Tooltip.Show(text)
    if not _tip then return end
    _tip.Lbl.Text  = text
    _tip.Visible   = true
end

function Tooltip.Hide()
    if not _tip then return end
    _tip.Visible = false
end

function Tooltip.Attach(el, text)
    el.MouseEnter:Connect(function() Tooltip.Show(text) end)
    el.MouseLeave:Connect(function() Tooltip.Hide()     end)
end

-- ──────────────────────────────────────────────────────────
--  LIBRARY  (top-level)
-- ──────────────────────────────────────────────────────────
local Library = {}
Library.__index  = Library
Library.Registry = Registry
Library.Theme    = Theme
Library.Version  = "2.0.0"

function Library:CreateWindow(opt)
    opt = opt or {}
    local winName    = opt.Name        or "Uiv2 PRO"
    local cfgName    = opt.ConfigName  or "uiv2_config"
    local accent     = opt.AccentColor or Theme.Accent
    local winSize    = opt.Size        or UDim2.new(0, 600, 0, 450)
    local winPos     = opt.Position    or UDim2.new(0.5, -300, 0.5, -225)
    Theme.Accent = accent

    -- ── ScreenGui ─────────────────────────────────────────
    local gui = U.New("ScreenGui", {
        Name            = "Uiv2PRO_"..winName,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
    })
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local notifSystem = Notif.new(gui)
    Tooltip.Setup(gui)

    -- ── Main canvas (CanvasGroup → group transparency + glass) ──
    local canvas = U.New("CanvasGroup", {
        Name                   = "Window",
        BackgroundColor3       = Theme.Background,
        BackgroundTransparency = Theme.BgAlpha,
        Position               = winPos,
        Size                   = winSize,
        GroupTransparency      = 1,
        ZIndex                 = 1,
        Parent                 = gui,
    })
    U.Corner(canvas, Theme.CornerLarge)
    U.Stroke(canvas, Theme.Border, Theme.BorderAlpha)

    -- drop shadow
    U.New("ImageLabel", {
        Name                = "Shadow",
        BackgroundTransparency = 1,
        Position            = UDim2.new(0,-18,0,-18),
        Size                = UDim2.new(1,36,1,36),
        Image               = "rbxassetid://6014261993",
        ImageColor3         = Theme.Shadow,
        ImageTransparency   = 0.45,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49,49,450,450),
        ZIndex              = 0,
        Parent              = canvas,
    })

    -- accent line at very top
    U.New("Frame", {
        BackgroundColor3 = accent,
        Size             = UDim2.new(1, 0, 0, 2),
        ZIndex           = 5,
        Parent           = canvas,
    })

    -- ── Title bar ─────────────────────────────────────────
    local titleBar = U.New("Frame", {
        BackgroundColor3       = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.25,
        Size                   = UDim2.new(1, 0, 0, 50),
        ZIndex                 = 4,
        Parent                 = canvas,
    })
    -- round top corners only by rounding all then covering bottom
    U.Corner(titleBar, Theme.CornerLarge)
    U.New("Frame", {
        BackgroundColor3       = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.25,
        Position               = UDim2.new(0,0,0.5,0),
        Size                   = UDim2.new(1,0,0.5,0),
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = titleBar,
    })

    -- logo badge
    local logoBadge = U.New("Frame", {
        BackgroundColor3       = accent,
        BackgroundTransparency = 0.75,
        Position               = UDim2.new(0,14,0.5,-13),
        Size                   = UDim2.new(0,26,0,26),
        ZIndex                 = 5,
        Parent                 = titleBar,
    })
    U.Corner(logoBadge, UDim.new(0,7))
    U.New("UIStroke",{Color=accent,Transparency=0.3,Thickness=1.5,Parent=logoBadge})
    U.New("TextLabel",{
        BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Text="U",TextColor3=accent,TextSize=14,Font=Enum.Font.GothamBold,ZIndex=5,Parent=logoBadge
    })

    -- window title
    U.New("TextLabel",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,48,0,6),Size=UDim2.new(0.55,0,0,20),
        Text=winName,TextColor3=Theme.TextPrimary,TextSize=15,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,Parent=titleBar,
    })
    U.New("TextLabel",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,48,0,26),Size=UDim2.new(0.55,0,0,14),
        Text="v"..Library.Version.."  ·  RightShift to toggle",
        TextColor3=Theme.TextDisabled,TextSize=10,
        Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,Parent=titleBar,
    })

    -- window control buttons (−  □  ×)
    local ctrlRow = U.New("Frame",{
        BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.new(0,80,0,22),
        ZIndex=5,Parent=titleBar,
    })
    U.New("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,6),Parent=ctrlRow,
    })

    local function ctrlBtn(col, sym, tip)
        local b = U.New("TextButton",{
            BackgroundColor3       = col,
            BackgroundTransparency = 0.35,
            Size                   = UDim2.new(0,20,0,20),
            Text                   = sym,
            TextColor3             = col,
            TextSize               = 12,
            Font                   = Enum.Font.GothamBold,
            TextTransparency       = 1,
            AutoButtonColor        = false,
            ZIndex                 = 5,
            Parent                 = ctrlRow,
        })
        U.Corner(b, UDim.new(1,0))
        b.MouseEnter:Connect(function() U.Tween(b,{BackgroundTransparency=0,TextTransparency=0},Theme.TweenFast) end)
        b.MouseLeave:Connect(function() U.Tween(b,{BackgroundTransparency=0.35,TextTransparency=1},Theme.TweenFast) end)
        if tip then Tooltip.Attach(b, tip) end
        return b
    end

    local btnMin   = ctrlBtn(Theme.Warning, "−", "Minimise")
    local btnClose = ctrlBtn(Theme.Error,   "×", "Close")

    U.Draggable(canvas, titleBar)

    -- ── Left nav (tab list) ────────────────────────────────
    local nav = U.New("ScrollingFrame",{
        Name                   = "Nav",
        BackgroundColor3       = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.45,
        Position               = UDim2.new(0,0,0,50),
        Size                   = UDim2.new(0,148,1,-50),
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0,0,0,0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        BorderSizePixel        = 0,
        ZIndex                 = 3,
        Parent                 = canvas,
    })
    -- round left corners only
    U.Corner(nav, Theme.CornerLarge)
    U.New("Frame",{
        BackgroundColor3       = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.45,
        Position               = UDim2.new(1,-12,0,0),
        Size                   = UDim2.new(0,12,1,0),
        BorderSizePixel        = 0,
        ZIndex                 = 3,
        Parent                 = nav,
    })

    U.Padding(nav, 8,8,6,6)
    U.List(nav, nil, 4)

    -- nav search
    local navSearch = U.New("Frame",{
        BackgroundColor3=Theme.SurfaceActive,
        Size=UDim2.new(1,0,0,30),
        LayoutOrder=-1,ZIndex=3,Parent=nav,
    })
    U.Corner(navSearch)
    U.Stroke(navSearch, Theme.Border, 0.6)
    U.Padding(navSearch,0,0,8,8)
    U.New("TextLabel",{
        BackgroundTransparency=1,Size=UDim2.new(0,14,1,0),
        Text="⌕",TextColor3=Theme.TextDisabled,TextSize=14,
        Font=Enum.Font.Gotham,ZIndex=3,Parent=navSearch,
    })
    local navSearchBox = U.New("TextBox",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,18,0,0),Size=UDim2.new(1,-18,1,0),
        PlaceholderText="Search tabs…",PlaceholderColor3=Theme.TextDisabled,
        Text="",TextColor3=Theme.TextPrimary,TextSize=12,
        Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false,ZIndex=3,Parent=navSearch,
    })

    -- ── Content area ──────────────────────────────────────
    local content = U.New("Frame",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,156,0,58),
        Size=UDim2.new(1,-164,1,-66),
        ClipsDescendants=true,
        ZIndex=2,Parent=canvas,
    })

    -- ── Window object ─────────────────────────────────────
    local Win = {
        _tabs      = {},
        _active    = nil,
        _visible   = true,
        _minimised = false,
        _gui       = gui,
        _notif     = notifSystem,
        _cfg       = cfgName,
    }

    function Win:Notify(o) self._notif:Send(o) end

    function Win:ToggleVisibility()
        self._visible = not self._visible
        if self._visible then
            canvas.Visible = true
            U.Tween(canvas,{GroupTransparency=0},Theme.Tween)
        else
            U.Tween(canvas,{GroupTransparency=1},Theme.Tween)
            task.delay(0.3, function() canvas.Visible = false end)
        end
    end

    function Win:SetAccent(color)
        Theme.Accent = color
        -- re-tint accent line
        canvas:FindFirstChild("Frame").BackgroundColor3 = color
    end

    function Win:SaveConfig()
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, Registry:GetAll())
        if ok then
            pcall(function() if writefile then writefile(self._cfg..".json", enc) end end)
            self:Notify({Title="Config Saved",Description=self._cfg..".json",Type="Success",Duration=3})
        end
    end

    function Win:LoadConfig()
        local ok, raw = pcall(function() return readfile and readfile(self._cfg..".json") end)
        if ok and raw then
            local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 then
                for k,v in pairs(data) do Registry:Set(k,v) end
                self:Notify({Title="Config Loaded",Description=self._cfg..".json",Type="Info",Duration=3})
            end
        end
    end

    -- Minimise
    btnMin.MouseButton1Click:Connect(function()
        Win._minimised = not Win._minimised
        U.Tween(canvas,{Size=Win._minimised and UDim2.new(0,winSize.X.Offset,0,50) or winSize}, Theme.Tween)
    end)
    -- Close
    btnClose.MouseButton1Click:Connect(function()
        U.Tween(canvas,{GroupTransparency=1},Theme.Tween)
        task.delay(0.32, function() gui:Destroy() end)
    end)
    -- RightShift toggle
    UserInputService.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.RightShift then Win:ToggleVisibility() end
    end)
    -- Nav search filter
    navSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = navSearchBox.Text:lower()
        for _, t in ipairs(Win._tabs) do
            t._btn.Visible = q=="" or t._name:lower():find(q,1,true) ~= nil
        end
    end)

    -- ── Open animation ────────────────────────────────────
    canvas.Size = UDim2.new(0, winSize.X.Offset, 0, 0)
    U.Tween(canvas,{GroupTransparency=0,Size=winSize},Theme.TweenSlow)

    -- ══════════════════════════════════════════════════════
    --  CreateTab
    -- ══════════════════════════════════════════════════════
    function Win:CreateTab(opt)
        opt = opt or {}
        local tName  = opt.Name  or "Tab"
        local tIcon  = opt.Icon  or "≡"
        local tBadge = opt.Badge

        -- nav button
        local btn = U.New("TextButton",{
            BackgroundColor3       = Theme.SurfaceHover,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1,0,0,38),
            Text                   = "",
            AutoButtonColor        = false,
            ZIndex                 = 4,
            Parent                 = nav,
        })
        U.Corner(btn)

        local indicator = U.New("Frame",{
            BackgroundColor3       = accent,
            BackgroundTransparency = 1,
            Position               = UDim2.new(0,0,0.2,0),
            Size                   = UDim2.new(0,3,0.6,0),
            ZIndex                 = 4, Parent=btn,
        })
        U.Corner(indicator, UDim.new(1,0))

        local iconLbl = U.New("TextLabel",{
            BackgroundTransparency=1,
            Position=UDim2.new(0,10,0.5,-9),Size=UDim2.new(0,18,0,18),
            Text=tIcon,TextColor3=Theme.TextSecondary,TextSize=14,
            Font=Enum.Font.Gotham,ZIndex=4,Parent=btn,
        })
        local nameLbl = U.New("TextLabel",{
            BackgroundTransparency=1,
            Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-44,1,0),
            Text=tName,TextColor3=Theme.TextSecondary,TextSize=13,
            Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=4,Parent=btn,
        })

        if tBadge then
            local badge = U.New("Frame",{
                BackgroundColor3=Theme.Error,
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-4,0.5,0),
                Size=UDim2.new(0,16,0,16),
                ZIndex=5,Parent=btn,
            })
            U.Corner(badge, UDim.new(1,0))
            U.New("TextLabel",{
                BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
                Text=tostring(tBadge),TextColor3=Color3.new(1,1,1),
                TextSize=10,Font=Enum.Font.GothamBold,ZIndex=5,Parent=badge,
            })
        end

        -- page (ScrollingFrame)
        local page = U.New("ScrollingFrame",{
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=4,
            ScrollBarImageColor3=Theme.ScrollBar,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false,ZIndex=2,Parent=content,
        })

        -- two-column layout
        local cols = U.New("Frame",{
            BackgroundTransparency=1,
            Size=UDim2.new(1,-8,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            ZIndex=2,Parent=page,
        })
        U.Padding(cols,4,4,0,0)
        U.New("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,6),
            VerticalAlignment=Enum.VerticalAlignment.Top,
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            Parent=cols,
        })

        local leftCol  = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-3,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=cols})
        local rightCol = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-3,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=cols})
        U.List(leftCol,  nil, 6)
        U.List(rightCol, nil, 6)

        -- Tab object
        local Tab = { _name=tName, _btn=btn, _page=page, _left=leftCol, _right=rightCol }

        local function setActive(on)
            Tab._active = on
            if on then
                page.Visible = true
                page.Position = UDim2.new(0.04,0,0,0)
                page:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.22,true)
                U.Tween(btn,       {BackgroundTransparency=0.72,BackgroundColor3=accent},Theme.TweenFast)
                U.Tween(iconLbl,   {TextColor3=accent},Theme.TweenFast)
                U.Tween(nameLbl,   {TextColor3=Theme.TextPrimary},Theme.TweenFast)
                nameLbl.Font = Enum.Font.GothamBold
                U.Tween(indicator, {BackgroundTransparency=0},Theme.TweenFast)
            else
                page.Visible = false
                U.Tween(btn,       {BackgroundTransparency=1},Theme.TweenFast)
                U.Tween(iconLbl,   {TextColor3=Theme.TextSecondary},Theme.TweenFast)
                U.Tween(nameLbl,   {TextColor3=Theme.TextSecondary},Theme.TweenFast)
                nameLbl.Font = Enum.Font.Gotham
                U.Tween(indicator, {BackgroundTransparency=1},Theme.TweenFast)
            end
        end

        btn.MouseEnter:Connect(function()
            if not Tab._active then U.Tween(btn,{BackgroundTransparency=0.88,BackgroundColor3=Theme.SurfaceHover},Theme.TweenFast) end
        end)
        btn.MouseLeave:Connect(function()
            if not Tab._active then U.Tween(btn,{BackgroundTransparency=1},Theme.TweenFast) end
        end)
        btn.MouseButton1Click:Connect(function()
            if Win._active then setActive(false) end
            Win._active = Tab
            setActive(true)
        end)

        if #Win._tabs == 0 then Win._active = Tab; setActive(true) end
        table.insert(Win._tabs, Tab)

        -- ══════════════════════════════════════════════════
        --  CreateSection
        -- ══════════════════════════════════════════════════
        function Tab:CreateSection(opt)
            opt = opt or {}
            local sName     = opt.Name      or "Section"
            local side      = opt.Side      or "Left"
            local collapsed = opt.Collapsed or false
            local col       = side=="Right" and self._right or self._left

            local sec = U.New("Frame",{
                BackgroundColor3       = Theme.BackgroundSecondary,
                BackgroundTransparency = 0.28,
                Size                   = UDim2.new(1,0,0,0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                ClipsDescendants       = true,
                ZIndex                 = 2, Parent=col,
            })
            U.Corner(sec, UDim.new(0,10))
            U.Stroke(sec, Theme.Border, Theme.BorderAlpha)

            -- header
            local hdr = U.New("TextButton",{
                BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,36),
                Text="",AutoButtonColor=false,ZIndex=3,Parent=sec,
            })
            U.Padding(hdr,0,0,12,12)
            U.New("TextLabel",{
                BackgroundTransparency=1,
                Size=UDim2.new(1,-20,1,0),
                Text=sName,TextColor3=Theme.TextPrimary,TextSize=12,
                Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=3,Parent=hdr,
            })
            local chevron = U.New("TextLabel",{
                BackgroundTransparency=1,
                Position=UDim2.new(1,-20,0.5,-8),Size=UDim2.new(0,16,0,16),
                Text="▾",TextColor3=Theme.TextSecondary,TextSize=12,
                Font=Enum.Font.GothamBold,ZIndex=3,Parent=hdr,
            })
            -- separator
            local sep = U.New("Frame",{
                BackgroundColor3=Theme.Border,BackgroundTransparency=0.65,
                Position=UDim2.new(0,8,0,36),Size=UDim2.new(1,-16,0,1),
                ZIndex=2,Parent=sec,
            })
            -- element container
            local ctr = U.New("Frame",{
                BackgroundTransparency=1,
                Position=UDim2.new(0,0,0,37),
                Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                ZIndex=2,Parent=sec,
            })
            U.Padding(ctr,6,8,8,8)
            U.List(ctr,nil,4)

            -- collapse logic
            local isClosed = false
            local function setCollapsed(v)
                isClosed = v
                if v then
                    U.Tween(chevron,{Rotation=-90},Theme.TweenFast)
                    ctr.AutomaticSize = Enum.AutomaticSize.None
                    U.Tween(ctr,{Size=UDim2.new(1,0,0,0)},Theme.TweenFast)
                    sep.Visible = false
                else
                    U.Tween(chevron,{Rotation=0},Theme.TweenFast)
                    ctr.AutomaticSize = Enum.AutomaticSize.Y
                    sep.Visible = true
                end
            end
            hdr.MouseButton1Click:Connect(function() setCollapsed(not isClosed) end)
            if collapsed then setCollapsed(true) end

            -- ── Section API ───────────────────────────────
            local Sec = { _ctr=ctr }

            -- ─── Label ────────────────────────────────────
            function Sec:AddLabel(o)
                o = o or {}
                local f = U.New("Frame",{
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,o.Description and 46 or 24),
                    ZIndex=2,Parent=ctr,
                })
                local lbl = U.New("TextLabel",{
                    BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),
                    Text=o.Text or "",TextColor3=Theme.TextPrimary,TextSize=13,
                    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true,ZIndex=2,Parent=f,
                })
                if o.Description then
                    U.New("TextLabel",{
                        BackgroundTransparency=1,Position=UDim2.new(0,0,0,22),
                        Size=UDim2.new(1,0,0,18),Text=o.Description,
                        TextColor3=Theme.TextSecondary,TextSize=11,
                        Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
                        TextWrapped=true,ZIndex=2,Parent=f,
                    })
                end
                local LO={}
                function LO:Set(t) lbl.Text=t end
                function LO:Get() return lbl.Text end
                return LO
            end

            -- ─── Separator ────────────────────────────────
            function Sec:AddSeparator()
                U.New("Frame",{
                    BackgroundColor3=Theme.Border,BackgroundTransparency=0.5,
                    Size=UDim2.new(1,0,0,1),ZIndex=2,Parent=ctr,
                })
            end

            -- ─── Button ───────────────────────────────────
            -- opt.Style = "Default"|"Primary"|"Danger"|"Success"
            function Sec:AddButton(o)
                o = o or {}
                local styleMap = { Default=Theme.Surface, Primary=accent, Danger=Theme.Error, Success=Theme.Success }
                local col2  = styleMap[o.Style or "Default"] or Theme.Surface
                local fancy = o.Style and o.Style ~= "Default"

                local f = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),ZIndex=2,Parent=ctr})
                local b = U.New("TextButton",{
                    BackgroundColor3=col2,BackgroundTransparency=fancy and 0.68 or 0.45,
                    Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,ZIndex=2,Parent=f,
                })
                U.Corner(b)
                U.Stroke(b, fancy and col2 or Theme.Border, fancy and 0.4 or 0.68)
                U.New("TextLabel",{
                    BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
                    Text=o.Name or "Button",
                    TextColor3=fancy and Color3.new(1,1,1) or Theme.TextPrimary,
                    TextSize=13,Font=Enum.Font.GothamSemibold,ZIndex=2,Parent=b,
                })

                b.MouseEnter:Connect(function()   U.Tween(b,{BackgroundTransparency=fancy and 0.4 or 0.25},Theme.TweenFast) end)
                b.MouseLeave:Connect(function()   U.Tween(b,{BackgroundTransparency=fancy and 0.68 or 0.45},Theme.TweenFast) end)
                b.MouseButton1Down:Connect(function() U.Tween(b,{Size=UDim2.new(0.97,0,0.9,0)},Theme.TweenFast) end)
                b.MouseButton1Up:Connect(function()   U.Tween(b,{Size=UDim2.new(1,0,1,0)},Theme.TweenFast) end)
                b.MouseButton1Click:Connect(function()
                    if o.Callback then task.spawn(o.Callback) end
                end)
                if o.Tooltip then Tooltip.Attach(b, o.Tooltip) end

                local BO={}
                function BO:SetText(t) b:FindFirstChildWhichIsA("TextLabel").Text=t end
                return BO
            end

            -- ─── Toggle ───────────────────────────────────
            function Sec:AddToggle(o)
                o = o or {}
                local val = o.Default or false
                local key = o.ConfigKey or o.Name or "toggle"
                Registry:Set(key, val)

                local f = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),ZIndex=2,Parent=ctr})
                local bg = U.New("Frame",{
                    BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,
                    Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=f,
                })
                U.Corner(bg); U.Stroke(bg, Theme.Border, 0.68); U.Padding(bg,0,0,12,12)
                U.New("TextLabel",{
                    BackgroundTransparency=1,Size=UDim2.new(1,-56,1,0),
                    Text=o.Name or "Toggle",TextColor3=Theme.TextPrimary,TextSize=13,
                    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=bg,
                })

                local track = U.New("Frame",{
                    BackgroundColor3=val and accent or Theme.SurfaceActive,
                    Position=UDim2.new(1,-44,0.5,-10),Size=UDim2.new(0,40,0,20),ZIndex=3,Parent=bg,
                })
                U.Corner(track,UDim.new(1,0))
                local tStroke = U.Stroke(track, val and accent or Theme.Border, 0.45)

                local knob = U.New("Frame",{
                    BackgroundColor3=Color3.new(1,1,1),
                    Position=val and UDim2.new(1,-18,0.5,-7) or UDim2.new(0,2,0.5,-7),
                    Size=UDim2.new(0,16,0,16),ZIndex=4,Parent=track,
                })
                U.Corner(knob,UDim.new(1,0))
                U.New("UIStroke",{Color=Color3.new(0,0,0),Transparency=0.72,Thickness=1,Parent=knob})

                local TO={_value=val}

                local function anim(v)
                    if v then
                        U.Tween(track,{BackgroundColor3=accent},Theme.TweenFast)
                        U.Tween(tStroke,{Color=accent,Transparency=0.25},Theme.TweenFast)
                        U.Tween(knob,{Position=UDim2.new(1,-18,0.5,-7)},Theme.TweenFast)
                    else
                        U.Tween(track,{BackgroundColor3=Theme.SurfaceActive},Theme.TweenFast)
                        U.Tween(tStroke,{Color=Theme.Border,Transparency=0.45},Theme.TweenFast)
                        U.Tween(knob,{Position=UDim2.new(0,2,0.5,-7)},Theme.TweenFast)
                    end
                end

                local click = U.New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=5,Parent=bg})
                click.MouseButton1Click:Connect(function()
                    val = not val; TO._value=val
                    anim(val); Registry:Set(key,val)
                    if o.Callback then task.spawn(o.Callback,val) end
                end)
                if o.Tooltip then Tooltip.Attach(click, o.Tooltip) end

                function TO:Set(v) val=v; self._value=v; anim(v); Registry:Set(key,v); if o.Callback then task.spawn(o.Callback,v) end end
                function TO:Get() return val end
                return TO
            end

            -- ─── Slider ───────────────────────────────────
            function Sec:AddSlider(o)
                o = o or {}
                local mn  = o.Min     or 0
                local mx  = o.Max     or 100
                local val = math.clamp(o.Default or mn, mn, mx)
                local sfx = o.Suffix  or ""
                local key = o.ConfigKey or o.Name or "slider"
                Registry:Set(key, val)

                local f = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight+10),ZIndex=2,Parent=ctr})
                local bg = U.New("Frame",{
                    BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,
                    Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=f,
                })
                U.Corner(bg); U.Stroke(bg,Theme.Border,0.68); U.Padding(bg,6,6,12,12)

                local top = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),ZIndex=2,Parent=bg})
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.65,0,1,0),Text=o.Name or "Slider",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=top})
                local valLbl = U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.35,0,1,0),Text=tostring(val)..sfx,TextColor3=accent,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=2,Parent=top})

                local rail = U.New("Frame",{BackgroundColor3=Theme.SurfaceActive,Position=UDim2.new(0,0,0,24),Size=UDim2.new(1,0,0,6),ZIndex=3,Parent=bg})
                U.Corner(rail,UDim.new(1,0))
                local fill = U.New("Frame",{BackgroundColor3=accent,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),ZIndex=3,Parent=rail})
                U.Corner(fill,UDim.new(1,0))
                local knob = U.New("Frame",{
                    BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new((val-mn)/(mx-mn),0,0.5,0),Size=UDim2.new(0,14,0,14),ZIndex=5,Parent=rail,
                })
                U.Corner(knob,UDim.new(1,0))
                U.New("UIStroke",{Color=accent,Transparency=0.25,Thickness=2,Parent=knob})

                local SO={_value=val}
                local drag=false

                local function apply(v)
                    v = o.Precise and v or math.floor(v)
                    v = math.clamp(v,mn,mx)
                    local p=(v-mn)/(mx-mn)
                    U.Tween(fill,{Size=UDim2.new(p,0,1,0)},Theme.TweenFast)
                    U.Tween(knob,{Position=UDim2.new(p,0,0.5,0)},Theme.TweenFast)
                    valLbl.Text = (o.Precise and string.format("%.2f",v) or tostring(v))..sfx
                    val=v; SO._value=v
                    Registry:Set(key,v)
                    if o.Callback then task.spawn(o.Callback,v) end
                end

                local hit = U.New("TextButton",{
                    BackgroundTransparency=1,Position=UDim2.new(0,0,0,18),
                    Size=UDim2.new(1,0,0,18),Text="",ZIndex=6,Parent=bg,
                })
                local function fromInput(i)
                    local p=math.clamp((i.Position.X-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1)
                    apply(mn+(mx-mn)*p)
                end
                hit.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        drag=true; fromInput(i)
                    end
                end)
                hit.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        fromInput(i)
                    end
                end)

                function SO:Set(v) apply(v) end
                function SO:Get() return val end
                return SO
            end

            -- ─── Dropdown ─────────────────────────────────
            -- Supports MultiSelect, Searchable options
            function Sec:AddDropdown(o)
                o = o or {}
                local opts   = o.Options    or {}
                local multi  = o.MultiSelect or false
                local key    = o.ConfigKey  or o.Name or "dropdown"
                local val    = multi and {} or o.Default
                if multi and o.Default then val = type(o.Default)=="table" and o.Default or {[o.Default]=true} end
                Registry:Set(key, val)

                local f = U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),ZIndex=2,Parent=ctr})
                local hdr = U.New("TextButton",{
                    BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,
                    Size=UDim2.new(1,0,1,0),Text="",AutoButtonColor=false,ZIndex=2,Parent=f,
                })
                U.Corner(hdr); U.Stroke(hdr,Theme.Border,0.68); U.Padding(hdr,0,0,12,12)
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.48,0,1,0),Text=o.Name or "Dropdown",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=hdr})
                local valLbl=U.New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0.48,0,0,0),Size=UDim2.new(0.48,0,1,0),Text=o.Default or (multi and "None" or "Select…"),TextColor3=Theme.TextSecondary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=2,Parent=hdr})
                local arrow=U.New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-18,0.5,-8),Size=UDim2.new(0,16,0,16),Text="▾",TextColor3=Theme.TextSecondary,TextSize=12,ZIndex=2,Parent=hdr})

                -- popup list
                local pop=U.New("Frame",{
                    BackgroundColor3=Theme.BackgroundSecondary,BackgroundTransparency=0.06,
                    Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,0),
                    ZIndex=20,ClipsDescendants=true,Visible=false,Parent=f,
                })
                U.Corner(pop); U.Stroke(pop,Theme.Border,0.45)

                -- optional search inside dropdown
                local dsearch
                if o.Searchable then
                    local dsf=U.New("Frame",{BackgroundColor3=Theme.Surface,Size=UDim2.new(1,-8,0,28),ZIndex=21,Parent=pop})
                    U.Corner(dsf,UDim.new(0,6)); U.Padding(dsf,0,0,8,8)
                    dsearch=U.New("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),PlaceholderText="Search…",PlaceholderColor3=Theme.TextDisabled,Text="",TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,ZIndex=21,Parent=dsf})
                end

                local scroll=U.New("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=Theme.ScrollBar,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=21,Parent=pop})
                U.List(scroll,nil,2); U.Padding(scroll,4,4,4,4)

                local DO={_value=val}
                local btns={}
                local isOpen=false

                local function updateDisp()
                    if multi then
                        local ks={}; for k in pairs(val) do table.insert(ks,k) end
                        valLbl.Text=#ks>0 and table.concat(ks,", ") or "None"
                    else valLbl.Text=val or "Select…" end
                end

                local function rebuild(flt)
                    for _,b in ipairs(btns) do b:Destroy() end; btns={}
                    for _,opt2 in ipairs(opts) do
                        if flt and flt~="" and not opt2:lower():find(flt:lower(),1,true) then continue end
                        local sel = multi and val[opt2] or val==opt2
                        local ob=U.New("TextButton",{
                            BackgroundColor3=sel and accent or Theme.Surface,
                            BackgroundTransparency=sel and 0.68 or 0.48,
                            Size=UDim2.new(1,0,0,30),Text="",AutoButtonColor=false,ZIndex=22,Parent=scroll,
                        })
                        U.Corner(ob,UDim.new(0,6)); U.Padding(ob,0,0,10,10)
                        U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Text=opt2,TextColor3=sel and Color3.new(1,1,1) or Theme.TextPrimary,TextSize=12,Font=sel and Enum.Font.GothamSemibold or Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22,Parent=ob})
                        if sel then U.New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-18,0.5,-7),Size=UDim2.new(0,14,0,14),Text="✓",TextColor3=Color3.new(1,1,1),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=22,Parent=ob}) end
                        ob.MouseEnter:Connect(function() if not(multi and val[opt2] or val==opt2) then U.Tween(ob,{BackgroundTransparency=0.28},Theme.TweenFast) end end)
                        ob.MouseLeave:Connect(function() if not(multi and val[opt2] or val==opt2) then U.Tween(ob,{BackgroundTransparency=0.48},Theme.TweenFast) end end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then val[opt2]=val[opt2] and nil or true
                            else
                                val=opt2; isOpen=false
                                U.Tween(pop,{Size=UDim2.new(1,0,0,0)},Theme.TweenFast)
                                task.delay(0.16,function() pop.Visible=false end)
                                U.Tween(arrow,{Rotation=0},Theme.TweenFast)
                            end
                            DO._value=val; updateDisp(); rebuild(dsearch and dsearch.Text or nil)
                            Registry:Set(key,val)
                            if o.Callback then task.spawn(o.Callback,val) end
                        end)
                        table.insert(btns, ob)
                    end
                    local h=math.min(#btns*34+8, 200)
                    pop.Size=UDim2.new(1,0,0,h)
                end

                hdr.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    if isOpen then
                        pop.Visible=true; pop.Size=UDim2.new(1,0,0,0); rebuild()
                        local h=math.min(#btns*34+8,200)
                        U.Tween(pop,{Size=UDim2.new(1,0,0,h)},Theme.Tween)
                        U.Tween(arrow,{Rotation=180},Theme.TweenFast)
                    else
                        U.Tween(pop,{Size=UDim2.new(1,0,0,0)},Theme.TweenFast)
                        task.delay(0.16,function() pop.Visible=false end)
                        U.Tween(arrow,{Rotation=0},Theme.TweenFast)
                    end
                end)
                if dsearch then dsearch:GetPropertyChangedSignal("Text"):Connect(function() rebuild(dsearch.Text) end) end
                updateDisp()

                function DO:Set(v) if multi then val=type(v)=="table" and v or {} else val=v end; self._value=val; updateDisp(); Registry:Set(key,val); if o.Callback then task.spawn(o.Callback,val) end end
                function DO:Refresh(t) opts=t; if isOpen then rebuild(dsearch and dsearch.Text or nil) end end
                function DO:Get() return val end
                return DO
            end

            -- ─── Keybind ──────────────────────────────────
            function Sec:AddKeybind(o)
                o = o or {}
                local val  = o.Default or Enum.KeyCode.Unknown
                local key  = o.ConfigKey or o.Name or "keybind"
                local wait = false
                Registry:Set(key, val)

                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),ZIndex=2,Parent=ctr})
                local bg=U.New("Frame",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=f})
                U.Corner(bg); U.Stroke(bg,Theme.Border,0.68); U.Padding(bg,0,0,12,12)
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-80,1,0),Text=o.Name or "Keybind",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=bg})
                local kbtn=U.New("TextButton",{
                    BackgroundColor3=Theme.SurfaceActive,
                    Position=UDim2.new(1,-74,0.5,-12),Size=UDim2.new(0,70,0,24),
                    Text=val.Name,TextColor3=accent,TextSize=11,Font=Enum.Font.GothamBold,
                    AutoButtonColor=false,ZIndex=3,Parent=bg,
                })
                U.Corner(kbtn,UDim.new(0,6)); U.Stroke(kbtn,accent,0.45)

                local KO={_value=val}
                kbtn.MouseButton1Click:Connect(function()
                    wait=true; kbtn.Text="…"
                    U.Tween(kbtn,{BackgroundColor3=accent,TextColor3=Color3.new(1,1,1)},Theme.TweenFast)
                end)
                UserInputService.InputBegan:Connect(function(i,gp)
                    if wait and i.UserInputType==Enum.UserInputType.Keyboard then
                        wait=false; val=i.KeyCode; KO._value=val
                        kbtn.Text=val.Name
                        U.Tween(kbtn,{BackgroundColor3=Theme.SurfaceActive,TextColor3=accent},Theme.TweenFast)
                        Registry:Set(key,val)
                        if o.Callback then task.spawn(o.Callback,val) end
                    elseif not gp and not wait and i.KeyCode==val then
                        if o.Callback then task.spawn(o.Callback,val) end
                    end
                end)

                function KO:Set(kc) val=kc; self._value=kc; kbtn.Text=kc.Name; Registry:Set(key,kc); if o.Callback then task.spawn(o.Callback,kc) end end
                function KO:Get() return val end
                return KO
            end

            -- ─── ColorPicker ──────────────────────────────
            function Sec:AddColorPicker(o)
                o = o or {}
                local val = o.Default or Color3.fromRGB(255,80,80)
                local key = o.ConfigKey or o.Name or "color"
                local h,s,v = Color3.toHSV(val)
                Registry:Set(key, val)

                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),AutomaticSize=Enum.AutomaticSize.None,ZIndex=2,Parent=ctr})
                local hdr=U.New("TextButton",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,Size=UDim2.new(1,0,0,Theme.ElementHeight),Text="",AutoButtonColor=false,ZIndex=2,Parent=f})
                U.Corner(hdr); U.Stroke(hdr,Theme.Border,0.68); U.Padding(hdr,0,0,12,12)
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-52,1,0),Text=o.Name or "Color",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=hdr})
                local preview=U.New("Frame",{BackgroundColor3=val,Position=UDim2.new(1,-44,0.5,-10),Size=UDim2.new(0,40,0,20),ZIndex=3,Parent=hdr})
                U.Corner(preview,UDim.new(0,6)); U.Stroke(preview,Theme.Border,0.5)

                -- picker panel
                local panel=U.New("Frame",{BackgroundColor3=Theme.BackgroundSecondary,BackgroundTransparency=0.06,Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,160),ZIndex=10,Visible=false,Parent=f})
                U.Corner(panel); U.Stroke(panel,Theme.Border,0.45); U.Padding(panel,8,8,8,8)

                -- SV field
                local svf=U.New("Frame",{BackgroundColor3=Color3.fromHSV(h,1,1),Size=UDim2.new(0,120,1,-28),ZIndex=11,Parent=panel})
                U.Corner(svf,UDim.new(0,6))
                U.New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}),Parent=svf})
                local svdark=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=11,Parent=svf})
                U.New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Rotation=90,Parent=svdark})
                local svKnob=U.New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(s,0,1-v,0),Size=UDim2.new(0,12,0,12),ZIndex=13,Parent=svf})
                U.Corner(svKnob,UDim.new(1,0)); U.New("UIStroke",{Color=Color3.new(0,0,0),Transparency=0.5,Thickness=1.5,Parent=svKnob})

                -- Hue bar
                local huef=U.New("Frame",{Position=UDim2.new(0,128,0,0),Size=UDim2.new(0,16,1,-28),ZIndex=11,Parent=panel})
                U.Corner(huef,UDim.new(0,4))
                local hKeys={}; for i=0,6 do table.insert(hKeys,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1))) end
                U.New("UIGradient",{Color=ColorSequence.new(hKeys),Rotation=90,Parent=huef})
                local hueKnob=U.New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,h,0),Size=UDim2.new(1,4,0,8),ZIndex=13,Parent=huef})
                U.Corner(hueKnob,UDim.new(0,3)); U.New("UIStroke",{Color=Color3.new(0,0,0),Transparency=0.5,Thickness=1,Parent=hueKnob})

                -- Hex input
                local hexf=U.New("Frame",{BackgroundColor3=Theme.Surface,Position=UDim2.new(0,0,1,-24),Size=UDim2.new(1,0,0,24),ZIndex=11,Parent=panel})
                U.Corner(hexf,UDim.new(0,6)); U.Padding(hexf,0,0,8,8)
                local hexBox=U.New("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=U.Color3toHex(val),TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Code,PlaceholderText="#FFFFFF",ClearTextOnFocus=false,ZIndex=11,Parent=hexf})

                local CO={_value=val}
                local function refresh()
                    val=Color3.fromHSV(h,s,v); CO._value=val
                    preview.BackgroundColor3=val
                    svf.BackgroundColor3=Color3.fromHSV(h,1,1)
                    svKnob.Position=UDim2.new(s,0,1-v,0)
                    hueKnob.Position=UDim2.new(0.5,0,h,0)
                    hexBox.Text=U.Color3toHex(val)
                    Registry:Set(key,val)
                    if o.Callback then task.spawn(o.Callback,val) end
                end

                -- SV drag
                local svDrag=false
                svf.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        svDrag=true
                        s=math.clamp((i.Position.X-svf.AbsolutePosition.X)/svf.AbsoluteSize.X,0,1)
                        v=1-math.clamp((i.Position.Y-svf.AbsolutePosition.Y)/svf.AbsoluteSize.Y,0,1)
                        refresh()
                    end
                end)
                svf.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
                -- Hue drag
                local hueDrag=false
                huef.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        hueDrag=true
                        h=math.clamp((i.Position.Y-huef.AbsolutePosition.Y)/huef.AbsoluteSize.Y,0,1)
                        refresh()
                    end
                end)
                huef.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseMovement then
                        if svDrag then
                            s=math.clamp((i.Position.X-svf.AbsolutePosition.X)/svf.AbsoluteSize.X,0,1)
                            v=1-math.clamp((i.Position.Y-svf.AbsolutePosition.Y)/svf.AbsoluteSize.Y,0,1)
                            refresh()
                        elseif hueDrag then
                            h=math.clamp((i.Position.Y-huef.AbsolutePosition.Y)/huef.AbsoluteSize.Y,0,1)
                            refresh()
                        end
                    end
                end)
                hexBox.FocusLost:Connect(function()
                    local ok2,c2=pcall(U.HextoColor3,hexBox.Text)
                    if ok2 then val=c2; h,s,v=Color3.toHSV(c2); refresh() end
                end)

                local pOpen=false
                hdr.MouseButton1Click:Connect(function()
                    pOpen=not pOpen; panel.Visible=pOpen
                    f.Size=UDim2.new(1,0,0,pOpen and Theme.ElementHeight+168 or Theme.ElementHeight)
                end)

                function CO:Set(c) val=c; h,s,v=Color3.toHSV(c); self._value=c; refresh() end
                function CO:Get() return val end
                return CO
            end

            -- ─── Input ────────────────────────────────────
            -- opt.Numeric=true  → accept numbers only
            -- opt.MultiLine=true → tall textarea
            function Sec:AddInput(o)
                o = o or {}
                local val = o.Default or ""
                local key = o.ConfigKey or o.Name or "input"
                local tall = o.MultiLine
                Registry:Set(key, val)

                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,tall and 68 or Theme.ElementHeight),ZIndex=2,Parent=ctr})
                local bg=U.New("Frame",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=f})
                U.Corner(bg); local bgS=U.Stroke(bg,Theme.Border,0.68); U.Padding(bg,0,0,12,12)
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.44,0,0,Theme.ElementHeight),Text=o.Name or "Input",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=bg})
                local box=U.New("TextBox",{
                    BackgroundTransparency=1,
                    Position=UDim2.new(0.44,0,0,0),
                    Size=UDim2.new(0.56,0,tall and 1 or 0,tall and 0 or Theme.ElementHeight),
                    Text=val,PlaceholderText=o.Placeholder or "Enter…",PlaceholderColor3=Theme.TextDisabled,
                    TextColor3=Theme.TextSecondary,TextSize=12,Font=Enum.Font.Gotham,
                    TextXAlignment=Enum.TextXAlignment.Right,ClearTextOnFocus=false,
                    MultiLine=tall,TextWrapped=tall,ZIndex=3,Parent=bg,
                })
                box.Focused:Connect(function()    U.Tween(bgS,{Color=accent,Transparency=0.28},Theme.TweenFast) end)
                box.FocusLost:Connect(function(enter)
                    U.Tween(bgS,{Color=Theme.Border,Transparency=0.68},Theme.TweenFast)
                    if o.Numeric then
                        local n=tonumber(box.Text)
                        if n then val=n; box.Text=tostring(n) else box.Text=tostring(val) end
                    else val=box.Text end
                    Registry:Set(key,val)
                    if o.Callback then task.spawn(o.Callback,val,enter) end
                end)

                local IO={_value=val}
                function IO:Set(t) val=tostring(t); self._value=val; box.Text=val; Registry:Set(key,val); if o.Callback then task.spawn(o.Callback,val) end end
                function IO:Get() return val end
                return IO
            end

            -- ─── ProgressBar (NEW) ────────────────────────
            function Sec:AddProgressBar(o)
                o = o or {}
                local mn  = o.Min    or 0
                local mx  = o.Max    or 100
                local val = math.clamp(o.Default or 0, mn, mx)
                local sfx = o.Suffix or "%"

                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44),ZIndex=2,Parent=ctr})
                local bg=U.New("Frame",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=f})
                U.Corner(bg); U.Stroke(bg,Theme.Border,0.68); U.Padding(bg,6,6,12,12)
                local top=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),ZIndex=2,Parent=bg})
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.65,0,1,0),Text=o.Name or "Progress",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=top})
                local pctLbl=U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0.35,0,1,0),Text=tostring(math.floor((val-mn)/(mx-mn)*100))..sfx,TextColor3=accent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=2,Parent=top})
                local rail=U.New("Frame",{BackgroundColor3=Theme.SurfaceActive,Position=UDim2.new(0,0,0,24),Size=UDim2.new(1,0,0,8),ZIndex=3,Parent=bg})
                U.Corner(rail,UDim.new(1,0))
                local fill=U.New("Frame",{BackgroundColor3=accent,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),ZIndex=3,Parent=rail})
                U.Corner(fill,UDim.new(1,0))
                -- animated highlight
                local shine=U.New("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.78,Size=UDim2.new(0,22,1,0),ZIndex=4,Parent=fill})
                U.Corner(shine,UDim.new(1,0))

                local PO={_value=val}
                function PO:Set(nv)
                    nv=math.clamp(nv,mn,mx); val=nv; self._value=nv
                    local p=(nv-mn)/(mx-mn)
                    U.Tween(fill,{Size=UDim2.new(p,0,1,0)},Theme.Tween)
                    pctLbl.Text=tostring(math.floor(p*100))..sfx
                end
                function PO:Get() return val end
                return PO
            end

            -- ─── RadioGroup (NEW) ─────────────────────────
            function Sec:AddRadioGroup(o)
                o = o or {}
                local choices = o.Choices or {}
                local val     = o.Default or choices[1]
                local key     = o.ConfigKey or o.Name or "radio"
                Registry:Set(key, val)

                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=ctr})
                local bg=U.New("Frame",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=f})
                U.Corner(bg); U.Stroke(bg,Theme.Border,0.68); U.Padding(bg,8,8,12,12)
                U.New("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,4),Parent=bg})
                U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Text=o.Name or "Radio",TextColor3=Theme.TextPrimary,TextSize=13,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=0,ZIndex=2,Parent=bg})

                local RO={_value=val}
                local rbtns={}

                local function pick(c)
                    val=c; RO._value=c
                    for _,rb in pairs(rbtns) do
                        local sel=rb._c==c
                        U.Tween(rb._o,{BackgroundColor3=sel and accent or Theme.Surface,BackgroundTransparency=sel and 0 or 0.5},Theme.TweenFast)
                        rb._i.Visible=sel
                    end
                    Registry:Set(key,c)
                    if o.Callback then task.spawn(o.Callback,c) end
                end

                for i,ch in ipairs(choices) do
                    local row=U.New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),Text="",AutoButtonColor=false,LayoutOrder=i,ZIndex=3,Parent=bg})
                    local outer=U.New("Frame",{BackgroundColor3=val==ch and accent or Theme.Surface,BackgroundTransparency=val==ch and 0 or 0.5,Position=UDim2.new(0,0,0.5,-8),Size=UDim2.new(0,16,0,16),ZIndex=3,Parent=row})
                    U.Corner(outer,UDim.new(1,0)); U.Stroke(outer,val==ch and accent or Theme.Border,0.3)
                    local inner=U.New("Frame",{BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,6,0,6),Visible=val==ch,ZIndex=4,Parent=outer})
                    U.Corner(inner,UDim.new(1,0))
                    U.New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,22,0,0),Size=UDim2.new(1,-22,1,0),Text=ch,TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=row})
                    table.insert(rbtns,{_c=ch,_o=outer,_i=inner})
                    row.MouseButton1Click:Connect(function() pick(ch) end)
                end

                function RO:Set(c) pick(c) end
                function RO:Get() return val end
                return RO
            end

            -- ─── ButtonGroup (NEW) ────────────────────────
            -- A row of equal-width buttons  {Buttons={{Name,Callback,Style},...}}
            function Sec:AddButtonGroup(o)
                o = o or {}
                local btns = o.Buttons or {}
                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Theme.ElementHeight),ZIndex=2,Parent=ctr})
                U.New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=f})
                for _,bd in ipairs(btns) do
                    local b=U.New("TextButton",{
                        BackgroundColor3=Theme.Surface,BackgroundTransparency=0.28,
                        Size=UDim2.new(1/#btns,-(4*(#btns-1)/#btns),1,0),
                        Text=bd.Name or "…",TextColor3=Theme.TextPrimary,TextSize=12,
                        Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=2,Parent=f,
                    })
                    U.Corner(b); U.Stroke(b,Theme.Border,0.68)
                    b.MouseEnter:Connect(function() U.Tween(b,{BackgroundTransparency=0.1},Theme.TweenFast) end)
                    b.MouseLeave:Connect(function() U.Tween(b,{BackgroundTransparency=0.28},Theme.TweenFast) end)
                    b.MouseButton1Click:Connect(function() if bd.Callback then task.spawn(bd.Callback) end end)
                end
            end

            -- ─── Paragraph (NEW) ──────────────────────────
            -- For rich descriptions / patch notes / help text
            function Sec:AddParagraph(o)
                o = o or {}
                local f=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=ctr})
                local bg=U.New("Frame",{BackgroundColor3=Theme.Surface,BackgroundTransparency=0.55,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=2,Parent=f})
                U.Corner(bg); U.Stroke(bg,Theme.Border,0.75); U.Padding(bg,8,8,10,10)
                if o.Title then
                    U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Text=o.Title,TextColor3=accent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=bg})
                end
                U.New("TextLabel",{
                    BackgroundTransparency=1,
                    Position=UDim2.new(0,0,0,o.Title and 22 or 0),
                    Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                    Text=o.Body or "",TextColor3=Theme.TextSecondary,TextSize=12,
                    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true,ZIndex=2,Parent=bg,
                })
            end

            return Sec
        end -- CreateSection

        return Tab
    end -- CreateTab

    return Win
end -- CreateWindow

return Library
